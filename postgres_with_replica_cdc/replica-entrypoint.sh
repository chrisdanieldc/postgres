#!/bin/bash
set -euo pipefail

PGDATA="${PGDATA:-/var/lib/postgresql/data}"
PRIMARY_HOST="${PRIMARY_HOST:-postgres-primary}"
REPLICA_USER="${REPLICA_USER:-replicator}"
REPLICA_PASSWORD="${REPLICATION_PASSWORD:-replicatorpass}"
REPLICA_SLOT="${REPLICA_SLOT:-replica_slot_1}"

until pg_isready -h "$PRIMARY_HOST" -p 5432 -U postgres; do
  echo "Waiting for primary..."
  sleep 2
done

until PGPASSWORD="$REPLICA_PASSWORD" psql -h "$PRIMARY_HOST" -U "$REPLICA_USER" -d postgres -c 'SELECT 1' >/dev/null 2>&1; do
  echo "Waiting for replicator role..."
  sleep 2
done

if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "Taking base backup from primary..."
  rm -rf "${PGDATA:?}/"*
  PGPASSWORD="$REPLICA_PASSWORD" gosu postgres pg_basebackup \
    --host="$PRIMARY_HOST" \
    --username="$REPLICA_USER" \
    --pgdata="$PGDATA" \
    --wal-method=stream \
    --checkpoint=fast \
    --slot="$REPLICA_SLOT" \
    --verbose \
    --progress

  cat >> "$PGDATA/postgresql.auto.conf" <<EOF
primary_conninfo = 'host=${PRIMARY_HOST} port=5432 user=${REPLICA_USER} password=${REPLICA_PASSWORD} application_name=postgres-replica'
primary_slot_name = '${REPLICA_SLOT}'
hot_standby = on
EOF
  chown postgres:postgres "$PGDATA/postgresql.auto.conf"
  gosu postgres touch "$PGDATA/standby.signal"
fi

exec docker-entrypoint.sh postgres \
  -c hot_standby=on \
  -c wal_level=replica \
  -c max_wal_senders=10 \
  -c max_replication_slots=10
