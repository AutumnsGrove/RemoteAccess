# Phase 2: Web-Based Terminal with ttyd

Add a browser-accessible terminal to your setup for a more visual, GUI-like experience.

## 🎯 What is ttyd?

ttyd creates a web server that lets you access your terminal through a browser. Benefits for iPhone:

- ✅ Better text rendering and scrolling
- ✅ No app needed - just use Safari
- ✅ Easier copy/paste
- ✅ Better for reading long outputs
- ✅ Can have multiple tabs open to different sessions

## 📋 Prerequisites

- Completed Phase 1 setup (Tailscale + SSH + tmux)
- Comfortable with terminal commands

---

## Installation (10 minutes)

### On Mac mini:

1. **Install ttyd via Homebrew**
   ```bash
   brew install ttyd
   ```

2. **Test basic setup**
   ```bash
   # Start ttyd on port 7681
   ttyd -p 7681 bash
   ```

3. **On iPhone (Safari)**
   - Navigate to: `http://100.x.x.x:7681` (your Tailscale IP)
   - You should see a terminal in the browser!
   - Press `Ctrl-C` in the original terminal to stop ttyd

---

## Configuration

### Option 1: Simple tmux Integration

Run ttyd with tmux attach by default:

```bash
ttyd -p 7681 tmux attach -t claude-code
```

**Pros**: Instantly shows your Claude Code session  
**Cons**: When you close browser, the session ends

### Option 2: Smart Session Launcher (Recommended)

Create a script that attaches to existing session or creates new one:

1. **Create launcher script**
   ```bash
   nano ~/bin/tmux-launcher.sh
   ```

2. **Add content**:
   ```bash
   #!/bin/bash
   
   SESSION_NAME="${1:-claude-code}"
   
   # Check if session exists
   if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
       # Attach to existing session
       tmux attach-session -t "$SESSION_NAME"
   else
       # Create new session
       tmux new-session -s "$SESSION_NAME"
   fi
   ```

3. **Make executable**
   ```bash
   chmod +x ~/bin/tmux-launcher.sh
   ```

4. **Run ttyd with launcher**
   ```bash
   ttyd -p 7681 ~/bin/tmux-launcher.sh claude-code
   ```

### Option 3: Multi-Session Selector

Show a menu of available sessions:

1. **Create selector script**
   ```bash
   nano ~/bin/tmux-selector.sh
   ```

2. **Add content**:
   ```bash
   #!/bin/bash
   
   echo "Available tmux sessions:"
   tmux ls 2>/dev/null || echo "No sessions found"
   echo ""
   echo "Enter session name (or press Enter for 'claude-code'):"
   read -r SESSION
   
   SESSION="${SESSION:-claude-code}"
   
   if tmux has-session -t "$SESSION" 2>/dev/null; then
       tmux attach-session -t "$SESSION"
   else
       echo "Creating new session: $SESSION"
       tmux new-session -s "$SESSION"
   fi
   ```

3. **Make executable**
   ```bash
   chmod +x ~/bin/tmux-selector.sh
   ```

4. **Run ttyd**
   ```bash
   ttyd -p 7681 ~/bin/tmux-selector.sh
   ```

---

## Running ttyd Automatically

### As a Launch Agent (Recommended)

Keep ttyd running all the time, automatically starting on boot.

1. **Create launch agent plist**
   ```bash
   nano ~/Library/LaunchAgents/com.ttyd.terminal.plist
   ```

2. **Add configuration**:
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
   <plist version="1.0">
   <dict>
       <key>Label</key>
       <string>com.ttyd.terminal</string>
       
       <key>ProgramArguments</key>
       <array>
           <string>/opt/homebrew/bin/ttyd</string>
           <string>-p</string>
           <string>7681</string>
           <string>-t</string>
           <string>fontSize=16</string>
           <string>-t</string>
           <string>theme={"background":"#1e1e1e","foreground":"#d4d4d4"}</string>
           <string>/Users/YOUR_USERNAME/bin/tmux-launcher.sh</string>
           <string>claude-code</string>
       </array>
       
       <key>RunAtLoad</key>
       <true/>
       
       <key>KeepAlive</key>
       <true/>
       
       <key>StandardErrorPath</key>
       <string>/tmp/ttyd.err</string>
       
       <key>StandardOutPath</key>
       <string>/tmp/ttyd.out</string>
   </dict>
   </plist>
   ```
   
   **Important**: Replace `YOUR_USERNAME` with your actual username!

3. **Load the launch agent**
   ```bash
   launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist
   ```

4. **Verify it's running**
   ```bash
   # Check if process is running
   ps aux | grep ttyd
   
   # Test in Safari
   # Navigate to: http://100.x.x.x:7681
   ```

5. **Management commands**
   ```bash
   # Stop ttyd
   launchctl unload ~/Library/LaunchAgents/com.ttyd.terminal.plist
   
   # Start ttyd
   launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist
   
   # Restart ttyd
   launchctl unload ~/Library/LaunchAgents/com.ttyd.terminal.plist && \
   launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist
   ```

---

## Customization

### Appearance Options

ttyd supports various themes and settings:

```bash
# Larger font
ttyd -p 7681 -t fontSize=18 tmux attach

# Dark theme (custom colors)
ttyd -p 7681 \
  -t theme='{"background":"#1a1a1a","foreground":"#ffffff"}' \
  tmux attach

