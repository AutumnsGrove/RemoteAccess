# Setup Guide: Remote Mac Mini Workspace

Complete step-by-step instructions to set up remote access to your Mac mini from anywhere.

## Prerequisites

- Mac mini running macOS (any recent version)
- iPhone with iOS 14+
- Internet connection on both devices
- Admin access to Mac mini

---

## Phase 1: Tailscale Setup (15 minutes)

Tailscale creates a secure private network between your devices without any router configuration.

### On Mac mini:

1. **Download Tailscale**
   ```bash
   # Visit https://tailscale.com/download
   # Or install via Homebrew:
   brew install --cask tailscale
   ```

2. **Install and Launch**
   - Open the downloaded .pkg file
   - Follow installation prompts
   - Launch Tailscale from Applications
   - Click "Log in" in the menu bar icon

3. **Sign up / Log in**
   - Use Google, Microsoft, or email
   - Grant necessary permissions
   - Your Mac will appear in the Tailscale admin panel

4. **Note your Tailscale IP**
   - Click the Tailscale menu bar icon
   - Your IP will be something like `100.x.x.x`
   - **Write this down** - you'll need it for SSH

### On iPhone:

1. **Install Tailscale app**
   - Open App Store
   - Search "Tailscale"
   - Install the official app

2. **Log in with same account**
   - Use the same credentials as Mac
   - Enable VPN profile when prompted
   - Toggle Tailscale ON

3. **Verify connection**
   - Both devices should appear in your Tailscale network
   - Green dot = connected

