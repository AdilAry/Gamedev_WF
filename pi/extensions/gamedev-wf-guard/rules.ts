/**
 * Gamedev-WF guard: the decisions, as a pure function (no pi imports), so
 * they can be tested with plain `node --test` (see rules.test.ts).
 *
 * It mirrors what Claude Code gets from the project's .claude/settings.json:
 *   ask   before the agent edits design/ (the human's documents) or harness/ (the kit's)
 *   ask   before `git reset --hard`
 *   block `git commit --no-verify` and forced pushes
 *
 * This is a seatbelt, not a sandbox: pi runs with your user's permissions and
 * a shell command can always find another way to change a file. The real
 * boundary is where pi runs (the agent box / a dedicated user) plus git.
 */

export type Verdict = { action: "allow" | "ask" | "block"; reason: string };

const ALLOW: Verdict = { action: "allow", reason: "" };

/** Folders the agent must not change on its own, relative to the project root. */
export const PROTECTED: Record<string, string> = {
	design: "design/ holds the human's design documents. Do not edit them: file a row in docs/QUESTIONS.md or propose a change request instead.",
	harness: "harness/ is copied from the Gamedev-WF kit. Do not edit it per project: improve the kit and run scripts/update-harness.sh.",
};

/** Path relative to root with forward slashes, or null if it is outside root. */
export function relativeTo(root: string, path: string): string | null {
	const split = (p: string) => {
		const parts: string[] = [];
		for (const part of p.replace(/\\/g, "/").split("/")) {
			if (part === "" || part === ".") continue;
			if (part === "..") parts.pop();
			else parts.push(part);
		}
		return parts;
	};
	const isAbsolute = /^([a-zA-Z]:)?[\\/]/.test(path) || path.startsWith("~");
	const rootParts = split(root);
	const resolved = isAbsolute ? split(path) : split(`${root}/${path}`);
	if (resolved.length < rootParts.length) return null;
	for (let i = 0; i < rootParts.length; i++) {
		if (resolved[i].toLowerCase() !== rootParts[i].toLowerCase()) return null;
	}
	return resolved.slice(rootParts.length).join("/");
}

function protectedFolder(root: string, path: string): string | null {
	const rel = relativeTo(root, path);
	if (rel === null) return null;
	const first = rel.split("/")[0].toLowerCase();
	return first in PROTECTED && rel.includes("/") ? first : null;
}

export function judgeFileEdit(root: string, path: string): Verdict {
	const folder = protectedFolder(root, path);
	if (folder === null) return ALLOW;
	return { action: "ask", reason: PROTECTED[folder] };
}

const WRITERS = ["rm", "mv", "cp", "tee", "truncate", "touch", "rmdir"];

/** Which protected folder does this simple command write into, if any? */
function shellWriteTarget(part: string): string | null {
	const inFolder = (word: string): string | null => {
		const clean = word.replace(/^["']|["']$/g, "").replace(/^\.\//, "").toLowerCase();
		for (const folder of Object.keys(PROTECTED)) {
			if (clean === folder || clean.startsWith(`${folder}/`)) return folder;
		}
		return null;
	};
	// output redirection:  ... > design/x.md
	const redirect = part.match(/>>?\s*(\S+)/);
	if (redirect && inFolder(redirect[1])) return inFolder(redirect[1]);

	const words = part.trim().split(/\s+/).filter((w) => w !== "sudo");
	if (words.length === 0) return null;
	const cmd = words[0];
	const args = words.slice(1).filter((w) => !w.startsWith("-"));
	const inPlace = (cmd === "sed" || cmd === "perl") && words.slice(1).some((w) => /^-[a-zA-Z]*i/.test(w));
	if (!WRITERS.includes(cmd) && !inPlace) return null;
	// cp only writes to its last argument; the others touch every argument
	const candidates = cmd === "cp" ? args.slice(-1) : args;
	for (const word of candidates) {
		const folder = inFolder(word);
		if (folder) return folder;
	}
	return null;
}

export function judgeBash(command: string): Verdict {
	// look at each simple command of a pipeline / list on its own
	for (const part of command.split(/&&|\|\||[;|\n]/)) {
		// drop quoted text first, so a commit message that mentions "-n" is not a flag
		const words = part.replace(/"[^"]*"|'[^']*'/g, '""').trim().split(/\s+/);
		const git = words.indexOf("git");
		if (git !== -1) {
			const rest = words.slice(git + 1);
			const at = rest.findIndex((w) => w === "commit" || w === "push" || w === "reset");
			const sub = at === -1 ? "" : rest[at];
			const flags = at === -1 ? [] : rest.slice(at + 1).filter((w) => w.startsWith("-"));
			if (sub === "commit" && flags.some((f) => f === "--no-verify" || /^-[a-zA-Z]*n[a-zA-Z]*$/.test(f))) {
				return { action: "block", reason: "git commit --no-verify skips the harness gate. Fix what the gate reports, or record it under Broken in PROGRESS.md." };
			}
			if (sub === "push" && flags.some((f) => f.startsWith("--force") || /^-[a-zA-Z]*f[a-zA-Z]*$/.test(f))) {
				return { action: "block", reason: "Forced pushes rewrite history the human may already have pulled. Ask the human to do it if it is really needed." };
			}
			if (sub === "reset" && flags.includes("--hard")) {
				return { action: "ask", reason: "git reset --hard throws away uncommitted work." };
			}
		}
		// shell commands that write into a protected folder (a heuristic, not a parser)
		const folder = shellWriteTarget(part);
		if (folder !== null) return { action: "ask", reason: PROTECTED[folder] };
	}
	return ALLOW;
}

/** One entry point for the extension. `input` is the tool's argument object. */
export function judge(root: string, toolName: string, input: Record<string, unknown>): Verdict {
	if (toolName === "write" || toolName === "edit") {
		return typeof input.path === "string" ? judgeFileEdit(root, input.path) : ALLOW;
	}
	if (toolName === "bash" || toolName === "powershell") {
		return typeof input.command === "string" ? judgeBash(input.command) : ALLOW;
	}
	return ALLOW;
}
