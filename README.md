# 🐳 Docker Stack Volume Backup Script

This script automates backups of Docker stacks by identifying containers labeled with `SDVB=...`, stopping them, archiving their named volumes, and restarting them. It’s designed to work across systems like TrueNAS SCALE and Debian, backing up only Docker-managed volumes (not bind mounts or host paths).

---

## 🔧 What It Does

- **Discovers all running containers** with a `SDVB` label.
- **Groups containers by unique `SDVB=` value** (e.g., `SDVB=Netbox`, `SDVB=Gitea`).
- **Stops containers in each stack** to ensure volume consistency.
- **Identifies named Docker volumes** (ignores bind mounts and host paths).
- **Creates a `.tar` archive** of each stack’s volumes in a specified backup directory.
- **Restarts containers** after backup is complete.

---

## 📦 Backup Format

Each backup file is named:
<StackName>Backup<YYYY-MM-DD>.tar


Example:
Netbox_Backup_2025-10-05.tar

---

## 🗂 Directory Structure

Backups are stored in:

You can change this path by editing the `BACKUP_DIRECTORY` variable in the script.

---

## 🚀 How to Use

🚀 How to Use
Label your containers with SDVB=<StackName> in your Docker Compose or run commands.

Example:
```
labels:
  - SDVB=Netbox
```
Place the script on your host system (e.g., /usr/local/bin/docker_stack_backup.sh).

Make it executable:
```
chmod +x docker_stack_backup.sh
```

Run the script manually:

```
./docker_stack_backup.sh
```

(Optional) Automate with cron:
```
crontab -e
```
```
0 2 * * * /usr/local/bin/docker_stack_backup.sh >> /var/log/docker_backup.log 2>&1
```
