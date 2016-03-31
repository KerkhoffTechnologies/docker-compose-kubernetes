#!/bin/bash

set -e

if [ $# -gt 0 ]; then
        if [ "$1" == "--trustme" ]; then
                MY_KUBERNETES_HOST=$2
                MY_KUBERNETES_PORT=$3
        else
                echo Invalid usage, try again...
                exit 0
        fi
else
        MY_KUBERNETES_HOST="127.0.0.1"
        MY_KUBERNETES_PORT="8080"
fi
MY_KUBECTL_PARAMS="--server=$MY_KUBERNETES_HOST:$MY_KUBERNETES_PORT"
export MY_KUBECTL_PARAMS=$MY_KUBECTL_PARAMS

echo Working with $MY_KUBECTL_PARAMS

require_command_exists() {
    command -v "$1" >/dev/null 2>&1 || { echo "$1 is required but is not installed. Aborting." >&2; exit 1; }
}

require_command_exists kubectl
require_command_exists docker
require_command_exists docker-compose

this_dir=$(cd -P "$(dirname "$0")" && pwd)

docker info > /dev/null
if [ $? != 0 ]; then
    echo "A running Docker engine is required. Is your Docker host up?"
    exit 1
fi

cd "$this_dir/kubernetes"
docker-compose up -d

cd "$this_dir/scripts"

source docker-machine-port-forwarding.sh
forward_port_if_not_forwarded $KUBERNETES_API_PORT

./wait-for-kubernetes.sh
./create-kube-system-namespace.sh
./activate-dns.sh
./activate-kube-ui.sh
