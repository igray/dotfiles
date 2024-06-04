#!/usr/bin/env bash
export RESTIC_CACHE_DIR=/var/cache/restic-backups-work
export RESTIC_PASSWORD_FILE=/home/igray/.restic-password
export RESTIC_REPOSITORY=sftp:igray@home.igster.org:/media/backup/restic

restic -o sftp.command='ssh igray@home.igster.org -i /home/igray/.ssh/restic -s sftp' "$@"

unset RESTIC_CACHE_DIR
unset RESTIC_PASSWORD_FILE
unset RESTIC_REPOSITORY
