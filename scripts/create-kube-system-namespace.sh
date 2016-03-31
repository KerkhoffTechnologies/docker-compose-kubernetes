#!/bin/bash

kubectl $MY_KUBECTL_PARAMS create -f - << EOF
kind: Namespace
apiVersion: v1
metadata:
  name: kube-system
  labels:
    name: kube-system
EOF
