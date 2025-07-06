# Task 4 — Kubernetes RBAC Hardening

## Ролевая модель доступа к Kubernetes (Minikube)

| Группа пользователей (O в X.509) | Роль / ClusterRole      | Полномочия (verbs) | Охват ресурсов | Комментарий |
|----------------------------------|-------------------------|--------------------|----------------|-------------|
| **k8s-admins**                   | `cluster-admin` (built-in) | * (полный доступ) | Весь кластер   | Администраторы: управление кластерами, просмотр/изменение секретов, CRDs, узлов |
| **k8s-ops**                      | `config-manager` (custom) | get, list, watch, create, update, patch, delete | Deployments, StatefulSets, DaemonSets, Pods, Services, Ingress, ConfigMaps, Jobs, CronJobs, Pods/log | Инженеры эксплуатации — могут «крутить» манифесты, но **не** видят/меняют Secrets и Cluster‑scope ресурсы |
| **k8s-viewers**                  | `view` (built-in)       | get, list, watch   | Все namespace‑ресурсы (кроме secrets) | Разработчики, QA, аналитики — только наблюдение |

---

## Быстрый старт

1. **Запустить Minikube**

```bash
minikube start
```

2. **Сделать скрипты исполняемыми**

```bash
chmod +x Task4/*.sh
```

3. **Создать пользователей**

```bash
Task4/01-create-users.sh
```

4. **Создать кастомную роль**

```bash
Task4/02-create-roles.sh
```

5. **Привязать роли к группам**

```bash
Task4/03-bind-roles.sh
```

## Проверка доступа

*Пользователь alice* (группа **k8s‑ops**):

```bash
kubectl --context=alice@minikube get deploy -A      # ✅
kubectl --context=alice@minikube get secrets -A     # ⛔ Forbidden
```

*Пользователь bob* (группа **k8s‑viewers**):

```bash
kubectl --context=bob@minikube get pods -A          # ✅
kubectl --context=bob@minikube delete pod nginx     # ⛔ Forbidden
```