# Custom font family
ttyd -p 7681 -t fontFamily='Monaco' tmux attach

# Combine options
ttyd -p 7681 \
  -t fontSize=16 \
  -t fontFamily='Menlo' \
  -t theme='{"background":"#282c34","foreground":"#abb2bf"}' \
  ~/bin/tmux-launcher.sh
```

### Multiple ttyd Instances

Run different sessions on different ports:

```bash
# Claude Code on 7681
ttyd -p 7681 tmux attach -t claude-code

# Experiments on 7682
ttyd -p 7682 tmux attach -t experiments

# System monitoring on 7683
ttyd -p 7683 htop
```

Access via:
- `http://100.x.x.x:7681` - Claude Code
- `http://100.x.x.x:7682` - Experiments  
- `http://100.x.x.x:7683` - System monitor

---

## Security Considerations

### Basic Authentication (Optional)

Add password protection:

```bash
# With username and password
ttyd -p 7681 -c username:password tmux attach
```

Update the launch agent if using auth:

```xml
<array>
    <string>/opt/homebrew/bin/ttyd</string>
    <string>-p</string>
    <string>7681</string>
    <string>-c</string>
    <string>username:password</string>
    <!-- rest of arguments... -->
</array>
```

**Note**: Since you're using Tailscale (encrypted private network), authentication is optional. Your Mac is only accessible to your devices.

---

## Safari Optimization (iPhone)

### Make it Feel Like a Native App

1. **Add to Home Screen**
   - In Safari, navigate to `http://100.x.x.x:7681`
   - Tap Share button
   - Scroll down, tap "Add to Home Screen"
   - Name it "Mac Terminal" or "Claude Code"
   - Tap "Add"

2. **Result**: An app icon that launches directly into your terminal!

### Safari Tips

- **Pinch to zoom**: If text is too small
- **Tap to focus**: Keyboard appears
- **Copy text**: Long press on terminal output
- **Paste**: Long press in terminal, select "Paste"
- **Full screen**: Tap the ᴀA button in URL bar → "Hide Toolbar"

---

## Usage Patterns

### When to use ttyd vs Termius?

**Use ttyd (browser) for**:
- 📖 Reading long outputs
- 📋 Copy/paste operations
- 👀 Visual monitoring
- 🎨 Better colors and fonts
- 📱 Quick checks without opening an app

**Use Termius for**:
- ⚡ Quick commands
- 🔑 SSH key management
- 📦 Saved snippets and commands
- 🖥️ Multiple host management
- 📡 More stable for long sessions

**Best practice**: Use both! 
- ttyd for monitoring and reading
- Termius for active work and management

---

## Troubleshooting

### Can't access ttyd in browser

1. **Check if ttyd is running**
   ```bash
   ps aux | grep ttyd
   ```

2. **Check Tailscale IP**
   ```bash
   # On Mac mini
   ifconfig utun3
   # or
   tailscale ip
   ```

3. **Try restarting ttyd**
   ```bash
   # If using launch agent
   launchctl unload ~/Library/LaunchAgents/com.ttyd.terminal.plist
   launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist
   
   # Manual restart
   pkill ttyd
   ttyd -p 7681 bash
   ```

4. **Check the port**
   ```bash
   lsof -i :7681
   ```

### Browser shows "Connection refused"

- Ensure ttyd is actually running
- Verify you're using the correct Tailscale IP
- Check Tailscale is connected on iPhone

### Terminal appears but is frozen

- Try refreshing the page
- Check tmux session status: `tmux ls`
- Kill the session and reconnect

### Styling issues

```bash
# Try forcing terminal type
ttyd -p 7681 -t terminalType='xterm-256color' tmux attach

# Or set in tmux config
echo "set -g default-terminal 'screen-256color'" >> ~/.tmux.conf
tmux source ~/.tmux.conf
```

---

## Advanced: Multiple Terminals Side-by-Side

Create a dashboard page with multiple terminals:

1. **Create HTML dashboard**
   ```bash
   nano ~/ttyd-dashboard.html
   ```

2. **Add content**:
   ```html
   <!DOCTYPE html>
   <html>
   <head>
       <title>Mac Mini Dashboard</title>
       <style>
           body { margin: 0; padding: 0; display: flex; height: 100vh; }
           iframe { flex: 1; border: none; border-right: 1px solid #333; }
           iframe:last-child { border-right: none; }
       </style>
   </head>
   <body>
       <iframe src="http://100.x.x.x:7681"></iframe>
       <iframe src="http://100.x.x.x:7682"></iframe>
   </body>
   </html>
   ```

3. **Serve with Python**
   ```bash
   cd ~
   python3 -m http.server 8080
   ```

4. **Access**: `http://100.x.x.x:8080/ttyd-dashboard.html`

---

## 🎉 You're Done!

You now have a web-based terminal accessible from Safari! 

### Quick Reference

**Start ttyd manually**:
```bash
ttyd -p 7681 tmux attach -t claude-code
```

**Access from iPhone**:
```
http://100.x.x.x:7681
```

**Restart launch agent**:
```bash
launchctl unload ~/Library/LaunchAgents/com.ttyd.terminal.plist && \
launchctl load ~/Library/LaunchAgents/com.ttyd.terminal.plist
```

---

Next: Check out [usage-guide.md](./usage-guide.md) for daily workflows combining Termius and ttyd!
