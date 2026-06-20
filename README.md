<div align="center">

# 🚗 Lección 01 — ¿Qué es Kubernetes?
## El parking inteligente

[![Nivel](https://img.shields.io/badge/Nivel-Principiante-brightgreen?style=flat-square)](#)
[![Tiempo](https://img.shields.io/badge/Tiempo-30%20min-blue?style=flat-square)](#)
[![Temporada](https://img.shields.io/badge/Temporada-1%20·%20Llegando%20a%20Daikoku-orange?style=flat-square)](#)

</div>

---

## 🎯 Lo que vas a aprender

- Qué problema resuelve Kubernetes (y por qué existe)
- Qué significa "orquestación de contenedores"
- La arquitectura básica usando la analogía Wagen
- Instalar `kubectl` y `minikube`
- Explorar tu primer cluster y lanzar tu primera app

---

## 🏁 El problema: antes de Kubernetes

Imagina que tienes una aplicación web. La despliegas en un servidor. Todo funciona.

Pero llega el Black Friday. El tráfico se multiplica por 10. Tu servidor revienta. La app cae.

¿Qué haces? Pones otro servidor a mano. ¿Y si cae ese? ¿Y si necesitas actualizar la app sin que se caiga? ¿Y si un servidor falla a las 3 de la mañana?

**Esto era la pesadilla antes de Kubernetes.**

Antes, los equipos gestionaban los servidores a mano:
- Actualizaciones manuales que causaban downtime
- Escalado manual cuando había picos de tráfico
- Si una app fallaba, alguien tenía que reiniciarla manualmente
- Cada servidor era diferente ("en mi máquina funciona...")

---

## 🐳 Paso previo: los contenedores

Antes de entender Kubernetes, necesitamos entender **qué es un contenedor**.

Un contenedor es como un **maletero perfectamente empaquetado**:

- Contiene todo lo que una app necesita para funcionar (código, librerías, configuración)
- Funciona igual en cualquier máquina
- Es ligero y arranca en segundos
- Se puede replicar infinitas veces

**Docker** es la herramienta más popular para crear contenedores.

> 💡 Piensa en un contenedor como en un **coche de carreras en su transportín**: lleva todo lo que necesita, se puede mover de un circuito a otro y siempre funciona igual.

---

## ☸️ Entonces, ¿qué es Kubernetes?

**Kubernetes** (también llamado **K8s**) es un sistema que gestiona contenedores de forma automática.

Es el **jefe del parking**:

- Decide dónde aparca cada coche (contenedor)
- Si un coche se avería, llama a uno nuevo automáticamente
- Si hay demasiados coches esperando, abre más plazas
- Controla quién puede entrar y por dónde
- Actualiza los coches sin cerrar el parking

> **Kubernetes = El sistema que organiza, escala y mantiene vivos tus contenedores automáticamente.**

El nombre "Kubernetes" viene del griego: significa **timonel** o **piloto de barco**. El logo (el timón) lo refleja perfectamente. Nosotros lo llamamos el **jefe del parking Daikoku**.

---

## 🚗 La analogía Wagen: el parking Daikoku

Vamos a construir nuestra primera imagen mental del sistema completo.

```
╔══════════════════════════════════════════════════════╗
║              🏢 PARKING DAIKOKU (Cluster)             ║
║                                                      ║
║   ┌──────────────────────────────────────────────┐   ║
║   │          🚦 CONTROL ROOM (Control Plane)      │   ║
║   │   Decide dónde va cada coche y qué hace      │   ║
║   └──────────────────────────────────────────────┘   ║
║                                                      ║
║   ┌─────────────┐  ┌─────────────┐  ┌────────────┐  ║
║   │  🚗 WAGEN 1 │  │  🚗 WAGEN 2 │  │  🚗 WAGEN 3│  ║
║   │   (Node)    │  │   (Node)    │  │   (Node)   │  ║
║   │             │  │             │  │            │  ║
║   │ 👤👤 Pod A  │  │ 👤 Pod C    │  │ 👤👤 Pod E │  ║
║   │ 👤 Pod B    │  │ 👤👤 Pod D  │  │            │  ║
║   └─────────────┘  └─────────────┘  └────────────┘  ║
║                                                      ║
╚══════════════════════════════════════════════════════╝
```

| Elemento | En el parking | En Kubernetes |
|----------|--------------|---------------|
| El parking entero | Daikoku | **Cluster** |
| La sala de control | Control Room | **Control Plane** |
| Cada coche | Wagen | **Node** |
| Los pasajeros | Personas dentro del coche | **Pods** |
| Cada asiento | Asiento individual | **Container** |

---

## 🧠 Los componentes clave (sin profundizar aún)

### Control Plane — La sala de control del parking
Es el cerebro de Kubernetes. Toma todas las decisiones:
- ¿Dónde desplegamos esta app?
- ¿Cuántas copias necesitamos?
- ¿Qué hacemos si un nodo cae?

### Nodes — Los Wagen
Son las máquinas físicas (o virtuales) donde realmente corren las apps. Pueden ser servidores en tu empresa, VMs en la nube, o tu propio ordenador.

### Pods — Los pasajeros
La unidad más pequeña de Kubernetes. Un Pod contiene uno o más contenedores que trabajan juntos. Profundizaremos en la Lección 03.

---

## ⚙️ Instalando el entorno

Para practicar Kubernetes en local vamos a usar **minikube**: un cluster de un solo nodo que corre en tu máquina. Tu parking personal.

### 1. Instalar kubectl

`kubectl` es la herramienta de línea de comandos para hablar con Kubernetes. Como la app del parking para ver dónde está cada coche.

**macOS:**
```bash
brew install kubectl
```

**Linux:**
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

**Windows:**
```powershell
winget install Kubernetes.kubectl
```

Verifica que funciona:
```bash
kubectl version --client
```

---

### 2. Instalar minikube

**macOS:**
```bash
brew install minikube
```

**Linux:**
```bash
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

**Windows:**
```powershell
winget install Kubernetes.minikube
```

---

## 🛠️ Práctica — Manos al volante

Con el entorno instalado, vamos a explorar el cluster y lanzar nuestra primera app.

---

### Ejercicio 1 — Arranca tu parking

```bash
# Arranca el cluster
minikube start
```

Verás algo así mientras levanta:

```
😄  minikube v1.32.0
✨  Automatically selected the docker driver
📌  Using Docker Desktop driver with root privileges
🔥  Creating docker container (CPUs=2, Memory=2200MB)
🐳  Preparing Kubernetes v1.28.3 on Docker 24.0.7
🚀  Launching Kubernetes...
✅  Done! kubectl is now configured to use "minikube"
```

---

### Ejercicio 2 — Explora el cluster

```bash
# ¿Está el parking abierto?
kubectl cluster-info
```

```
Kubernetes control plane is running at https://127.0.0.1:52807
CoreDNS is running at https://127.0.0.1:52807/api/v1/namespaces/...
```

```bash
# ¿Cuántos Wagen tienes?
kubectl get nodes
```

```
NAME       STATUS   ROLES           AGE   VERSION
minikube   Ready    control-plane   1m    v1.28.0
```

Un solo Node. Control Plane y Worker en el mismo Wagen. Perfecto para aprender.

---

### Ejercicio 3 — ¿Qué hay corriendo por defecto?

Antes de desplegar nada, K8s ya tiene sus propios Pods internos. Veámoslos:

```bash
# Pods del sistema (los que mantienen K8s vivo)
kubectl get pods --namespace kube-system
```

```
NAME                               READY   STATUS    
coredns-5dd5756b68-x9tmk           1/1     Running   
etcd-minikube                      1/1     Running   
kube-apiserver-minikube            1/1     Running   
kube-controller-manager-minikube   1/1     Running   
kube-proxy-abc12                   1/1     Running   
kube-scheduler-minikube            1/1     Running   
storage-provisioner                1/1     Running   
```

Reconoces las caras: `kube-apiserver`, `etcd`, `kube-scheduler`, `kube-controller-manager`. Son los componentes del Control Plane corriendo como Pods dentro del propio cluster.

---

### Ejercicio 4 — Lanza tu primera app en el parking

Vamos a desplegar un servidor **nginx** (un servidor web simple) para ver K8s en acción por primera vez:

```bash
# Despliega nginx en el cluster
kubectl create deployment mi-primer-wagen --image=nginx

# ¿Se ha creado el Pod?
kubectl get pods
```

```
NAME                               READY   STATUS    RESTARTS   AGE
mi-primer-wagen-7d6b9c8f4-xk2p9   1/1     Running   0          15s
```

Tu primera app corriendo en Kubernetes. El Control Plane ha decidido en qué Node colocarla, el kubelet la ha arrancado y está lista.

---

### Ejercicio 5 — Accede a la app

El Pod está corriendo pero no es accesible desde fuera todavía. Vamos a exponerlo:

```bash
# Expón el deployment como un Service
kubectl expose deployment mi-primer-wagen --type=NodePort --port=80

# Abre la app en el navegador (minikube lo hace automático)
minikube service mi-primer-wagen
```

Se abrirá el navegador con la página de bienvenida de nginx. **Tu primera app en Kubernetes funcionando.**

---

### Ejercicio 6 — Escala la app

Ahora viene la magia. Vamos a tener 3 copias del nginx corriendo con un solo comando:

```bash
# Escala a 3 réplicas
kubectl scale deployment mi-primer-wagen --replicas=3

# Observa cómo arrancan los nuevos Pods
kubectl get pods
```

```
NAME                               READY   STATUS    RESTARTS   AGE
mi-primer-wagen-7d6b9c8f4-xk2p9   1/1     Running   0          2m
mi-primer-wagen-7d6b9c8f4-abc12   1/1     Running   0          5s
mi-primer-wagen-7d6b9c8f4-def34   1/1     Running   0          5s
```

Tres Pods. Tres copias de tu app. Un solo comando.

---

### Ejercicio 7 — Limpieza

```bash
# Elimina el deployment y el service
kubectl delete deployment mi-primer-wagen
kubectl delete service mi-primer-wagen

# Para el cluster
minikube stop
```

---

### 🎯 Reto opcional — El dashboard visual

```bash
minikube start
minikube dashboard
```

Se abre una interfaz web donde puedes ver en tiempo real todo lo que pasa en el cluster. Repite los ejercicios 4, 5 y 6 y observa cómo cambia el dashboard mientras ejecutas los comandos.

---

## ✅ Checklist de la lección

**Teoría**
- [ ] Entiendo qué problema resuelve Kubernetes
- [ ] Sé qué es un contenedor y cómo se relaciona con K8s
- [ ] Conozco la analogía Cluster/Node/Pod con el parking Daikoku
- [ ] Entiendo qué hace el Control Plane y qué hacen los Nodes

**Práctica**
- [ ] Tengo `kubectl` instalado y funcionando
- [ ] Tengo `minikube` arrancado y el cluster listo
- [ ] He explorado los Pods internos del sistema con `--namespace kube-system`
- [ ] He desplegado mi primera app con `kubectl create deployment`
- [ ] He escalado a 3 réplicas con `kubectl scale`
- [ ] He accedido a la app desde el navegador con `minikube service`

---

## 🔗 Recursos adicionales

- [Documentación oficial de Kubernetes](https://kubernetes.io/docs/home/)
- [Documentación de minikube](https://minikube.sigs.k8s.io/docs/)
- [Play with Kubernetes](https://labs.play-with-k8s.com/) — Practica en el navegador sin instalar nada

---

## ➡️ Siguiente lección

**[Lección 02 → Nodos: Los Wagen del parking](../02-nodos/README.md)**

En la próxima lección nos metemos dentro de los Nodos: qué son, qué componentes tienen, cómo inspeccionarlos y qué pasa cuando uno se avería.

---

<div align="center">

**¿Te ha sido útil esta lección?**  
Dale una ⭐ al repo y comparte el post en LinkedIn

[← Volver al índice](../README.md)

<sub>Proyecto Daikoku · Lección 01 de 16</sub>

</div>
