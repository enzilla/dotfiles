// Injects live ChatGPT Plus quota into the system prompt.
// ponytail: xAI has no remaining-credits API; show tier + local 7d spend only.
import { execFileSync } from "node:child_process"
import { readFileSync } from "node:fs"
import { homedir } from "node:os"
import { join } from "node:path"

const AUTH = join(homedir(), ".local/share/opencode/auth.json")
const DB = join(homedir(), ".local/share/opencode/opencode.db")
const TTL_MS = 60_000

let cache = { at: 0, text: "" }

function jwtPayload(token) {
  const part = String(token || "").split(".")[1]
  if (!part) return {}
  return JSON.parse(Buffer.from(part, "base64url").toString("utf8"))
}

function fmtDur(sec) {
  const s = Math.max(0, Number(sec) || 0)
  if (s >= 86400) return `${Math.floor(s / 86400)}d ${Math.floor((s % 86400) / 3600)}h`
  if (s >= 3600) return `${Math.floor(s / 3600)}h ${Math.floor((s % 3600) / 60)}m`
  return `${Math.floor(s / 60)}m`
}

function windowLine(label, win) {
  if (!win) return null
  const left = Math.max(0, 100 - Number(win.used_percent || 0))
  return `${label}: ${left}% left · reset ${fmtDur(win.reset_after_seconds)}`
}

async function chatgptQuota() {
  const auth = JSON.parse(readFileSync(AUTH, "utf8"))
  const rec = auth.openai
  if (!rec?.access) return null
  const claims = jwtPayload(rec.access)
  if ((claims.exp || 0) * 1000 < Date.now()) return "chatgpt plus: token expired, re-auth"
  const account = claims["https://api.openai.com/auth"]?.chatgpt_account_id
  if (!account) return null

  const res = await fetch("https://chatgpt.com/backend-api/wham/usage", {
    headers: {
      Authorization: `Bearer ${rec.access}`,
      "ChatGPT-Account-Id": account,
      Accept: "application/json",
    },
    signal: AbortSignal.timeout(2500),
  })
  if (!res.ok) return `chatgpt plus: usage ${res.status}`
  const data = await res.json()
  const rl = data.rate_limit || {}
  const lines = [
    `chatgpt ${data.plan_type || "plus"} quota:`,
    windowLine("  weekly", rl.secondary_window),
    windowLine("  5h", rl.primary_window),
  ].filter(Boolean)
  if (rl.limit_reached) lines.push("  limit reached: yes")
  return lines.join("\n")
}

function xaiLocalSpend() {
  const out = execFileSync(
    "sqlite3",
    [
      "-json",
      DB,
      `SELECT ROUND(SUM(cost), 4) AS cost FROM session
       WHERE json_extract(model, '$.providerID') = 'xai'
         AND time_updated >= (strftime('%s','now','-7 days') * 1000)`,
    ],
    { encoding: "utf8", timeout: 2000 },
  )
  const cost = Number(JSON.parse(out || "[]")[0]?.cost || 0)
  return `$${cost.toFixed(2)}`
}

function xaiQuota() {
  const auth = JSON.parse(readFileSync(AUTH, "utf8"))
  const rec = auth.xai
  if (!rec?.access) return "xai: not logged in"
  const claims = jwtPayload(rec.access)
  const tier = claims.tier ?? "?"
  // xAI is prepaid credits. OAuth has no remaining-balance endpoint.
  return [
    "xai: prepaid — remaining only on console.x.ai",
    `  rate-limit tier ${tier} · opencode 7d spend ${xaiLocalSpend()}`,
  ].join("\n")
}

async function snapshot() {
  const now = Date.now()
  if (now - cache.at < TTL_MS && cache.text) return cache.text
  const parts = []
  try {
    const gpt = await chatgptQuota()
    if (gpt) parts.push(gpt)
  } catch {}
  try {
    parts.push(xaiQuota())
  } catch {
    parts.push("xai: unavailable")
  }
  const text = parts.join("\n")
  cache = { at: now, text }
  return text
}

export const ProviderUsagePlugin = async () => {
  return {
    "experimental.chat.system.transform": async (_input, output) => {
      try {
        output.system.push(await snapshot())
      } catch {
        // skip rather than break the turn
      }
    },
  }
}
