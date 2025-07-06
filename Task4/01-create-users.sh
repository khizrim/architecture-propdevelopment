#!/usr/bin/env bash
# Создаёт пользователей (X.509‑сертификаты) и kubeconfig‑контексты для Minikube.
# Требования: openssl, kubectl, minikube (кластер уже запущен).

set -euo pipefail
MINIKUBE_IP=$(minikube ip)

create_user () {
  local USERNAME=$1
  local GROUP=$2

  # 1. Генерация ключа и CSR
  openssl genrsa -out ${USERNAME}.key 2048
  openssl req -new -key ${USERNAME}.key \
    -out ${USERNAME}.csr \
    -subj "/CN=${USERNAME}/O=${GROUP}"

  # 2. Подпись CSR корневым CA Minikube
  sudo openssl x509 -req -in ${USERNAME}.csr -CA ~/.minikube/ca.crt \
    -CAkey ~/.minikube/ca.key -CAcreateserial \
    -out ${USERNAME}.crt -days 365

  # 3. kubeconfig
  kubectl config set-credentials ${USERNAME} \
    --client-certificate=${USERNAME}.crt \
    --client-key=${USERNAME}.key

  kubectl config set-context ${USERNAME}@minikube \
    --cluster=minikube \
    --user=${USERNAME}

  echo "✅  Пользователь ${USERNAME} (${GROUP}) создан."
}

create_user alice   k8s-ops
create_user bob     k8s-viewers
# create_user charlie k8s-admins  # при необходимости

echo "Все пользователи созданы."
