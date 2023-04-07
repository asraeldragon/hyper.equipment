#!/bin/bash
set -euo pipefail
# COMPOSE_DIR=/opt/compose/calckey
COMPOSE_TWO=/opt/compose/double_calckey

# files to copy in
PG_SERVICE_NAME=db
PG_FILES_LOCATION=volumes/db
DOUBLE_BACKUP_LOCATION=double_postgres.tar.gz

# rclone parameters
DEST_BACKEND=encrypted
DEST_SUBDIR=hyper.equipment-backups/backups

TEMP_DIR="$(mktemp -d)"

if [ ! -f "$DOUBLE_BACKUP_LOCATION" ]; then
  echo "Downloading most recent backup..."
  FILENAME="$(rclone ls "${DEST_BACKEND}:${DEST_SUBDIR}" | tail -n 1 | cut -d' ' -f2)"
  time rclone copyto "${DEST_BACKEND}:${DEST_SUBDIR}/${FILENAME}" "$DOUBLE_BACKUP_LOCATION"
fi

echo "Uncompressing..."
tar -C "$TEMP_DIR" -xf "$DOUBLE_BACKUP_LOCATION" .

echo "Destroying Postgres..."
docker-compose --project-directory "$COMPOSE_TWO" down
rm -rf "${COMPOSE_TWO:?}/${PG_FILES_LOCATION:?}" || true
docker-compose --project-directory "$COMPOSE_TWO" up -d "$PG_SERVICE_NAME"

echo "Waiting for Postgres to come back up..."
times=0
while \
  ! docker-compose --project-directory "$COMPOSE_TWO" exec "$PG_SERVICE_NAME" psql -U calckey calckey -c 'select
1;' > /dev/null && \
  [ $times -lt 30 ]
do
  sleep 1
  (( times = times + 1 ))
done

if [ "$times" == 30 ]; then
  echo "Timed out waiting for postgres to start back up!"
  exit 1
fi

echo "Uploading backup to clean Postgres..."
time gunzip "${TEMP_DIR}/backup.psql.gz" | docker-compose --project-directory "$COMPOSE_TWO" exec -T --user postgres "$PG_SERVICE_NAME" psql -U calckey

echo "Starting Calckey..."
docker-compose --project-directory "$COMPOSE_TWO" up -d

echo "Cleaning up..."
rm -rf "$TEMP_DIR"

echo "Done!"
