# Task 5 — NetworkPolicy: изоляция трафика внутри Kubernetes

## 1. Развёртывание pod’ов

```bash
# обычная пара
kubectl run front-end-app         --image=nginx --labels role=front-end         --expose --port 80
kubectl run back-end-api-app      --image=nginx --labels role=back-end-api      --expose --port 80

# админ‑пара
kubectl run admin-front-end-app   --image=nginx --labels role=admin-front-end   --expose --port 80
kubectl run admin-back-end-app    --image=nginx --labels role=admin-back-end-api --expose --port 80
```

*Каждый `--expose` создаёт headless Service с одноимённым DNS‑именем.*

**Итоговые метки**

| Pod/Service name        | `role` label          |
|-------------------------|-----------------------|
| `front-end-app`         | `front-end`           |
| `back-end-api-app`      | `back-end-api`        |
| `admin-front-end-app`   | `admin-front-end`     |
| `admin-back-end-app`    | `admin-back-end-api`  |


## 2. Сетевые политики


| Файл | Что делает |
|------|------------|
| `non-admin-api-allow.yaml` | Разрешает двусторонний трафик между `front-end` и `back-end-api` |
| `admin-api-allow.yaml` | Разрешает двусторонний трафик между `admin-front-end` и `admin-back-end-api` |
| `network-policies.yaml` | Две политики выше в одном файле (разделены `---`) |

### Применение

```bash
kubectl apply -f Task5/network-policies.yaml
```

## 3. Проверка связности

Временный pod Alpine:

```bash
kubectl run test-$RANDOM --rm -i -t --image=alpine -- sh
/ # apk add --no-cache curl

# ✅ разрешённый трафик
/ # curl -sSf http://front-end-app     # изнутри pod back-end-api
/ # curl -sSf http://back-end-api-app  # изнутри pod front-end

# ⛔ запрещённый
/ # curl --max-time 2 http://admin-back-end-app   # должен зависнуть / connection refused
```

## 4. Удаление

```bash
kubectl delete networkpolicy non-admin-ui-api-allow admin-ui-api-allow
kubectl delete deploy,svc -l role
```
