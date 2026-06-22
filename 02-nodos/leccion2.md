<div align="center">

# 🚗 Lección 02 — Nodos
## Los Wagen del parking

[![Nivel](https://img.shields.io/badge/Nivel-Principiante-brightgreen?style=flat-square)](#)
[![Tiempo](https://img.shields.io/badge/Tiempo-30%20min-blue?style=flat-square)](#)
[![Temporada](https://img.shields.io/badge/Temporada-1%20·%20Llegando%20a%20Daikoku-orange?style=flat-square)](#)

</div>

---

## 🎯 Lo que vas a aprender

- Qué es un Node y cuántos tipos existen
- Los componentes internos de cada Node (kubelet, kube-proxy, container runtime)
- Cómo inspeccionar Nodes con `kubectl`
- Qué pasa cuando un Node falla y cómo K8s reacciona
- Labels y Taints: controlar dónde aparca cada Pod

---

## 🚗 El Wagen: más que un coche

En la lección anterior vimos el parking Daikoku a vista de pájaro. Hoy nos metemos dentro de los coches.

Un **Node** es la máquina donde realmente corre tu aplicación. Puede ser:

- Un servidor físico en tu datacenter
- Una máquina virtual en AWS, GCP o Azure
- Tu propio ordenador (cuando usas minikube)

Lo importante: **Kubernetes no ejecuta tu app directamente — la ejecuta dentro de un Node**.

El Control Plane (la sala de control del parking) toma decisiones. El Node (el Wagen) hace el trabajo físico.

---

## 🏗️ Tipos de Nodes

Hay dos tipos de Nodes en un cluster con roles completamente distintos:

```
╔══════════════════════════════════════════════════════════════╗
║                   PARKING DAIKOKU (Cluster)                  ║
║                                                              ║
║  ┌─────────────────────────────────┐                         ║
║  │     🟦 CONTROL PLANE NODE        │                         ║
║  │   (El jefe del parking)          │                         ║
║  │                                  │                         ║
║  │  kube-apiserver                  │                         ║
║  │  etcd                            │                         ║
║  │  kube-scheduler                  │                         ║
║  │  kube-controller-manager         │                         ║
║  └──────────────┬───────────────────┘                         ║
║                 │ ordena                                       ║
║     ┌───────────┼───────────┐                                 ║
║     ▼           ▼           ▼                                 ║
║  ┌──────┐   ┌──────┐   ┌──────┐                              ║
║  │🟩    │   │🟩    │   │🟩    │                              ║
║  │Worker│   │Worker│   │Worker│                              ║
║  │Node 1│   │Node 2│   │Node 3│                              ║
║  │      │   │      │   │      │                              ║
║  │ Pods │   │ Pods │   │ Pods │                              ║
║  └──────┘   └──────┘   └──────┘                              ║
╚══════════════════════════════════════════════════════════════╝
```

### 🟦 Control Plane Node — El jefe del parking

No ejecuta aplicaciones de usuario. Solo toma decisiones:

- ¿Dónde va este Pod?
- ¿Cuántas réplicas necesito?
- ¿Qué ha fallado y cómo lo soluciono?

Sus componentes principales:

| Componente | Función |
|---|---|
| `kube-apiserver` | Punto de entrada de todo — recibe todas las peticiones de kubectl |
| `etcd` | Base de datos clave-valor donde K8s guarda el estado del cluster |
| `kube-scheduler` | Decide en qué Worker Node va cada Pod nuevo |
| `kube-controller-manager` | Vigila que el estado real del cluster coincide con el deseado |

> En producción, este Node **nunca recibe cargas de trabajo de usuario**. Tiene un Taint que lo impide.

### 🟩 Worker Nodes — Los Wagen de verdad

Aquí viven tus apps. Reciben órdenes del Control Plane y las ejecutan. Un cluster puede tener de 1 a miles de Worker Nodes.

> En minikube hay **un solo Node que hace los dos roles** a la vez. Perfecto para aprender, nunca para producción.

---

## 🔧 Anatomía de un Worker Node

Cada Wagen lleva su propia mecánica interna. Tres piezas clave:

```
┌─────────────────────────────────────────────┐
│              WORKER NODE (Wagen)             │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  kubelet            🔧 El motor       │   │
│  │                                       │   │
│  │  Agente que corre en cada Node.       │   │
│  │  Recibe órdenes del API Server        │   │
│  │  y arranca o para contenedores.       │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  kube-proxy         🛣️ El GPS         │   │
│  │                                       │   │
│  │  Gestiona las reglas de red.          │   │
│  │  Permite que los Pods se comuniquen   │   │
│  │  dentro y fuera del cluster.          │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  ┌──────────────────────────────────────┐   │
│  │  Container Runtime  🏎️ El chasis      │   │
│  │                                       │   │
│  │  Ejecuta los contenedores.            │   │
│  │  K8s no usa Docker directamente       │   │
│  │  desde la v1.24 — usa containerd.     │   │
│  └──────────────────────────────────────┘   │
│                                              │
│  [ Pod A ]    [ Pod B ]    [ Pod C ]        │
└─────────────────────────────────────────────┘
```

### kubelet — El motor del Wagen

Es el componente más importante de un Worker Node. Su ciclo de trabajo:

1. El `kube-scheduler` decide que un Pod va a este Node
2. El `kube-apiserver` le dice al `kubelet`: "arranca este Pod"
3. El `kubelet` le pide al Container Runtime que ejecute los contenedores
4. El `kubelet` monitoriza que los contenedores siguen vivos
5. Si un contenedor muere, el `kubelet` intenta reiniciarlo
6. Reporta el estado del Node al Control Plane cada pocos segundos (heartbeat)

> Si el kubelet deja de funcionar, el Node queda fuera de control. Nadie gestiona sus Pods.

### kube-proxy — El GPS

Mantiene las reglas de red (`iptables` o `ipvs`) para que:
- Los Pods puedan comunicarse entre sí, aunque estén en Nodes distintos
- Los Services enruten el tráfico correctamente a los Pods

### Container Runtime — El chasis

Es quien realmente ejecuta los contenedores. Kubernetes usa la interfaz **CRI (Container Runtime Interface)** para comunicarse con él.

| Runtime | Uso |
|---------|-----|
| `containerd` | El más usado en producción |
| `CRI-O` | Ligero, pensado específicamente para K8s |
| `Docker Engine` | Eliminado en K8s 1.24 (usaba un shim intermedio) |

---

## 🩺 El estado de salud de un Node: Conditions

Cuando ejecutas `kubectl describe node`, la sección `Conditions` te dice si el Wagen está sano:

| Condition | Estado normal | Qué significa si cambia |
|-----------|--------------|------------------------|
| `MemoryPressure` | `False` | El Node se está quedando sin RAM |
| `DiskPressure` | `False` | El Node se está quedando sin disco |
| `PIDPressure` | `False` | Demasiados procesos corriendo |
| `Ready` | `True` | Si es `False`, K8s deja de enviar Pods aquí |

---

## 🚨 ¿Qué pasa cuando un Wagen falla?

Esta es la magia de Kubernetes. Todo automático:

```
T+0s    El Node deja de enviar heartbeats al kube-controller-manager
T+40s   El Node pasa a estado "Unknown"
T+5min  El Node pasa a estado "NotReady"
        kube-controller-manager marca sus Pods como "Terminating"
        kube-scheduler asigna los Pods a otros Nodes disponibles
        Los nuevos Pods arrancan en los Nodes sanos

Cuando el Node vuelve → se reincorpora al cluster automáticamente
```

Sin intervención manual. Sin alarmas a las 3am. K8s lo resuelve solo.

---

## 🏷️ Labels y Taints: controlando el parking

### Labels — La matrícula del Wagen

Un Label es una etiqueta clave-valor que puedes poner en cualquier objeto de K8s, incluidos los Nodes. Sirven para identificar y seleccionar:

```bash
# Etiquetar un Node
kubectl label node minikube tipo=produccion zona=eu-west

# Luego en un Pod puedes decirle: solo quiero correr en Nodes con tipo=produccion
```

### Taints — La zona reservada

Un Taint es como un cartel de **"Zona restringida"** en el parking. Si un Node tiene un Taint, los Pods normales no pueden aterrizar ahí a menos que tengan la **Toleration** (el permiso) correspondiente.

```
Node con Taint zona=gpu:NoSchedule
├── Pod sin Toleration → ❌ No puede entrar
└── Pod con Toleration → ✅ Puede entrar
```

Ejemplo de Pod con Toleration en YAML:

```yaml
spec:
  tolerations:
    - key: "zona"
      operator: "Equal"
      value: "gpu"
      effect: "NoSchedule"
```

> El Control Plane Node tiene por defecto el Taint `node-role.kubernetes.io/control-plane:NoSchedule`. Por eso tus Pods nunca van ahí.

---

## 🛠️ Práctica — Manos al volante

Ejecuta el script de esta lección y sigue los ejercicios:

```bash
bash leccion2.sh
```

El script cubre:

1. Arrancar el cluster e inspeccionar el Wagen con `-o wide`
2. Diseccionar el Node con `kubectl describe`
3. Añadir un segundo Wagen con `minikube node add`
4. Etiquetar los Nodes con `kubectl label`
5. Simular el fallo de un Node en tiempo real
6. Recuperar el Node caído
7. Aplicar y eliminar un Taint (reto opcional)

---

## ✅ Checklist de la lección

**Teoría**
- [ ] Entiendo la diferencia entre Control Plane Node y Worker Node
- [ ] Sé qué hace el `kubelet`, `kube-proxy` y el Container Runtime
- [ ] Entiendo las Conditions y qué significan
- [ ] Sé qué pasa paso a paso cuando un Node falla
- [ ] Entiendo para qué sirven los Labels y los Taints

**Práctica**
- [ ] He ejecutado `kubectl get nodes -o wide` y entiendo el output
- [ ] He ejecutado `kubectl describe node` y sé leer las Conditions
- [ ] He añadido un segundo Node con `minikube node add`
- [ ] He etiquetado un Node con `kubectl label`
- [ ] He simulado el fallo de un Node y visto cómo K8s reacciona
- [ ] He aplicado y eliminado un Taint

---

## 🔗 Recursos adicionales

- [Documentación oficial — Nodes](https://kubernetes.io/docs/concepts/architecture/nodes/)
- [kubelet reference](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
- [Taints y Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

---

## ➡️ Siguiente lección

**[Lección 03 → Pods: Los pasajeros del Wagen](../03-pods/leccion3.md)**

La unidad mínima de Kubernetes. Qué es un Pod, qué tiene dentro, cómo se crea con YAML y por qué nunca deberías crear uno a mano en producción.

---

<div align="center">

**¿Te ha sido útil esta lección?**
Dale una ⭐ al repo y comparte el post en LinkedIn

[← Lección 01](../01-que-es-kubernetes/leccion1.md) · [Volver al índice](../README.md)

<sub>Proyecto Daikoku · Lección 02 de 16</sub>

</div>
