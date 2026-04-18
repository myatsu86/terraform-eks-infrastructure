#!/bin/bash
set -o xtrace

# Bootstrap the node to join the EKS cluster
/etc/eks/bootstrap.sh '${cluster_name}' \
  --b64-cluster-ca '${cluster_ca}' \
  --apiserver-endpoint '${cluster_endpoint}'

# Custom bootstrapping can be added here
# For example: installing additional packages, configuring logging, etc.
