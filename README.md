# Secure AI-Enhanced Home Infrastructure

A distributed home lab environment demonstrating security monitoring, AI-powered log analysis, and remote development capabilities. Built to explore the intersection of infrastructure security, machine learning, and systems architecture.

## 🎯 Project Overview

This project showcases a multi-tier home infrastructure with:
- **Security-first architecture** with zero-trust networking
- **Remote development workflows** optimized for asynchronous work
- **Persistent sessions** that survive disconnections and power cycles
- **Comprehensive session logging** and usage analytics
- **Planned: On-premises AI inference** for log analysis and monitoring
- **Planned: Distributed security monitoring** across multiple devices

**Key Differentiator:** Combines practical remote access infrastructure (currently working) with plans for local AI inference, demonstrating edge computing principles and data privacy best practices without reliance on cloud APIs.

## 🏗️ System Architecture

### Current Architecture (Phase 1 - ✅ Implemented)

```
                    ┌─────────────────┐
                    │   iPhone/iPad   │
                    │ (Remote Client) │
                    └────────┬────────┘
                             │
                    Tailscale VPN
                   (Encrypted Mesh)
                             │
                    ┌────────┴────────┐
                    │    Mac mini     │
                    │  (Main Host)    │
                    │                 │
                    │ • SSH Server    │
                    │ • tmux          │
                    │ • Session Log   │
                    │ • File Sync     │
                    │ • VNC Server    │
                    │ • Wake-on-LAN   │
                    └─────────────────┘
```

### Future Architecture (Phases 2-4 - 📋 Planned)

```
                    ┌─────────────────┐
                    │   iPhone/iPad   │
                    │ (Remote Client) │
                    └────────┬────────┘
                             │
                    Tailscale VPN (Encrypted Mesh Network)
                             │
        ┌────────────────────┼────────────────────┐
        │                    │                    │
        ▼                    ▼                    ▼
┌───────────────┐   ┌──────────────┐    ┌─────────────┐
│  Home Server  │   │   Mac mini   │    │  Pi-hole    │
│  (Main Host)  │◄──┤ (AI Inference)│    │ (DNS/Firewall)
│               │   │               │    │             │
│ • SSH Server  │   │ • LLM Runtime │    │ • Ad Block  │
│ • tmux        │   │ • LM Studio/  │    │ • Malware   │
│ • Log Collector│  │   Ollama      │    │   Blocking  │
│ • File Sync   │   │ • API Server  │    │ • Query Log │
│ • Monitoring  │   │ • Analysis    │    │ • Analytics │
└───────────────┘   └──────────────┘    └─────────────┘
        │                   │                   │
        └───────────────────┴───────────────────┘
                    LAN (192.168.x.x)
```

## ✨ Current Features (Phase 1 - Production Ready)

### 🔒 Secure Remote Access
- ✅ **Zero-trust networking** via Tailscale (WireGuard-based)
- ✅ **SSH hardening** with key-based auth and best practices
- ✅ **No port forwarding** required - all access via encrypted VPN
- ✅ **Mobile-first interface** optimized for iPhone/iPad via Termius

### 🔧 Persistent Development Environment
- ✅ **tmux integration** - sessions persist through disconnections
- ✅ **Claude Code support** - monitor long-running AI tasks remotely
- ✅ **Screen sharing/VNC** - visual access to GUI applications
- ✅ **Cross-device file sync** - iCloud/Dropbox integration

### 📊 Session Logging & Analytics
- ✅ **Automated usage tracking** - monitor SSH, tmux, and Claude Code sessions
- ✅ **Session analytics** - generate reports on usage patterns
- ✅ **Location tracking** - identify connection sources (Tailscale vs local)
- ✅ **Export capabilities** - JSON export for further analysis

### 💤 Power Management
- ✅ **Wake-on-LAN** - remotely power on Mac mini from sleep
- ✅ **Energy efficiency** - sleep when not in use, wake on demand
- ✅ **Multiple wake methods** - iOS Shortcuts, command line, automation

### 🌐 Optional Enhancements
- ✅ **Web-based terminal (ttyd)** - browser access as alternative to SSH
- ✅ **Template configurations** - ready-to-customize SSH, tmux, and service configs

## 📋 Planned Features (Roadmap)

### 🤖 Phase 2: AI Integration (In Planning)
- [ ] **On-premises LLM deployment** on Mac mini (Ollama/LM Studio)
- [ ] **Automated log analysis** via scheduled batch processing
- [ ] **Natural language queries** for system status
- [ ] **Anomaly detection** in session logs
- [ ] **Security event summarization**
- [ ] **Model options**: Llama 3.2, Mistral, or other local models

