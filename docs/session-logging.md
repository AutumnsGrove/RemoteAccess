# Session Logging and Usage Analytics

Track your remote workspace usage with automated session logging and detailed analytics.

## 🎯 What Gets Tracked

The session logger automatically records:

- ✅ **SSH login/logout events** - When you connect and disconnect
- ✅ **tmux session activity** - New sessions, attaches, detaches
- ✅ **Claude Code usage** - Start and stop events
- ✅ **Connection location** - Local, Tailscale, or remote IP
- ✅ **Timestamps** - Precise ISO 8601 format (UTC)
- ✅ **Session names** - Which projects you're working on
- ✅ **Custom events** - Anything else you want to track

## 📋 Quick Start (5 minutes)

### 1. Install the Logger

```bash
# Copy logger script to your bin directory
mkdir -p ~/bin
cp session-logger.sh ~/bin/session-logger
chmod +x ~/bin/session-logger

# Copy analyzer script
cp analyze-logs.sh ~/bin/analyze-logs
chmod +x ~/bin/analyze-logs

# Add bin to PATH if not already (add to ~/.zshrc or ~/.bash_profile)
export PATH="$HOME/bin:$PATH"
```

### 2. Set Up Auto-Logging

Add to your `~/.zshrc` or `~/.bash_profile`:

```bash
# ============================================
# Session Logging Integration
# ============================================

# Log SSH login
if [ -n "$SSH_CONNECTION" ]; then
    session-logger login 2>/dev/null
fi

# Log SSH logout (in trap)
trap 'session-logger logout 2>/dev/null' EXIT

# Alias for tmux with logging
alias tmux-log='_tmux_with_log'
_tmux_with_log() {
    if [ "$1" = "new" ]; then
        local session_name="${3:-${2:-default}}"
        session-logger tmux-new "$session_name"
        command tmux "$@"
    elif [ "$1" = "attach" ] || [ "$1" = "a" ]; then
        local session_name="${3:-${2:-default}}"
        session-logger tmux-attach "$session_name"
        command tmux "$@"
    else
        command tmux "$@"
    fi
}

# Shortcut for tmux sessions (with logging)
alias tm='_tm_session'
_tm_session() {
    local session="${1:-claude-code}"
    if tmux has-session -t "$session" 2>/dev/null; then
        session-logger tmux-attach "$session"
        tmux attach -t "$session"
    else
        session-logger tmux-new "$session"
        tmux new -s "$session"
    fi
}

# Log Claude Code starts (optional wrapper)
alias claude-code='_claude_with_log'
_claude_with_log() {
    session-logger claude-start "${TMUX_SESSION:-claude-code}"
    command claude-code "$@"
    session-logger claude-stop "${TMUX_SESSION:-claude-code}"
}
```

Reload your shell:
```bash
source ~/.zshrc  # or ~/.bash_profile
```

### 3. Test It

```bash
# These commands now automatically log
tm claude-code          # Creates/attaches with logging
claude-code             # Logs start/stop

# View logs
analyze-logs summary
```

---

## 📊 Viewing Your Analytics

### Quick Commands

```bash
# Summary statistics
analyze-logs summary

# Last 20 activities
analyze-logs recent 20

# Session breakdown
analyze-logs sessions

# Where you connect from
analyze-logs locations

# Daily timeline
analyze-logs timeline

# Full report
analyze-logs report

# Interactive menu
analyze-logs menu
```

### Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Remote Workspace Session Analytics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary Statistics

  Total Events: 247
  Date Range: 2025-01-15 to 2025-10-06
  SSH Logins: 42
  tmux Sessions Created: 18
  Claude Code Sessions: 35

📅 Recent Activity (Last 10 events)

  Time                Event              Session          Location
  ────────────────────────────────────────────────────────────────
  2025-10-06 14:23    ssh_login          -                tailscale-network
  2025-10-06 14:24    tmux_attach        claude-code      tailscale-network
  2025-10-06 14:25    claude_code_start  claude-code      tailscale-network
  2025-10-06 15:45    tmux_detach        claude-code      tailscale-network
  2025-10-06 15:45    ssh_logout         -                tailscale-network

📂 Session Breakdown

  Session Name               Times Used    Last Used
  ────────────────────────────────────────────────────
  claude-code                87 times      2025-10-06
  experiments                23 times      2025-10-05
  project-alpha              15 times      2025-10-04
```

---

## 🔍 Advanced Features

### Search Logs

```bash
# Search for specific events
analyze-logs search "claude"
analyze-logs search "tmux_attach"
analyze-logs search "2025-10-06"
```

### Export to JSON

```bash
# Export for analysis in other tools
analyze-logs export session-data.json

