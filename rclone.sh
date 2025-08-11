#!/bin/bash

# Var
DATE=$(date +"%Y%m%d-%H%M%S")
CONTAINER=""
DB_NAME=""
DB_USER=""
DB_PASS=""
BACKUP_DIR=""
LOG="$BACKUP_DIR/backup.log"
SQL_BACKUP="$BACKUP_DIR/$DB_NAME-$DATE.sql"

mkdir -p "$BACKUP_DIR"
echo "[$(date)] Backup dimulai" >> "$LOG"

# Backup Lokal
if docker exec -i "$CONTAINER" mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$SQL_BACKUP"; then
    echo "[$(date)] Backup berhasil" >> "$LOG"
else
    echo "[$(date)] Backup gagal" >> "$LOG"
    exit 1
fi

# Backup GDrive
if rclone copy "$SQL_BACKUP" gdrive:/backup-db/; then
    echo "[$(date)] Backup ke Google Drive berhasil" >> "$LOG"
else
    echo "[$(date)] Backup ke Google Drive gagal" >> "$LOG"
    exit 1
fi

# 5 Terbaru
cd "$BACKUP_DIR" || exit
ls -1t $DB_NAME-*.sql | tail -n +6 | while read -r old_backup; do
    rm -f "$old_backup"
    echo "[$(date)] Backup lama dihapus: $old_backup" >> "$LOG"
done

rclone lsf gdrive:/backup-db --files-only | sort -r | tail -n +6 | while read -r old_backup; do
    rclone delete "gdrive:/backup-db/$old_backup"
    echo "[$(date)] Backup lama dihapus di Google Drive: $old_backup" >> "$LOG"
done