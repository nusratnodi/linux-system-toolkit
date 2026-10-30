#!/bin/bash
# Member 1: System information
# Shows details about the computer: OS, CPU, memory, disk and network.

REPORT_DIR="$SCRIPT_DIR/reports"

show_system_overview() {
    header "System Overview"
    echo "Hostname : $(hostname)"
    echo "User     : $(whoami)"
    echo "OS       : $(grep PRETTY_NAME /etc/os-release | cut -d '"' -f 2)"
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p)"
    echo "Date     : $(date)"
}

show_cpu_memory() {
    header "CPU and Memory"
    echo "CPU model    : $(lscpu | grep 'Model name' | sed 's/Model name:[[:space:]]*//')"
    echo "CPU cores    : $(nproc)"
    echo "Load average : $(cut -d ' ' -f 1-3 /proc/loadavg)  (last 1, 5, 15 minutes)"
    echo
    free -h
}

show_disk_usage() {
    header "Disk Usage"
    df -h -x tmpfs -x devtmpfs -x squashfs -x efivarfs

    # warn about any disk that is 80% full or more
    df -x tmpfs -x devtmpfs -x squashfs -x efivarfs --output=pcent,target | tail -n +2 |
        while read -r percent mount; do
            if [ "${percent%\%}" -ge 80 ]; then
                echo -e "${YELLOW}Warning: $mount is $percent full${RESET}"
            fi
        done
}

show_network() {
    header "Network"
    echo "IP address(es): $(hostname -I)"
    echo
    ip -brief address
    echo
    if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
        success "Internet: connected"
    else
        error "Internet: not connected"
    fi
}

save_report() {
    mkdir -p "$REPORT_DIR"
    report_file="$REPORT_DIR/report_$(date +%Y%m%d_%H%M%S).txt"

    # run every check and save the output, removing the color codes
    {
        show_system_overview
        show_cpu_memory
        show_disk_usage
        show_network
    } | sed 's/\x1b\[[0-9;]*m//g' > "$report_file"

    success "Report saved to $report_file"
    log_action "Saved system report $report_file"
}

system_info_menu() {
    while true; do
        header "System Information"
        echo "1. System overview"
        echo "2. CPU and memory"
        echo "3. Disk usage"
        echo "4. Network"
        echo "5. Save a full report to a file"
        echo "0. Back"
        read -rp "Choose: " choice

        case $choice in
            1) show_system_overview ;;
            2) show_cpu_memory ;;
            3) show_disk_usage ;;
            4) show_network ;;
            5) save_report ;;
            0) return ;;
            *) error "Invalid choice" ;;
        esac
        pause
    done
}
