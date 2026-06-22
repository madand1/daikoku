#!/bin/bash

# ============================================================
#  🚗 PROYECTO DAIKOKU — Lección 02
#  Nodos: Los Wagen del parking
#  github.com/madand1/daikoku
# ============================================================

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

titulo() {
  echo ""
  echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║  $1${RESET}"
  echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${RESET}"
  echo ""
}

paso() { echo -e "${BOLD}${CYAN}▶ $1${RESET}"; }
info() { echo -e "${YELLOW}  💡 $1${RESET}"; }
ok()   { echo -e "${GREEN}  ✅ $1${RESET}"; }
error(){ echo -e "${RED}  ❌ $1${RESET}"; }
separador() { echo -e "${BLUE}  ────────────────────────────────────────${RESET}"; }

pausa() {
  echo ""
  echo -e "${YELLOW}  Pulsa ENTER para continuar...${RESET}"
  read -r
}

# ============================================================
#  INICIO
# ============================================================

clear

echo ""
echo -e "${BOLD}${BLUE}"
echo "  ██████╗  █████╗ ██╗██╗  ██╗ ██████╗ ██╗  ██╗██╗   ██╗"
echo "  ██╔══██╗██╔══██╗██║██║ ██╔╝██╔═══██╗██║ ██╔╝██║   ██║"
echo "  ██║  ██║███████║██║█████╔╝ ██║   ██║█████╔╝ ██║   ██║"
echo "  ██║  ██║██╔══██║██║██╔═██╗ ██║   ██║██╔═██╗ ██║   ██║"
echo "  ██████╔╝██║  ██║██║██║  ██╗╚██████╔╝██║  ██╗╚██████╔╝"
echo "  ╚═════╝ ╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ "
echo -e "${RESET}"
echo -e "  ${BOLD}Lección 02 — Nodos: Los Wagen del parking${RESET}"
echo -e "  ${CYAN}github.com/madand1/daikoku${RESET}"
echo ""
separador
echo ""

# ============================================================
#  COMPROBACIONES PREVIAS
# ============================================================

titulo "0️⃣  Comprobando requisitos"

if ! command -v kubectl &>/dev/null; then
  error "kubectl no encontrado. Completa primero la Lección 01."
  exit 1
fi
ok "kubectl: $(kubectl version --client --short 2>/dev/null | head -1)"

if ! command -v minikube &>/dev/null; then
  error "minikube no encontrado. Completa primero la Lección 01."
  exit 1
fi
ok "minikube: $(minikube version --short 2>/dev/null)"

pausa

# ============================================================
#  EJERCICIO 1 — Arrancar y observar el primer Wagen
# ============================================================

titulo "1️⃣  Arrancando el cluster"

info "Un Node es la máquina donde realmente corre tu app."
info "Puede ser un servidor físico, una VM o tu propia máquina."
echo ""

paso "minikube start"
minikube start
echo ""

if minikube status | grep -q "Running"; then
  ok "Cluster arrancado. El parking está abierto."
else
  error "Error arrancando minikube."
  exit 1
fi

pausa

# ============================================================
#  EJERCICIO 2 — get nodes básico y -o wide
# ============================================================

titulo "2️⃣  Inspeccionando los Wagen"

paso "kubectl get nodes — Vista básica"
echo ""
kubectl get nodes
echo ""
info "STATUS Ready = el Wagen está operativo y acepta Pods."
echo ""
separador
echo ""

paso "kubectl get nodes -o wide — Vista completa"
echo ""
kubectl get nodes -o wide
echo ""
info "INTERNAL-IP      → IP del Node dentro del cluster"
info "OS-IMAGE         → sistema operativo del Node"
info "CONTAINER-RUNTIME → quién ejecuta los contenedores (containerd, CRI-O...)"
info "  K8s no usa Docker directamente desde la v1.24."

pausa

# ============================================================
#  EJERCICIO 3 — describe node
# ============================================================

titulo "3️⃣  Diseccionando el Wagen — kubectl describe"

info "describe node es el comando más completo para inspeccionar un Node."
info "Fíjate especialmente en: Conditions, Capacity y Allocatable."
echo ""

paso "kubectl describe node minikube"
echo ""
kubectl describe node minikube
echo ""

separador
echo ""
echo -e "  ${BOLD}Las Conditions te dicen si el Wagen está sano:${RESET}"
echo ""
echo "    MemoryPressure  False → RAM suficiente"
echo "    DiskPressure    False → Disco suficiente"
echo "    PIDPressure     False → Procesos bajo control"
echo "    Ready           True  → Node operativo y aceptando Pods"
echo ""
echo -e "  ${BOLD}Capacity vs Allocatable:${RESET}"
echo ""
echo "    Capacity    → recursos físicos totales del Node"
echo "    Allocatable → lo que queda para tus Pods"
echo "                  (K8s se reserva parte para sí mismo)"

pausa

# ============================================================
#  EJERCICIO 4 — Ver los Pods que corren en el Node
# ============================================================

titulo "4️⃣  ¿Qué Pods están corriendo en el Wagen?"

info "Podemos filtrar los Pods por Node directamente."
echo ""

paso "kubectl get pods --all-namespaces --field-selector spec.nodeName=minikube"
echo ""
kubectl get pods --all-namespaces --field-selector spec.nodeName=minikube
echo ""
info "Aquí ves todos los Pods del sistema que viven en este Node."
info "El kubelet de este Node es quien los mantiene vivos."

