#!/bin/bash
# Member 2: File manager
# Searches files, finds what uses space, and makes and restores backups.

BACKUP_DIR="$SCRIPT_DIR/backups"
RESTORE_DIR="$SCRIPT_DIR/restored"

# Ask for a folder and store it in $folder (Enter = home folder)
ask_folder() {
    read -rp "Folder (press Enter for $HOME): " folder
    folder="${folder:-$HOME}"
    folder="${folder/#\~/$HOME}"  # allow paths like ~/Documents
    if [ ! -d "$folder" ]; then
        error "Folder not found: $folder"
        return 1
    fi
}

search_files() {
    header "Search Files"
    ask_folder || return
    read -rp "Part of the file name: " name

    results=$(find "$folder" -iname "*$name*" 2> /dev/null)
    if [ -z "$results" ]; then
        echo "No files found."
        return
    fi
    echo
    echo "$results" | head -n 20
    success "\nFound $(echo "$results" | wc -l) match(es), showing up to 20"
    log_action "Searched for '$name' in $folder"
}

show_largest_files() {
    header "10 Largest Files"
    ask_folder || return
    echo
    find "$folder" -type f -printf '%s\t%p\n' 2> /dev/null |
        sort -rn |
        head -n 10 |
        numfmt --to=iec --suffix=B --field=1 --delimiter=$'\t'
}

show_file_types() {
    header "File Types"
    ask_folder || return
    echo
    echo "Count  Extension"
    # take the text after the last dot of every file name, then count each one
    find "$folder" -type f -name "*.*" 2> /dev/null |
        sed 's/.*\.//' |
        tr 'A-Z' 'a-z' |
        sort |
        uniq -c |
        sort -rn |
        head -n 10
}

backup_folder() {
    header "Back Up a Folder"
    ask_folder || return
    folder=$(realpath "$folder")
    echo "Folder size: $(du -sh "$folder" 2> /dev/null | cut -f1)"
    read -rp "Create backup? (y/n): " answer
    if [ "$answer" != "y" ]; then
        echo "Cancelled."
        return
    fi

    mkdir -p "$BACKUP_DIR"
    backup_file="$BACKUP_DIR/$(basename "$folder")_$(date +%Y%m%d_%H%M%S).tar.gz"
    if tar -czf "$backup_file" -C "$(dirname "$folder")" "$(basename "$folder")" 2> /dev/null; then
        success "Backup created: $backup_file ($(du -h "$backup_file" | cut -f1))"
    else
        error "Backup finished with warnings (some files could not be read)"
    fi
    log_action "Backed up $folder to $backup_file"
}

restore_backup() {
    header "Restore a Backup"
    backups=("$BACKUP_DIR"/*.tar.gz)
    if [ ! -e "${backups[0]}" ]; then
        echo "No backups yet. Create one first."
        return
    fi

    for i in "${!backups[@]}"; do
        echo "  $((i + 1)). $(basename "${backups[$i]}")  ($(du -h "${backups[$i]}" | cut -f1))"
    done
    read -rp "Choose a backup number: " number
    if ! [[ "$number" =~ ^[0-9]+$ ]] || [ "$number" -lt 1 ] || [ "$number" -gt "${#backups[@]}" ]; then
        error "Invalid choice"
        return
    fi

    backup_file="${backups[$((number - 1))]}"
    mkdir -p "$RESTORE_DIR"
    tar -xzf "$backup_file" -C "$RESTORE_DIR"
    success "Restored into $RESTORE_DIR"
    log_action "Restored $backup_file"
}

file_manager_menu() {
    while true; do
        header "File Manager"
        echo "1. Search files by name"
        echo "2. Show the 10 largest files"
        echo "3. Count files by type"
        echo "4. Back up a folder"
        echo "5. Restore a backup"
        echo "0. Back"
        read -rp "Choose: " choice

        case $choice in
            1) search_files ;;
            2) show_largest_files ;;
            3) show_file_types ;;
            4) backup_folder ;;
            5) restore_backup ;;
            0) return ;;
            *) error "Invalid choice" ;;
        esac
        pause
    done
}
