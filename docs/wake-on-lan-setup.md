# Wake-on-LAN Setup Guide

Power on your Mac mini remotely from anywhere using Wake-on-LAN over Tailscale.

## 🎯 What is Wake-on-LAN?

Wake-on-LAN (WoL) allows you to remotely power on a computer that's in sleep mode or completely shut down. This is perfect for:
- Powering on your Mac mini from your iPhone
- Saving energy when not in use
- Starting remote work sessions on-demand

## ⚡ How It Works

1. Your Mac mini goes to sleep or shuts down
2. The network interface stays powered (listening for "magic packet")
3. You send a Wake-on-LAN packet from your iPhone
4. Mac mini wakes up and becomes accessible

## 📋 Prerequisites

- Mac mini with Ethernet connection (required for WoL)
- Router that supports WoL (most modern routers do)
- Tailscale installed and configured (from main setup)

---

## Setup on Mac mini (10 minutes)

### 1. Enable Wake for Network Access

```bash
# Enable Wake-on-LAN
sudo pmset -a womp 1

# Verify it's enabled
pmset -g | grep womp
# Should show: womp 1
```

**Or via GUI**:
1. System Settings → Energy (or Battery on laptops)
2. Options (button at bottom)
3. ✅ Enable "Wake for network access"

### 2. Prevent Deep Sleep

```bash
# Prevent hibernation mode that can't be woken remotely
sudo pmset -a hibernatemode 0

# Prevent disk sleep
sudo pmset -a disksleep 0

# Keep network alive
sudo pmset -a networkoversleep 1

# Verify settings
pmset -g
```

### 3. Get Your Mac's MAC Address

```bash
# Get MAC address of Ethernet interface (usually en0 or en1)
ifconfig en0 | grep ether
# Output: ether XX:XX:XX:XX:XX:XX

# Save this - you'll need it!
# It looks like: a4:83:e7:2b:ff:3c
```

**Or via GUI**:
1. System Settings → Network
2. Select Ethernet (usually en0)
3. Click "Details"
4. Hardware → MAC Address

### 4. Configure Router (Optional but Recommended)

For most reliable WoL, configure your router:

1. **Reserve IP for Mac mini**
   - Router settings → DHCP
   - Reserve IP based on MAC address
   - This ensures consistent IP

2. **Enable WoL forwarding** (if available)
   - Some routers have explicit WoL settings
   - Usually under Advanced → WoL

**For Deco Routers specifically**:
1. Open Deco app
2. Network → Your Mac mini
3. Reserve IP address
4. Enable "Wake on LAN" if available

---

## Setup on iPhone (5 minutes)

### Option 1: Using Termius (Recommended)

Termius has built-in WoL support!

1. **Open Termius**
2. **Edit your Mac mini host**
   - Tap the host
   - Tap "Edit" (top right)
3. **Scroll to "Wake on LAN"**
   - Enable it
   - MAC Address: `XX:XX:XX:XX:XX:XX` (from Mac)
   - Broadcast: Usually leave as default
4. **Save**

**To wake your Mac**:
1. Open Termius
2. Long press on "Mac mini" host
3. Select "Wake on LAN"
4. Wait 30-60 seconds
5. Connect normally

### Option 2: Dedicated WoL App

**Install "Mocha WOL"** (free, works great):

1. App Store → Search "Mocha WOL" → Install
2. Open app → "+"
3. **Add Device**:
   - Name: Mac mini
   - MAC Address: `XX:XX:XX:XX:XX:XX`
   - IP/Host: Your Tailscale IP (100.x.x.x)
   - Port: 9 (default)
4. Save

**To wake**:
1. Open Mocha WOL
2. Tap "Mac mini"
3. Wait 30-60 seconds
4. Connect via Termius

### Option 3: Shortcuts App

Create an iOS Shortcut for one-tap wake:

1. **Shortcuts app** → "+" → New Shortcut
2. **Add Action** → "Run Script Over SSH"
   - Host: YOUR_TAILSCALE_IP
   - User: YOUR_USERNAME
   - Script: `echo "waking"` (or any command)
3. **Add Action** → "Wait" → 60 seconds
4. **Add Action** → "Open App" → Termius
5. **Name it**: "Wake Mac mini"

