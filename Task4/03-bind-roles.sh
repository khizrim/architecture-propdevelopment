#!/usr/bin/env bash
# Создаёт ClusterRoleBindings для трёх групп пользователей.

set -euo pipefail

kubectl create clusterrolebinding k8s-admins-binding \
  --clusterrole=cluster-admin \
  --group=k8s-admins \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create clusterrolebinding k8s-ops-binding \
  --clusterrole=config-manager \
  --group=k8s-ops \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create clusterrolebinding k8s-viewers-binding \
  --clusterrole=view \
  --group=k8s-viewers \
  --dry-run=client -o yaml | kubectl apply -f -

echo "✅  Привязки ролей созданы."
