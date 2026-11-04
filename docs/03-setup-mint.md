# 03 - Turning the ThinkPad into the agent box (Linux Mint)

Time: about an hour. Goal: a machine where Claude Code runs with full
permissions on game projects, headless Godot tests/sims/screenshots work,
and you can reach it from the Legion over SSH.

> The idea is the same as the VM in the embedded videos: the agent is the boss
> *inside its box*, and the box contains nothing you'd be sad to lose.

## 0. Clean the box
You said it was a file dump. Before giving an agent full rights, move
anything personal off it, or at least keep it out of reach of the agent's
user (next step). Make sure Mint is up to date:

```bash
sudo apt update && sudo apt full-upgrade -y
```

## 1. A dedicated user for the agent
Your normal account keeps sudo; the agent's account does not. A
full-permission agent can then wreck its own home folder, but not the system
or your files.

```bash
sudo adduser agent
```

```bash
sudo chmod 700 /home/$USER
```

(`agent` gets **no** sudo. When something needs installing system-wide, the
agent asks you, and you run it from your own account. That happens rarely,
mostly during setup.)

## 2. System packages (as your own user)

```bash
sudo apt install -y git curl unzip tmux openssh-server xvfb mesa-utils python3 avahi-daemon samba
```

- `openssh-server` - SSH in from the Legion.
- `tmux` - the agent keeps working when your SSH connection drops.
- `xvfb` + `mesa-utils` - a virtual screen so the agent can render screenshots
  (`gw.sh shot`) even when nobody is logged in on the desktop.
- `avahi-daemon` - lets you reach the box as `<hostname>.local`. Set a
  memorable hostname: `sudo hostnamectl set-hostname mint-dev`.

Keep it awake with the lid closed: Mint *Power Management* -> "When the lid
is closed: Do nothing" (on AC power).

## 3. Godot (for everyone)

```bash
cd /tmp && curl -LO https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip
```

```bash
unzip Godot_v4.7.2-stable_linux.x86_64.zip && sudo install -m 755 Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot
```

```bash
godot --version
```

Use the **same version** on both laptops and in CI (`GODOT_VERSION` in the
workflow). To upgrade later, repeat with the new version number and run
`/commission` again.

## 4. Claude Code for the agent user

```bash
sudo -iu agent
```

Now, as `agent`, install Claude Code with the native installer command from
the official docs (currently `curl -fsSL https://claude.ai/install.sh | bash`),
then:

```bash
claude
```

Log in with your Claude Pro account when asked (it opens a URL; you can
complete it on the Legion's browser).

### The `superclaude` shortcut (like the video)

```bash
echo "alias superclaude='claude --dangerously-skip-permissions'" >> ~/.bashrc && source ~/.bashrc
```

Only ever add this alias in the `agent` account on this box.

## 5. Git + GitHub for the agent
Still as `agent`:

```bash
git config --global user.name "Your Name" && git config --global user.email "you@example.com"
```

```bash
ssh-keygen -t ed25519 -C "agent@mint-dev" -f ~/.ssh/id_ed25519 -N ""
```

```bash
cat ~/.ssh/id_ed25519.pub
```

Add that key on GitHub. The safest way is as a **deploy key with write
access** on each game repo (Repo -> Settings -> Deploy keys), so the agent can
only push to the repos you allow. The convenient way is your account's SSH keys.
Optionally install the GitHub CLI `gh` so the agent can create repos and
read CI results (`gh auth login`).

## 6. The kit and its skills (as `agent`)

```bash
git clone https://github.com/AdilAry/Gamedev_WF.git ~/Gamedev_WF && ~/Gamedev_WF/scripts/install.sh && source ~/.bashrc
```

```bash
cd ~/Gamedev_WF/example/colony_sim && ./harness/gw.sh check && ./harness/gw.sh shot
```

You want `CHECK OK` and three PNG paths. That's your first commissioning.

## 7. Working on it from the Legion

```bash
ssh agent@mint-dev.local
```

```bash
tmux new -A -s game
```

Inside tmux: `cd ~/games/<project> && superclaude`, give it a task (e.g.
`/build phase 2`), then detach with `Ctrl-b d`. Close the laptop lid, go to
work, come back, `tmux attach -t game` to read the summary.

Several projects in parallel = several tmux windows (`Ctrl-b c`), one per
project folder. Keep it to two or three: the limit is your Pro usage, not
the CPU.

## 8. Optional: Samba share (file tree in Windows Explorer)
As your own user:

```bash
sudo smbpasswd -a agent
```

Append to `/etc/samba/smb.conf`:

```ini
[games]
   path = /home/agent/games
   valid users = agent
   read only = no
```

```bash
sudo systemctl restart smbd
```

In Windows Explorer: `\\mint-dev.local\games`. Open files with Obsidian or VS
Code from there. **Play and edit in Godot on Windows from a `git pull`ed
copy**, not from the share: Godot's import cache over a network share is slow
and can conflict with the agent's.

## 9. Housekeeping
- `reports/` folders (logs, CSVs, screenshots) are git-ignored. Clean them
  occasionally: `rm -rf ~/games/*/reports`.
- Update Claude Code from time to time (it usually updates itself) and
  `git -C ~/Gamedev_WF pull && ~/Gamedev_WF/scripts/install.sh` for kit updates.
