# 01 - Your machines and their roles

## The two laptops

| | **Legion Y540 (main)** | **ThinkPad T480s (agent box)** |
|---|---|---|
| CPU | i5-9300H, 4C/8T, 45 W | i5-8350U, 4C/8T, 15 W |
| GPU | GTX 1650 (4 GB) | Intel UHD 620 (integrated) |
| RAM | 16 GB dual channel | 8 GB single channel |
| Disk | 476 GB SSD | 380 GB SSD |
| OS | Windows 10 | Linux Mint |
| **Role** | **You**: Godot editor, playtesting, Claude Desktop (design chats + supervised Claude Code), Obsidian | **The agent**: Claude Code with full permissions, headless Godot, test/sim/screenshot loops, long unattended `/build` runs |

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
 │  - Chat: design, GDD │                │  superclaude (YOLO)      │
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
- Or move your main dev work to Linux as well. Godot, Git, Claude Code and
  Obsidian all run natively on Linux.

## Small upgrades worth considering (optional)

- **T480s:** a second RAM stick for dual channel would noticeably speed up its
  integrated GPU (screenshots, running the editor). Not needed for headless work.
- **Legion:** matched RAM sticks are nice but not important; 16 GB is fine.