**✅ Success check**: Open Safari on iPhone, navigate to `http://100.x.x.x` (your Mac's Tailscale IP). You should see a "connection refused" or similar - that's fine! It means the network is working.

---

## Phase 2: Enable Remote Login (5 minutes)

Enable SSH server on your Mac mini.

### On Mac mini:

1. **System Settings → General → Sharing**
   
2. **Enable "Remote Login"**
   - Toggle it ON
   - Set to "Only these users:"
   - Add your user account
   
3. **Note your username**
   - Your username is shown in the Remote Login panel
   - Usually your short name (e.g., `john` not `John Smith`)

**✅ Success check**: The Remote Login panel should show "To log in to this computer remotely, type: ssh username@100.x.x.x"

---

## Phase 3: Install and Configure tmux (10 minutes)

tmux keeps your sessions alive even when you disconnect.

### On Mac mini:

1. **Install tmux**
   ```bash
   brew install tmux
   ```

2. **Create tmux config**
   ```bash
   # Create the config file
   touch ~/.tmux.conf
   ```

3. **Add configuration**
   Open `~/.tmux.conf` in a text editor and add:
   ```bash
   # Better prefix key (Ctrl-a instead of Ctrl-b)
   unbind C-b
   set -g prefix C-a
   bind C-a send-prefix

   # Enable mouse support
   set -g mouse on

   # Increase scrollback buffer
   set -g history-limit 50000

   # Better colors
   set -g default-terminal "screen-256color"

   # Status bar at top
   set -g status-position top

   # Status bar styling
   set -g status-style 'bg=colour235 fg=colour250'
   set -g status-left '#[fg=colour197]#S #[default]'
   set -g status-right '#[fg=colour197]%H:%M #[default]'

   # Window numbering starts at 1
   set -g base-index 1
   set -g pane-base-index 1

   # Automatic rename
   setw -g automatic-rename on
   ```

4. **Test tmux**
   ```bash
   # Start a new session
   tmux new -s test
   
   # Inside tmux, press Ctrl-a then d to detach
   # Reattach with:
   tmux attach -t test
   ```

**✅ Success check**: You should be able to create a session, detach, and reattach successfully.

---

## Phase 4: Install Termius on iPhone (5 minutes)

Termius is a polished SSH client for iOS.

### On iPhone:

1. **Install Termius**
   - App Store → Search "Termius"
   - Install (free version is sufficient)

2. **Add your Mac as a host**
   - Tap "+" → "New Host"
   - **Alias**: "Mac mini" (or whatever you prefer)
   - **Hostname**: Your Tailscale IP (100.x.x.x)
   - **Port**: 22
   - **Username**: Your Mac username
   - **Password**: Your Mac password (for now)
   - Save

3. **Test connection**
   - Tap the "Mac mini" host
   - Should prompt for password
   - You'll see your Mac's terminal!

**✅ Success check**: You should see your Mac's command prompt in Termius.

---

## Phase 5: SSH Key Setup (10 minutes) - RECOMMENDED

Replace password authentication with secure keys.

### On iPhone (in Termius):

1. **Generate SSH key**
   - Termius → Keychain tab
   - Tap "+" → "New Key"
   - **Label**: "iPhone to Mac"
   - **Type**: ED25519 (most secure)
   - Generate
   - Copy the public key (tap to copy)

### On Mac mini:

1. **Add iPhone's public key**
   ```bash
   # Create .ssh directory if it doesn't exist
   mkdir -p ~/.ssh
   chmod 700 ~/.ssh
   
   # Edit authorized_keys
   nano ~/.ssh/authorized_keys
   
   # Paste the public key from iPhone (one line)
   # Save: Ctrl-O, Enter, Ctrl-X
   
   # Set correct permissions
   chmod 600 ~/.ssh/authorized_keys
   ```

### Back on iPhone (in Termius):

1. **Update host to use key**
   - Edit your Mac mini host
   - **Keys**: Select "iPhone to Mac"
   - Remove password field
   - Save

2. **Test connection**
   - Connect - should work without password!

**✅ Success check**: You can now connect via SSH without entering a password.

---

## Phase 6: Claude Code + tmux Workflow (5 minutes)

Set up your standard workflow for running Claude Code persistently.

### On Mac mini (via Termius):

1. **Create a dedicated tmux session for Claude Code**
   ```bash
   tmux new -s claude-code
   ```

2. **Start Claude Code in this session**
   ```bash
   # Your normal Claude Code command
   claude-code
   ```

3. **Detach when needed**
   - Press `Ctrl-a` then `d`
   - Claude Code keeps running!

4. **Reattach from anywhere**
   ```bash
   tmux attach -t claude-code
   ```

5. **Create a helper alias**
   Add to your `~/.zshrc` or `~/.bash_profile`:
   ```bash
   alias cc-attach='tmux attach -t claude-code || tmux new -s claude-code'
   ```
   
   Now you can just type `cc-attach` to jump back into your session!

**✅ Success check**: Start Claude Code in tmux, detach, close Termius, reopen and reattach - Claude Code should still be running.

---

## Phase 7: Screenshot Sharing Setup (5 minutes)

Set up a shared folder for sending screenshots to Claude Code.

### Option A: iCloud Drive (Recommended)

1. **On Mac mini**:
   ```bash
   # Create a dedicated folder
   mkdir -p ~/Library/Mobile\ Documents/com~apple~CloudDocs/ClaudeScreenshots
   
   # Create a symlink for easy access
   ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/ClaudeScreenshots ~/screenshots
   ```

2. **On iPhone**:
   - Files app → iCloud Drive
   - Create folder "ClaudeScreenshots"
   - Save screenshots here
   - They sync automatically!

3. **In Claude Code**:
   ```bash
   # Reference screenshots like:
   open ~/screenshots/latest.png
   # or pass path to Claude Code
   ```

### Option B: Dropbox

1. Install Dropbox on both devices
2. Create a shared folder: `~/Dropbox/ClaudeScreenshots`
3. Same workflow as iCloud

**✅ Success check**: Save a screenshot from iPhone to the folder, verify it appears on Mac mini within a few seconds.

---

## Phase 8: Screen Sharing / VNC Setup (10 minutes)

For when you need to see the Mac's display visually.

### On Mac mini:

1. **Enable Screen Sharing**
   - System Settings → General → Sharing
   - Toggle "Screen Sharing" ON
   - Set to "Only these users:" and add yourself

### On iPhone:

1. **Install VNC client**
   - **Recommended**: Jump Desktop (paid, best experience)
   - **Free alternative**: RealVNC Viewer

2. **Add VNC connection**
   - Protocol: VNC
   - Address: Your Tailscale IP (100.x.x.x)
   - Port: 5900
   - Username: Your Mac username
   - Password: Your Mac password

3. **Test connection**
   - Make sure Tailscale is ON
   - Connect - you should see your Mac's screen!

**✅ Success check**: You can see and interact with your Mac's desktop from iPhone.

---

## 🎉 Phase Complete!

You now have a fully functional remote workspace! See [usage-guide.md](./usage-guide.md) for daily workflows.

## Quick Reference

**Tailscale IPs**:
- Mac mini: `100.x.x.x` (replace with your actual IP)

**SSH Connection**:
```bash
ssh username@100.x.x.x
```

**tmux Commands**:
```bash
tmux new -s session-name      # Create new session
tmux attach -t session-name   # Reattach to session
tmux ls                       # List sessions
Ctrl-a then d                 # Detach from session
Ctrl-a then [                 # Scroll mode (q to exit)
```

**Screenshot folder**: `~/screenshots/` on Mac

---

## Next Steps

- [Daily Usage Guide](./usage-guide.md) - Common workflows
- [Phase 2: ttyd Web Terminal](./ttyd-setup.md) - Add web-based interface
- [Troubleshooting](./troubleshooting.md) - Fix common issues

## Security Reminders

- ✅ Keep Tailscale logged in on both devices
- ✅ Use SSH keys instead of passwords
- ✅ Don't share your Tailscale IPs publicly
- ✅ Never commit actual IPs, keys, or passwords to git
