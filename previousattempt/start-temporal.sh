#!/bin/bash

set -eu -o pipefail

# SERVICES="${SERVICES:-}"
# SERVICE_FLAGS="${SERVICE_FLAGS:-}"

# if [ -z "${SERVICE_FLAGS}" ] && [ -n "${SERVICES}" ]; then
#     # Convert semicolon (or comma, for backward compatibility) separated string (i.e. "history:matching")
#     # to valid flag list (i.e. "--service=history --service=matching").
#     IFS=':,' read -ra SERVICE_FLAGS <<< "${SERVICES}"
#     for i in "${!SERVICE_FLAGS[@]}"; do SERVICE_FLAGS[$i]="--service=${SERVICE_FLAGS[$i]}"; done
# fi

# ERROR: start command doesn't support arguments. Use --service flag instead.
# exec temporal-server --env docker start "${SERVICE_FLAGS[@]}"

echo 'SWYX: starting temporal server'
exec temporal-server --env docker start "--service=frontend --service=history --service=matching --service=workflow"
echo 'SWYX: started temporal server'

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


# Run this func in parallel process. It will wait for server to start and then run required steps.
setup_server &