#!/bin/bash
# ============================================
# Session Log Analyzer
# ============================================
# Analyzes session logs and displays usage statistics

LOG_FILE="$HOME/.session-log.csv"

# Check if log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "❌ No session log found at: $LOG_FILE"
    echo "Run some sessions first to generate logs!"
    exit 1
fi

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ============================================
# Analysis Functions
# ============================================

show_header() {
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}    Remote Workspace Session Analytics${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

show_summary() {
    echo -e "${CYAN}${BOLD}📊 Summary Statistics${NC}"
    echo ""
    
    # Total events
    local total_events=$(tail -n +2 "$LOG_FILE" | wc -l | xargs)
    echo -e "  ${BOLD}Total Events:${NC} $total_events"
    
    # Date range
    local first_date=$(tail -n +2 "$LOG_FILE" | head -1 | cut -d',' -f1 | cut -d'T' -f1)
    local last_date=$(tail -n +2 "$LOG_FILE" | tail -1 | cut -d',' -f1 | cut -d'T' -f1)
    echo -e "  ${BOLD}Date Range:${NC} $first_date to $last_date"
    
    # SSH Logins
    local ssh_logins=$(tail -n +2 "$LOG_FILE" | grep -c "ssh_login")
    echo -e "  ${BOLD}SSH Logins:${NC} $ssh_logins"
    
    # tmux sessions created
    local tmux_created=$(tail -n +2 "$LOG_FILE" | grep -c "tmux_new")
    echo -e "  ${BOLD}tmux Sessions Created:${NC} $tmux_created"
    
    # Claude Code starts
    local claude_starts=$(tail -n +2 "$LOG_FILE" | grep -c "claude_code_start")
    echo -e "  ${BOLD}Claude Code Sessions:${NC} $claude_starts"
    
    echo ""
}

show_recent_activity() {
    local count="${1:-10}"
    echo -e "${GREEN}${BOLD}📅 Recent Activity (Last $count events)${NC}"
    echo ""
    
    echo -e "  ${BOLD}Time                Event              Session          Location${NC}"
    echo "  ────────────────────────────────────────────────────────────────────────"
    
    tail -n +2 "$LOG_FILE" | tail -$count | while IFS=',' read -r timestamp event_type username session_name client_ip location details; do
        # Format timestamp (show time only)
        local time=$(echo "$timestamp" | cut -d'T' -f2 | cut -d'Z' -f1 | cut -d':' -f1-2)
        local date=$(echo "$timestamp" | cut -d'T' -f1)
        
        # Color code event types
        local event_color="$NC"
        case "$event_type" in
            ssh_login) event_color="$GREEN" ;;
            ssh_logout) event_color="$RED" ;;
            tmux_new) event_color="$CYAN" ;;
            tmux_attach) event_color="$BLUE" ;;
            claude_code_start) event_color="$MAGENTA" ;;
            *) event_color="$NC" ;;
        esac
        
        printf "  %s %s ${event_color}%-18s${NC} %-16s %-20s\n" \
            "$date" "$time" "$event_type" "${session_name:--}" "${location:--}"
    done
    
    echo ""
}

show_session_breakdown() {
    echo -e "${YELLOW}${BOLD}📂 Session Breakdown${NC}"
    echo ""
    
    echo -e "  ${BOLD}Session Name               Times Used    Last Used${NC}"
    echo "  ────────────────────────────────────────────────────────────────"
    
    # Get unique session names and their counts
    tail -n +2 "$LOG_FILE" | cut -d',' -f4 | grep -v '^$' | sort | uniq -c | sort -rn | while read -r count session; do
        # Get last used date for this session
        local last_used=$(tail -n +2 "$LOG_FILE" | grep ",$session," | tail -1 | cut -d',' -f1 | cut -d'T' -f1)
        printf "  %-26s %-13s %s\n" "$session" "$count times" "$last_used"
    done
    
    echo ""
}

show_location_stats() {
    echo -e "${BLUE}${BOLD}🌍 Connection Locations${NC}"
    echo ""
    
    echo -e "  ${BOLD}Location                   Connections${NC}"
    echo "  ────────────────────────────────────────────────"
    
    tail -n +2 "$LOG_FILE" | cut -d',' -f6 | sort | uniq -c | sort -rn | while read -r count location; do
        printf "  %-26s %s\n" "$location" "$count times"
    done
    
    echo ""
}

show_event_timeline() {
    echo -e "${MAGENTA}${BOLD}📈 Daily Activity Timeline${NC}"
    echo ""
    
    echo -e "  ${BOLD}Date           SSH Logins    tmux Sessions    Claude Code${NC}"
    echo "  ─────────────────────────────────────────────────────────────────"
    
    # Get unique dates
    tail -n +2 "$LOG_FILE" | cut -d',' -f1 | cut -d'T' -f1 | sort | uniq | while read -r date; do
        local ssh_count=$(grep "^$date" "$LOG_FILE" | grep -c "ssh_login")
        local tmux_count=$(grep "^$date" "$LOG_FILE" | grep -c "tmux")
        local claude_count=$(grep "^$date" "$LOG_FILE" | grep -c "claude_code")
        
        printf "  %-14s %-13s %-16s %s\n" \
            "$date" "$ssh_count" "$tmux_count" "$claude_count"
    done
    
    echo ""
}

