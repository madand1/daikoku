<div align="center">

# 🚗 Lección 04 — Tu primer Pod desde cero
## Del YAML al cluster, paso a paso

[![Nivel](https://img.shields.io/badge/Nivel-Principiante-brightgreen?style=flat-square)](#)
[![Tiempo](https://img.shields.io/badge/Tiempo-35%20min-blue?style=flat-square)](#)
[![Temporada](https://img.shields.io/badge/Temporada-1%20·%20Llegando%20a%20Daikoku-orange?style=flat-square)](#)

</div>

---

## 🎯 Lo que vas a aprender

- Escribir un manifiesto YAML completo desde cero
- Entender cada campo del manifiesto y por qué existe
- Desplegar, actualizar y eliminar Pods con `kubectl`
- Depurar Pods que fallan con logs y eventos
- Variables de entorno, health checks y init containers
- Diferencia entre `kubectl apply` y `kubectl create`

---

## ✍️ Escribiendo YAML como un profesional

En la lección anterior vimos un YAML básico. Ahora vamos a construir uno completo, campo a campo, entendiendo cada línea.

### La estructura obligatoria

Todo manifiesto de K8s tiene siempre estos cuatro bloques:

```yaml
apiVersion:   # qué versión de la API usamos
kind:         # qué tipo de objeto creamos
metadata:     # nombre, namespace, labels...
spec:         # cómo queremos que sea el objeto
```

### apiVersion — ¿qué versión usamos?

Depende del tipo de objeto:

| Objeto | apiVersion |
|--------|-----------|
| Pod | `v1` |
| Deployment | `apps/v1` |
| Service | `v1` |
| Ingress | `networking.k8s.io/v1` |
| CronJob | `batch/v1` |

Para ver todas las versiones disponibles en tu cluster:
```bash
kubectl api-resources
```

### metadata — identidad del Pod

```yaml
metadata:
  name: wagen-app          # nombre único en el namespace
  namespace: produccion    # namespace donde vive (default si no se pone)
  labels:
    app: mi-app            # etiquetas para seleccionar el Pod
    version: "1.0"
    entorno: produccion
  annotations:
    descripcion: "Pod principal de mi-app"
    contacto: "equipo@empresa.com"
```

**Labels vs Annotations:**
- `labels` → se usan para seleccionar y filtrar objetos (Services, Deployments...)
- `annotations` → metadatos informativos, no se usan para selección

---

## 🔬 El manifiesto completo

Construimos un Pod realista, con todo lo que se necesita en producción:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wagen-completo
  labels:
    app: mi-app
    version: "1.0"
    entorno: desarrollo
spec:
  # Init container: se ejecuta ANTES que los contenedores principales
  initContainers:
    - name: init-permisos
      image: busybox
      command: ["sh", "-c", "echo 'Preparando el Wagen...' && sleep 2"]

  containers:
    - name: app
      image: nginx:1.25
      
      # Puertos expuestos por el contenedor
      ports:
        - containerPort: 80
          name: http
          protocol: TCP

      # Variables de entorno
      env:
        - name: ENTORNO
          value: "desarrollo"
        - name: VERSION
          value: "1.0"
        - name: LOG_LEVEL
          value: "info"

      # Límites de recursos (siempre definirlos)
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "500m"

      # Health checks
      livenessProbe:        # ¿sigue vivo el contenedor?
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 10

      readinessProbe:       # ¿está listo para recibir tráfico?
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5

  # Política de reinicio
  restartPolicy: Always
```

---

## 🏥 Health Checks: liveness y readiness

Son dos de los conceptos más importantes de los Pods. K8s los usa para saber el estado real del contenedor.

### livenessProbe — ¿sigue vivo?

K8s pregunta periódicamente: "¿estás vivo?" Si no responde → reinicia el contenedor.

```
livenessProbe falla → contenedor reiniciado automáticamente
```

### readinessProbe — ¿estás listo?

K8s pregunta: "¿puedes recibir tráfico?" Si no → el Pod sale de la rotación del Service pero **no se reinicia**.

```
readinessProbe falla → Pod sale de rotación, NO se reinicia
readinessProbe OK    → Pod entra en rotación, recibe tráfico
```

> 💡 Un Pod puede estar vivo (`liveness OK`) pero no listo para tráfico (`readiness KO`). Por ejemplo, mientras carga la base de datos al arrancar.

### Tipos de probes

```yaml
# HTTP (el más común)
httpGet:
  path: /health
  port: 8080

# TCP (comprueba que el puerto está abierto)
tcpSocket:
  port: 3306

# Comando (ejecuta un comando dentro del contenedor)
exec:
  command: ["cat", "/tmp/healthy"]
```

---

## 🌱 Init Containers

Los **init containers** se ejecutan **antes** que los contenedores principales y deben terminar con éxito para que el Pod arranque.

Casos de uso reales:

- Esperar a que la base de datos esté disponible
- Descargar configuración antes de arrancar la app
- Preparar directorios o permisos
- Ejecutar migraciones

```yaml
initContainers:
  - name: esperar-db
    image: busybox
    command: ['sh', '-c', 'until nc -z mysql-service 3306; do echo "Esperando DB..."; sleep 2; done']
```

```
Pod arrancando:
  1. init-container: esperar-db    → espera hasta que MySQL responde
  2. init-container: preparar-dir  → crea directorios necesarios
  3. contenedor principal: app     → arranca solo cuando los init terminan
```

---

## ⚙️ Variables de entorno

Hay varias formas de pasar configuración a los contenedores:

### Directas en el YAML

```yaml
env:
  - name: ENTORNO
    value: "produccion"
```

### Desde un ConfigMap (Lección 09)

```yaml
env:
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: mi-config
        key: db_host
```

### Desde un Secret (Lección 09)

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: mi-secret
        key: password
```

---

## 🔧 kubectl apply vs kubectl create

Dos formas de crear objetos en K8s:

| | `kubectl create` | `kubectl apply` |
|--|-----------------|-----------------|
| Si el objeto no existe | Lo crea ✅ | Lo crea ✅ |
| Si el objeto ya existe | Error ❌ | Lo actualiza ✅ |
| Uso recomendado | Tests rápidos | Siempre en proyectos reales |

**Regla de oro:** usa siempre `kubectl apply -f fichero.yaml`. Funciona tanto para crear como para actualizar.

---

## 🐛 Depurando Pods que fallan

Cuando un Pod no arranca o falla, estos son los pasos para diagnosticarlo:

```bash
# 1. Ver el estado del Pod
kubectl get pods

# 2. Ver los eventos y la causa del error
kubectl describe pod <nombre-del-pod>

# 3. Ver los logs del contenedor
kubectl logs <nombre-del-pod>

# 4. Ver los logs del contenedor anterior (si se reinició)
kubectl logs <nombre-del-pod> --previous

# 5. Si el Pod arranca, entrar dentro para inspeccionar
kubectl exec -it <nombre-del-pod> -- /bin/sh
```

### Errores más comunes

| Error | Causa probable |
|-------|---------------|
| `ImagePullBackOff` | Imagen no existe o credenciales incorrectas |
| `CrashLoopBackOff` | El contenedor falla al arrancar repetidamente |
| `OOMKilled` | El contenedor superó el límite de memoria |
| `Pending` sin avanzar | No hay Nodes con recursos suficientes |
| `Error: failed to create containerd` | Problema con el runtime del Node |

---

## 🛠️ Práctica — Manos al volante

Ejecuta el script de esta lección:

```bash
bash leccion4.sh
```

El script cubre:

1. Pod completo con todos los campos
2. Variables de entorno y cómo leerlas dentro
3. Health checks en acción
4. Init containers paso a paso
5. Depurar un Pod con errores reales
6. `kubectl apply` para actualizar sin borrar

---

## ✅ Checklist de la lección

**Teoría**
- [ ] Entiendo los cuatro bloques del manifiesto YAML
- [ ] Sé la diferencia entre `labels` y `annotations`
- [ ] Entiendo `livenessProbe` vs `readinessProbe`
- [ ] Sé para qué sirven los init containers
- [ ] Conozco la diferencia entre `kubectl apply` y `kubectl create`
- [ ] Sé cómo depurar un Pod que falla

**Práctica**
- [ ] He escrito un manifiesto YAML completo desde cero
- [ ] He usado variables de entorno en un Pod
- [ ] He configurado liveness y readiness probes
- [ ] He creado un Pod con init container
- [ ] He depurado un Pod con error usando describe y logs
- [ ] He actualizado un Pod con `kubectl apply` sin borrar

---

## 🔗 Recursos adicionales

- [Documentación oficial — Pod spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)
- [Configure Liveness and Readiness Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
- [Init Containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/)

---

## ➡️ Siguiente lección

**[Lección 05 → Deployments: La fábrica de clones](../05-deployments/leccion5.md)**

Por qué no se crean Pods a mano, cómo un Deployment los gestiona, rolling updates sin downtime y cómo hacer rollback en segundos.

---

<div align="center">

**¿Te ha sido útil esta lección?**
Dale una ⭐ al repo y comparte el post en LinkedIn

[← Lección 03](../03-pods/leccion3.md) · [Volver al índice](../README.md)

<sub>Proyecto Daikoku · Lección 04 de 16</sub>

</div>
