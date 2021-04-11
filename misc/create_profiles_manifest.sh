#!/bin/bash

# Usage:
# ./create_profiles_manifest.sh myuser@domain.com | kubectl apply -f -

USERMAIL=$1
if [[ $USERMAIL != *"@"* ]]; then
  echo "User has to have a mail address, usage:"
  echo "./$0 myuser@domain.com"
  exit 1
fi
USER=$( echo $USERMAIL | sed "s/\(.*\)@.*/\1/" )

cat << EOF
apiVersion: kubeflow.org/v1
kind: Profile
metadata:
  finalizers:
  - profile-finalizer
  name: $USER
spec:
  owner:
    kind: User
    name: $USERMAIL
  resourceQuotaSpec: {}
EOF