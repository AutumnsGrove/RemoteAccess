# Configuration Reference

All important configuration files and settings for your remote workspace.

## 📁 File Locations

### tmux Configuration
- **Location**: `~/.tmux.conf`
- **Purpose**: tmux behavior, appearance, keybindings
- **Reload**: `tmux source ~/.tmux.conf`

### SSH Configuration
- **Location**: `~/.ssh/config`
- **Purpose**: SSH client settings, host aliases
- **Keys**: `~/.ssh/` (keep private!)
- **Authorized keys**: `~/.ssh/authorized_keys`

### Shell Configuration
- **zsh**: `~/.zshrc`
- **bash**: `~/.bash_profile` or `~/.bashrc`
- **Purpose**: Environment variables, aliases, functions

### ttyd Launch Agent
- **Location**: `~/Library/LaunchAgents/com.ttyd.terminal.plist`
- **Purpose**: Auto-start ttyd on boot
- **Logs**: `/tmp/ttyd.out` and `/tmp/ttyd.err`

### Helper Scripts
- **Location**: `~/bin/` (recommended)
- **Scripts**:
  - `tmux-launcher.sh` - Smart session attach
  - `tmux-selector.sh` - Multi-session selector
  - Add to PATH: `export PATH="$HOME/bin:$PATH"`

---

## ⚙️ Complete Configuration Files

### Optimal `~/.tmux.conf`

```bash
# ============================================
# tmux Configuration for Remote Development
# ============================================

# -------- CORE SETTINGS --------

# Better prefix key (Ctrl-a instead of Ctrl-b)
unbind C-b
set -g prefix C-a
bind C-a send-prefix

# Enable mouse support (scrolling, pane selection)
set -g mouse on

# Increase scrollback buffer
set -g history-limit 50000

# Fast command sequences
set -s escape-time 0

# Start window and pane numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Renumber windows when one is closed
set -g renumber-windows on

# Enable 256 colors
set -g default-terminal "screen-256color"

# Enable terminal focus events
set -g focus-events on

# -------- STATUS BAR --------

# Position at top
set -g status-position top

# Update every 5 seconds
set -g status-interval 5

# Status bar styling
set -g status-style 'bg=colour235 fg=colour250'
set -g status-left-length 50
set -g status-right-length 100

# Left: session name
set -g status-left '#[fg=colour197,bold]❐ #S #[default]│ '

# Right: date and time
set -g status-right '#[fg=colour250]%Y-%m-%d #[fg=colour197,bold]%H:%M#[default]'

# Window status
setw -g window-status-format '#[fg=colour250] #I:#W '
setw -g window-status-current-format '#[fg=colour197,bold] #I:#W#[default]'

# -------- PANE MANAGEMENT --------

# Split panes with | and -
bind | split-window -h -c "#{pane_current_path}"
bind - split-window -v -c "#{pane_current_path}"
unbind '"'
unbind %

# Navigate panes with Alt+arrow (no prefix)
bind -n M-Left select-pane -L
bind -n M-Right select-pane -R
bind -n M-Up select-pane -U
bind -n M-Down select-pane -D

# Resize panes with Prefix+arrow
bind -r Left resize-pane -L 5
bind -r Right resize-pane -R 5
bind -r Up resize-pane -U 5
bind -r Down resize-pane -D 5

# -------- WINDOW MANAGEMENT --------

# Create new window in current directory
bind c new-window -c "#{pane_current_path}"

# Easy window switching
bind -n S-Left previous-window
bind -n S-Right next-window

# -------- COPY MODE --------

# Use vim keybindings in copy mode
setw -g mode-keys vi

# Enter copy mode
bind [ copy-mode

# Paste buffer
bind ] paste-buffer

# Copy mode bindings (vim-like)
bind -T copy-mode-vi v send -X begin-selection
bind -T copy-mode-vi y send -X copy-selection-and-cancel
bind -T copy-mode-vi Escape send -X cancel

# -------- OTHER KEYBINDINGS --------

# Reload config with Prefix+r
bind r source-file ~/.tmux.conf \; display "Config reloaded!"

# Kill pane without confirmation
bind x kill-pane

# Kill window without confirmation  
bind X kill-window

# Clear history
bind K clear-history \; display "History cleared!"

# -------- ACTIVITY MONITORING --------

# Highlight windows with activity
setw -g monitor-activity on
set -g visual-activity off

# -------- SESSION MANAGEMENT --------

# Auto-rename windows based on running command
setw -g automatic-rename on

# Set terminal title
set -g set-titles on
set -g set-titles-string '#S:#W - tmux'

# ============================================
# End Configuration
# ============================================
```

