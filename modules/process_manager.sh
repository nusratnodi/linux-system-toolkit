#!/bin/bash
# Member 3: Processes and users
# Shows running programs, lets you stop them, and lists users.

show_top_processes() {
    header "Top Processes"
    echo -e "${BOLD}By CPU:${RESET}"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6
    echo -e "\n${BOLD}By memory:${RESET}"
    ps -eo pid,user,%cpu,%mem,comm --sort=-%mem | head -n 6
}

search_process() {
    header "Search Process"
    read -rp "Process name: " name
    if [ -z "$name" ]; then
        return
    fi
    echo
    if ! pgrep -a -i "$name"; then
        echo "No running process matches '$name'."
    fi
}

# Starts a harmless background process, so 'Kill a process' can be shown safely
start_test_process() {
    header "Start Test Process"
    sleep 600 > /dev/null 2>&1 &
    success "Started a test process (sleep 600) with PID $!"
    echo "Use 'Kill a process' with this PID to stop it."
    log_action "Started test process $!"
}

kill_process() {
    header "Kill a Process"
    read -rp "PID to kill: " pid
    if ! [[ "$pid" =~ ^[0-9]+$ ]] || ! ps -p "$pid" > /dev/null; then
        error "No process with PID $pid"
        return
    fi

    ps -p "$pid" -o pid,user,comm
    read -rp "Kill this process? (y/n): " answer
    if [ "$answer" != "y" ]; then
        echo "Cancelled."
        return
    fi

    process_name=$(ps -p "$pid" -o comm=)
    if kill "$pid" 2> /dev/null; then
        success "Process $pid ($process_name) stopped."
        log_action "Killed process $pid ($process_name)"
    else
        error "Could not kill $pid. It may belong to another user."
    fi
}

show_users() {
    header "Users"
    echo -e "${BOLD}Logged in now:${RESET}"
    users | tr ' ' '\n' | sort -u | sed 's/^/  /'
    echo -e "\n${BOLD}User accounts on this system:${RESET}"
    # normal users have an ID of 1000 or more in /etc/passwd
    awk -F: '$3 >= 1000 && $3 < 65534 { printf "  %-15s home: %s\n", $1, $6 }' /etc/passwd
    echo -e "\n${BOLD}Your groups:${RESET} $(groups)"
}

process_manager_menu() {
    while true; do
        header "Processes and Users"
        echo "1. Top processes (CPU and memory)"
        echo "2. Search for a process"
        echo "3. Start a test process"
        echo "4. Kill a process"
        echo "5. Users"
        echo "0. Back"
        read -rp "Choose: " choice

        case $choice in
            1) show_top_processes ;;
            2) search_process ;;
            3) start_test_process ;;
            4) kill_process ;;
            5) show_users ;;
            0) return ;;
            *) error "Invalid choice" ;;
        esac
        pause
    done
}