show_raw_log() {
    local count="${1:-20}"
    echo -e "${CYAN}${BOLD}📄 Raw Log (Last $count entries)${NC}"
    echo ""
    
    tail -n $count "$LOG_FILE" | column -t -s','
    echo ""
}

export_to_json() {
    local output_file="${1:-session-log.json}"
    
    echo -e "${BLUE}Exporting to JSON...${NC}"
    
    echo "[" > "$output_file"
    
    local first=true
    tail -n +2 "$LOG_FILE" | while IFS=',' read -r timestamp event_type username session_name client_ip location details; do
        if [ "$first" = true ]; then
            first=false
        else
            echo "," >> "$output_file"
        fi
        
        cat >> "$output_file" << EOF
  {
    "timestamp": "$timestamp",
    "event_type": "$event_type",
    "username": "$username",
    "session_name": "$session_name",
    "client_ip": "$client_ip",
    "location": "$location",
    "details": "$details"
  }
EOF
    done
    
    echo "" >> "$output_file"
    echo "]" >> "$output_file"
    
    echo -e "${GREEN}✅ Exported to: $output_file${NC}"
    echo ""
}

search_logs() {
    local search_term="$1"
    echo -e "${CYAN}${BOLD}🔍 Search Results for: '$search_term'${NC}"
    echo ""
    
    echo -e "  ${BOLD}Timestamp            Event              Session          Details${NC}"
    echo "  ──────────────────────────────────────────────────────────────────────────"
    
    grep -i "$search_term" "$LOG_FILE" | tail -20 | while IFS=',' read -r timestamp event_type username session_name client_ip location details; do
        local time=$(echo "$timestamp" | cut -d'T' -f2 | cut -d'Z' -f1 | cut -d':' -f1-2)
        local date=$(echo "$timestamp" | cut -d'T' -f1)
        
        printf "  %s %s %-18s %-16s %s\n" \
            "$date" "$time" "$event_type" "${session_name:--}" "${details:--}"
    done
    
    echo ""
}

# ============================================
# Main Menu
# ============================================

show_menu() {
    echo -e "${BOLD}Select an option:${NC}"
    echo ""
    echo "  1) Summary Statistics"
    echo "  2) Recent Activity"
    echo "  3) Session Breakdown"
    echo "  4) Connection Locations"
    echo "  5) Daily Timeline"
    echo "  6) View Raw Log"
    echo "  7) Search Logs"
    echo "  8) Export to JSON"
    echo "  9) Full Report (All above)"
    echo "  0) Exit"
    echo ""
    echo -n "Choice: "
}

show_full_report() {
    show_header
    show_summary
    show_recent_activity 15
    show_session_breakdown
    show_location_stats
    show_event_timeline
}

# ============================================
# Command Line Interface
# ============================================

case "${1:-}" in
    summary)
        show_header
        show_summary
        ;;
    recent)
        show_header
        show_recent_activity "${2:-10}"
        ;;
    sessions)
        show_header
        show_session_breakdown
        ;;
    locations)
        show_header
        show_location_stats
        ;;
    timeline)
        show_header
        show_event_timeline
        ;;
    raw)
        show_header
        show_raw_log "${2:-20}"
        ;;
    search)
        show_header
        search_logs "${2:-}"
        ;;
    export)
        export_to_json "${2:-session-log.json}"
        ;;
    report)
        show_full_report
        ;;
    menu)
        # Interactive menu
        while true; do
            clear
            show_header
            show_menu
            read -r choice
            
            case $choice in
                1) clear; show_header; show_summary; read -p "Press Enter to continue..." ;;
                2) clear; show_header; show_recent_activity 20; read -p "Press Enter to continue..." ;;
                3) clear; show_header; show_session_breakdown; read -p "Press Enter to continue..." ;;
                4) clear; show_header; show_location_stats; read -p "Press Enter to continue..." ;;
                5) clear; show_header; show_event_timeline; read -p "Press Enter to continue..." ;;
                6) clear; show_header; show_raw_log 30; read -p "Press Enter to continue..." ;;
                7) 
                    clear
                    show_header
                    echo -n "Enter search term: "
                    read -r term
                    search_logs "$term"
                    read -p "Press Enter to continue..."
                    ;;
                8)
                    clear
                    show_header
                    echo -n "Output filename (default: session-log.json): "
                    read -r filename
                    export_to_json "${filename:-session-log.json}"
                    read -p "Press Enter to continue..."
                    ;;
                9) clear; show_full_report; read -p "Press Enter to continue..." ;;
                0) echo "Goodbye!"; exit 0 ;;
                *) echo "Invalid choice"; sleep 1 ;;
            esac
        done
        ;;
    *)
        echo "Usage: $0 {summary|recent|sessions|locations|timeline|raw|search|export|report|menu}"
        echo ""
        echo "Examples:"
        echo "  $0 summary              - Show summary statistics"
        echo "  $0 recent 20            - Show last 20 activities"
        echo "  $0 search 'claude'      - Search logs for term"
        echo "  $0 export stats.json    - Export to JSON file"
        echo "  $0 report               - Generate full report"
        echo "  $0 menu                 - Interactive menu"
        echo ""
        exit 1
        ;;
esac
