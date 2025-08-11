#!/bin/bash

DATE=$(date +"%d-%b-%Y_%H-%M-%S")
LOG="/var/log/daily-update.log"

if apt update && apt upgrade -y; then
  echo "[$DATE] Update completed successfully." >> $LOG
else
  echo "[$DATE] Update failed." >> $LOG
  exit 1
fi

if apt autoremove && apt autoclean; then
  echo "[$DATE] Cleanup completed successfully." >> $LOG
else
  echo "[$DATE] Cleanup failed." >> $LOG
  exit 1
fi