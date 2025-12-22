#!/bin/bash
backup_dir="/path/to/backup/directory"
source_dir="/habibi"
create_backup() { # Function to create backup.
    mkdir -p "$backup_dir"
    timestamp=$(date +%Y%m%d%H%M%S)
    tar -czf "$backup_dir/habibi_backup_$timestamp.tar.gz" "$source_dir"
}
delete_oldest_backup() { # Function to delete oldest backup of 7 days.
    cd "$backup_dir" || exit
    backup_count=$(ls -1 | grep habibi_backup | wc -l)
    if [ "$backup_count" -gt 7 ]; then
        oldest_backup=$(ls -1t | grep habibi_backup | tail -n 1)
        rm "$oldest_backup"
    fi
}
create_backup
delete_oldest_backup