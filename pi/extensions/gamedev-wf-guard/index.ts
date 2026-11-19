/**
 * Gamedev-WF guard for pi.
 *
 * Active only in a folder that has harness/gw.sh (a game set up with the
 * Gamedev-WF kit). There it keeps the human in the loop for the few actions
 * the workflow reserves for them:
 *   - editing design/ or harness/      -> asks you first
 *   - git reset --hard                 -> asks you first
 *   - git commit --no-verify, push -f  -> blocked, with the reason given to the model
 * Without a UI (pi -p, JSON mode) "ask" becomes "block".
 *
 * Commands: /guard shows whether it is active here.
 *
 * Seatbelt, not sandbox. See rules.ts and the kit's docs/10-pi.md.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync } from "node:fs";
import { join } from "node:path";
import { judge } from "./rules.ts";

export default function (pi: ExtensionAPI) {
	const isGame = (cwd: string) => existsSync(join(cwd, "harness", "gw.sh"));

	pi.on("tool_call", async (event, ctx) => {
		if (!isGame(ctx.cwd)) return undefined;

		const verdict = judge(ctx.cwd, event.toolName, event.input as Record<string, unknown>);
		if (verdict.action === "allow") return undefined;

		const what =
			typeof event.input.path === "string"
				? `${event.toolName} ${event.input.path}`
				: String(event.input.command ?? event.toolName);

		if (verdict.action === "ask" && ctx.hasUI) {
			const ok = await ctx.ui.confirm("Gamedev-WF guard", `The agent wants to run:\n\n  ${what}\n\n${verdict.reason}\n\nAllow this once?`);
			if (ok) return undefined;
			return { block: true, reason: `The human said no. ${verdict.reason}` };
		}

		if (ctx.hasUI) ctx.ui.notify(`Guard blocked: ${what}`, "warning");
		return { block: true, reason: verdict.reason };
	});

	pi.registerCommand("guard", {
		description: "Gamedev-WF guard: is it active in this folder?",
		handler: async (_args, ctx) => {
			ctx.ui.notify(
				isGame(ctx.cwd)
					? "Guard active: asks before edits to design/ and harness/, blocks --no-verify and forced pushes."
					: "Guard idle: no harness/gw.sh in this folder.",
				"info",
			);
		},
	});
}
