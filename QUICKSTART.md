# Quick Start Guide

Get your remote Mac mini workspace running in 30 minutes.

## Prerequisites
- Mac mini with macOS (any recent version)
- iPhone with iOS 14+
- Admin access to Mac mini
- Both devices connected to internet

## Step-by-Step Setup

### 1. Install Tailscale (5 minutes)

**On Mac mini**:
1. Visit https://tailscale.com/download or run:
   ```bash
   brew install --cask tailscale
   ```
2. Launch Tailscale, click "Log in"
3. Sign in with Google/Microsoft/email
4. Note your Tailscale IP (looks like `100.x.x.x`)

**On iPhone**:
1. App Store → Search "Tailscale" → Install
2. Open app, log in with **same account**
3. Toggle Tailscale ON

### 2. Enable Remote Login (2 minutes)

**On Mac mini**:
1. System Settings → General → Sharing
2. Toggle "Remote Login" ON
3. Set to "Only these users:" and add yourself
4. Note your username (shown in the Remote Login panel)

### 3. Install Tools (5 minutes)

**On Mac mini terminal**:
```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install tmux
brew install tmux

# Create config file
cat > ~/.tmux.conf << 'EOF'
# Better prefix key
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse
set -g mouse on

# Increase history
set -g history-limit 50000

# Better colors
set -g default-terminal "screen-256color"

# Status bar at top
set -g status-position top
set -g status-style 'bg=colour235 fg=colour250'
set -g status-left '#[fg=colour197]#S #[default]'
EOF
```

### 4. Setup SSH Keys (5 minutes)

**On iPhone (in Termius)**:
1. Install Termius from App Store
2. Open Termius → Keychain tab → "+"
3. "New Key" → Type: ED25519 → Generate
4. Tap key → Copy public key

**On Mac mini**:
```bash
# Create SSH directory
mkdir -p ~/.ssh
chmod 700 ~/.ssh

# Add iPhone's public key
nano ~/.ssh/authorized_keys
# Paste the public key, save (Ctrl-O, Enter, Ctrl-X)

# Set permissions
chmod 600 ~/.ssh/authorized_keys
```

**Back in Termius**:
1. Hosts tab → "+" → "New Host"
2. Alias: "Mac mini"
3. Hostname: YOUR_TAILSCALE_IP (e.g., 100.x.x.x)
4. Username: YOUR_MAC_USERNAME
5. Keys: Select your generated key
6. Save

### 5. Test Connection (2 minutes)

**On iPhone**:
1. Tap "Mac mini" in Termius
2. You should see your Mac's terminal!
3. Try: `ls -la` to verify it works

### 6. Create Your First tmux Session (5 minutes)

**In Termius (connected to Mac)**:
```bash
# Create a session
tmux new -s claude-code

# Inside tmux, try some commands
pwd
ls

# Detach (keeps session running)
# Press: Ctrl-a then d

# Close Termius completely
# Reopen and connect
# Reattach to session:
tmux attach -t claude-code
```

You're now seeing the same session you left! 🎉

### 7. Start Claude Code (2 minutes)

```bash
# In your tmux session
cd ~/your-project-directory
claude-code

# When you need to step away:
# Press: Ctrl-a then d
# Claude Code keeps running!

# Come back anytime:
tmux attach -t claude-code
```

## Daily Usage

### Starting a Task
```bash
ssh YOUR_TAILSCALE_IP    # or tap "Mac mini" in Termius
tmux attach -t claude-code || tmux new -s claude-code
claude-code
# Do your work...
# Press Ctrl-a then d to detach
```

### Checking on Progress
```bash
# Open Termius anytime
tmux attach -t claude-code
# See exactly where you left off!
# Press Ctrl-a then d when done
```

### tmux Quick Reference
```bash
Ctrl-a d     # Detach from session
Ctrl-a [     # Scroll mode (q to exit)
Ctrl-a c     # Create new window
Ctrl-a n     # Next window
Ctrl-a p     # Previous window
```

## Screenshot Sharing

**On iPhone**:
1. Settings → iCloud → iCloud Drive → ON
2. Files app → iCloud Drive → Create folder "ClaudeScreenshots"

**On Mac**:
```bash
ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/ClaudeScreenshots ~/screenshots
```

**Usage**:
- iPhone: Save screenshots to ClaudeScreenshots folder
- Mac: Reference with `~/screenshots/filename.png`

## Screen Sharing (Optional)

**On Mac**:
1. System Settings → Sharing → Screen Sharing → ON

**On iPhone**:
1. Install Jump Desktop or RealVNC Viewer
2. Add connection:
   - Address: YOUR_TAILSCALE_IP
   - Port: 5900
   - Username: YOUR_MAC_USERNAME
   - Password: YOUR_MAC_PASSWORD

## Troubleshooting

**Can't connect via Termius?**
- Check Tailscale is ON (green dot on iPhone)
- Verify Tailscale IP with: `tailscale ip -4` on Mac
- Try restarting Tailscale on both devices

**tmux session not found?**
- Session doesn't exist yet: `tmux new -s claude-code`
- List sessions: `tmux ls`

**Screenshot not syncing?**
- Check iCloud Drive is enabled on both devices
- Wait 10-30 seconds for sync
- Check internet connection

## Next Steps

Once comfortable with basics:
- [Full Setup Guide](./docs/setup-guide.md) - Web terminal (ttyd) and more
- [Usage Guide](./docs/usage-guide.md) - Advanced workflows
- [Configuration](./docs/configuration.md) - Customization options

### Optional Enhancements

- [Wake-on-LAN](./docs/wake-on-lan-setup.md) - Power on Mac remotely
- [Session Logging](./docs/session-logging.md) - Track usage and generate analytics
- [ttyd Web Terminal](./docs/ttyd-setup.md) - Browser-based terminal interface

## Support

- See [troubleshooting.md](./docs/troubleshooting.md) for common issues
- Check Tailscale docs: https://tailscale.com/kb/
- tmux wiki: https://github.com/tmux/tmux/wiki

---

**You're all set!** 🚀 You now have a persistent remote workspace accessible from your iPhone anywhere in the world.