### Example `~/.ssh/config`

```bash
# Mac Mini via Tailscale
Host mac-mini
    HostName 100.x.x.x
    User YOUR_USERNAME
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 60
    ServerAliveCountMax 3
    Compression yes
    
# Shorter alias
Host mm
    HostName 100.x.x.x
    User YOUR_USERNAME
    IdentityFile ~/.ssh/id_ed25519
```

**Usage**: `ssh mac-mini` or `ssh mm`

### Shell Aliases (add to `~/.zshrc`)

```bash
# ============================================
# Remote Workspace Aliases
# ============================================

# tmux shortcuts
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'
alias tk='tmux kill-session -t'

# Claude Code session
alias cc='tmux attach -t claude-code || tmux new -s claude-code'
alias cc-kill='tmux kill-session -t claude-code'

# Quick navigation
alias screenshots='cd ~/screenshots'
alias projects='cd ~/projects'

# System info
alias myip='tailscale ip -4'
alias mylocalip='ipconfig getifaddr en0'

# Disk space check
alias diskspace='df -h'

# Process monitoring
alias watching='ps aux | grep -v grep | grep'

# ============================================
# Functions
# ============================================

# Create and attach to tmux session
tm() {
    if [ -z "$1" ]; then
        echo "Usage: tm <session-name>"
        return 1
    fi
    tmux new -s "$1" || tmux attach -t "$1"
}

# Quick note in screenshot folder
note() {
    echo "$(date '+%Y-%m-%d %H:%M:%S'): $*" >> ~/screenshots/notes.txt
    echo "Note saved!"
}

# Show active tmux sessions with details
tmuxls() {
    if tmux ls 2>/dev/null; then
        echo "\nSession details:"
        for session in $(tmux ls | cut -d: -f1); do
            echo "\n📁 $session:"
            tmux list-windows -t "$session" | sed 's/^/  /'
        done
    else
        echo "No active tmux sessions"
    fi
}
```

### `~/bin/tmux-launcher.sh`

```bash
#!/bin/bash
# ============================================
# Smart tmux Session Launcher
# ============================================
# Usage: tmux-launcher.sh [session-name]
# If session exists, attaches. Otherwise, creates.

SESSION_NAME="${1:-claude-code}"

# Check if tmux is installed
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux is not installed"
    echo "Install with: brew install tmux"
    exit 1
fi

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Attaching to existing session: $SESSION_NAME"
    tmux attach-session -t "$SESSION_NAME"
else
    echo "Creating new session: $SESSION_NAME"
    
    # Create session with nice default layout
    tmux new-session -s "$SESSION_NAME" \; \
         set -g status-left "#[fg=colour197,bold]❐ $SESSION_NAME #[default]│ " \; \
         display-message "Session $SESSION_NAME created!"
fi
```

### `~/bin/tmux-selector.sh`

