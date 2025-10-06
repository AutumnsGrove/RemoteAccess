# Troubleshooting Guide

Common issues and their solutions for your remote Mac mini workspace.

## 🔌 Connection Issues

### Problem: Can't connect to Mac mini via Termius

**Symptoms**: "Connection refused", "Host unreachable", or timeout errors

**Diagnosis checklist**:
1. Is Tailscale running on iPhone? (Check the app - should show green dot)
2. Is Tailscale running on Mac mini? (Check menu bar icon)
3. Is Mac mini powered on and connected to network?
4. Are you using the correct Tailscale IP?

**Solutions**:

```bash
# Verify Tailscale IP on Mac mini (need physical access or VNC)
tailscale ip -4

# Restart Tailscale on iPhone
# (Toggle off and on in the app)

# Test basic connectivity from iPhone Safari
http://100.x.x.x
# Should get SOME response (even "connection refused" means network works)

# Restart SSH on Mac mini (if you have access)
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
```

### Problem: Tailscale shows "Not connected"

**Symptoms**: Gray dot in Tailscale app, no devices visible

**Solutions**:

1. **Check internet connection**
   - Try Safari on iPhone
   - Check WiFi/cellular is working

2. **Re-authenticate Tailscale**
   - Open Tailscale app
   - Tap Settings → Log out
   - Log back in
   - Toggle VPN on

3. **Restart device**
   - Sometimes iOS VPN profiles get stuck
   - Restart iPhone
   - Reopen Tailscale

4. **Check Tailscale status**
   - Visit https://login.tailscale.com/admin/machines
   - Both devices should show "Connected"
   - If one shows "Offline", restart Tailscale on that device

---

## 🖥️ tmux Issues

### Problem: "tmux: command not found"

**Symptom**: Error when running tmux commands

**Solution**:

```bash
# Install tmux
brew install tmux

# Verify installation
which tmux
tmux -V
```

### Problem: Can't attach to session - "no server running"

**Symptom**: `tmux attach -t claude-code` returns error

**Solution**:

```bash
# Session doesn't exist - create it
tmux new -s claude-code

# Or check what sessions exist
tmux ls
```

### Problem: Attached to tmux but screen is frozen

**Symptoms**: Can't type, nothing happens, screen doesn't update

**Diagnosis**: Usually a process is hanging or waiting for input

**Solutions**:

```bash
# Try sending interrupt
Ctrl-C

# If that doesn't work, check if you're in copy mode
# Press 'q' to exit copy mode

# Force detach from session
Ctrl-a D  (capital D)

# If session is truly hung, kill it
tmux kill-session -t claude-code

# Create new session
tmux new -s claude-code
```

### Problem: Can't scroll in tmux

**Symptom**: Arrow keys don't scroll, output disappears off screen

**Solution**:

```bash
# Enter copy/scroll mode
Ctrl-a [

# Now use:
# - Arrow keys to move
# - Page Up/Down to jump
# - / to search
# - q to exit

# To enable mouse scrolling (add to ~/.tmux.conf):
set -g mouse on

# Reload config:
tmux source ~/.tmux.conf
```

### Problem: Lost session after Mac restart

**Symptom**: Mac restarted, can't find your tmux session

**Prevention**: tmux sessions don't survive restarts by default

**Solutions**:

```bash
# Install tmux-resurrect for session persistence
brew install tmux-resurrect

# Add to ~/.tmux.conf:
run-shell /opt/homebrew/opt/tmux-resurrect/share/tmux-resurrect/resurrect.tmux

# Save session: Ctrl-a Ctrl-s
# Restore session: Ctrl-a Ctrl-r
```

**Alternative**: Start Claude Code in a new session after restart

---

## 🌐 ttyd Issues

### Problem: Can't access ttyd in Safari

**Symptom**: Browser shows "Can't connect to server" or "Safari cannot open the page"

**Diagnosis**:

```bash
# Check if ttyd is running
ps aux | grep ttyd

# Check what's listening on port 7681
lsof -i :7681

# Verify Tailscale IP
tailscale ip -4
```

**Solutions**:

```bash
# Start ttyd manually
ttyd -p 7681 bash

# Or restart launch agent
launchctl unload ~/Library/LaunchAgents/com.ttyd.terminal.plist
launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist

# Check logs
cat /tmp/ttyd.err
cat /tmp/ttyd.out
```

### Problem: ttyd works but terminal is blank

**Symptom**: Web page loads but shows black/empty terminal

**Solutions**:

1. **Refresh the page** (pull down in Safari)

2. **Check browser console**
   - Safari → Develop → Show JavaScript Console
   - Look for errors

3. **Try different shell**
   ```bash
   # Kill current ttyd
   pkill ttyd
   
   # Try with explicit shell
   ttyd -p 7681 /bin/zsh
   ```

4. **Clear browser cache**
   - Safari Settings → Clear History and Website Data

### Problem: ttyd launch agent won't start

**Symptom**: launchctl load succeeds but ttyd isn't running

**Diagnosis**:

