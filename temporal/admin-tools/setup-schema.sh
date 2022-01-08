#!/usr/bin/env bash
temporal-sql-tool --endpoint "$SQL_HOST" --port "$SQL_PORT" --user "$SQL_USER" --password "$SQL_PASSWORD" --database "$SQL_DATABASE" --plugin postgres setup-schema --version "$SCHEMA_VERSION"

echo "Schema setup complete. Running tail -f /dev/null to keep container running."

tail -f /dev/null
