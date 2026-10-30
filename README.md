# Linux System Toolkit

A menu-driven Bash program to check the system, manage files and control processes, all from one place.
It only uses standard Linux commands, so there is nothing to install.

## How to run

```
chmod +x toolkit.sh
./toolkit.sh
```

Pick a number in each menu. `0` goes back.

## Features

**1. System information** (Member 1, `modules/system_info.sh`)
- System overview: hostname, user, OS, kernel version, uptime
- CPU and memory: CPU model, cores, load average, RAM usage
- Disk usage, with a warning when a disk is 80% full or more
- Network: IP addresses, network interfaces, internet check
- Saves a full report to a text file in `reports/`

**2. File manager** (Member 2, `modules/file_manager.sh`)
- Search files by name
- Show the 10 largest files in a folder
- Count files by type (txt, jpg, pdf…)
- Back up a folder into a compressed `.tar.gz` file in `backups/`
- Restore a backup into `restored/`

**3. Processes and users** (Member 3, `modules/process_manager.sh`)
- Top processes by CPU and by memory
- Search for a running process
- Start a harmless test process, so killing a process can be shown safely
- Kill a process by PID (asks for confirmation first)
- Show logged-in users, user accounts and your groups

**Activity log** (shared): every important action (backup, restore, kill, report) is saved to `toolkit.log`
with the date and user. You can view it from the main menu.

## Project structure

```
linux-system-toolkit/
├── toolkit.sh                 Main menu (shared)
└── modules/
    ├── common.sh              Colors, headers, logging (shared)
    ├── system_info.sh         Member 1
    ├── file_manager.sh        Member 2
    └── process_manager.sh     Member 3
```

These folders are created automatically when used: `reports/`, `backups/`, `restored/` and the file `toolkit.log`.

## Linux concepts used

| Concept | Where |
|---|---|
| Variables, functions, `if`, `while`, `case`, `for` | Every file |
| Reading user input (`read`) | Every menu |
| Pipes (`\|`) and redirection (`>`, `>>`, `2> /dev/null`) | Report saving, file types, logging |
| Text processing: `grep`, `sed`, `awk`, `cut`, `tr`, `sort`, `uniq`, `head`, `tail`, `wc` | All modules |
| System info: `uname`, `hostname`, `uptime`, `lscpu`, `nproc`, `free`, `df`, `ip`, `ping` | Member 1 |
| The `/proc` and `/etc` files: `/proc/loadavg`, `/etc/os-release`, `/etc/passwd` | Members 1 and 3 |
| Files: `find`, `du`, `tar`, `realpath`, `numfmt` | Member 2 |
| Processes: `ps`, `pgrep`, `kill`, background jobs (`&`, `$!`) | Member 3 |
| Users and permissions: `whoami`, `users`, `groups`, user IDs | Member 3 |
| Splitting code into files with `source` | `toolkit.sh` |

## Suggested demo for the showcase

1. **Member 1:** System overview, then Disk usage, then save a report and open the file with `cat`.
2. **Member 2:** Back up a folder, show the `.tar.gz` file, then restore it and show it came back.
3. **Member 3:** Start a test process, find it with Search, then kill it. Show that killing PID 1
   (owned by root) is refused.
4. **Everyone:** Open the Activity log to show everything that was done.