pausa

# ============================================================
#  EJERCICIO 5 — Añadir un segundo Wagen
# ============================================================

titulo "5️⃣  Añadiendo un segundo Wagen al parking"

info "minikube permite simular un cluster multi-nodo."
info "Vamos a añadir un Worker Node independiente."
echo ""

paso "minikube node add"
echo ""
minikube node add
echo ""

paso "kubectl get nodes — Ahora tenemos dos Wagen"
echo ""
kubectl get nodes
echo ""
ok "Control Plane y Worker Node separados. Así es en producción."

pausa

# ============================================================
#  EJERCICIO 6 — Etiquetar los Wagen con Labels
# ============================================================

titulo "6️⃣  Poniendo matrícula a cada Wagen — Labels"

info "Los Labels son etiquetas clave=valor para identificar objetos en K8s."
info "Más adelante los usaremos para decirle a K8s dónde colocar cada Pod."
echo ""

paso "Etiquetando el Worker Node..."
kubectl label node minikube-m02 tipo=worker entorno=practicas --overwrite 2>/dev/null
echo ""

paso "kubectl get nodes --show-labels"
echo ""
kubectl get nodes --show-labels
echo ""
info "El Worker Node ahora tiene: tipo=worker y entorno=practicas."
info "Kubernetes también añade sus propios labels automáticamente."

pausa

# ============================================================
#  EJERCICIO 7 — Simular el fallo de un Wagen
# ============================================================

titulo "7️⃣  Simulando el fallo de un Wagen"

info "Vamos a parar el Worker Node para ver cómo K8s detecta el fallo."
info "El proceso:"
echo ""
echo "    T+0s   Node deja de enviar heartbeats"
echo "    T+40s  Node pasa a Unknown"
echo "    T+5min Node pasa a NotReady → K8s reubica los Pods"
echo ""

paso "Parando minikube-m02..."
minikube node stop minikube-m02
echo ""

info "Monitorizando el estado durante 45 segundos..."
echo ""

for i in {1..9}; do
  echo -e "  ${CYAN}$(date '+%H:%M:%S')${RESET}"
  kubectl get nodes --no-headers 2>/dev/null
  echo ""
  sleep 5
done

echo ""
info "Has visto cómo el Node pasa de Ready → Unknown."
info "Con más tiempo llegaría a NotReady y K8s movería los Pods."

pausa

# ============================================================
#  EJERCICIO 8 — Recuperar el Wagen caído
# ============================================================

titulo "8️⃣  Recuperando el Wagen caído"

paso "minikube node start minikube-m02"
minikube node start minikube-m02
echo ""

paso "kubectl get nodes — ¿Volvió el Wagen?"
echo ""
kubectl get nodes
echo ""
ok "Node recuperado. K8s lo reincorpora al cluster automáticamente."
info "Sin intervención manual. Sin alarmas a las 3am."

pausa

# ============================================================
#  RETO OPCIONAL — Taints
# ============================================================

titulo "🎯 Reto opcional — Zona reservada con Taints"

info "Un Taint marca un Node como zona restringida."
info "Los Pods normales no pueden entrar sin la Toleration correcta."
echo ""
echo "    Node con Taint zona=gpu:NoSchedule"
echo "    ├── Pod sin Toleration → ❌ No puede entrar"
echo "    └── Pod con Toleration → ✅ Puede entrar"
echo ""

paso "Aplicando Taint al Worker Node..."
kubectl taint node minikube-m02 zona=gpu:NoSchedule 2>/dev/null || \
  echo "  (Taint ya existente)"
echo ""

paso "Comprobando el Taint:"
kubectl describe node minikube-m02 | grep -A3 "Taints"
echo ""

info "Ahora ningún Pod irá a ese Node salvo que tenga la Toleration."
echo ""

paso "Eliminando el Taint (el - al final lo borra)..."
kubectl taint node minikube-m02 zona=gpu:NoSchedule-
echo ""
ok "Taint eliminado. Node disponible de nuevo."

pausa

# ============================================================
#  LIMPIEZA
# ============================================================

titulo "🧹 Limpieza"

paso "Eliminando el segundo Node..."
minikube node delete minikube-m02
echo ""

paso "Parando el cluster..."
minikube stop
echo ""
ok "Cluster parado. Parking vacío."

# ============================================================
#  FIN
# ============================================================

echo ""
separador
echo ""
echo -e "  ${BOLD}🏁 Lección 02 completada${RESET}"
echo ""
echo -e "  ${CYAN}Lo que has hecho hoy:${RESET}"
echo "  → Inspeccionado Nodes con get nodes -o wide y describe"
echo "  → Visto los Pods del sistema corriendo en el Node"
echo "  → Añadido un segundo Node con minikube node add"
echo "  → Etiquetado Nodes con kubectl label"
echo "  → Simulado el fallo de un Node en tiempo real"
echo "  → Aplicado y eliminado un Taint"
echo ""
echo -e "  ${CYAN}Siguiente:${RESET}"
echo "  → Lección 03: Pods — los pasajeros del Wagen"
echo "  → cd ../03-pods && bash leccion3.sh"
echo ""
separador
echo ""
