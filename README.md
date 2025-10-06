# Remote Mac Mini Workspace

A comprehensive setup for remotely accessing and monitoring Claude Code sessions on a Mac mini from an iPhone, enabling asynchronous development workflows from anywhere.

## 🎯 Project Goals

- **Persistent Sessions**: Keep Claude Code running continuously with tmux
- **Remote Access**: Connect securely from anywhere via Tailscale
- **Mobile-Friendly**: Optimized interface for iPhone monitoring
- **Asynchronous Workflow**: Check in on long-running tasks (10 min - 3 hours) without interruption
- **Full Interaction**: Send text commands and screenshots to Claude Code
- **Visual Access**: VNC for viewing GUI applications and results

## 🏗️ Architecture

```
iPhone (Termius/Safari)
    ↓
Tailscale VPN (secure tunnel)
    ↓
Mac mini
    ├── SSH Server (terminal access)
    ├── tmux (persistent sessions)
    ├── ttyd (web-based terminal - optional)
    ├── Screen Sharing/VNC (visual access)
    └── Shared Folder (screenshot uploads)
```

## ✨ Features

- ✅ Secure zero-configuration VPN with Tailscale
- ✅ Persistent terminal sessions that survive disconnections
- ✅ Multiple interface options (terminal + web GUI)
- ✅ Screenshot sharing workflow
- ✅ Full screen sharing for visual debugging
- ✅ No port forwarding or router configuration needed
- ✅ Wake-on-LAN support for remote power-on
- ✅ Comprehensive session logging and usage analytics

## 📚 Documentation

- [Setup Guide](./docs/setup-guide.md) - Complete step-by-step installation
- [Daily Usage](./docs/usage-guide.md) - Common workflows and tips
- [Configuration](./docs/configuration.md) - Customization and advanced options
- [Troubleshooting](./docs/troubleshooting.md) - Common issues and solutions
- [Wake-on-LAN](./docs/wake-on-lan-setup.md) - Remote power-on setup
- [Session Logging](./docs/session-logging.md) - Usage tracking and analytics

## 🛠️ Tech Stack

- **VPN**: Tailscale (WireGuard-based mesh network)
- **Terminal Multiplexer**: tmux
- **SSH Client (iPhone)**: Termius
- **Web Terminal**: ttyd (optional)
- **Screen Sharing**: macOS built-in + Jump Desktop/RealVNC
- **File Sync**: iCloud Drive / Dropbox

## 🚀 Quick Start

1. Install Tailscale on Mac mini and iPhone
2. Enable Remote Login on Mac mini
3. Configure tmux for persistent sessions
4. Connect via Termius app
5. Start Claude Code in tmux session

See [Setup Guide](./docs/setup-guide.md) for detailed instructions.

## 📱 Use Cases

- Monitor Claude Code's multi-step tasks from anywhere
- Respond to subagent prompts during long operations
- Review code changes and approve actions remotely
- Check deployment status without being at desk
- Share screenshots for Claude Code to process

## 🔒 Security Notes

- All connections encrypted via Tailscale
- No ports exposed to public internet
- SSH keys recommended over passwords
- Tailscale ACLs can restrict device access
- **Important**: Never commit IP addresses, keys, or credentials to git

## 📄 License

MIT License - Feel free to use and adapt for your own remote workspace needs.

## 🤝 Contributing

This is a personal infrastructure project, but suggestions and improvements are welcome!

---

**Note**: This repository contains configuration examples and documentation only. Actual IP addresses, SSH keys, and sensitive configuration values are excluded via `.gitignore`.
