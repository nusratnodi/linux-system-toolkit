#!/bin/bash
# Linux System Toolkit
# Run with:  ./toolkit.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$SCRIPT_DIR/toolkit.log"

source "$SCRIPT_DIR/modules/common.sh"
source "$SCRIPT_DIR/modules/system_info.sh"
source "$SCRIPT_DIR/modules/file_manager.sh"
source "$SCRIPT_DIR/modules/process_manager.sh"

show_log() {
    header "Activity Log (last 15 actions)"
    if [ -f "$LOG_FILE" ]; then
        tail -n 15 "$LOG_FILE"
    else
        echo "Nothing logged yet."
    fi
}

echo -e "${CYAN}${BOLD}"
echo "  _     _                    _____           _ _    _ _   "
echo " | |   (_)_ __  _   ___  __ |_   _|__   ___ | | | _(_) |_ "
echo " | |   | | '_ \| | | \ \/ /   | |/ _ \ / _ \| | |/ / | __|"
echo " | |___| | | | | |_| |>  <    | | (_) | (_) | |   <| | |_ "
echo " |_____|_|_| |_|\__,_/_/\_\   |_|\___/ \___/|_|_|\_\_|\__|"
echo -e "${RESET}"
echo "  Welcome, $(whoami)! Today is $(date '+%A, %d %B %Y')."

while true; do
    header "Main Menu"
    echo "1. System information"
    echo "2. File manager"
    echo "3. Processes and users"
    echo "4. View activity log"
    echo "0. Exit"
    read -rp "Choose: " choice

    case $choice in
        1) system_info_menu ;;
        2) file_manager_menu ;;
        3) process_manager_menu ;;
        4) show_log; pause ;;
        0) echo "Goodbye!"; exit 0 ;;
        *) error "Invalid choice" ;;
    esac
done