```bash
# Check if it loaded
launchctl list | grep ttyd

# Check error logs
cat /tmp/ttyd.err
```

**Common issues**:

1. **Wrong path in plist**
   ```bash
   # Find correct path
   which ttyd
   
   # Update plist with correct path
   # Intel Mac: /usr/local/bin/ttyd
   # Apple Silicon: /opt/homebrew/bin/ttyd
   ```

2. **Wrong username in script path**
   - Verify `YOUR_USERNAME` is replaced with actual username
   
3. **Script not executable**
   ```bash
   chmod +x ~/bin/tmux-launcher.sh
   ```

---

## 📸 Screenshot Sync Issues

### Problem: Screenshots not appearing on Mac

**Symptom**: Saved screenshot to iCloud on iPhone but can't see it on Mac

**Solutions**:

1. **Check iCloud is enabled**
   - iPhone: Settings → [Your Name] → iCloud → iCloud Drive (ON)
   - Mac: System Settings → Apple ID → iCloud → iCloud Drive (ON)

2. **Verify folder exists**
   ```bash
   ls ~/Library/Mobile\ Documents/com~apple~CloudDocs/ClaudeScreenshots/
   
   # Or via symlink
   ls ~/screenshots/
   ```

3. **Force sync**
   - Open Files app on iPhone
   - Navigate to the file
   - Tap and hold, select "Download" if cloud icon present

4. **Check storage**
   - Make sure iCloud isn't full
   - Settings → [Your Name] → iCloud → Manage Storage

5. **Wait longer**
   - Initial sync can take 30-60 seconds
   - Large files take longer on cellular

**Alternative**: Use AirDrop if on same network
```bash
# Drop files directly to Mac when iPhone is nearby
# No waiting for cloud sync!
```

---

## 🔐 SSH Key Issues

### Problem: SSH key not working, still asks for password

**Symptom**: Termius prompts for password despite having key configured

**Solutions**:

1. **Verify key is associated with host**
   - Termius → Edit Host
   - Check "Keys" field has your key selected

2. **Check authorized_keys on Mac**
   ```bash
   cat ~/.ssh/authorized_keys
   # Should contain your iPhone's public key
   
   # Verify permissions
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

3. **Test SSH key manually**
   ```bash
   # From another Mac/Linux machine
   ssh -i /path/to/private_key username@100.x.x.x
   ```

4. **Regenerate key**
   - Termius → Keychain → Create new key
   - Copy public key again
   - Add to Mac's authorized_keys

### Problem: "Permission denied (publickey)"

**Symptom**: Can't connect at all, even with password

**Solution**:

```bash
# On Mac mini, check SSH config
sudo nano /etc/ssh/sshd_config

# Ensure these are set:
PasswordAuthentication yes    # for initial setup
PubkeyAuthentication yes       # for keys
PermitRootLogin no            # security
UsePAM yes

# Restart SSH
sudo launchctl unload /System/Library/LaunchDaemons/ssh.plist
sudo launchctl load /System/Library/LaunchDaemons/ssh.plist
```

---

## 🖼️ VNC / Screen Sharing Issues

### Problem: VNC client can't connect

**Symptom**: Jump Desktop or RealVNC shows "connection refused" or timeout

**Solutions**:

1. **Check Screen Sharing is enabled**
   - Mac: System Settings → Sharing
   - Screen Sharing toggle should be ON

2. **Verify correct IP and port**
   - IP: Tailscale IP (100.x.x.x)
   - Port: 5900 (default VNC port)

3. **Check firewall**
   ```bash
   # Check if firewall is blocking
   # System Settings → Network → Firewall
   
   # If enabled, allow Screen Sharing
   ```

4. **Restart Screen Sharing**
   - Toggle OFF, wait 5 seconds, toggle ON

### Problem: Connected but screen is black

**Symptom**: VNC connects but shows black screen

**Solutions**:

1. **Mac is in sleep mode**
   - System Settings → Lock Screen → Prevent automatic sleeping (when display is off)

2. **Display settings**
   - Try clicking/tapping to wake
   - Move mouse cursor around

3. **Permission issues**
   - Mac: System Settings → Privacy & Security → Screen Recording
   - Ensure VNC/Screen Sharing has permission

---

## 🐛 Claude Code Specific Issues

### Problem: Claude Code exits when I disconnect

**Symptom**: Come back to find Claude Code has stopped

**Solution**: Always run in tmux!

```bash
# Wrong way (exits when you disconnect):
ssh username@100.x.x.x
claude-code
# [disconnect] - Claude Code stops!

# Right way (keeps running):
ssh username@100.x.x.x
tmux new -s claude-code
claude-code
# Ctrl-a d to detach
# [disconnect] - Claude Code keeps running!
```

### Problem: Claude Code is waiting for input but I'm not at terminal

**Symptom**: Come back to find Claude Code paused, waiting for response

**Prevention strategy**:

```bash
# Before starting long task, check:
# 1. Are there likely to be prompts?
# 2. Do I need to approve actions?
# 3. Should I enable auto-approve for this task?

