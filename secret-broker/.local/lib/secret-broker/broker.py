#!/usr/bin/env python3
"""MCP stdio broker: run allowlisted commands with a Bitwarden secret in env.

The agent never gets the secret back. Same-UID processes can still read the
token file — this only keeps secrets out of the model context.
"""
from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import sys
from json import JSONDecodeError
from pathlib import Path
from urllib.parse import quote

CONFIG_DIR = Path.home() / ".config" / "secret-broker"
CONFIG_PATH = CONFIG_DIR / "config.json"
TOKEN_PATH = CONFIG_DIR / "token"
DEFAULT_PARAM = r"^[\w./@+=:-]+$"
UUID_RE = re.compile(
    r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", re.I
)
PLACEHOLDER_RE = re.compile(r"\{(\w+)\}")
DROP_ENV = (
    "BWS_ACCESS_TOKEN",
    "BW_SESSION",
    "BW_CLIENTSECRET",
    "BW_CLIENTID",
    "SECRET_BROKER_TEST_SECRET",
)


def log(msg: str) -> None:
    print(msg, file=sys.stderr, flush=True)


def load_config() -> dict:
    if not CONFIG_PATH.exists():
        raise SystemExit(f"missing config: {CONFIG_PATH}")
    try:
        return json.loads(CONFIG_PATH.read_text())
    except JSONDecodeError as e:
        raise SystemExit(f"invalid config {CONFIG_PATH}: {e}") from e


def load_token() -> str | None:
    if TOKEN_PATH.exists():
        return TOKEN_PATH.read_text().strip() or None
    return None


def redact(text: str, secret: str) -> str:
    if not text or not secret:
        return text
    out = text.replace(secret, "***")
    enc = quote(secret, safe="")
    if enc != secret:
        out = out.replace(enc, "***")
    return out


def render_argv(argv: list[str], params: dict[str, str], allowed: dict) -> list[str]:
    def repl(m: re.Match[str]) -> str:
        k = m.group(1)
        if k not in allowed:
            raise ValueError(f"unknown param {{{k}}}")
        if k not in params:
            raise ValueError(f"missing param {k}")
        v = params[k]
        if not isinstance(v, str):
            raise ValueError(f"param {k} must be a string")
        pat = allowed[k].get("pattern", DEFAULT_PARAM) if isinstance(allowed[k], dict) else DEFAULT_PARAM
        if not re.fullmatch(pat, v):
            raise ValueError(f"invalid param {k}")
        return v

    return [PLACEHOLDER_RE.sub(repl, part) for part in argv]


def action_params(action: dict) -> dict:
    if "params" in action:
        return action["params"] or {}
    names = []
    for part in action.get("argv") or []:
        names.extend(PLACEHOLDER_RE.findall(part))
    return {n: {} for n in names}


def pick_backend(cfg: dict) -> str:
    wanted = cfg.get("backend", "auto")
    if wanted != "auto":
        return wanted
    if shutil.which("bws") and (os.environ.get("BWS_ACCESS_TOKEN") or load_token()):
        return "bws"
    if shutil.which("bw") and (os.environ.get("BW_SESSION") or load_token()):
        return "bw"
    if shutil.which("bws"):
        return "bws"
    if shutil.which("bw"):
        return "bw"
    raise RuntimeError("install bws (Secrets Manager) or bitwarden-cli (bw)")


def _run_bw(argv: list[str], extra_env: dict[str, str]) -> subprocess.CompletedProcess[str]:
    env = os.environ.copy()
    env.update(extra_env)
    return subprocess.run(argv, capture_output=True, text=True, env=env, timeout=30)


def get_secret(cfg: dict, name: str) -> str:
    test = os.environ.get("SECRET_BROKER_TEST_SECRET")
    if test is not None:
        return test
    backend = pick_backend(cfg)
    token = os.environ.get("BWS_ACCESS_TOKEN") or os.environ.get("BW_SESSION") or load_token()
    if backend == "bws":
        extra = {}
        if token:
            extra["BWS_ACCESS_TOKEN"] = token
        if UUID_RE.match(name):
            r = _run_bw(["bws", "secret", "get", name], extra)
            if r.returncode != 0:
                raise RuntimeError(redact(r.stderr.strip() or "bws secret get failed", token or ""))
            try:
                return json.loads(r.stdout)["value"]
            except (JSONDecodeError, KeyError, TypeError) as e:
                raise RuntimeError("bws secret get: bad json") from e
        r = _run_bw(["bws", "secret", "list"], extra)
        if r.returncode != 0:
            raise RuntimeError(redact(r.stderr.strip() or "bws secret list failed", token or ""))
        try:
            items = json.loads(r.stdout)
        except JSONDecodeError as e:
            raise RuntimeError("bws secret list: bad json") from e
        for item in items:
            if item.get("key") == name or item.get("id") == name:
                return item["value"]
        raise RuntimeError(f"unknown secret {name!r}")
    if backend == "bw":
        extra = {}
        if token:
            extra["BW_SESSION"] = token
        r = _run_bw(["bw", "get", "password", name], extra)
        if r.returncode != 0:
            raise RuntimeError(redact(r.stderr.strip() or "bw get failed", token or ""))
        return r.stdout.strip()
    raise RuntimeError(f"unknown backend {backend!r}")


