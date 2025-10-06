#!/bin/bash
# ============================================
# Session Logger for Remote Mac Workspace
# ============================================
# Tracks SSH logins, tmux sessions, and usage metrics
# Logs to: ~/.session-log.csv

LOG_FILE="$HOME/.session-log.csv"
LOG_DIR="$HOME/.session-logs"

# Create log directory and file if they don't exist
mkdir -p "$LOG_DIR"

# Initialize CSV with headers if it doesn't exist
if [ ! -f "$LOG_FILE" ]; then
    echo "timestamp,event_type,username,session_name,client_ip,location,details" > "$LOG_FILE"
fi

# ============================================
# Helper Functions
# ============================================

get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

get_client_ip() {
    # Try to get SSH client IP
    if [ -n "$SSH_CLIENT" ]; then
        echo "$SSH_CLIENT" | awk '{print $1}'
    elif [ -n "$SSH_CONNECTION" ]; then
        echo "$SSH_CONNECTION" | awk '{print $1}'
    else
        echo "local"
    fi
}

get_location() {
    local ip="$1"
    
    # If local connection
    if [ "$ip" = "local" ]; then
        echo "localhost"
        return
    fi
    
    # Check if it's a Tailscale IP (100.x.x.x)
    if [[ "$ip" =~ ^100\. ]]; then
        echo "tailscale-network"
        return
    fi
    
    # Try to get rough location via ipapi (optional, requires internet)
    # Uncomment if you want geolocation (sends IP to external service)
    # local location=$(curl -s "http://ip-api.com/json/$ip" | grep -o '"city":"[^"]*' | cut -d'"' -f4)
    # if [ -n "$location" ]; then
    #     echo "$location"
    # else
    #     echo "unknown"
    # fi
    
    echo "remote"
}

log_event() {
    local event_type="$1"
    local session_name="${2:-}"
    local details="${3:-}"
    
    local timestamp=$(get_timestamp)
    local username="$USER"
    local client_ip=$(get_client_ip)
    local location=$(get_location "$client_ip")
    
    # Escape commas in details
    details="${details//,/;}"
    
    echo "$timestamp,$event_type,$username,$session_name,$client_ip,$location,$details" >> "$LOG_FILE"
}

# ============================================
# Main Logging Functions
# ============================================

log_ssh_login() {
    log_event "ssh_login" "" "SSH connection established"
}

log_ssh_logout() {
    log_event "ssh_logout" "" "SSH connection closed"
}

log_tmux_attach() {
    local session_name="$1"
    log_event "tmux_attach" "$session_name" "Attached to tmux session"
}

log_tmux_new() {
    local session_name="$1"
    log_event "tmux_new" "$session_name" "Created new tmux session"
}

log_tmux_detach() {
    local session_name="$1"
    log_event "tmux_detach" "$session_name" "Detached from tmux session"
}

log_claude_code_start() {
    local session_name="${1:-claude-code}"
    log_event "claude_code_start" "$session_name" "Started Claude Code"
}

log_claude_code_stop() {
    local session_name="${1:-claude-code}"
    log_event "claude_code_stop" "$session_name" "Stopped Claude Code"
}

log_wake_on_lan() {
    log_event "wake_on_lan" "" "Mac woken via WoL"
}

# ============================================
# Command Line Interface
# ============================================

case "${1:-}" in
    login)
        log_ssh_login
        ;;
    logout)
        log_ssh_logout
        ;;
    tmux-attach)
        log_tmux_attach "${2:-unknown}"
        ;;
    tmux-new)
        log_tmux_new "${2:-unknown}"
        ;;
    tmux-detach)
        log_tmux_detach "${2:-unknown}"
        ;;
    claude-start)
        log_claude_code_start "${2:-claude-code}"
        ;;
    claude-stop)
        log_claude_code_stop "${2:-claude-code}"
        ;;
    wake)
        log_wake_on_lan
        ;;
    custom)
        log_event "${2:-custom}" "${3:-}" "${4:-}"
        ;;
    *)
        echo "Usage: $0 {login|logout|tmux-attach|tmux-new|tmux-detach|claude-start|claude-stop|wake|custom} [session_name] [details]"
        echo ""
        echo "Examples:"
        echo "  $0 login"
        echo "  $0 tmux-attach claude-code"
        echo "  $0 custom backup \"Started backup process\""
        exit 1
        ;;
esac

exit 0
