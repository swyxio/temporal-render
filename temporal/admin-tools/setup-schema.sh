#!/usr/bin/env bash
# From https://github.com/temporalio/temporal/blob/16bf19dcb5389f491691e650e17d46f027ede67d/docker/auto-setup.sh#L173
TEMPORAL_HOME=${TEMPORAL_HOME:-/etc/temporal}
SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/temporal/versioned
# Create database only if its name is different from the user name. Otherwise PostgreSQL container itself will create database.
if [ "${DBNAME}" != "${POSTGRES_USER}" ]; then
    temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" create --db "${DBNAME}"
fi
temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${DBNAME}" update-schema -d "${SCHEMA_DIR}"
VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/visibility/versioned
if [ "${VISIBILITY_DBNAME}" != "${POSTGRES_USER}" ]; then
    temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" create --db "${VISIBILITY_DBNAME}"
fi
temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${VISIBILITY_DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${VISIBILITY_DBNAME}" update-schema -d "${VISIBILITY_SCHEMA_DIR}"

echo "Database setup complete. Running tail -f /dev/null to keep container running."
tail -f /dev/null
