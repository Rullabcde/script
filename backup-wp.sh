#!/bin/bash

# Warna
GREEN="\e[32m"
NC="\e[0m"

# Timestamp
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

# Konfigurasi
DB_NAME="wordpress"
DB_USER="userdb"
DB_PASS="passdb"
WP_PATH="/var/www/html/wordpress"
BACKUP_DIR="/backup"
EMAIL="kamu@email.com"

# File
LOG_FILE="$BACKUP_DIR/backup-log.txt"
SQL_BACKUP_FILE="$BACKUP_DIR/db-$DB_NAME-$DATE.sql"
SQL_BACKUP_FILE_GZ="$SQL_BACKUP_FILE.gz"
WP_ZIP_FILE="$BACKUP_DIR/wp-$DATE.zip"
WP_UNCOMPRESSED_DIR="$BACKUP_DIR/wp-uncompressed-$DATE"

# Buat folder backup
mkdir -p "$BACKUP_DIR"

# Kirim email awal
echo "Backup WordPress & Database dimulai: $DATE" | mail -s "Backup DIMULAI - $DATE" "$EMAIL"
echo -e "${GREEN}Backup dimulai...${NC}"
echo "[$(date)] Backup dimulai" >> "$LOG_FILE"

# Backup database
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$SQL_BACKUP_FILE"
if [ $? -eq 0 ]; then
    gzip -c "$SQL_BACKUP_FILE" > "$SQL_BACKUP_FILE_GZ"
    echo "[$(date)] Backup database berhasil: $SQL_BACKUP_FILE + .gz" >> "$LOG_FILE"
else
    echo "[$(date)] GAGAL backup database" >> "$LOG_FILE"
    echo "Backup GAGAL saat export database!" | mail -s "Backup GAGAL - $DATE" "$EMAIL"
    exit 1
fi

# Backup WordPress (zip)
zip -r "$WP_ZIP_FILE" "$WP_PATH" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup ZIP WordPress berhasil: $WP_ZIP_FILE" >> "$LOG_FILE"
else
    echo "[$(date)] GAGAL backup WordPress (ZIP)" >> "$LOG_FILE"
    echo "Backup GAGAL saat zip WordPress!" | mail -s "Backup GAGAL - $DATE" "$EMAIL"
    exit 1
fi

# Backup WordPress (uncompressed)
cp -r "$WP_PATH" "$WP_UNCOMPRESSED_DIR"
if [ $? -eq 0 ]; then
    echo "[$(date)] Backup uncompressed berhasil: $WP_UNCOMPRESSED_DIR" >> "$LOG_FILE"
else
    echo "[$(date)] GAGAL copy WordPress (uncompressed)" >> "$LOG_FILE"
    echo "Backup GAGAL saat copy folder WordPress!" | mail -s "Backup GAGAL - $DATE" "$EMAIL"
    exit 1
fi

# Sukses
echo "[$(date)] Backup selesai di $BACKUP_DIR" >> "$LOG_FILE"
echo -e "${GREEN}Backup selesai. File disimpan di $BACKUP_DIR${NC}"
echo -e "Backup WordPress & Database selesai pada $DATE\n\n- DB: $SQL_BACKUP_FILE\n- DB.gz: $SQL_BACKUP_FILE_GZ\n- WP ZIP: $WP_ZIP_FILE\n- WP Raw: $WP_UNCOMPRESSED_DIR" | mail -s "Backup SELESAI - $DATE" "$EMAIL"
