#!/bin/bash
echo "Waiting for Kubernetes cluster $MY_KUBECTL_PARAMS to become available..."

until $(kubectl $MY_KUBECTL_PARAMS cluster-info &> /dev/null); do
    sleep 1
done

echo "Kubernetes cluster is up."
