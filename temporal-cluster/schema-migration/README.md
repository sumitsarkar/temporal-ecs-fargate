# Database Migration Task

The Database Schema setup and migration is a necessary step for Temporal to run. The `admin-tools` docker image of Temporal contains two binaries that help with this `temporal-cassandra-tool` and `temporal-sql-tool`. Since our cluster operates on Aurora PostgreSQL, we'd be using the `temporal-sql-tool` to run database schema setup and migrations. It's generally recommended to run this tool only when setting up the cluster for the first time or upgrading Temporal Servers. The following steps need to be taken for any upgrades:

1. Run `temporal-sql-tool` from the new version of `admin-tools` image to migrate the schema.
2. Update images of each of the Temporal services: `frontend`, `history`, `matching` and `worker`.


# What does this subdirectory do?

This subdirectory maintains a lambda that is created to execute `temporal-sql-tool` on Aurora PostgreSQL instance and then destroy the lambda to protect the DB from any accidental migrations.
