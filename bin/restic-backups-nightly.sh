#!/usr/bin/env bash
export RESTIC_CACHE_DIR=/var/cache/restic-backups-nightly
export RESTIC_PASSWORD_FILE=/etc/nixos/restic-password
export RESTIC_REPOSITORY=s3:s3.amazonaws.com/resticlaptop

set -a
source /etc/nixos/restic.env
set +a

restic check --with-cache

unset RESTIC_CACHE_DIR
unset RESTIC_PASSWORD_FILE
unset RESTIC_REPOSITORY
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION
