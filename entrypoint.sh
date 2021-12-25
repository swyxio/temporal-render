#!/bin/bash

set -eu -o pipefail

echo "hi from entrypoint.sh"

export BIND_ON_IP="${BIND_ON_IP:-$(hostname -i)}"

if [[ "${BIND_ON_IP}" =~ ":" ]]; then
    # ipv6
    export TEMPORAL_CLI_ADDRESS="[${BIND_ON_IP}]:7233"
else
    # ipv4
    export TEMPORAL_CLI_ADDRESS="${BIND_ON_IP}:7233"
fi

dockerize -template /etc/temporal/config/config_template.yaml:/etc/temporal/config/docker.yaml

# Automatically setup Temporal Server (databases, Elasticsearch, default namespace) if "autosetup" is passed as an argument.
exec /etc/temporal/custom-auto-setup.sh

exec /etc/temporal/start-temporal.sh