# Use with jq for powerful queries
cat session-data.json | jq '.[] | select(.event_type == "claude_code_start")'
```

### Manual Logging

```bash
# Log custom events
session-logger custom "backup" "Started database backup"
session-logger custom "deploy" "Deployed to production"
session-logger wake  # Log Wake-on-LAN event
```

---

## 📈 Understanding Your Data

### Log File Format

Location: `~/.session-log.csv`

```csv
timestamp,event_type,username,session_name,client_ip,location,details
2025-10-06T14:23:15Z,ssh_login,john,,100.85.23.45,tailscale-network,SSH connection established
2025-10-06T14:24:30Z,tmux_attach,john,claude-code,100.85.23.45,tailscale-network,Attached to tmux session
```

### Event Types

| Event Type | Description |
|------------|-------------|
| `ssh_login` | SSH connection established |
| `ssh_logout` | SSH connection closed |
| `tmux_new` | New tmux session created |
| `tmux_attach` | Attached to existing session |
| `tmux_detach` | Detached from session |
| `claude_code_start` | Claude Code started |
| `claude_code_stop` | Claude Code stopped |
| `wake_on_lan` | Mac woken remotely |
| `custom` | User-defined event |

### Location Tracking

- **localhost** - Direct local access
- **tailscale-network** - Connected via Tailscale VPN (100.x.x.x IPs)
- **remote** - Other IP addresses

For more detailed geolocation, uncomment the ipapi section in `session-logger` (sends IP to external service).

---

## 📊 Usage Reports

### Monthly Report

```bash
# Filter by date range
grep "2025-10" ~/.session-log.csv | wc -l
# Shows October activity count

# Or use analyze-logs
analyze-logs timeline | grep "2025-10"
```

### Session Duration Tracking

Create helper to track session duration:

```bash
# Add to ~/.zshrc
alias track-session='_track_session_duration'
_track_session_duration() {
    local session="${1:-claude-code}"
    local start=$(date +%s)
    
    # Work in session
    tm "$session"
    
    # Calculate duration on exit
    local end=$(date +%s)
    local duration=$((end - start))
    local hours=$((duration / 3600))
    local minutes=$(( (duration % 3600) / 60 ))
    
    session-logger custom "session_duration" "Session: $session, Duration: ${hours}h ${minutes}m"
}
```

### Token Usage Tracking (Claude Code Integration)

If Claude Code exposes token usage, integrate it:

```bash
# Create wrapper that captures token usage
alias claude-code-tracked='_claude_tracked'
_claude_tracked() {
    # Run Claude Code and capture output
    command claude-code "$@" 2>&1 | tee /tmp/claude-output.txt
    
    # Parse token usage from output (adjust grep pattern as needed)
    local tokens=$(grep -o "tokens: [0-9]*" /tmp/claude-output.txt | tail -1 | cut -d' ' -f2)
    
    if [ -n "$tokens" ]; then
        session-logger custom "tokens_used" "Tokens: $tokens"
    fi
}
```

---

## 📱 Mobile Access to Logs

### Via Termius

```bash
# Quick aliases for mobile
alias logs='analyze-logs recent 10'
alias stats='analyze-logs summary'
alias sessions='analyze-logs sessions'
```

### Via ttyd Web Interface

```bash
# Access logs in browser
analyze-logs report | less
```

### Export and View on iPhone

```bash
# Export to human-readable format
analyze-logs report > ~/screenshots/usage-report.txt

# View in Files app on iPhone
# (syncs via iCloud if using screenshot folder)
```

---

## 🔐 Privacy & Security

### What's Stored

- ✅ Timestamps (UTC)
- ✅ Event types (login, tmux, etc.)
- ✅ Session names
- ✅ Client IP (for location)
- ✅ Basic details

### What's NOT Stored

- ❌ Passwords or credentials
- ❌ Actual commands executed
- ❌ File contents or data
- ❌ Screenshots or visual data
- ❌ Detailed command history

### Sensitive Data

The log file may contain:
- Your username
- Client IP addresses
- Session names (may contain project names)

**Security measures**:

```bash
# Restrict log file permissions
chmod 600 ~/.session-log.csv

# Already in .gitignore
# Never commit logs to git!

