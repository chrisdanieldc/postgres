# Basic Postgres CDC Setup

Single Postgres instance configured for change data capture. If you're getting started with CDC or just need a local database that works with Debezium, this is probably what you want.

## What you get

Two containers: Postgres 17 and pgAdmin. The database runs with `wal_level=logical` so CDC tools can hook into it.

First time you start it, the init scripts create three databases:
- `employees` - pre-loaded with employee records from CSV
- `students` - pre-loaded with student data from CSV
- `testdb` - empty, for whatever you need

The CSV files are in `data/` and get imported automatically. Scripts in `init/` handle the setup - they only run once when the volume is fresh.

## Access

- Database: `localhost:5432`
- pgAdmin: `localhost:5050`

Default credentials are in `.env.postgres` and `.env.pgadmin`.

## Starting up

```bash
docker-compose up -d
```

Check the logs if you want to watch it initialize:

```bash
docker-compose logs -f postgres
```

## Resetting everything

Kill the containers and wipe the volumes:

```bash
docker-compose down -v
docker-compose up -d
```

This forces the init scripts to run again. Useful when you've made a mess of the test data.

## CDC configuration

The Postgres instance is already configured with:
- `wal_level=logical`
- `max_wal_senders=10`
- `max_replication_slots=10`

These settings let you connect up to 10 CDC connectors (like Debezium) without changing anything. Each connector uses one slot and one sender.

If you're connecting Debezium, point it at `localhost:5432` and it should work out of the box.