### 🔐 Phase 3: Enhanced Security Monitoring (Future)
- [ ] **Pi-hole DNS filtering** for network-wide ad/malware blocking
- [ ] **Centralized logging** from all devices
- [ ] **fail2ban integration** - automatic threat blocking
- [ ] **Real-time alerting** for suspicious activity
- [ ] **Network traffic monitoring**

### 📈 Phase 4: Advanced Observability (Future)
- [ ] **System health dashboard** - CPU, RAM, disk, network metrics
- [ ] **Security event timeline** - visualize access patterns
- [ ] **AI analysis reports** - periodic system activity summaries
- [ ] **Custom anomaly detection models**

### 🚀 Phase 5: Infrastructure Expansion (Future)
- [ ] **Multi-machine distributed system**
- [ ] **vLLM for real-time analysis** (high-throughput option)
- [ ] **Web-based management dashboard**
- [ ] **Integration with threat intelligence feeds**
- [ ] **Automated incident response**

## 🛠️ Tech Stack

### Core Infrastructure (Implemented)
- **VPN**: Tailscale (WireGuard-based mesh networking)
- **Terminal Multiplexer**: tmux
- **SSH Server**: OpenSSH (hardened configuration)
- **OS**: macOS (Mac mini)
- **Remote Access**: Termius (iOS), native SSH clients
- **Screen Sharing**: macOS built-in VNC, Jump Desktop
- **File Sync**: iCloud Drive, Dropbox

### Monitoring & Logging (Implemented)
- **Session Tracking**: Custom bash scripts (session-logger.sh)
- **Analytics**: Log analysis tools (analyze-logs.sh)
- **Wake-on-LAN**: macOS system utilities + iOS Shortcuts

### Planned AI/ML Components
- **LLM Runtime**: Ollama / LM Studio (planned)
- **Model**: Llama 3.2 (3B/8B) or Mistral 7B (planned)
- **API**: FastAPI/Flask for LLM endpoint (planned)
- **Scheduling**: cron jobs for batch analysis (planned)

### Planned Security Components
- **DNS/Firewall**: Pi-hole (planned)
- **Intrusion Prevention**: fail2ban (planned)
- **Log Aggregation**: Centralized syslog (planned)
- **Network Monitoring**: tcpdump, Wireshark (planned)

## 📁 Project Structure

```
remote-access-infrastructure/
├── README.md                          # This file - project overview
├── QUICKSTART.md                      # 30-minute basic setup guide
├── INDEX.md                           # Complete navigation guide
├── PORTFOLIO.md                       # Skills showcase for employers
├── GITHUB_SETUP.md                    # Safe publishing guide
├── LICENSE                            # MIT license
├── .gitignore                         # Security - no secrets committed
│
├── docs/
│   ├── setup-guide.md                # Complete step-by-step installation
│   ├── usage-guide.md                # Daily workflows and commands
│   ├── configuration.md              # All configuration options
│   ├── troubleshooting.md            # Common issues and solutions
│   ├── ttyd-setup.md                 # Web terminal setup (optional)
│   ├── wake-on-lan-setup.md          # Remote power-on configuration
│   └── session-logging.md            # Usage tracking and analytics
│
├── examples/
│   ├── session-logger.sh             # ✅ Working usage tracker
│   ├── analyze-logs.sh               # ✅ Working analytics tool
│   ├── ssh_config.template           # SSH client configuration
│   └── ttyd-launch-agent.template    # Auto-start web terminal
│
└── (planned directories)
    ├── configs/                       # Planned: system configs
    ├── scripts/ai/                    # Planned: AI analysis scripts
    ├── scripts/monitoring/            # Planned: security monitoring
    └── data/                          # Planned: logs and analysis output
```

## 🚀 Quick Start

### Prerequisites
- Mac mini (or any Mac) with macOS
- iPhone/iPad with Termius app
- Tailscale account (free tier sufficient)
- 30 minutes for basic setup

### Basic Setup (Phase 1 - Working Now)

```bash
# 1. Install Tailscale on both Mac mini and iPhone
# Download from: https://tailscale.com/download

# 2. Enable Remote Login on Mac mini
sudo systemsetup -setremotelogin on

# 3. Configure tmux (see docs/setup-guide.md)

# 4. Set up session logging
chmod +x examples/session-logger.sh
chmod +x examples/analyze-logs.sh

# 5. Connect via Termius app from iPhone
# Use your Tailscale IP address

# 6. Start a tmux session
tmux new -s claude-dev
```

See [QUICKSTART.md](./QUICKSTART.md) for the complete 30-minute setup guide.

See [docs/setup-guide.md](./docs/setup-guide.md) for detailed configuration.

## 📱 Remote Development Workflow

### Typical Use Case: Long-Running Claude Code Tasks

1. **Start session** remotely via Termius:
   ```bash
   tmux new -s claude-dev
   claude-code "Build a REST API with authentication"
   ```

2. **Detach and go mobile**: Press `Ctrl+B`, then `D`
   - Session continues running on Mac mini
   - You can close Termius, turn off iPhone, etc.

