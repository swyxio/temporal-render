#!/usr/bin/env bash
# From https://github.com/temporalio/temporal/blob/16bf19dcb5389f491691e650e17d46f027ede67d/docker/auto-setup.sh#L173
TEMPORAL_HOME=${TEMPORAL_HOME:-/etc/temporal}
SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/temporal/versioned

temporal-sql-tool --plugin postgres --endpoint "${POSTGRES_SEEDS}" --user "${POSTGRES_USER}" --password "$POSTGRES_PWD" --port "${DB_PORT}" --db "${DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin postgres --endpoint "${POSTGRES_SEEDS}" --user "${POSTGRES_USER}" --password "$POSTGRES_PWD" --port "${DB_PORT}" --db "${DBNAME}" update-schema -d "${SCHEMA_DIR}"
VISIBILITY_SCHEMA_DIR=${TEMPORAL_HOME}/schema/postgresql/v96/visibility/versioned

temporal-sql-tool --plugin postgres --endpoint "${POSTGRES_SEEDS}" --user "${POSTGRES_USER}" --password "$POSTGRES_PWD" --port "${DB_PORT}" --db "${VISIBILITY_DBNAME}" setup-schema -v 0.0
temporal-sql-tool --plugin postgres --endpoint "${POSTGRES_SEEDS}" --user "${POSTGRES_USER}" --password "$POSTGRES_PWD" --port "${DB_PORT}" --db "${VISIBILITY_DBNAME}" update-schema -d "${VISIBILITY_SCHEMA_DIR}"

echo "Setting up namespaces..."

until tctl cluster health | grep SERVING; do
    echo "Waiting for Temporal server to start..."
    sleep 1
done
echo "Temporal server started."
echo "Registering default namespace: ${DEFAULT_NAMESPACE}."
if ! tctl --ns "${DEFAULT_NAMESPACE}" namespace describe; then
    echo "Default namespace ${DEFAULT_NAMESPACE} not found. Creating..."
    tctl --ns "${DEFAULT_NAMESPACE}" namespace register --rd "${DEFAULT_NAMESPACE_RETENTION}" --desc "Default namespace for Temporal Server."
    echo "Default namespace ${DEFAULT_NAMESPACE} registration complete."
else
    echo "Default namespace ${DEFAULT_NAMESPACE} already registered."
fi

echo "Database setup complete. Running tail -f /dev/null to keep container running."
tail -f /dev/null
