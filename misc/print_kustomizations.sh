#!/bin/bash

export NAMESPACE=$1
export NOTEBOOK=$2
export USER=$3

if [[ ! $1 || ! $2 || ! $3 ]] ; then
  echo "usage:"
  echo "$0 <namespace> <notebook name> <kubeflow user id>"
  echo "example:"
  echo "$0 moritz mynotebook moritz"
  exit 1
fi

cat  << EOM
apiVersion: rbac.istio.io/v1alpha1
kind: ServiceRoleBinding
metadata:
  name: bind-ml-pipeline-nb-${NAMESPACE}
  namespace: kubeflow
spec:
  roleRef:
    kind: ServiceRole
    name: ml-pipeline-services
  subjects:
  - properties:
      source.principal: cluster.local/ns/${NAMESPACE}/sa/default-editor
---
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: add-header
  namespace: ${NAMESPACE}
spec:
  configPatches:
  - applyTo: VIRTUAL_HOST
    match:
      context: SIDECAR_OUTBOUND
      routeConfiguration:
        vhost:
          name: ml-pipeline.kubeflow.svc.cluster.local:8888
          route:
            name: default
    patch:
      operation: MERGE
      value:
        request_headers_to_add:
        - append: true
          header:
            key: kubeflow-userid
            value: ${USER}
  workloadSelector:
    labels:
      notebook-name: ${NOTEBOOK}
EOM
