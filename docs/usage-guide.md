# Daily Usage Guide

Common workflows for your remote Mac mini workspace.

## 🚀 Starting Your Day

### Morning Checklist

1. **Ensure Tailscale is running**
   - iPhone: Check Tailscale app (should show green dot)
   - Connects automatically, but verify if having issues

2. **Connect via Termius**
   - Open Termius app
   - Tap "Mac mini" host
   - You're in!

3. **Attach to your Claude Code session**
   ```bash
   tmux attach -t claude-code
   ```
   
   Or if you set up the alias:
   ```bash
   cc-attach
   ```

---

## 📱 Typical Workflows

### Workflow 1: Starting a New Claude Code Task

```bash
# Connect via Termius
ssh username@100.x.x.x

# Create or attach to tmux session
tmux new -s claude-code    # if starting fresh
# or
tmux attach -t claude-code # if session exists

# Start Claude Code
cd ~/your-project-directory
claude-code

# Work with Claude...

# When done for now - DETACH (don't exit!)
# Press: Ctrl-a then d

# Close Termius - Claude Code keeps running!
```

### Workflow 2: Checking on Long-Running Tasks

```bash
# Open Termius anytime
# Connect to Mac mini
tmux attach -t claude-code

# You'll see exactly where Claude left off!
# Read the output, see what's happening

# Detach again: Ctrl-a then d
```

### Workflow 3: Sending Screenshots to Claude Code

**On iPhone:**

1. Take screenshot (Side button + Volume Up)
2. Edit/annotate if needed
3. Share → Save to Files
4. iCloud Drive → ClaudeScreenshots folder
5. Name it something clear: `bug-screenshot.png`

**Back in Termius:**

```bash
# Attach to session
tmux attach -t claude-code

# Reference the screenshot
ls ~/screenshots/
# You'll see: bug-screenshot.png

# In your conversation with Claude Code:
"Please analyze ~/screenshots/bug-screenshot.png and fix the layout issue"
```

### Workflow 4: Responding to Claude Code Prompts

When Claude Code asks for input:

1. **Get notification** (if task running overnight)
   - Open Termius when you have time
   - Attach to session
   
2. **Read the prompt**
   - Scroll up if needed: `Ctrl-a` then `[`, then use arrows
   - Press `q` to exit scroll mode

3. **Respond to Claude**
   - Just type your response normally
   - Claude Code continues!

4. **Detach again**
   - `Ctrl-a` then `d`

### Workflow 5: Viewing Visual Results

When you need to see GUI applications or results:

1. **Open VNC client** (Jump Desktop / RealVNC)
2. **Connect to Mac mini**
3. **See the actual screen**
   - View browser results
   - Check design changes
   - Verify UI components
   - Take more screenshots if needed

4. **Close VNC when done**
   - Everything keeps running

---

## 🎯 Pro Tips

### Multiple tmux Sessions

You can run multiple projects simultaneously:

```bash
# Create sessions for different projects
tmux new -s project-alpha
tmux new -s project-beta
tmux new -s experiments

# List all sessions
tmux ls

# Switch between them
tmux attach -t project-alpha
# Detach (Ctrl-a d), then:
tmux attach -t project-beta
```

### tmux Windows (Tabs)

Work with multiple "tabs" in one session:

```bash
# Inside a tmux session:
Ctrl-a c          # Create new window
Ctrl-a n          # Next window
Ctrl-a p          # Previous window
Ctrl-a 0-9        # Jump to window number
Ctrl-a ,          # Rename current window
```

Example layout:
- Window 0: Claude Code running
- Window 1: File system navigation
- Window 2: Log monitoring

### Split Panes (Advanced)

View multiple things at once:

```bash
Ctrl-a %          # Split vertically
Ctrl-a "          # Split horizontally
Ctrl-a arrow keys # Navigate between panes
Ctrl-a x          # Close current pane
```

### Scrolling in tmux

```bash
Ctrl-a [          # Enter scroll mode
↑↓                # Arrow keys to scroll
Page Up/Down      # Jump by pages
q                 # Exit scroll mode
```

### Quick Session Management

Add these to your `~/.zshrc`:

```bash
# Quick aliases
alias cc='tmux attach -t claude-code || tmux new -s claude-code'
alias tls='tmux ls'
alias ta='tmux attach -t'
alias tn='tmux new -s'

# Usage:
# cc           - attach to claude-code session
# tls          - list all sessions  
# ta project-a - attach to project-a
# tn test      - create new session called 'test'
```

