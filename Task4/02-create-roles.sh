#!/usr/bin/env bash
# Создаёт custom ClusterRole "config-manager" для группы k8s-ops.

set -euo pipefail

cat <<'EOF' | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: config-manager
rules:
  - apiGroups: ["apps", "batch", "extensions"]
    resources:
      - deployments
      - statefulsets
      - daemonsets
      - jobs
      - cronjobs
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources:
      - services
      - endpoints
      - configmaps
      - pods
      - pods/log
    verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
  - apiGroups: [""]
    resources: ["namespaces"]
    verbs: ["get", "list", "watch"]
EOF

echo "✅  ClusterRole config-manager создана."
