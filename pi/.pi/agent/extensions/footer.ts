import type { Usage } from "@earendil-works/pi-ai";
import type { ExtensionAPI, SessionEntry } from "@earendil-works/pi-coding-agent";
import { truncateToWidth, visibleWidth } from "@earendil-works/pi-tui";
import { execFile } from "node:child_process";
import { promisify } from "node:util";
import { existsSync } from "node:fs";
import { basename, join } from "node:path";

const exec = promisify(execFile);

type FooterTheme = {
  fg(c: "accent" | "dim" | "success" | "warning" | "error", t: string): string;
};
type ContextUsage = { percent: number | null; tokens?: number | null } | null | undefined;
type SessionUsage = {
  input: number;
  output: number;
  cacheRead: number;
  cacheWrite: number;
  cost: number;
  turns: number;
};

let jjLabel = "";
let ins = 0;
let del = 0;
let isJj = false;
let repoCwd = "";
let lastRefresh = 0;
const REFRESH_DEBOUNCE = 300;

async function out(cmd: string, args: string[]): Promise<string> {
  try {
    const { stdout } = await exec(cmd, args, { cwd: repoCwd, env: { ...process.env, LC_ALL: "C" } });
    return stdout.trim();
  } catch {
    return "";
  }
}

function parseDiff(s: string): [number, number] {
  const i = s.match(/(\d+) insertion/);
  const d = s.match(/(\d+) deletion/);
  return [i ? +i[1] : 0, d ? +d[1] : 0];
}

async function refresh(): Promise<void> {
  if (isJj) {
    const base = ["--ignore-working-copy", "--no-pager"];
    const tmpl = ["-n", "1", "--no-graph", "--color", "never", "-T"];
    const bm = await out("jj", [...base, "log", "-r", "latest(bookmarks() & ::@)", ...tmpl, "bookmarks"]);
    jjLabel = bm || (await out("jj", [...base, "log", "-r", "@", ...tmpl, "change_id.shortest(8)"]));
    [ins, del] = parseDiff(await out("jj", [...base, "diff", "-r", "@", "--stat"]));
  } else {
    [ins, del] = parseDiff(await out("git", ["diff", "--shortstat", "HEAD"]));
  }
}

function toK(n: number): string {
  return n >= 1000 ? `${Math.round(n / 1000)}k` : `${n}`;
}

function addUsage(total: SessionUsage, usage: Usage | undefined): void {
  if (!usage) return;

  total.input += usage.input;
  total.output += usage.output;
  total.cacheRead += usage.cacheRead;
  total.cacheWrite += usage.cacheWrite;
  total.cost += usage.cost.total;
}

function getSessionUsage(entries: readonly SessionEntry[]): SessionUsage {
  const total: SessionUsage = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, cost: 0, turns: 0 };

  for (const entry of entries) {
    if (entry.type === "message") {
      if ("usage" in entry.message) addUsage(total, entry.message.usage);
      if (entry.message.role === "assistant") total.turns += 1;
    } else if (entry.type === "compaction" || entry.type === "branch_summary") {
      addUsage(total, entry.usage);
    }
  }

  return total;
}

function cacheHitRate(usage: SessionUsage): number {
  const totalInput = usage.input + usage.cacheRead;
  return totalInput === 0 ? 0 : Math.round((usage.cacheRead / totalInput) * 100);
}

function buildLeft(cwd: string, vcs: string | null | undefined, model: string, effort: string, t: FooterTheme): string {
  const segs = [t.fg("accent", cwd)];
  if (vcs) {
    const diff = ins || del ? ` ${t.fg("success", `+${ins}`)}${t.fg("dim", "/")}${t.fg("error", `-${del}`)}` : "";
    segs.push(t.fg("dim", vcs) + diff);
  }
  segs.push(t.fg("dim", model), t.fg("dim", effort));
  return " " + segs.join(t.fg("dim", " · "));
}

function buildRight(usage: ContextUsage, limit: number, session: SessionUsage, t: FooterTheme): string {
  const pct = usage && usage.percent !== null ? Math.round(usage.percent) : 0;
  const tokens = usage?.tokens ?? 0;
  const pctColor = pct < 50 ? "success" : pct < 80 ? "warning" : "error";
  const tok = limit > 0 ? `${toK(tokens)}/${toK(limit)}` : toK(tokens);
  const metrics = [
    `↑${toK(session.input)}`,
    `↓${toK(session.output)}`,
    `R${toK(session.cacheRead)}`,
    `W${toK(session.cacheWrite)}`,
    `CH${cacheHitRate(session)}%`,
    `T${session.turns}`,
    `$${session.cost.toFixed(2)}`,
  ].map((metric) => t.fg("dim", metric));

  return [...metrics, t.fg("dim", tok), t.fg(pctColor, `${pct}%`)].join(t.fg("dim", " · ")) + " ";
}

function compose(width: number, left: string, right: string): string {
  if (visibleWidth(left) + visibleWidth(right) < width) {
    return left + " ".repeat(width - visibleWidth(left) - visibleWidth(right)) + right;
  }

  if (visibleWidth(right) >= width) return truncateToWidth(right, width);
  return truncateToWidth(left, width - visibleWidth(right) - 1) + " " + right;
}

export default function (pi: ExtensionAPI) {
  if (process.env.PI_SUBAGENT_CHILD === "1") return;

  pi.on("turn_end", async () => {
    await refresh();
  });

  pi.on("tool_execution_end", async (event) => {
    if (event.toolName === "bash" || event.toolName === "write" || event.toolName === "edit") {
      const now = Date.now();
      if (now - lastRefresh < REFRESH_DEBOUNCE) return;
      lastRefresh = now;
      await refresh();
    }
  });

  pi.on("session_start", async (_event, ctx) => {
    repoCwd = ctx.cwd;
    isJj = existsSync(join(ctx.cwd, ".jj"));
    await refresh();

    ctx.ui.setFooter((_tui, theme, footerData) => ({
      dispose: () => {},
      invalidate() {},
      render(width: number): string[] {
        const usage = ctx.getContextUsage();
        const limit =
          ctx.model?.contextWindow ?? (usage && usage.percent ? Math.round((usage.tokens ?? 0) / usage.percent * 100) : 0);
        const vcs = isJj ? jjLabel : footerData.getGitBranch();
        const left = buildLeft(basename(ctx.cwd), vcs, ctx.model?.id ?? "no-model", pi.getThinkingLevel(), theme);
        const session = getSessionUsage(ctx.sessionManager.getBranch());
        const right = buildRight(usage, limit, session, theme);
        return [compose(width, left, right)];
      },
    }));
  });
}
