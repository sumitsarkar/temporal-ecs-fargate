#!/bin/bash

set -eux -o pipefail

# === Auto setup defaults ===

# Server setup
: "${TEMPORAL_CLI_ADDRESS:=}"
: "${NAMESPACE_NAME:=}"
: "${DEFAULT_NAMESPACE_RETENTION:=1}"


# === Helper functions ===

die() {
    echo "$*" 1>&2
    exit 1
}

# === Main database functions ===

validate_namespace_env() {
  if [[ -z ${NAMESPACE_NAME} ]]; then
    die "NAMESPACE_NAME env must be set to create a namespace."
  fi;
}

register_namespace() {
    echo "Registering namespace: ${NAMESPACE_NAME}."
    if ! tctl --ns "${NAMESPACE_NAME}" namespace describe; then
        echo "Namespace ${NAMESPACE_NAME} not found. Creating..."
        tctl --ns "${NAMESPACE_NAME}" namespace register --rd "${DEFAULT_NAMESPACE_RETENTION}" --desc "Namespace for Temporal Server."
        echo "Namespace ${NAMESPACE_NAME} registration complete."
    else
        echo "The namespace ${NAMESPACE_NAME} already registered."
    fi
}

create_namespace(){
    echo "Temporal CLI address: ${TEMPORAL_CLI_ADDRESS}."

    until tctl cluster health | grep -q SERVING; do
        echo "Waiting for Temporal server to start..."
        sleep 1
    done
    echo "Temporal server started."

    register_namespace
}

validate_namespace_env
create_namespace
