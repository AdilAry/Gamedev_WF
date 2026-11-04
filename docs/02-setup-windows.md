# 02 - Setting up the main laptop (Windows, Legion Y540)

Time: about 45 minutes. Goal: you can design with Claude Desktop, run
Claude Code on a game folder in a supervised way, run the harness, and
play builds pulled from GitHub.

## 1. Install
| Tool | Why | Where |
|---|---|---|
| **Git for Windows** | version control, and **Git Bash**, which Claude Code on Windows uses as its shell | git-scm.com |
| **Godot 4.7.x (standard, not .NET)** | the engine | godotengine.org/download |
| **Claude Desktop** | chat + the **Code** tab (Claude Code) | claude.ai/download |
| **Obsidian** (you probably have it) | editing GDD/IDEA/LOG Markdown nicely | obsidian.md |
| Windows Terminal (optional) | nicer terminal for SSH to the Mint box | Microsoft Store |
| VS Code (optional) | file tree + Remote-SSH into the Mint box | code.visualstudio.com |

### Godot: keep the console build
The Windows download zip has two executables:
- `Godot_v4.7.2-stable_win64.exe` - for you (the editor).
- `Godot_v4.7.2-stable_win64_console.exe` - **for the agent**. Only this one
  prints output to the terminal; without it the agent is blind.

Unzip both to e.g. `C:\Tools\Godot\` and set an environment variable (PowerShell):

```powershell
[Environment]::SetEnvironmentVariable("GODOT", "C:\Tools\Godot\Godot_v4.7.2-stable_win64_console.exe", "User")
```

## 2. Get this kit
In Git Bash:

```bash
cd ~ && git clone https://github.com/AdilAry/Gamedev_WF.git
```

```bash
powershell -ExecutionPolicy Bypass -File ~/Gamedev_WF/scripts/install.ps1
```

This copies the skills to `%USERPROFILE%\.claude\skills\` (so `/define`,
`/build` etc. work in **every** project) and sets `GAMEDEV_WF`. Restart Claude
Desktop afterwards.

## 3. Try the example project
In Git Bash:

```bash
cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check
```

You should see `RESULT OK: 16 passed`, `SMOKE OK`, `CHECK OK`. Then open
the folder in the Godot editor (Import -> `project.godot`) and press F5 to
play it. Try `./harness/gw.sh sim --seeds=1-10 --ticks=500` for the balance
table, and `./harness/gw.sh shot` for screenshots in `reports/shots/`.

## 4. Claude Code in Claude Desktop
- Open Claude Desktop, switch to the **Code** tab, choose a **local** session
  and pick your project folder (e.g. `~/Gamedev_WF/example/colony_sim`).
- Type `/` to see the skills. Try: *"Run the harness check and explain the
  architecture of this project in 10 lines."*
- Permissions: the first time it wants to run `./harness/gw.sh`, allow it
  "always for this project". Projects created by `/harness` also get a
  `.claude/settings.json` allow-list, so routine commands don't prompt.
- **Don't** use full-permission/YOLO mode on this machine. That is what the
  Mint box is for.

If you prefer a terminal: install the Claude Code CLI with the native
installer from the Claude Code docs (PowerShell one-liner), then run
`claude` inside a project folder in Git Bash or Windows Terminal.

## 5. Claude Desktop chat: a design studio
Use normal chats / **Projects** for thinking, not coding:
- Create a Project per game, add `docs/GDD.md` and `docs/STYLE_GUIDE.md` as
  project knowledge, and use it for brainstorming mechanics, naming, lore,
  and reviewing your GDD before `/build`.
- Skills can also be added to Claude Desktop/claude.ai (Settings ->
  Capabilities/Skills, upload a skill folder as a zip). `/pitch`, `/define`
  and `/style-guide` are useful there too. Check the current UI, it moves.

## 6. SSH into the Mint box (after doc 03)
Windows 10/11 ships an OpenSSH client:

```bash
ssh agent@mint-dev.local
```

Then `tmux attach` to see what the agent is doing. For a file tree, use VS
Code -> "Remote-SSH: Connect to Host" or map the Samba share from doc 03.

## 7. Pull and play what the agent built

```bash
cd ~/games/my-game && git pull && "$GODOT" --path . 
```

(or open it in the editor). Then `/playtest` with your notes.
