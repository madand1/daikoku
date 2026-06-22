<div align="center">

# 🚗 Lección 03 — Pods
## Los pasajeros del Wagen

[![Nivel](https://img.shields.io/badge/Nivel-Principiante-brightgreen?style=flat-square)](#)
[![Tiempo](https://img.shields.io/badge/Tiempo-30%20min-blue?style=flat-square)](#)
[![Temporada](https://img.shields.io/badge/Temporada-1%20·%20Llegando%20a%20Daikoku-orange?style=flat-square)](#)

</div>

---

## 🎯 Lo que vas a aprender

- Qué es un Pod y cómo se diferencia de un contenedor
- Anatomía de un Pod: qué tiene dentro
- El ciclo de vida de un Pod
- Cómo escribir tu primer manifiesto YAML
- Por qué nunca deberías crear Pods a mano en producción
- Comandos esenciales para gestionar Pods

---

## 👤 El Pod: la unidad mínima de Kubernetes

En las lecciones anteriores vimos el parking (Cluster) y los coches (Nodes). Hoy nos centramos en los **pasajeros**: los Pods.

Un **Pod** es la unidad mínima de despliegue en Kubernetes. No es un contenedor — es un **envoltorio** que contiene uno o más contenedores que:

- Comparten la misma dirección IP
- Comparten el mismo almacenamiento (volúmenes)
- Se comunican entre sí por `localhost`
- Se despliegan y eliminan siempre juntos

> 💡 Si un Node es el coche, el Pod son los pasajeros. Todos los pasajeros del mismo coche comparten el mismo vehículo, el mismo destino y pueden hablar entre ellos sin pasar por fuera.

---

## 🆚 Pod vs Contenedor — ¿cuál es la diferencia?

Esta es la pregunta más frecuente al empezar con K8s:

```
Docker:        Contenedor ← unidad mínima
Kubernetes:    Pod ← unidad mínima (contiene contenedores)
```

| | Docker | Kubernetes |
|--|--------|------------|
| Unidad mínima | Contenedor | Pod |
| Red | Cada contenedor tiene su IP | Todos los contenedores del Pod comparten IP |
| Comunicación interna | Por red | Por localhost |
| Gestión | Manual o docker-compose | Automática por K8s |

---

## 🏗️ Anatomía de un Pod

```
┌─────────────────────────────────────────────────┐
│                    POD                           │
│                                                  │
│  IP: 10.244.0.5  (compartida por todos)          │
│                                                  │
│  ┌─────────────────┐  ┌─────────────────┐       │
│  │  Contenedor A    │  │  Contenedor B    │       │
│  │  (app principal) │  │  (sidecar)      │       │
│  │                  │  │                 │       │
│  │  puerto: 8080    │  │  puerto: 9090   │       │
│  └─────────────────┘  └─────────────────┘       │
│            │                    │                │
│            └────────────────────┘                │
│                   localhost                      │
│                                                  │
│  📁 Volumen compartido: /datos                   │
│                                                  │
└─────────────────────────────────────────────────┘
```

Un Pod puede tener:

- **Un solo contenedor** → lo más común (99% de los casos)
- **Varios contenedores** → patrón sidecar (logging, proxies, agentes)

### El patrón Sidecar

Cuando un Pod tiene varios contenedores, el secundario se llama **sidecar**. Ejemplos reales:

| Contenedor principal | Sidecar |
|---------------------|---------|
| App web (nginx) | Agente de logs (Fluentd) |
| API (Node.js) | Proxy de seguridad (Envoy) |
| Base de datos | Agente de backup |

---

## 🔄 Ciclo de vida de un Pod

Un Pod pasa por varios estados desde que se crea hasta que muere:

```
Pending → Running → Succeeded
                 ↘ Failed
                 ↘ Unknown
```

| Estado | Significado |
|--------|-------------|
| `Pending` | K8s aceptó el Pod pero aún no está corriendo. Puede estar descargando la imagen o esperando un Node. |
| `Running` | El Pod está en un Node y al menos un contenedor está activo. |
| `Succeeded` | Todos los contenedores terminaron correctamente (código de salida 0). |
| `Failed` | Algún contenedor terminó con error. |
| `Unknown` | No se puede determinar el estado — normalmente problema de red con el Node. |

### Restart policies

Cuando un contenedor dentro de un Pod falla, K8s decide qué hacer según la política definida:

| Política | Comportamiento |
|----------|---------------|
| `Always` | Reinicia siempre (por defecto en Deployments) |
| `OnFailure` | Reinicia solo si falló (código de salida != 0) |
| `Never` | No reinicia nunca |

---

## 📄 Tu primer manifiesto YAML

En Kubernetes todo se define en **YAML**. Un manifiesto es el "plano del coche" — describes cómo quieres que sea y K8s lo construye.

### Pod básico con un contenedor

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mi-primer-pod
  labels:
    app: nginx
    proyecto: daikoku
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
```

Cada campo tiene su función:

| Campo | Descripción |
|-------|-------------|
| `apiVersion` | Versión de la API de K8s que usamos |
| `kind` | Tipo de objeto (Pod, Deployment, Service...) |
| `metadata.name` | Nombre único del Pod en el cluster |
| `metadata.labels` | Etiquetas para identificar y seleccionar el Pod |
| `spec.containers` | Lista de contenedores dentro del Pod |
| `image` | Imagen Docker a usar |
| `ports` | Puertos que expone el contenedor |

### Pod con recursos limitados (recomendado siempre)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: wagen-con-limites
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
```

| Campo | Descripción |
|-------|-------------|
| `requests` | Mínimo garantizado que necesita el contenedor |
| `limits` | Máximo que puede usar. Si lo supera, K8s lo mata |
| `250m` | 250 milicores = 0.25 CPUs |
| `64Mi` | 64 Mebibytes de RAM |

> ⚠️ Definir siempre `requests` y `limits` es una buena práctica. Sin ellos, un Pod puede consumir todos los recursos del Node y afectar al resto.

---

## ❌ ¿Por qué no crear Pods a mano en producción?

Los Pods son **efímeros**. Si un Pod muere, K8s no lo recupera solo — a menos que alguien se lo diga.

```
Pod creado a mano:
├── Node falla → Pod desaparece para siempre ❌
└── Pod falla  → Pod desaparece para siempre ❌

Pod gestionado por un Deployment:
├── Node falla → K8s crea un nuevo Pod automáticamente ✅
└── Pod falla  → K8s crea un nuevo Pod automáticamente ✅
```

En producción siempre usarás **Deployments** (Lección 05) para gestionar Pods. Los Pods directos solo se usan para pruebas rápidas o tareas puntuales.

---

## 🛠️ Práctica — Manos al volante

Ejecuta el script de esta lección:

```bash
bash leccion3.sh
```

El script cubre:

1. Crear un Pod desde YAML
2. Inspeccionar el Pod con `describe`
3. Ver los logs del contenedor
4. Entrar dentro del Pod con `exec`
5. Pod multi-contenedor
6. Ver el ciclo de vida en tiempo real

---

## ✅ Checklist de la lección

**Teoría**
- [ ] Entiendo la diferencia entre Pod y contenedor
- [ ] Sé qué comparten los contenedores dentro de un Pod
- [ ] Conozco los estados del ciclo de vida de un Pod
- [ ] Entiendo qué son `requests` y `limits`
- [ ] Sé por qué no se crean Pods a mano en producción

**Práctica**
- [ ] He escrito y aplicado mi primer manifiesto YAML
- [ ] He usado `kubectl describe pod` para inspeccionar un Pod
- [ ] He visto los logs con `kubectl logs`
- [ ] He entrado dentro de un Pod con `kubectl exec`
- [ ] He creado un Pod multi-contenedor

---

## 🔗 Recursos adicionales

- [Documentación oficial — Pods](https://kubernetes.io/docs/concepts/workloads/pods/)
- [Pod lifecycle](https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/)
- [Resource management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

---

## ➡️ Siguiente lección

**[Lección 04 → Tu primer Pod desde cero](../04-primer-pod/leccion4.md)**

Creamos un Pod real paso a paso, lo inspeccionamos a fondo, le hacemos port-forwarding y entendemos qué pasa por dentro cuando algo falla.

---

<div align="center">

**¿Te ha sido útil esta lección?**
Dale una ⭐ al repo y comparte el post en LinkedIn

[← Lección 02](../02-nodos/leccion2.md) · [Volver al índice](../README.md)

<sub>Proyecto Daikoku · Lección 03 de 16</sub>

</div>
