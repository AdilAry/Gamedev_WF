// Run: node --test pi/extensions/gamedev-wf-guard/rules.test.ts   (Node 22.18+ / 24)
import assert from "node:assert/strict";
import { test } from "node:test";
import { judge, judgeBash, judgeFileEdit, relativeTo } from "./rules.ts";

const ROOT = "/home/agent/games/colony";

test("paths are resolved against the project root", () => {
	assert.equal(relativeTo(ROOT, "design/Stats.md"), "design/Stats.md");
	assert.equal(relativeTo(ROOT, "./sim/../design/Stats.md"), "design/Stats.md");
	assert.equal(relativeTo(ROOT, `${ROOT}/harness/gw.sh`), "harness/gw.sh");
	assert.equal(relativeTo(ROOT, "/etc/passwd"), null);
	assert.equal(relativeTo("C:\\Users\\me\\games\\colony", "C:\\Users\\me\\games\\colony\\Design\\a.md"), "Design/a.md");
});

test("edits to design/ and harness/ ask the human", () => {
	assert.equal(judgeFileEdit(ROOT, "design/Progression/Levels.md").action, "ask");
	assert.equal(judgeFileEdit(ROOT, `${ROOT}/design/x.md`).action, "ask");
	assert.equal(judgeFileEdit(ROOT, "harness/gw.sh").action, "ask");
	assert.equal(judgeFileEdit(ROOT, "sim/../design/x.md").action, "ask");
	assert.equal(judge(ROOT, "write", { path: "design/new.md", content: "x" }).action, "ask");
	assert.equal(judge(ROOT, "edit", { path: "Design/Stats.md" }).action, "ask");
});

test("normal project files are left alone", () => {
	for (const p of ["sim/colony_sim.gd", "docs/spec/stats.md", "docs/QUESTIONS.md", "data/rules.json", "tests/unit/test_design.gd", "sim/harness_hook.gd", "design.md", "/tmp/design/x.md"]) {
		assert.equal(judgeFileEdit(ROOT, p).action, "allow", p);
	}
	assert.equal(judge(ROOT, "read", { path: "design/Stats.md" }).action, "allow");
});

test("the commit gate cannot be skipped", () => {
	assert.equal(judgeBash('git commit --no-verify -m "x"').action, "block");
	assert.equal(judgeBash('git add -A && git commit -n -m "x"').action, "block");
	assert.equal(judgeBash('git commit -anm "x"').action, "block");
	assert.equal(judgeBash('git -C . commit --no-verify').action, "block");
	assert.equal(judgeBash('git commit -m "STA-004: bars"').action, "allow");
	assert.equal(judgeBash('git commit -am "no-verify is forbidden -n"').action, "allow");
	assert.equal(judgeBash('git commit -m "fix the -n flag"').action, "allow");
});

test("forced pushes are blocked, hard resets ask", () => {
	assert.equal(judgeBash("git push --force").action, "block");
	assert.equal(judgeBash("git push -f origin main").action, "block");
	assert.equal(judgeBash("git push --force-with-lease").action, "block");
	assert.equal(judgeBash("git push -u origin main").action, "allow");
	assert.equal(judgeBash("git reset --hard HEAD~1").action, "ask");
	assert.equal(judgeBash("git reset HEAD file.gd").action, "allow");
});

test("shell writes into protected folders ask, reads do not", () => {
	assert.equal(judgeBash("rm -rf design/old").action, "ask");
	assert.equal(judgeBash("sed -i 's/a/b/' design/Stats.md").action, "ask");
	assert.equal(judgeBash("echo hi > design/x.md").action, "ask");
	assert.equal(judgeBash("cp /tmp/gw.sh harness/gw.sh").action, "ask");
	assert.equal(judgeBash("mv notes.md ./design/notes.md").action, "ask");
	assert.equal(judgeBash("grep -rn '^#' design/").action, "allow");
	assert.equal(judgeBash("cat design/Stats.md | head -20").action, "allow");
	assert.equal(judgeBash("./harness/gw.sh test unit status").action, "allow");
	assert.equal(judgeBash("ls -R design | wc -l > /tmp/count.txt").action, "allow");
	assert.equal(judgeBash("cp design/table.csv data/table.csv").action, "allow"); // copying OUT of design/ is a read
});