3. **Check in later** from anywhere:
   ```bash
   tmux attach -t claude-dev
   # Review progress, respond to prompts, approve changes
   ```

4. **View analytics**:
   ```bash
   ./examples/analyze-logs.sh report
   # See usage patterns, session history, connection stats
   ```

5. **Wake Mac remotely** if it went to sleep:
   - Use iOS Shortcuts app
   - Or command line: `wakeonlan [MAC_ADDRESS]`

## 🎓 Skills Demonstrated

This project showcases competencies relevant to modern infrastructure and security roles:

### Technical Skills (Current Implementation)
- ✅ **Systems Architecture**: Secure remote access design
- ✅ **Network Security**: VPN configuration, zero-trust networking
- ✅ **macOS Administration**: SSH hardening, service management
- ✅ **Shell Scripting**: Bash automation for logging and analytics
- ✅ **Remote Operations**: Asynchronous workflows, persistent sessions
- ✅ **Documentation**: Comprehensive technical writing (75,000+ words)

### Planned Technical Skills (Roadmap)
- 🔄 **AI/ML Integration**: On-premises LLM deployment and inference
- 🔄 **Security Monitoring**: Log analysis, intrusion detection
- 🔄 **Infrastructure as Code**: Automated deployment scripts
- 🔄 **Distributed Systems**: Multi-machine coordination
- 🔄 **DNS Security**: Pi-hole deployment and configuration

### Soft Skills
- ✅ **Problem Solving**: End-to-end solution design for real needs
- ✅ **Self-Learning**: Independent research and implementation
- ✅ **Security Mindset**: Proactive threat modeling and defense-in-depth
- ✅ **Project Planning**: Clear roadmap with phased implementation

### Relevant for Roles In
- 🎯 **DevOps / Platform Engineer**
- 🎯 **Site Reliability Engineer (SRE)**
- 🎯 **Security Engineer** (with AI/ML focus)
- 🎯 **Systems Administrator**
- 🎯 **Cloud/Edge Computing Engineer**
- 🎯 **AI/ML Infrastructure Engineer**

## 📊 Current Project Metrics

### Implemented (Phase 1)
- **Uptime**: Persistent sessions survive disconnections
- **Access Methods**: 3 (SSH, ttyd web terminal, VNC)
- **Documentation**: 75,000+ words across 8 guides
- **Working Scripts**: 2 (session logging + analytics)
- **Setup Time**: 30 minutes (basic) to 2 hours (complete)
- **Security**: Zero-trust VPN, no exposed ports

### Session Analytics Example Output

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    Remote Workspace Session Analytics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary Statistics

  Total Events: 127
  Date Range: 2025-10-01 to 2025-10-15
  SSH Logins: 45
  tmux Sessions Created: 23
  Claude Code Sessions: 18

📅 Recent Activity (Last 10 events)

  Time                Event              Session          Location
  ────────────────────────────────────────────────────────────────
  2025-10-15 14:23   claude_code_start  claude-dev       tailscale
  2025-10-15 09:47   tmux_attach        claude-dev       tailscale
  2025-10-15 08:15   ssh_login          -                tailscale
  ...
