#!/bin/bash

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

this_dir=$(cd -P "$(dirname "$0")" && pwd)

echo "Removing replication controllers, services, pods and secrets..."
kubectl $MY_KUBECTL_PARAMS delete replicationcontrollers,services,pods,secrets --all
if [ $? != 0 ]; then
    echo "Kubernetes already down?"
fi

source scripts/docker-machine-port-forwarding.sh
remove_port_if_forwarded $KUBERNETES_API_PORT

cd "$this_dir/kubernetes"

if [ ! -z "$(docker-compose ps -q)" ]; then
    docker-compose stop
    docker-compose rm -f -v
fi

k8s_containers=`docker ps -a -f "name=k8s_" -q`

if [ ! -z "$k8s_containers" ]; then
    echo "Stopping and removing all other containers that were started by Kubernetes..."
    docker stop $k8s_containers
    docker rm -f -v $k8s_containers
fi
