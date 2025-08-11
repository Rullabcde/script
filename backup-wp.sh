#!/bin/bash

# Timestamp
DATE=$(date +"%d-%b-%Y_%H-%M-%S")

# Konfigurasi
read -p "Masukkan nama database yang akan dibackup: " DB_NAME
read -p "Masukkan user database: " DB_USER
read -sp "Masukkan password database: " DB_PASS
echo ""
read -p "Masukkan path folder WordPress: " WP_PATH
read -p "Masukkan direktori backup: " BACKUP_DIR

# File
LOG="$BACKUP_DIR/backup.log"
SQL_FILE="$BACKUP_DIR/$DB_NAME-$DATE.sql"
ZIP_FILE="$BACKUP_DIR/$DATE.zip"

mkdir -p "$BACKUP_DIR"
echo "Backup WordPress & Database dimulai" | tee -a "$LOG"

# Backup Database
if mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$SQL_FILE"; then
    echo "[$(date)] Backup database berhasil" >> "$LOG"
else
    echo "[$(date)] Backup database gagal" >> "$LOG"
    exit 1
fi

# Backup WordPress
if zip -r "$ZIP_FILE" "$WP_PATH" > /dev/null 2>&1; then
    echo "[$(date)] Backup ZIP WordPress berhasil" >> "$LOG"
else
    echo "[$(date)] Backup ZIP WordPress gagal" >> "$LOG"
    exit 1
fi

echo "[$(date)] Backup selesai disimpan di $BACKUP_DIR" >> "$LOG"