def get_item_fields(cfg: dict, name: str, wanted: dict[str, str]) -> dict[str, str]:
    """env {VAR: campo} a partir de um item do bw: username, password ou campo personalizado."""
    test = os.environ.get("SECRET_BROKER_TEST_SECRET")
    if test is not None:
        return {var: test for var in wanted}
    if pick_backend(cfg) != "bw":
        raise RuntimeError("env com mapa de campos exige o backend bw")
    token = os.environ.get("BW_SESSION") or load_token()
    r = _run_bw(["bw", "get", "item", name], {"BW_SESSION": token} if token else {})
    if r.returncode != 0:
        raise RuntimeError(redact(r.stderr.strip() or "bw get item failed", token or ""))
    try:
        item = json.loads(r.stdout)
    except JSONDecodeError as e:
        raise RuntimeError("bw get item: bad json") from e
    login = item.get("login") or {}
    campos = {f.get("name"): f.get("value") for f in item.get("fields") or []}
    out = {}
    for var, campo in wanted.items():
        valor = login.get(campo) if campo in ("username", "password") else campos.get(campo)
        if not valor:
            raise RuntimeError(f"item {name!r} sem o campo {campo!r}")
        out[var] = valor
    return out


def run_action(cfg: dict, name: str, params: dict[str, str] | None = None) -> str:
    actions = cfg.get("actions") or {}
    if name not in actions:
        raise ValueError(f"unknown action {name!r}")
    action = actions[name]
    params = params or {}
    argv = render_argv(list(action["argv"]), params, action_params(action))
    env_spec = action.get("env")
    if not env_spec:
        raise ValueError(f"action {name!r} missing env")
    if isinstance(env_spec, dict):
        injected = get_item_fields(cfg, action["secret"], env_spec)
    else:
        injected = {env_spec: get_secret(cfg, action["secret"])}
    env = os.environ.copy()
    for k in DROP_ENV:
        env.pop(k, None)
    env.update(injected)
    try:
        timeout = int(action.get("timeout_sec") or cfg.get("timeout_sec") or 60)
    except (TypeError, ValueError) as e:
        raise ValueError("timeout_sec must be an int") from e
    proc = subprocess.run(
        argv,
        capture_output=True,
        text=True,
        env=env,
        timeout=timeout,
    )
    out = (proc.stdout or "") + (("\n" + proc.stderr) if proc.stderr else "")
    # ponytail: mascara todo valor injetado (até host/porta); valor curto demais vira ruído
    for valor in sorted(injected.values(), key=len, reverse=True):
        if len(valor) >= 4:
            out = redact(out, valor)
    if proc.returncode != 0:
        raise RuntimeError(f"exit {proc.returncode}\n{out}".strip())
    return out.strip()


def list_actions(cfg: dict) -> list[dict]:
    rows = []
    for name, action in (cfg.get("actions") or {}).items():
        rows.append(
            {
                "name": name,
                "description": action.get("description", ""),
                "params": sorted(action_params(action)),
            }
        )
    return rows


# --- MCP stdio ---

def read_message() -> dict | None:
    headers: dict[str, str] = {}
    while True:
        line = sys.stdin.buffer.readline()
        if not line:
            return None
        if line in (b"\r\n", b"\n"):
            break
        try:
            k, _, v = line.decode("utf-8").partition(":")
        except UnicodeDecodeError:
            return None
        headers[k.strip().lower()] = v.strip()
    try:
        n = int(headers.get("content-length", "0"))
    except ValueError:
        return None
    if n <= 0:
        return None
    body = sys.stdin.buffer.read(n)
    try:
        return json.loads(body)
    except JSONDecodeError:
        return None


