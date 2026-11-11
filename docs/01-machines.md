# 01 - Your machines and their roles

## The two laptops

| | **Legion Y540 (main)** | **ThinkPad T480s (agent box)** |
|---|---|---|
| CPU | i5-9300H, 4C/8T, 45 W | i5-8350U, 4C/8T, 15 W |
| GPU | GTX 1650 (4 GB) | Intel UHD 620 (integrated) |
| RAM | 16 GB dual channel | 8 GB single channel |
| Disk | 476 GB SSD | 380 GB SSD |
| OS | Windows 10 | Linux Mint |
| **Role** | **You**: Godot editor, playtesting, Obsidian (your `design/` documents, answering `docs/QUESTIONS.md`), Claude Desktop (design chats + supervised Claude Code) | **The agent**: pi or Claude Code without permission prompts, headless Godot, test/sim/screenshot loops, long simulation runs, prepared batches |

Why this split, following the embedded videos:
- The agent needs **full control** to be fast (install, run, delete,
  experiment) but must not be able to damage your **main** machine. The
  videos solve this with a VM; your spare laptop is a physical VM.
- Headless Godot (tests, sims) needs CPU, not GPU. The T480s's 4 cores are
  plenty. 8 GB is enough for Claude Code + headless Godot + a terminal.
- Playing and editing want the GTX 1650 and the bigger RAM, so they stay on
  the Legion.
- **GitHub sits between them.** The agent pushes; you pull and play. You
  can also open the Mint box's files from Windows (Samba share or VS Code
  Remote-SSH), as the video does.

```
   Legion (Windows)                         ThinkPad (Mint)
 ┌──────────────────────┐   SSH / tmux   ┌──────────────────────────┐
 │ Claude Desktop       │ ─────────────► │ user "agent"             │
 │  - Chat: design, GDD │                │  pi / superclaude        │
 │  - Code tab: small,  │                │  godot --headless        │
 │    supervised edits  │                │  gw.sh test/sim/shot     │
 │ Godot editor + play  │                │  xvfb for screenshots    │
 │ Obsidian (docs)      │                └────────────┬─────────────┘
 └──────────┬───────────┘                             │ git push
            │ git pull                      ┌─────────▼─────────┐
            └──────────────────────────────►│ GitHub (+ CI runs │
                                            │ the same tests)   │
                                            └───────────────────┘
```

## Can I do it with only the Legion?

Yes. Options, from easiest:
1. **Claude Code on Windows only**, using the allow-list in
   `.claude/settings.json` and/or auto mode instead of YOLO. Slower (more
   prompts), but it works. Everything in the harness runs in Git Bash.
2. **WSL2 (Ubuntu) on the Legion** as the sandbox. 16 GB RAM is enough. The
   agent gets full rights inside WSL, but WSL can still reach your Windows
   files through `/mnt/c`, so it isolates you less than the second laptop does.
3. A full VM (Hyper-V / VirtualBox): strongest isolation, but heavier.

The two-laptop setup is recommended because it also lets the agent work
while you play or use the main laptop for something else.

**pi changes this choice a little.** Claude Code asks before it runs things
unless you tell it not to; pi never asks. So pi on the Legion means an agent
with your full Windows account from the first minute. Use pi on the Mint box
(or in WSL2), and keep the Legion for the Code tab of Claude Desktop, where
the allow-list applies. See [10-pi.md](10-pi.md).

## Short loops work from either machine

The short loop (approve the tests, get a report, say "next") needs you at a
keyboard, but not at a particular one: SSH into the Mint box from the Legion
and talk to the agent in tmux, or sit at the ThinkPad. What you do between
slices (reading the spec, answering questions, playing the build) happens on
the Legion with no agent involved.

## Windows 10 - important

Microsoft ended Windows 10 support on 14 Oct 2025. In the EU/EEA, consumers
could get free Extended Security Updates for one more year, up to **13 Oct
2026**, and that has now ended too. Your main machine is therefore no longer
getting security patches unless you pay for further updates.
Practical consequences:
- Even more reason to keep the full-permission agent **off** that machine.
- The i5-9300H **is** on the Windows 11 supported CPU list and the Y540 has a
  firmware TPM (Intel PTT, enable it in the BIOS if the upgrade check complains),
  so a free Windows 11 upgrade should be possible. Back up first.
- Or move your main dev work to Linux as well, which you said you are
  considering. Godot, Git, Claude Code, pi and Obsidian all run natively on
  Linux, the harness is developed and CI-tested there, and pi's own docs list
  several Windows terminal problems that do not exist on Linux. The costs
  to weigh: check whether the Claude Desktop app is offered for Linux when
  you decide (if not, claude.ai in the browser plus the `claude` command line
  cover the same ground), and you would test your game's Windows build less
  often. A low-risk way to find out: use the Mint ThinkPad as your only
  machine for one week of game work.

## Small upgrades worth considering (optional)

- **T480s:** a second RAM stick for dual channel would noticeably speed up its
  integrated GPU (screenshots, running the editor). Not needed for headless work.
- **Legion:** matched RAM sticks are nice but not important; 16 GB is fine.