# Use flags to reduce interruptions (if available):
claude-code --auto-approve-low-risk
```

**When it happens**:
- Connect via Termius
- Attach to session
- Respond to prompt
- Detach and continue

---

## ⚡ Performance Issues

### Problem: Termius is slow/laggy

**Symptoms**: Delayed typing, slow screen updates

**Solutions**:

1. **Check internet connection**
   - Try speed test on iPhone
   - Switch to WiFi if on cellular

2. **Disconnect other devices**
   - Multiple SSH sessions can slow things
   - Close unused Termius tabs

3. **Reduce tmux history**
   ```bash
   # Add to ~/.tmux.conf
   set -g history-limit 10000  # down from 50000
   ```

4. **Clear terminal**
   ```bash
   clear
   # or
   Ctrl-L
   ```

### Problem: ttyd browser terminal is slow

**Symptoms**: Laggy typing, slow rendering in Safari

**Solutions**:

1. **Reduce font size**
   ```bash
   ttyd -p 7681 -t fontSize=14 tmux attach
   ```

2. **Close other Safari tabs**

3. **Limit output scrollback**
   ```bash
   # In terminal, clear often
   clear
   
   # Pipe long outputs to less
   your-long-command | less
   ```

---

## 🔄 Mac Mini Management

### Problem: Need to restart Mac remotely

**Solutions**:

```bash
# Restart
sudo shutdown -r now

# Shutdown
sudo shutdown -h now

# Schedule restart (in 10 minutes)
sudo shutdown -r +10

# Cancel scheduled shutdown
sudo shutdown -c
```

**Note**: You'll lose connection! Wait 2-3 minutes then reconnect.

### Problem: Mac mini seems completely unresponsive

**Symptoms**: Can't SSH, can't VNC, Tailscale shows offline

**Last resorts**:

1. **Physical access required**
   - Check power connection
   - Check network cable
   - Hard restart (hold power button)

2. **Remote power cycling**
   - If you have a smart plug, power cycle it
   - Look into: TP-Link Kasa, WeMo, etc.

3. **Prevention**:
   - Enable automatic login
   - Disable sleep: System Settings → Battery → Never sleep
   - Consider setting up Wake-on-LAN

---

## 📊 Diagnostic Commands

Keep these handy for troubleshooting:

```bash
# System info
uname -a
sw_vers

# Network status
ifconfig
tailscale status
ping google.com

# Check what's running
ps aux | grep tmux
ps aux | grep ttyd
ps aux | grep ssh

# Check ports
lsof -i :22    # SSH
lsof -i :5900  # VNC
lsof -i :7681  # ttyd

# Check processes
top
htop  # if installed

# Disk space
df -h

# Memory
vm_stat

# Recent logs
log show --predicate 'eventMessage contains "ssh"' --last 1h
```

---

## 🆘 Getting Help

### When to seek help vs troubleshoot yourself

**Try troubleshooting yourself first if**:
- Connection issues (check Tailscale, SSH, network)
- Configuration issues (typos, wrong paths)
- Known issues in this guide

**Seek help if**:
- Security concerns (weird connections, suspicious activity)
- Hardware failures (Mac won't boot, network dead)
- Repeated crashes with no clear cause
- Data loss or corruption

### Resources

- **Tailscale**: https://tailscale.com/kb/
- **tmux**: https://github.com/tmux/tmux/wiki
- **ttyd**: https://github.com/tsl0922/ttyd
- **Termius**: In-app support
- **macOS**: https://support.apple.com

### Creating a support request

If posting online for help, include:

1. What you were trying to do
2. What happened instead
3. Error messages (exact text)
4. Relevant logs
5. What you've tried so far
6. System info (macOS version, tool versions)

**Never share**:
- Your Tailscale IP addresses
- SSH keys (public or private)
- Passwords
- Personal file contents

---

## ✅ Preventive Maintenance

Avoid issues before they happen:

**Weekly**:
- [ ] Verify backups are working
- [ ] Check available disk space: `df -h`
- [ ] Update Homebrew: `brew update && brew upgrade`

**Monthly**:
- [ ] Update macOS (System Settings → General → Software Update)
- [ ] Review SSH authorized_keys for unknown entries
- [ ] Test VNC still works
- [ ] Verify all tmux sessions are needed (clean up old ones)

**As needed**:
- [ ] Restart Mac mini (clears memory leaks)
- [ ] Clean up Downloads folder
- [ ] Review and rotate SSH keys
- [ ] Update this documentation with new issues/solutions

---

## 🔍 Still Stuck?

If none of the above helped:

1. **Check the logs**
   - System logs: Console.app
   - SSH: `/var/log/system.log`
   - ttyd: `/tmp/ttyd.err`

2. **Try the simplest version**
   - Stop all extras (ttyd, VNC)
   - Just try basic SSH
   - Add components back one at a time

3. **Start fresh**
   - Create new tmux session
   - Test with new SSH key
   - Reinstall problematic tool

4. **Document your issue**
   - Write down exact steps
   - Note error messages
   - Capture screenshots
   - Ask for help with details

Remember: Most issues are simple misconfigurations or connection problems. Take it step by step! 🚀
