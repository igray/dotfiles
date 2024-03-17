#!/usr/bin/env bash
export RESTIC_CACHE_DIR=/var/cache/restic-backups-work
export RESTIC_PASSWORD_FILE=/home/igray/.restic-password
export RESTIC_REPOSITORY=sftp:igray@192.168.86.10:/media/backup/restic

restic -o sftp.command='ssh igray@192.168.86.10 -i /home/igray/.ssh/restic -s sftp' check --with-cache

unset RESTIC_CACHE_DIR
unset RESTIC_PASSWORD_FILE
unset RESTIC_REPOSITORY
