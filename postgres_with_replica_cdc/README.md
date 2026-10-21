# Postgres Primary-Replica Setup

Two Postgres instances with streaming replication between them. Good for testing how CDC behaves in multi-node setups or understanding replication mechanics.

## What's running

Three containers:
- **postgres-primary** (port 5434) - main database, accepts writes
- **postgres-replica** (port 5435) - read-only replica, stays in sync via WAL streaming
- **pgadmin** (port 5051) - management UI, pre-configured to connect to both

The replica uses physical replication with a dedicated replication slot (`replica_slot_1`). It starts from a base backup of the primary and then streams changes continuously.

## Initial data

Same as the basic setup - three databases get created on the primary:
- `employees` - employee records from CSV
- `students` - student data from CSV
- `testdb` - empty database

The replica mirrors everything automatically once it's synced up.

## Access points

- Primary DB: `localhost:5434`
- Replica DB: `localhost:5435`
- pgAdmin: `localhost:5051`

Credentials are in `.env.postgres` and `.env.pgadmin`. The replica uses a `replicator` user that gets created automatically on the primary.

## Starting it up

```bash
docker-compose up -d
```

The startup sequence matters:
1. Primary starts and runs init scripts
2. Replica waits for primary to be healthy
3. Replica runs `replica-entrypoint.sh` to create base backup and start streaming
4. pgAdmin starts once both databases are ready

Watch the replica sync:

```bash
docker-compose logs -f postgres-replica
```

## Testing replication

Write to the primary:

```bash
docker exec -it postgres-primary psql -U ccdc -d employees -c "INSERT INTO employees (first_name, last_name) VALUES ('Test', 'User');"
```

Read from the replica:

```bash
docker exec -it postgres-replica psql -U ccdc -d employees -c "SELECT * FROM employees WHERE last_name = 'User';"
```

Should see your new record almost instantly.

## pgAdmin setup

The `pgadmin/servers.json` file pre-configures both servers so they show up automatically when you log in. No manual server setup needed.

## Replication monitoring

Check lag on the replica:

```bash
docker exec -it postgres-replica psql -U ccdc -c "SELECT now() - pg_last_xact_replay_timestamp() AS replication_lag;"
```

Check replication status from the primary:

```bash
docker exec -it postgres-primary psql -U ccdc -c "SELECT * FROM pg_stat_replication;"
```

## Resetting

Wipe everything and start fresh:

```bash
docker-compose down -v
docker-compose up -d
```

The replica will rebuild itself from the primary automatically.

## How the replica works

The `replica-entrypoint.sh` script handles the setup:
1. Checks if data directory is empty
2. Runs `pg_basebackup` to clone the primary
3. Creates `standby.signal` file
4. Configures connection to primary in `postgresql.auto.conf`
5. Starts Postgres in standby mode

After that, it's hands-off - the replica just streams WAL from the primary's replication slot.

## Notes

- The replica is read-only. Try to write to it and you'll get an error.
- If the replica falls too far behind, the primary might start accumulating WAL that it can't clean up. In a real setup you'd monitor this.
- The replication is synchronous by default (`hot_standby=on`), so the replica can serve reads while streaming.