# Clear old logs if needed
mv ~/.session-log.csv ~/.session-log.csv.backup
# Logger will create new file
```

### Geolocation Privacy

By default, geolocation is **disabled** to avoid sending IPs to external services.

To enable (optional):
```bash
# Edit session-logger
# Uncomment the ipapi.com section
# This sends client IP to ip-api.com for city lookup
```

---

## 🎨 Customization

### Custom Dashboard

Create your own analytics:

```bash
#!/bin/bash
# ~/bin/my-dashboard

echo "🚀 My Workspace Dashboard"
echo ""

# This week's activity
echo "📅 This Week:"
start_of_week=$(date -v-Mon +%Y-%m-%d)  # macOS
current_week=$(grep "$start_of_week" ~/.session-log.csv | wc -l | xargs)
echo "  Events: $current_week"

# Most used session
echo ""
echo "⭐ Favorite Session:"
tail -n +2 ~/.session-log.csv | cut -d',' -f4 | grep -v '^$' | sort | uniq -c | sort -rn | head -1

# Hours worked (approximate from login/logout pairs)
echo ""
echo "⏰ Estimated Hours This Month:"
# Your calculation logic here
```

### Integration with Monitoring Tools

Export to Prometheus format:

```bash
# Convert to Prometheus metrics
cat ~/.session-log.csv | grep "$(date +%Y-%m-%d)" | wc -l > /tmp/daily_events.prom
echo "workspace_daily_events $(cat /tmp/daily_events.prom)" > /var/lib/prometheus/workspace.prom
```

### Slack Notifications

Send daily summary to Slack:

```bash
# ~/bin/daily-slack-summary
#!/bin/bash

SUMMARY=$(analyze-logs summary | tail -5)

curl -X POST YOUR_SLACK_WEBHOOK_URL \
  -H 'Content-Type: application/json' \
  -d "{\"text\": \"Daily Workspace Summary:\n\`\`\`$SUMMARY\`\`\`\"}"
```

---

## 🛠️ Troubleshooting

### Logs not being created

```bash
# Check logger is executable
ls -la ~/bin/session-logger
chmod +x ~/bin/session-logger

# Check PATH includes ~/bin
echo $PATH | grep "$HOME/bin"

# Test logger manually
session-logger login
cat ~/.session-log.csv
```

### Duplicate entries

```bash
# Check for duplicate login hooks
grep "session-logger" ~/.zshrc
# Should only appear once
```

### Permissions errors

```bash
# Fix log file permissions
chmod 600 ~/.session-log.csv
chmod 700 ~/.session-logs/
```

### Analyzer not showing colors

```bash
# Some terminals don't support colors
# Set NO_COLOR environment variable
export NO_COLOR=1
analyze-logs summary
```

---

## 📚 Example Queries

### "How many times did I use Claude Code last month?"

```bash
grep "2025-09" ~/.session-log.csv | grep "claude_code_start" | wc -l
```

### "What's my most active day of the week?"

```bash
tail -n +2 ~/.session-log.csv | cut -d',' -f1 | cut -d'T' -f1 | \
  xargs -I {} date -jf "%Y-%m-%d" {} "+%A" | sort | uniq -c | sort -rn
```

### "Average session length?"

```bash
# If you track session durations
grep "session_duration" ~/.session-log.csv | \
  cut -d',' -f7 | grep -o "[0-9]*h [0-9]*m" | \
  # Calculate average (requires awk/bc)
```

---

## 🎯 Portfolio Benefits

This logging system demonstrates:

- ✅ **Scripting proficiency** - Bash automation
- ✅ **Data analysis** - Log parsing and statistics
- ✅ **User experience** - Colored output, interactive menus
- ✅ **System integration** - Hooks into shell and tmux
- ✅ **CSV and JSON** - Multiple export formats
- ✅ **Privacy awareness** - Careful data collection

Perfect for showing employers you think about:
- Observability
- Usage metrics
- Data-driven decisions
- System monitoring

---

## 📖 Related Documentation

- [Setup Guide](./setup-guide.md) - Initial workspace setup
- [Usage Guide](./usage-guide.md) - Daily workflows
- [Configuration](./configuration.md) - Customize everything

---

## 🚀 Future Enhancements

Ideas for extending the logging system:

- [ ] Add session duration calculation
- [ ] Integrate with Claude Code token usage API
- [ ] Create web dashboard (HTML + JavaScript)
- [ ] Add graph visualizations (gnuplot)
- [ ] Export to database (SQLite)
- [ ] Real-time dashboard (watch + analyze-logs)
- [ ] Weekly email reports
- [ ] Machine learning on usage patterns
- [ ] Predict optimal working hours

---

**Track your productivity and showcase your skills!** 📊✨
