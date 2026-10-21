# Postgres CDC Setups

This repository has two Docker Compose setups for trying out Postgres change data capture (CDC).

## Setups

- [postgres_with_basic_cdc](./postgres_with_basic_cdc/): A single Postgres server with WAL settings for CDC and pgAdmin for database management.
- [postgres_with_replica_cdc](./postgres_with_replica_cdc/): A Postgres primary and replica connected with streaming replication. Use this setup to try CDC against a replicated database or observe replication lag.

Each setup has its own README with its ports, database details, and instructions.

## Start a setup

Choose one of the folders, change into it, and start the containers:

```bash
docker-compose up -d
```

The two setups are independent. Start only the one you want to use.

## Sample data

Both setups initialize these databases on first start:

- `employees` and `students`, populated from CSV files
- `testdb`, created empty for testing

The CSV files are in each setup's `data/` folder.

## Reset a setup

From the setup's folder, stop the containers and remove their volumes:

```bash
docker-compose down -v
```

Removing the volumes deletes the database data. The next `up` will initialize the databases again.