def write_message(obj: dict) -> None:
    data = json.dumps(obj, ensure_ascii=False).encode()
    sys.stdout.buffer.write(f"Content-Length: {len(data)}\r\n\r\n".encode() + data)
    sys.stdout.buffer.flush()


def result(id, payload) -> dict:
    return {"jsonrpc": "2.0", "id": id, "result": payload}


def error(id, code: int, message: str) -> dict:
    return {"jsonrpc": "2.0", "id": id, "error": {"code": code, "message": message}}


TOOLS = [
    {
        "name": "list_actions",
        "description": "List allowlisted secret-broker actions (names, descriptions, params). Does not return secrets.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "run_action",
        "description": "Run an allowlisted command with its Bitwarden secret injected as an env var. Returns stdout with secrets redacted. Use list_actions first.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "action": {"type": "string", "description": "Allowlisted action name"},
                "params": {
                    "type": "object",
                    "additionalProperties": {"type": "string"},
                    "description": "Values for {placeholders} in argv",
                },
            },
            "required": ["action"],
        },
    },
]


def handle(msg: dict) -> dict | None:
    method = msg.get("method")
    id = msg.get("id")
    params = msg.get("params") or {}
    if method == "initialize":
        ver = params.get("protocolVersion") or "2024-11-05"
        return result(
            id,
            {
                "protocolVersion": ver,
                "capabilities": {"tools": {}},
                "serverInfo": {"name": "secret-broker", "version": "1.0.0"},
            },
        )
    if method == "notifications/initialized" or method is None or id is None:
        return None
    if method == "ping":
        return result(id, {})
    if method == "tools/list":
        return result(id, {"tools": TOOLS})
    if method == "tools/call":
        name = params.get("name")
        args = params.get("arguments") or {}
        try:
            cfg = load_config()
            if name == "list_actions":
                text = json.dumps(list_actions(cfg), indent=2)
            elif name == "run_action":
                text = run_action(cfg, args["action"], args.get("params") or {}) or "(no output)"
            else:
                raise ValueError(f"unknown tool {name}")
            return result(id, {"content": [{"type": "text", "text": text}]})
        except (ValueError, RuntimeError, KeyError, TypeError, OSError, subprocess.TimeoutExpired, SystemExit) as e:
            return result(
                id,
                {"content": [{"type": "text", "text": str(e)}], "isError": True},
            )
    return error(id, -32601, f"Method not found: {method}")


def serve() -> None:
    while True:
        msg = read_message()
        if msg is None:
            return
        reply = handle(msg)
        if reply is not None:
            write_message(reply)


def self_check() -> None:
    assert redact("foo SECRET bar", "SECRET") == "foo *** bar"
    assert redact("ok", "SECRET") == "ok"
    argv = render_argv(
        ["gh", "api", "{path}"],
        {"path": "user"},
        {"path": {}},
    )
    assert argv == ["gh", "api", "user"]
    try:
        render_argv(["echo", "{x}"], {"x": ";rm"}, {"x": {}})
        raise SystemExit("bad param accepted")
    except ValueError:
        pass
    os.environ["SECRET_BROKER_TEST_SECRET"] = "s3cret-value"
    cfg = {
        "backend": "auto",
        "actions": {
            "echo-env": {
                "secret": "dummy",
                "env": "E",
                "argv": ["python3", "-c", "import os; print(os.environ['E'])"],
            }
        },
    }
    out = run_action(cfg, "echo-env")
    assert out == "***", out
    cfg["actions"]["echo-map"] = {
        "secret": "dummy",
        "env": {"A": "username", "B": "host"},
        "argv": ["python3", "-c", "import os; print(os.environ['A'], os.environ['B'])"],
    }
    out = run_action(cfg, "echo-map")
    assert out == "*** ***", out
    try:
        run_action(cfg, "nope")
        raise SystemExit("unknown action accepted")
    except ValueError:
        pass
    print("self-check ok")


def main() -> None:
    args = sys.argv[1:]
    if args == ["--self-check"]:
        self_check()
        return
    if not args:
        serve()
        return
    cfg = load_config()
    cmd = args[0]
    if cmd == "list":
        print(json.dumps(list_actions(cfg), indent=2))
        return
    if cmd == "run" and len(args) >= 2:
        params = {}
        for pair in args[2:]:
            k, _, v = pair.partition("=")
            params[k] = v
        print(run_action(cfg, args[1], params))
        return
    raise SystemExit("usage: secret-broker | secret-broker list | secret-broker run ACTION [k=v ...] | secret-broker --self-check")


if __name__ == "__main__":
    main()
