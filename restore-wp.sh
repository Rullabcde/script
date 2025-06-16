#!/bin/bash

# Warna
GREEN="\e[32m"
NC="\e[0m"

echo -e "${GREEN}=== Restore WordPress & Database ===${NC}"

# Input
read -p "Masukkan nama database yang akan direstore: " DB_NAME
read -p "Masukkan user database: " DB_USER
read -sp "Masukkan password database: " DB_PASS
echo ""
read -p "Masukkan path file backup database (.sql.gz): " SQL_BACKUP_GZ
read -p "Masukkan path file backup WordPress (.zip): " WP_ZIP_FILE
read -p "Masukkan path tujuan restore WordPress: " WP_RESTORE_PATH

# Restore Database
echo -e "${GREEN}Restore database...${NC}"
gunzip -c "$SQL_BACKUP_GZ" | mysql -u "$DB_USER" -p"$DB_PASS" "$DB_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Restore database berhasil${NC}"
else
    echo -e "Restore database gagal"
    exit 1
fi

# Restore WordPress
echo -e "${GREEN}Restore folder WordPress...${NC}"
rm -rf "$WP_RESTORE_PATH"/*
unzip -q "$WP_ZIP_FILE" -d "$WP_RESTORE_PATH-temp"

# Jika hasil ekstraksi berada dalam subfolder, pindahkan isi folder ke tujuan
INNER_DIR=$(find "$WP_RESTORE_PATH-temp" -mindepth 1 -maxdepth 1 -type d)
if [ "$(echo $INNER_DIR | wc -w)" -eq 1 ]; then
    mv "$INNER_DIR"/* "$WP_RESTORE_PATH"
    rm -r "$WP_RESTORE_PATH-temp"
else
    mv "$WP_RESTORE_PATH-temp"/* "$WP_RESTORE_PATH"
    rm -r "$WP_RESTORE_PATH-temp"
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Restore WordPress berhasil ke: $WP_RESTORE_PATH${NC}"
else
    echo -e "Restore WordPress gagal"
    exit 1
fi

echo -e "${GREEN}Restore selesai.${NC}"
