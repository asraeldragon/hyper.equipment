#!/bin/bash
set -euo pipefail
BACKUP_TARBALL="backup-$(date +'%Y-%m-%d_%H-%M').tar.gz"
BACKUP_TARBALL_LOCALPATH="/tmp/$BACKUP_TARBALL"
COMPOSE_DIR=/opt/compose/calckey

# files to copy in
DOCKERENV_FILE="$COMPOSE_DIR/docker.env"
CONFIG_VOLUME="$COMPOSE_DIR/volumes/config"
PG_SERVICE_NAME=db

# rclone parameters
DEST_BACKEND=encrypted
DEST_SUBDIR=hyper.equipment-backups/backups

TEMP_DIR="$(mktemp -d)"

echo "Dumping Postgres..."
time docker-compose --project-directory "$COMPOSE_DIR" exec -T --user postgres "$PG_SERVICE_NAME" \
  pg_dump -U calckey | gzip > "$TEMP_DIR/backup.psql.gz"

echo "Copying files..."
cp -a "$DOCKERENV_FILE" "$TEMP_DIR/"
cp -a "$CONFIG_VOLUME" "$TEMP_DIR/"

echo "Compressing..."
tar -C "$TEMP_DIR" -cvzf "$BACKUP_TARBALL_LOCALPATH" .

echo "Uploading..."
time rclone copyto "$BACKUP_TARBALL_LOCALPATH" "$DEST_BACKEND:$DEST_SUBDIR/$BACKUP_TARBALL"

echo "Cleaning up..."
rm -rf "$TEMP_DIR" "$BACKUP_TARBALL_LOCALPATH"

echo "Done!"
