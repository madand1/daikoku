# 🚗 Daikoku

Decidí aprender Kubernetes de verdad. No el típico tutorial de 10 minutos que te deja igual que antes — sino entenderlo de verdad, desde cero, sin saltarme nada.

Y para no aburrirme en el proceso, lo voy a explicar todo usando coches.

---

## Por qué coches

**Daikoku Futo** es un parking en Yokohama, Japón. Cada noche aparecen cientos de coches increíbles, todos distintos, todos conviviendo en el mismo espacio de forma organizada. Cuando lo vi por primera vez pensé: *esto es exactamente lo que hace Kubernetes*.

Así que en este repo cada concepto de Kubernetes tiene su equivalente en el mundo de los coches — a los que llamo **Wagen**. El cluster es el parking. Los nodos son los coches. Los pods son los pasajeros. Y así todo.

---

## Cómo funciona esto

Voy publicando lecciones a medida que las aprendo y las entiendo bien. Cada lección sale primero en LinkedIn y luego llega aquí documentada.

No hay fechas fijas. Sale cuando sale, pero con calidad.

### 🟢 Temporada 1 — Llegando a Daikoku

| # | Lección | |
|---|---------|--|
| 01 | [¿Qué es Kubernetes? El parking inteligente](./01-que-es-kubernetes/README.md) | ✅ |
| 02 | Nodos: Los coches del parking | 🔜 |
| 03 | Pods: ¿Cuántos van dentro del coche? | 🔜 |
| 04 | Tu primer Pod desde cero | 🔜 |

### 🟡 Temporada 2 — El taller mecánico

| # | Lección | |
|---|---------|--|
| 05 | Deployments: La fábrica de clones | 🔒 |
| 06 | ReplicaSets: Por qué siempre hay 3 coches iguales | 🔒 |
| 07 | Services: Las carreteras entre coches | 🔒 |
| 08 | Namespaces: Las zonas del parking | 🔒 |

### 🔴 Temporada 3 — Tuning avanzado

| # | Lección | |
|---|---------|--|
| 09 | ConfigMaps y Secrets: El cuadro de mandos y la llave | 🔒 |
| 10 | Volumes: El maletero persistente | 🔒 |
| 11 | Ingress: La autopista de entrada | 🔒 |
| 12 | HPA: Llamar refuerzos automáticamente | 🔒 |

### ⚫ Temporada 4 — El jefe del parking

| # | Lección | |
|---|---------|--|
| 13 | RBAC: Quién puede aparcar dónde | 🔒 |
| 14 | Helm: El catálogo de coches de serie | 🔒 |
| 15 | Monitorización con Prometheus y Grafana | 🔒 |
| 16 | CI/CD con Kubernetes | 🔒 |

---

## La tabla de traducción Wagen ↔ K8s

Por si en algún momento te pierdes con la analogía:

| En el parking | En Kubernetes |
|---|---|
| El parking Daikoku entero | Cluster |
| La sala de control | Control Plane |
| Un coche (Wagen) | Node |
| Los pasajeros | Pod |
| Cada asiento | Container |
| La fábrica de coches | Deployment |
| Las carreteras | Service |
| Zonas del parking | Namespace |
| La entrada/salida | Ingress |
| El cuadro de mandos | ConfigMap |
| La llave del coche | Secret |
| Pedir más coches | HPA |

---

## Lo que necesitas para seguir las lecciones

- `kubectl` — para hablar con el cluster desde la terminal
- `minikube` — tu parking en local para practicar
- Ganas de aprender (lo otro se instala en 5 minutos)

---

Si algo está mal explicado, abre un issue. Si tienes una analogía mejor, abre un PR. Esto es un aprendizaje compartido.

