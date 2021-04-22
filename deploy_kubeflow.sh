#!/bin/bash

git clone -b v1.3-branch https://github.com/kubeflow/manifests.git kubeflow-manifests

n=0

while ! kustomize build --load_restrictor=none basic | kubectl apply -f - && [[ "$n" -le 10 ]]; do 
  n=$((n+1))
  echo "Retrying to apply resources - Retry number $n"
  sleep 10
done

rm -rf kubeflow-manifests