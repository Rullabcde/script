#!/bin/bash

logfile=/var/log/daily-update.log

log() {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a $logfile
}

log "Start Update & Cleanup..."

if sudo apt update && sudo apt upgrade -y; then
    log "Update and Upgrade Berhasil."
else
    log "ERROR: Update and Upgrade Gagal."
    exit 1
fi

if sudo apt autoremove -y; then
    log "Autoremove Berhasil."
else
    log "WARNING: Autoremove Gagal."
fi

if sudo apt autoclean; then
    log "Autoclean Berhasil."
else
    log "WARNING: Autoclean Gagal."
fi

log "Update & Cleanup Berhasil."