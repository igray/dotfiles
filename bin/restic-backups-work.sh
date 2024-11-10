#!/usr/bin/env bash

HOME_SERVER=192.168.86.10
#HOME_SERVER=home.igster.org

export RESTIC_CACHE_DIR=/var/cache/restic-backups-work
export RESTIC_PASSWORD_FILE=/home/igray/.restic-password
export RESTIC_REPOSITORY="sftp:igray@$HOME_SERVER:/media/backup/restic"

restic -o sftp.command="ssh igray@$HOME_SERVER -i /home/igray/.ssh/restic -s sftp" "$@"

unset RESTIC_CACHE_DIR
unset RESTIC_PASSWORD_FILE
unset RESTIC_REPOSITORY
