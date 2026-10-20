# postgres

Simple PostgreSQL setup with pgAdmin for local development.

## What's in here

The compose file spins up two containers - a Postgres 17 instance and pgAdmin. The database is configured for logical replication (needed for change data capture tools like Debezium).

On first startup, it creates three databases (employees, students, and canada) and loads some sample data from CSV files into the first two. The init scripts run automatically when you start with a fresh volume.

pgAdmin is accessible at `localhost:5050` and the database at `localhost:5432`.

## Quick start

```bash
docker-compose up -d
```

To rebuild everything from scratch:

```bash
docker-compose down -v
docker-compose up -d
```

The `-v` flag clears the volumes so the init scripts run again.