```bash
#!/bin/bash
# ============================================
# Interactive tmux Session Selector
# ============================================

clear
echo "╔════════════════════════════════════════╗"
echo "║     tmux Session Selector              ║"
echo "╚════════════════════════════════════════╝"
echo ""

# Show existing sessions
if tmux ls 2>/dev/null; then
    echo "📁 Active sessions:"
    tmux ls | nl
    echo ""
else
    echo "ℹ️  No active sessions"
    echo ""
fi

# Prompt for action
echo "Options:"
echo "  [1-9] - Attach to session by number"
echo "  [name] - Attach to/create session by name"
echo "  [Enter] - Create session 'claude-code'"
echo ""
echo -n "Your choice: "
read -r choice

# Handle empty input
if [ -z "$choice" ]; then
    choice="claude-code"
fi

# Handle numeric input
if [[ "$choice" =~ ^[0-9]+$ ]]; then
    SESSION=$(tmux ls 2>/dev/null | sed -n "${choice}p" | cut -d: -f1)
    if [ -z "$SESSION" ]; then
        echo "Invalid selection"
        sleep 2
        exec "$0"
    fi
    choice="$SESSION"
fi

# Attach or create
if tmux has-session -t "$choice" 2>/dev/null; then
    tmux attach-session -t "$choice"
else
    echo "Creating new session: $choice"
    sleep 1
    tmux new-session -s "$choice"
fi
```

### ttyd Launch Agent Plist Template

**Location**: `~/Library/LaunchAgents/com.ttyd.terminal.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- Service identifier -->
    <key>Label</key>
    <string>com.ttyd.terminal</string>
    
    <!-- Command and arguments -->
    <key>ProgramArguments</key>
    <array>
        <!-- Path to ttyd (check with: which ttyd) -->
        <string>/opt/homebrew/bin/ttyd</string>
        
        <!-- Port -->
        <string>-p</string>
        <string>7681</string>
        
        <!-- Font size -->
        <string>-t</string>
        <string>fontSize=16</string>
        
        <!-- Font family -->
        <string>-t</string>
        <string>fontFamily=Menlo</string>
        
        <!-- Theme (dark) -->
        <string>-t</string>
        <string>theme={"background":"#1e1e1e","foreground":"#d4d4d4","cursor":"#ffffff"}</string>
        
        <!-- Launcher script -->
        <string>/Users/YOUR_USERNAME/bin/tmux-launcher.sh</string>
        <string>claude-code</string>
    </array>
    
    <!-- Start on login -->
    <key>RunAtLoad</key>
    <true/>
    
    <!-- Keep alive (restart if crashes) -->
    <key>KeepAlive</key>
    <true/>
    
    <!-- Working directory -->
    <key>WorkingDirectory</key>
    <string>/Users/YOUR_USERNAME</string>
    
    <!-- Logging -->
    <key>StandardOutPath</key>
    <string>/tmp/ttyd.out</string>
    
    <key>StandardErrorPath</key>
    <string>/tmp/ttyd.err</string>
    
    <!-- Environment variables (optional) -->
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
</dict>
</plist>
```

**Remember to**:
1. Replace `YOUR_USERNAME` with actual username
2. Verify ttyd path: `which ttyd`
3. Make launcher script executable: `chmod +x ~/bin/tmux-launcher.sh`

---

## 🔐 Security Configuration

### SSH Server Settings

**Location**: `/etc/ssh/sshd_config` (requires sudo)

**Recommended settings**:
```
# Authentication
PasswordAuthentication yes              # Allow passwords initially
PubkeyAuthentication yes                # Enable key-based auth
PermitRootLogin no                      # Disable root login
MaxAuthTries 3                          # Limit login attempts

# Security
X11Forwarding no                        # Disable X11 unless needed
PermitEmptyPasswords no                 # Require passwords
Protocol 2                              # Use SSH protocol 2 only

# Performance
UsePAM yes                              # Use PAM for authentication
ClientAliveInterval 300                 # Keep connections alive
ClientAliveCountMax 2                   # Disconnect after 2 missed keepalives
```

**After changes**: 
```bash
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
```

### macOS Firewall (Optional)

If enabling macOS firewall:

```bash
# System Settings → Network → Firewall

# Allow:
- Remote Login (SSH)
- Screen Sharing (VNC)
- Any apps you use with ttyd
```

**Note**: With Tailscale, firewall is less critical since you're on a private network.

---

## 📊 Monitoring Configuration

