# graphify

Knowledge-graph tooling for the Numih repositories, wired so the graphs live
entirely outside the git trees they describe.

```sh
stow --no-folding graphify
```

`--no-folding` matters: `~/.graphify` also holds the generated graphs, which are
large and unversioned. Folding would symlink the whole directory into this repo
and drag them in.

## On a new machine

```sh
~/.graphify/bootstrap.sh    # CLI via uv/pipx + skill for claude, opencode, pi + MCP server
~/.graphify/refresh.sh      # build the graphs (~7 min for 43 repositories)
```

`bootstrap.sh` is idempotent — re-run it to upgrade.

## Daily use

```sh
~/.graphify/refresh.sh              # reindex everything, incremental
~/.graphify/refresh.sh apoio auth   # just these
~/.graphify/refresh.sh --force      # ignore the cache
~/.graphify/refresh.sh --descobrir  # regenerate repos.conf on a new layout

~/.graphify/quem-usa.py                  # symbols shared across the most repos
~/.graphify/quem-usa.py rpc.Client       # who uses one, grouped by repository
~/.graphify/quem-usa.py BaseService --detalhe
```

Per-repository queries go through the CLI against the graph for that repo:

```sh
G=~/.graphify/out/apoio/graphify-out/graph.json
graphify god-nodes --graph $G --top 10
graphify explain "PessoaService" --graph $G
graphify affected "PessoaService" --graph $G --depth 2
```

## Files

| Path | Role |
| --- | --- |
| `bootstrap.sh` | install CLI + agent integrations + MCP registration |
| `refresh.sh` | reindex repositories and recompose the global graph |
| `quem-usa.py` | cross-repository usage of a shared symbol, grouped by repo |
| `repos.conf` | the repository list, relative to `$GRAPHIFY_DEV` (default `~/dev`) |

Unversioned, generated at runtime into `~/.graphify/`: `out/<repo>/` (per-repo
graphs), `global-graph.json`, `global-manifest.json`.

## Choices worth remembering

**No git hooks.** graphify ships `post-commit`/`post-checkout` hooks that rebuild
automatically, and they are deliberately not installed. Two reasons: they write
`graphify-out/` inside every repository, which defeats the out-of-tree layout;
and the hook resolves its Python interpreter from `graphify-out/.graphify_python`,
a repo-relative path — an executable file committed to a hostile repository can
therefore run on `git commit`. `refresh.sh` covers the same ground on demand.

**Scope of the installers.** `graphify <platform> install` installs into the
*project* (cwd). User scope is `graphify install --platform <platform>`, run from
outside any repository — otherwise it writes `CLAUDE.md` and `.claude/` into
whatever project you happened to be in. `bootstrap.sh` handles this.

**The MCP server serves the global graph**, so its tools answer cross-repository
questions from any working directory. It needs the `mcp` extra, which
`bootstrap.sh` installs.

**Generated skill payloads are not versioned.** They are tied to the graphify
release and would rot in git; `bootstrap.sh` regenerates them. The exception is
whatever lands under `~/.config/opencode`, which is a symlink into this repo, so
those files are versioned whether or not that was the intent.