---

## 📊 Monitoring Long Tasks

### Strategy for 10 min - 3 hour tasks:

1. **Start task in tmux**
2. **Set a timer** on your phone
3. **Check in periodically**:
   - 10 min tasks: Check at 5 min and 10 min
   - 1 hour tasks: Check every 15-20 min
   - 3 hour tasks: Check every 30-45 min

4. **Look for**:
   - Progress indicators
   - Prompts waiting for input
   - Errors that need attention
   - Completion status

### Setting up notifications (Optional):

If Claude Code completes a task, you can make it notify you:

```bash
# After a long command, add:
claude-code do-long-task && osascript -e 'display notification "Claude Code finished!" with title "Task Complete"'
```

You won't see this on iPhone, but if you check via VNC, notifications will be there.

---

## 🔍 Troubleshooting On-the-Go

### Can't connect via Termius?

1. Check Tailscale is ON (iPhone)
2. Check Mac mini is powered on
3. Try disconnecting and reconnecting Tailscale
4. Test with Safari: `http://100.x.x.x` (should get some response)

### tmux session seems frozen?

```bash
# Detach forcefully
Ctrl-a D  (capital D)

# Kill and restart session if needed
tmux kill-session -t claude-code
tmux new -s claude-code
```

### Can't see recent output?

```bash
# Scroll up
Ctrl-a [
# Use arrow keys or Page Up
# Press q when done
```

### Screenshots not syncing?

1. Check iCloud is enabled on both devices
2. Check WiFi/cellular connection
3. May take 10-30 seconds to sync
4. Force sync: Open Files app on iPhone, view the file

---

## 🎨 Customizing Your Setup

### Termius Tips

- **Snippets**: Save common commands
  - Termius → Snippets → Add new
  - Examples: `tmux attach -t claude-code`, `cd ~/projects`
  
- **Port Forwarding**: For web apps running on Mac
  - Edit host → Forwarding
  - Example: Forward Mac's `localhost:3000` to iPhone

### Better tmux Status Bar

Add to `~/.tmux.conf`:

```bash
# Show current directory in status bar
set -g status-right '#[fg=colour197]%H:%M #[fg=colour250]#(pwd)'

# Reload config
tmux source ~/.tmux.conf
```

### Color Schemes

Termius has themes! Experiment with:
- Settings → Appearance
- Try different fonts for readability

---

## 📅 Example Daily Schedule

**Morning (Starting a task)**:
```
9:00 AM  - Open Termius on iPhone
9:01 AM  - Attach to claude-code session
9:02 AM  - Start new task with Claude Code
9:05 AM  - Detach, go about your day
```

**Midday (Check-in)**:
```
12:30 PM - Open Termius
12:31 PM - Attach to see progress
12:32 PM - Respond to any prompts
12:33 PM - Detach, continue day
```

**Evening (Visual check)**:
```
6:00 PM  - Open VNC client
6:01 PM  - View results visually
6:02 PM  - Take screenshots if needed
6:05 PM  - Disconnect VNC
6:06 PM  - Back to Termius for final commands
```

---

## 🚨 Emergency Procedures

### Claude Code is stuck/hanging

```bash
# Attach to session
tmux attach -t claude-code

# Send interrupt signal
Ctrl-C

# If that doesn't work, kill the session
tmux kill-session -t claude-code

# Start fresh
tmux new -s claude-code
```

### Mac mini needs restart

```bash
# Via SSH:
sudo shutdown -r now

# Wait 2-3 minutes
# Reconnect via Termius
```

### Lost all connections

1. Check Mac mini is plugged in and powered on
2. Check router/internet is working
3. Check Tailscale on iPhone (restart if needed)
4. Worst case: Physical access to Mac mini to restart services

---

## 📚 Learning More

- **tmux**: `man tmux` or https://github.com/tmux/tmux/wiki
- **Termius**: In-app tutorials
- **Tailscale**: https://tailscale.com/kb/

---

## ✅ Daily Checklist

- [ ] Tailscale running on iPhone
- [ ] Connected to Mac via Termius
- [ ] tmux session active
- [ ] Claude Code working
- [ ] Screenshot folder syncing
- [ ] Can detach/reattach successfully
- [ ] Know how to check visual results via VNC

That's it! You're now a remote workspace pro. 🚀