Add to home screen for quick access!

---

## Wake-on-LAN Over Tailscale (Advanced)

Standard WoL uses broadcast packets on local network. With Tailscale, we need a different approach:

### Method 1: Wake Script on Another Device

If you have another always-on device (Raspberry Pi, NAS, etc.):

1. **Install wakeonlan tool**:
   ```bash
   # On Linux/Pi
   sudo apt-get install wakeonlan
   
   # On Mac
   brew install wakeonlan
   ```

2. **Create wake script**:
   ```bash
   # On the always-on device
   cat > ~/wake-mac.sh << 'EOF'
   #!/bin/bash
   wakeonlan XX:XX:XX:XX:XX:XX
   EOF
   
   chmod +x ~/wake-mac.sh
   ```

3. **Access via SSH**:
   ```bash
   # From iPhone (via Termius)
   ssh always-on-device
   ./wake-mac.sh
   ```

### Method 2: Use Tailscale Subnet Router

Turn another device into a WoL relay:

1. **On always-on device, install Tailscale**
2. **Enable subnet routing**:
   ```bash
   sudo tailscale up --advertise-routes=192.168.1.0/24 --accept-routes
   ```
   (Adjust subnet to match your local network)

3. **Approve in Tailscale admin** (https://login.tailscale.com)

4. **Now WoL works through Tailscale!**

### Method 3: Cloud-based WoL Service

**Use a service like RemoteWOL**:

1. Sign up at https://www.remotewol.com (or similar)
2. Add your Mac mini (MAC address)
3. Access from iPhone browser
4. Send wake packet remotely

---

## Automation Scripts

### Auto-wake on Connection Attempt

Create a script that tries to wake if Mac is asleep:

```bash
# ~/bin/wake-and-connect.sh
#!/bin/bash

TAILSCALE_IP="100.x.x.x"
MAC_ADDRESS="XX:XX:XX:XX:XX:XX"

echo "Checking if Mac mini is awake..."

# Try to ping
if ping -c 1 -W 2 "$TAILSCALE_IP" > /dev/null 2>&1; then
    echo "Mac mini is awake!"
    ssh "$TAILSCALE_IP"
else
    echo "Mac mini appears asleep. Sending wake packet..."
    wakeonlan "$MAC_ADDRESS"
    echo "Waiting 60 seconds for boot..."
    sleep 60
    
    echo "Attempting connection..."
    ssh "$TAILSCALE_IP"
fi
```

### Scheduled Auto-wake

Wake Mac automatically before you typically use it:

```bash
# Add to crontab (on iPhone via a-Shell app or another device)
# Wake Mac mini at 8 AM weekdays
0 8 * * 1-5 wakeonlan XX:XX:XX:XX:XX:XX
```

---

## Energy Settings for Best Results

Optimal Mac mini power settings for WoL:

```bash
# Recommended settings
sudo pmset -a womp 1                    # Wake on network
sudo pmset -a networkoversleep 1        # Keep network alive
sudo pmset -a sleep 30                  # Sleep after 30 min idle
sudo pmset -a displaysleep 10           # Display sleep after 10 min
sudo pmset -a disksleep 0               # Never sleep disk
sudo pmset -a hibernatemode 0           # Disable hibernation
sudo pmset -a powernap 0                # Disable power nap (can interfere)

# View all settings
pmset -g
```

**What each setting does**:
- `womp`: Wake on magic packet (WoL)
- `networkoversleep`: Keep network alive during sleep
- `sleep`: Main system sleep timer
- `disksleep`: Hard drive sleep (0 = never)
- `hibernatemode`: 0 = regular sleep, 3 = hibernation
- `powernap`: Apple's background task feature

---

## Troubleshooting

### Mac won't wake

1. **Check womp is enabled**:
   ```bash
   pmset -g | grep womp
   ```

2. **Verify Ethernet connection**:
   - WoL requires wired connection
   - WiFi WoL is unreliable

3. **Check hibernation mode**:
   ```bash
   pmset -g | grep hibernatemode
   # Should be 0
   ```

4. **Try disabling Power Nap**:
   ```bash
   sudo pmset -a powernap 0
   ```

5. **Reset SMC** (System Management Controller):
   - Shut down Mac mini
   - Unplug power for 15 seconds
   - Plug back in and start

### WoL packet not reaching Mac

1. **Verify MAC address** is correct:
   ```bash
   ifconfig en0 | grep ether
   ```

2. **Check firewall settings**:
   - System Settings → Network → Firewall
   - Allow incoming connections (or at least for WoL)

3. **Router may be blocking**:
   - Check router WoL settings
   - Some routers block broadcast packets

4. **Try different broadcast address**:
   - Default: 255.255.255.255
   - Try: Your subnet broadcast (e.g., 192.168.1.255)

### Works locally but not via Tailscale

This is expected - WoL uses broadcast packets which don't traverse Tailscale.

**Solutions**:
1. Use Method 1 (wake script on local device)
2. Use Method 2 (subnet router)
3. Use Method 3 (cloud service)
4. Keep Mac mini awake when you need it

---

## Testing Wake-on-LAN

### Step-by-step test:

1. **Put Mac to sleep**:
   ```bash
   # Via Terminal
   pmset sleepnow
   
   # Or: Apple menu → Sleep
   ```

2. **Wait 30 seconds**

3. **Send WoL packet** (from iPhone):
   - Use Termius WoL feature
   - Or Mocha WoL app
   - Or SSH to another device and run wakeonlan

4. **Wait 30-60 seconds**

5. **Try connecting**:
   ```bash
   ssh YOUR_TAILSCALE_IP
   ```

6. **Success?** 
   - ✅ Mac wakes and you can connect
   - ❌ Try troubleshooting steps above

---

## Alternative: Never Sleep

If WoL proves problematic, keep Mac awake:

```bash
# Disable all sleep
sudo pmset -a sleep 0
sudo pmset -a displaysleep 0
sudo pmset -a disksleep 0

# Mac mini stays on 24/7
# Uses ~10-15W when idle
```

**Pros**:
- Always accessible
- No wake-up delay
- Simpler setup

**Cons**:
- Higher electricity cost (~$10-15/year)
- More wear on hardware
- Less eco-friendly

---

## Best Practices

1. **Use Ethernet** - WoL requires wired connection
2. **Reserve IP** - Ensure Mac always has same local IP
3. **Test regularly** - WoL settings can reset after updates
4. **Have backup** - Keep another always-on device as relay
5. **Monitor power** - Use smart plug to track power usage
6. **Update firmware** - Keep router firmware updated

---

## Smart Plug Integration (Ultimate Solution)

For 100% reliability, use a smart plug:

**Setup**:
1. Get WiFi smart plug (TP-Link Kasa, WeMo, etc.)
2. Plug Mac mini into smart plug
3. Install manufacturer's iPhone app
4. Configure to turn off when Mac sleeps
5. Turn on remotely when needed

**iOS Shortcuts Integration**:
```
If can't SSH to Mac mini:
  → Turn off smart plug (5 seconds)
  → Turn on smart plug
  → Wait 60 seconds
  → Connect via SSH
```

**Pros**:
- Works even if Mac is completely off
- No WoL configuration needed
- Can force reboot if Mac hangs

**Cons**:
- Costs $15-30 for plug
- Hard power cycle (not graceful)
- Another device to manage

---

## Quick Reference

**Enable WoL**:
```bash
sudo pmset -a womp 1
```

**Get MAC address**:
```bash
ifconfig en0 | grep ether
```

**Send wake packet** (from another Mac/Linux):
```bash
wakeonlan XX:XX:XX:XX:XX:XX
```

**View power settings**:
```bash
pmset -g
```

**Test wake**:
```bash
# Sleep Mac
pmset sleepnow

# Wake remotely (wait 30-60 seconds)
# Connect via SSH
```

---

## Integration with Session Logging

Add WoL events to your session log:

```bash
# In wake script
echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"),wake-on-lan,success" >> ~/.session-log.csv
```

This tracks when you remotely woke the Mac!

---

**Next Steps**:
- Test WoL on your local network first
- Once working, integrate with Tailscale setup
- Consider smart plug for ultimate reliability
- See [usage-guide.md](./usage-guide.md) for daily workflows

WoL gives you complete control over your remote Mac! 🔌⚡