### Create System Monitor Session

Add to `~/.zshrc`:

```bash
# Start system monitoring session
alias monitor='tmux new -s monitor \
    "htop" \; \
    split-window -h "tail -f /var/log/system.log" \; \
    split-window -v "watch -n 5 df -h" \; \
    select-pane -t 0'
```

Creates a tmux session with:
- Pane 1: htop (process monitor)
- Pane 2: system logs
- Pane 3: disk space monitoring

---

## 🎨 Customization Ideas

### Different tmux Themes

**Gruvbox Dark**:
```bash
set -g status-style 'bg=#282828 fg=#ebdbb2'
set -g status-left '#[fg=#fb4934,bold]❐ #S #[default]│ '
set -g status-right '#[fg=#ebdbb2]%Y-%m-%d #[fg=#fb4934,bold]%H:%M'
```

**Nord**:
```bash
set -g status-style 'bg=#2e3440 fg=#eceff4'
set -g status-left '#[fg=#88c0d0,bold]❐ #S #[default]│ '
set -g status-right '#[fg=#eceff4]%Y-%m-%d #[fg=#88c0d0,bold]%H:%M'
```

**Dracula**:
```bash
set -g status-style 'bg=#282a36 fg=#f8f8f2'
set -g status-left '#[fg=#ff79c6,bold]❐ #S #[default]│ '
set -g status-right '#[fg=#f8f8f2]%Y-%m-%d #[fg=#ff79c6,bold]%H:%M'
```

### Custom ttyd Themes

**Monokai**:
```bash
ttyd -p 7681 -t theme='{"background":"#272822","foreground":"#f8f8f2","cursor":"#f8f8f0"}' tmux attach
```

**Solarized Dark**:
```bash
ttyd -p 7681 -t theme='{"background":"#002b36","foreground":"#839496","cursor":"#93a1a1"}' tmux attach
```

---

## 📋 Quick Reference

### File Checklist

- [ ] `~/.tmux.conf` - tmux configuration
- [ ] `~/.zshrc` or `~/.bash_profile` - shell aliases
- [ ] `~/.ssh/config` - SSH client config
- [ ] `~/.ssh/authorized_keys` - authorized public keys
- [ ] `~/bin/tmux-launcher.sh` - session launcher script
- [ ] `~/Library/LaunchAgents/com.ttyd.terminal.plist` - ttyd auto-start
- [ ] `~/screenshots/` - screenshot sync folder (symlink)

### Port Reference

- **22**: SSH (Remote Login)
- **5900**: VNC (Screen Sharing)
- **7681**: ttyd (web terminal)
- **7682-7690**: Additional ttyd instances (if needed)

### Important Paths

- Tailscale IP: Run `tailscale ip -4`
- SSH keys: `~/.ssh/`
- Screenshots: `~/Library/Mobile Documents/com~apple~CloudDocs/ClaudeScreenshots/`
- Screenshot symlink: `~/screenshots/`
- Homebrew: `/opt/homebrew/` (Apple Silicon) or `/usr/local/` (Intel)

---

## 🔄 Backup These Files!

**Critical files to backup**:
```bash
~/.tmux.conf
~/.zshrc
~/.bash_profile
~/.ssh/config
~/bin/*
~/Library/LaunchAgents/com.ttyd.terminal.plist
```

**Backup command**:
```bash
tar -czf ~/Desktop/workspace-config-backup.tar.gz \
    ~/.tmux.conf \
    ~/.zshrc \
    ~/.ssh/config \
    ~/bin \
    ~/Library/LaunchAgents/com.ttyd.terminal.plist
```

**Restore**:
```bash
cd ~
tar -xzf workspace-config-backup.tar.gz
```

---

## 🎯 Next Steps

- See [setup-guide.md](./setup-guide.md) for installation
- See [usage-guide.md](./usage-guide.md) for daily workflows
- See [troubleshooting.md](./troubleshooting.md) for common issues

Remember: Configuration is personal! Tweak these to match your workflow. 🚀
