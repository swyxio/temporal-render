#!/bin/bash

set -eux -o pipefail

# customized from https://github.com/temporalio/temporal/blob/master/docker/auto-setup.sh

# === Auto setup defaults ===

DB="${DB:-postgresql}"
SKIP_SCHEMA_SETUP="${SKIP_SCHEMA_SETUP:-false}"

# PostgreSQL
DBNAME="${DBNAME:-temporal}"
VISIBILITY_DBNAME="${VISIBILITY_DBNAME:-temporal_visibility}"
DB_PORT="${DB_PORT:-3306}"

POSTGRES_SEEDS="${POSTGRES_SEEDS:-}"
POSTGRES_USER="${POSTGRES_USER:-}"
POSTGRES_PWD="${POSTGRES_PWD:-}"

# Server setup
TEMPORAL_CLI_ADDRESS="${TEMPORAL_CLI_ADDRESS:-}"

SKIP_DEFAULT_NAMESPACE_CREATION="${SKIP_DEFAULT_NAMESPACE_CREATION:-false}"
DEFAULT_NAMESPACE="${DEFAULT_NAMESPACE:-default}"
DEFAULT_NAMESPACE_RETENTION=${DEFAULT_NAMESPACE_RETENTION:-1}

# === Main database functions ===

validate_db_env() {
    if [ -z "${POSTGRES_SEEDS}" ]; then
        echo "POSTGRES_SEEDS env must be set if DB is ${DB}."
        exit 1
    fi
}

wait_for_postgres() {
    until nc -z "${POSTGRES_SEEDS%%,*}" "${DB_PORT}"; do
        echo 'Waiting for PostgreSQL to startup.'
        sleep 1
    done

    echo 'PostgreSQL started.'
}

wait_for_db() {
    wait_for_postgres
}

setup_postgres_schema() {
    # TODO (alex): Remove exports
    { export SQL_PASSWORD=${POSTGRES_PWD}; } 2> /dev/null

    SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/temporal/versioned
#     # FOR RENDER - skip creating database since we do it externally
#     if [ "${DBNAME}" != "${POSTGRES_USER}" ]; then
#         temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" create --db "${DBNAME}"
#     fi
    echo 'setup_postgres_schema'
    temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${DBNAME}" setup-schema -v 0.0
    echo 'update_postgres_schema'
    temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${DBNAME}" update-schema -d "${SCHEMA_DIR}"
    # attempt to omit this bc render is annoyng about extra db's created
    # VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/visibility/versioned
    # if [ "${VISIBILITY_DBNAME}" != "${POSTGRES_USER}" ]; then
    #     temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" create --db "${VISIBILITY_DBNAME}"
    # fi
    # temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${VISIBILITY_DBNAME}" setup-schema -v 0.0
    # temporal-sql-tool --plugin postgres --ep "${POSTGRES_SEEDS}" -u "${POSTGRES_USER}" -p "${DB_PORT}" --db "${VISIBILITY_DBNAME}" update-schema -d "${VISIBILITY_SCHEMA_DIR}"
}

setup_schema() {
    echo 'Setup PostgreSQL schema.'
    setup_postgres_schema
}

# === Server setup ===

register_default_namespace() {
    echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
    if ! tctl --ns "${DEFAULT_NAMESPACE}" namespace describe; then
        echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
        tctl --ns "${DEFAULT_NAMESPACE}" namespace register --rd "${DEFAULT_NAMESPACE_RETENTION}" --desc "Default namespace for Temporal Server."
        echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
    else
        echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
    fi
}

setup_server(){
    echo "Temporal CLI address: ${TEMPORAL_CLI_ADDRESS}."

    until tctl cluster health | grep SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    if [ "${SKIP_DEFAULT_NAMESPACE_CREATION}" != true ]; then
        register_default_namespace
    fi

}

# === Main ===

echo 'SWYX: starting main'
if [ "${SKIP_SCHEMA_SETUP}" != true ]; then
    echo 'SWYX: not skipping setup'
    validate_db_env
    wait_for_db
    setup_schema
fi

# Run this func in parallel process. It will wait for server to start and then run required steps.
setup_server &
