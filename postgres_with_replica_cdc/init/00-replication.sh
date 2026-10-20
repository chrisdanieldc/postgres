#!/bin/bash
set -e

# Role the replica uses to stream WAL from this primary
psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" <<-EOSQL
  CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD '${REPLICATION_PASSWORD}';
  SELECT pg_create_physical_replication_slot('replica_slot_1');
EOSQL

# The default pg_hba.conf does not allow remote replication connections
echo "host replication replicator all scram-sha-256" >> "$PGDATA/pg_hba.conf"