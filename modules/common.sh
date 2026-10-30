#!/bin/bash
# Shared helpers used by every module (colors, headers, pause, logging)

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

header() {
    echo -e "\n${CYAN}${BOLD}===== $1 =====${RESET}"
}

success() {
    echo -e "${GREEN}$1${RESET}"
}

error() {
    echo -e "${RED}$1${RESET}"
}

pause() {
    echo
    read -rp "Press Enter to continue..." _
}

# Every important action is written to toolkit.log with the date and user
log_action() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') | $(whoami) | $1" >> "$LOG_FILE"
}
