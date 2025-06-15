#!/bin/bash

# Warna 
GREEN="\e[32m"
NC="\e[0m"

# Timestamp
DATE=$(date +"%Y-%m-%d_%H-%M-%S")

echo -e "${GREEN}=== Backup WordPress dan MySQL ===${NC}"
read -p "Masukkan nama database: " DB_NAME
read -p "Masukkan user database: " DB_USER
read -sp "Masukkan password database: " DB_PASS
echo ""
read -p "Masukkan path folder WordPress [default: /var/www/html/wordpress]: " WP_PATH
WP_PATH=${WP_PATH:-/var/www/html/wordpress}
read -p "Masukkan lokasi folder penyimpanan backup [default: /backup]: " BACKUP_DIR

LOG_FILE="$BACKUP_DIR/backup-log.txt"
BACKUP_DIR=${BACKUP_DIR:-/backup}
SQL_BACKUP_FILE="$BACKUP_DIR/db-$DB_NAME-$DATE.sql"
WP_BACKUP_FILE="$BACKUP_DIR/wp-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

echo -e "${GREEN}Memulai proses backup...${NC}"
echo "[$(date)] Backup dimulai" >> "$LOG_FILE"

# Backup database
echo -e "${GREEN}Backup database...${NC}"
mysqldump -u "$DB_USER" -p"$DB_PASS" "$DB_NAME" > "$SQL_BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup database berhasil: $SQL_BACKUP_FILE" >> "$LOG_FILE"
else
    echo -e "Gagal backup database"
    echo "[$(date)] Gagal backup database" >> "$LOG_FILE"
    exit 1
fi

# Backup folder WordPress
echo -e "${GREEN}Backup folder WordPress...${NC}"
tar -czf "$WP_BACKUP_FILE" -C "$WP_PATH" .

if [ $? -eq 0 ]; then
    echo "[$(date)] Backup WordPress berhasil: $WP_BACKUP_FILE" >> "$LOG_FILE"
else
    echo -e "Gagal backup folder WordPress"
    echo "[$(date)] Gagal backup folder WordPress" >> "$LOG_FILE"
    exit 1
fi

echo -e "${GREEN}Backup selesai. File disimpan di: $BACKUP_DIR${NC}"
echo "[$(date)] Backup selesai\n" >> "$LOG_FILE"