```

## 🔄 Development Roadmap

### ✅ Phase 1: Core Infrastructure (Complete)
- [x] Tailscale VPN setup
- [x] SSH hardening and key-based auth
- [x] tmux configuration and integration
- [x] Remote access workflows (iPhone/Termius)
- [x] Session logging and analytics
- [x] Wake-on-LAN configuration
- [x] VNC/Screen sharing setup
- [x] Comprehensive documentation

### 📋 Phase 2: AI Integration (In Planning)
- [ ] Research and select LLM (Llama 3.2 vs Mistral)
- [ ] Install and configure Ollama/LM Studio on Mac mini
- [ ] Develop log analysis scripts
- [ ] Create API endpoint for remote queries
- [ ] Implement scheduled batch processing
- [ ] Build natural language query interface
- [ ] Performance testing and optimization

### 🔮 Phase 3: Security Monitoring (Future)
- [ ] Deploy Pi-hole on Raspberry Pi
- [ ] Configure centralized logging (syslog)
- [ ] Install and configure fail2ban
- [ ] Set up basic alerting system
- [ ] Implement network traffic monitoring
- [ ] Create security event dashboard

### 🚀 Phase 4: Advanced Features (Future)
- [ ] Real-time log analysis (vLLM)
- [ ] Web-based management dashboard
- [ ] Custom anomaly detection models
- [ ] Automated incident response
- [ ] Integration with threat intelligence
- [ ] Multi-machine distributed architecture

### 🎯 Phase 5: Optimization & Polish (Future)
- [ ] Performance tuning across all systems
- [ ] Cost/resource analysis and optimization
- [ ] Documentation improvements and updates
- [ ] Community feedback integration
- [ ] Potential open-source contribution

## 📚 Complete Documentation

Comprehensive guides available in `/docs`:

- **[QUICKSTART.md](./QUICKSTART.md)**: Get running in 30 minutes
- **[INDEX.md](./INDEX.md)**: Complete project navigation
- **[PORTFOLIO.md](./PORTFOLIO.md)**: Professional skills showcase
- **[Setup Guide](./docs/setup-guide.md)**: Detailed installation walkthrough
- **[Usage Guide](./docs/usage-guide.md)**: Common workflows and commands
- **[Configuration](./docs/configuration.md)**: All configuration options
- **[Troubleshooting](./docs/troubleshooting.md)**: Common issues and solutions
- **[Session Logging](./docs/session-logging.md)**: Analytics setup and usage
- **[Wake-on-LAN](./docs/wake-on-lan-setup.md)**: Remote power-on guide
- **[ttyd Setup](./docs/ttyd-setup.md)**: Web terminal configuration

## 🤝 Use Cases

### Personal
- ✅ Remote Claude Code development from anywhere
- ✅ Monitor long-running AI tasks asynchronously
- ✅ Safe space to experiment with infrastructure
- 📋 Home network security improvement (with Pi-hole)
- 📋 Learn AI/ML infrastructure practically

### Professional Development
- ✅ Portfolio piece for job applications
- ✅ Demonstrates self-directed learning
- ✅ Shows security-first mindset
- 📋 Hands-on experience with enterprise tools (when complete)
- 📋 Research into AI-powered security monitoring

### Research & Learning
- ✅ Understand remote access best practices
- ✅ Learn terminal multiplexing and persistent sessions
- 📋 Test different LLM models for security use cases
- 📋 Experiment with prompt engineering for log analysis
- 📋 Learn distributed systems architecture

## 🔒 Security Features

### Current Implementation
- **Zero-trust networking**: All connections via Tailscale VPN
- **No exposed ports**: No port forwarding or public-facing services
- **SSH hardening**: Key-based authentication, custom configurations
- **Data privacy**: All logs and data stay on your devices
- **Git security**: `.gitignore` prevents committing secrets
- **Template configs**: Placeholders only, no real credentials

### Planned Enhancements
- **Pi-hole**: DNS-level malware/ad blocking
- **fail2ban**: Automatic IP blocking for threats
- **Centralized logging**: Encrypted log storage
- **Access auditing**: Comprehensive access logs
- **AI security**: Input sanitization, prompt injection protection

## ⚠️ Project Status & Disclaimers

**Current Phase**: Phase 1 Complete ✅ | Phase 2 In Planning 📋

**Last Updated**: October 2025

**Status**:
- Core remote access infrastructure: **Production Ready** ✅
- AI integration features: **Planned** 📋
- Multi-machine architecture: **Future Roadmap** 🔮

### Important Notes

- **Educational Purpose**: This is a learning project and portfolio piece
- **No Warranty**: Use at your own risk - maintain proper backups
- **Home Lab Grade**: Current implementation is personal infrastructure, not enterprise
- **Privacy**: Session logs may contain sensitive information - handle appropriately
- **Honest Roadmap**: AI features are planned, not yet implemented
- **Resource Requirements**: Future AI features will require significant compute resources

## 📄 License

MIT License - See [LICENSE](./LICENSE) for details.

Feel free to use and adapt for your own remote workspace and infrastructure needs.

## 🙏 Acknowledgments

- **Tailscale** for making secure networking accessible
- **Anthropic** for Claude Code and inspiring this remote workflow
- **tmux** maintainers for the excellent terminal multiplexer
- The homelab and self-hosting communities for inspiration
- **Future**: Ollama/LM Studio teams for local LLM inference tools
- **Future**: Pi-hole team for DNS filtering technology

## 📞 Contact & Links

**Autumn Brown**
Email: autumnbrown23@pm.me
GitHub: [github.com/yourusername/remote-access-infrastructure]

---

## 🌟 Why This Project Stands Out

1. **Honest Implementation**: Clear about what's working vs planned
2. **Production Ready Core**: Phase 1 is fully functional and documented
3. **Ambitious Vision**: Roadmap shows technical depth and planning
4. **Security First**: Zero-trust principles from day one
5. **Portfolio Quality**: Professional documentation and presentation
6. **Practical Application**: Solves real remote development needs
7. **Learning Journey**: Demonstrates growth mindset and continuous improvement

---

*Built with ☕ and curiosity about remote development, infrastructure security, and the future intersection of AI and systems administration.*

**Ready to get started?** → [QUICKSTART.md](./QUICKSTART.md)
**Want to explore everything?** → [INDEX.md](./INDEX.md)
**Building your portfolio?** → [PORTFOLIO.md](./PORTFOLIO.md)
