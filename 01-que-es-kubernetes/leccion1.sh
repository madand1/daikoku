#!/bin/bash

# ============================================================
#  🚗 PROYECTO DAIKOKU — Lección 01
#  ¿Qué es Kubernetes? El parking inteligente
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

# Funciones de utilidad
titulo() {
  echo ""
  echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${RESET}"
  echo -e "${BOLD}${BLUE}║  $1${RESET}"
  echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${RESET}"
  echo ""
}

paso() {
  echo -e "${BOLD}${CYAN}▶ $1${RESET}"
}

info() {
  echo -e "${YELLOW}  💡 $1${RESET}"
}

ok() {
  echo -e "${GREEN}  ✅ $1${RESET}"
}

error() {
  echo -e "${RED}  ❌ $1${RESET}"
}

pausa() {
  echo ""
  echo -e "${YELLOW}  Pulsa ENTER para continuar...${RESET}"
  read -r
}

separador() {
  echo -e "${BLUE}  ────────────────────────────────────────${RESET}"
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
echo -e "  ${BOLD}Lección 01 — ¿Qué es Kubernetes?${RESET}"
echo -e "  ${CYAN}github.com/madand1/daikoku${RESET}"
echo ""
separador
echo ""

# ============================================================
#  DETECTAR EL SISTEMA OPERATIVO
# ============================================================

detectar_os() {
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    if command -v apt-get &>/dev/null; then
      OS="debian"
    elif command -v dnf &>/dev/null; then
      OS="fedora"
    elif command -v pacman &>/dev/null; then
      OS="arch"
    else
      OS="linux"
    fi
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
  else
    OS="unknown"
  fi
}

detectar_os
info "Sistema detectado: $OSTYPE → tratando como '$OS'"

# ============================================================
#  INSTALACIÓN — kubectl
# ============================================================

titulo "0️⃣  Instalando kubectl"

if command -v kubectl &>/dev/null; then
  ok "kubectl ya está instalado: $(kubectl version --client --short 2>/dev/null | head -1)"
else
  info "kubectl no encontrado. Instalando..."
  echo ""

  case "$OS" in
    debian)
      paso "Instalando kubectl en Debian/Ubuntu..."
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      ;;
    fedora)
      paso "Instalando kubectl en Fedora/RHEL..."
      curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
      chmod +x kubectl
      sudo mv kubectl /usr/local/bin/
      ;;
    arch)
      paso "Instalando kubectl en Arch Linux..."
      sudo pacman -Sy --noconfirm kubectl
      ;;
    macos)
      paso "Instalando kubectl en macOS con Homebrew..."
      if ! command -v brew &>/dev/null; then
        error "Homebrew no encontrado. Instálalo desde https://brew.sh"
        exit 1
      fi
      brew install kubectl
      ;;
    *)
      error "Sistema no reconocido. Instala kubectl manualmente:"
      echo "  https://kubernetes.io/docs/tasks/tools/"
      exit 1
      ;;
  esac

  echo ""
  if command -v kubectl &>/dev/null; then
    ok "kubectl instalado correctamente: $(kubectl version --client --short 2>/dev/null | head -1)"
  else
    error "Algo fue mal instalando kubectl. Revisa los errores de arriba."
    exit 1
  fi
fi

pausa

# ============================================================
#  INSTALACIÓN — minikube
# ============================================================

titulo "0️⃣  Instalando minikube"

if command -v minikube &>/dev/null; then
  ok "minikube ya está instalado: $(minikube version --short 2>/dev/null)"
else
  info "minikube no encontrado. Instalando..."
  echo ""

  case "$OS" in
    debian|fedora|linux)
      paso "Instalando minikube en Linux..."
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube
      rm minikube-linux-amd64
      ;;
    arch)
      paso "Instalando minikube en Arch Linux..."
      sudo pacman -Sy --noconfirm minikube
      ;;
    macos)
      paso "Instalando minikube en macOS con Homebrew..."
      brew install minikube
      ;;
    *)
      error "Sistema no reconocido. Instala minikube manualmente:"
      echo "  https://minikube.sigs.k8s.io/docs/start/"
      exit 1
      ;;
  esac

  echo ""
  if command -v minikube &>/dev/null; then
    ok "minikube instalado correctamente: $(minikube version --short 2>/dev/null)"
  else
    error "Algo fue mal instalando minikube. Revisa los errores de arriba."
    exit 1
  fi
fi

pausa

# ============================================================
#  EJERCICIO 1 — Arrancar el cluster
# ============================================================

titulo "1️⃣  Arrancando tu parking (minikube start)"

info "minikube crea un cluster de Kubernetes en tu máquina local."
info "Es tu Daikoku personal — un solo Wagen que hace de todo."
echo ""

paso "Ejecutando: minikube start"
echo ""
minikube start

echo ""
if minikube status | grep -q "Running"; then
  ok "¡El parking está abierto!"
else
  error "Algo fue mal arrancando minikube. Revisa el output de arriba."
  exit 1
fi

pausa

# ============================================================
#  EJERCICIO 2 — Explorar el cluster
# ============================================================

titulo "2️⃣  Explorando el cluster"

paso "kubectl cluster-info — ¿Está el parking operativo?"
echo ""
kubectl cluster-info
echo ""
separador

paso "kubectl get nodes — ¿Cuántos Wagen tenemos?"
echo ""
kubectl get nodes
echo ""
info "Un solo Node (minikube) haciendo de Control Plane y Worker a la vez."
info "En producción estos roles siempre van separados."

pausa

# ============================================================
#  EJERCICIO 3 — Ver Pods internos del sistema
# ============================================================

titulo "3️⃣  Pods internos — lo que K8s necesita para vivir"

info "Antes de desplegar nada, Kubernetes ya tiene sus propios Pods."
info "Están en un Namespace especial llamado 'kube-system'."
echo ""

paso "kubectl get pods --namespace kube-system"
echo ""
kubectl get pods --namespace kube-system
echo ""
info "Reconoces las caras: kube-apiserver, etcd, kube-scheduler..."
info "Son los componentes del Control Plane corriendo como Pods."

pausa

# ============================================================
#  EJERCICIO 4 — Primera app en el parking
# ============================================================

titulo "4️⃣  Tu primera app en Kubernetes"

info "Vamos a desplegar un servidor nginx (servidor web simple)."
info "nginx es el 'Hola Mundo' de Kubernetes."
echo ""

paso "kubectl create deployment mi-primer-wagen --image=nginx"
kubectl create deployment mi-primer-wagen --image=nginx
echo ""

paso "Esperando a que el Pod arranque..."
kubectl rollout status deployment/mi-primer-wagen
echo ""

paso "kubectl get pods — ¿Está corriendo?"
echo ""
kubectl get pods
echo ""
ok "Tu primera app está corriendo en Kubernetes."

pausa

# ============================================================
#  EJERCICIO 5 — Exponer la app
# ============================================================

titulo "5️⃣  Exponer la app al mundo"

info "El Pod corre pero no es accesible desde fuera todavía."
info "Necesitamos un Service de tipo NodePort para exponerlo."
echo ""

paso "kubectl expose deployment mi-primer-wagen --type=NodePort --port=80"
kubectl expose deployment mi-primer-wagen --type=NodePort --port=80
echo ""

paso "kubectl get services — Ver el Service creado"
echo ""
kubectl get services
echo ""

paso "minikube service mi-primer-wagen — Abre la app en el navegador"
minikube service mi-primer-wagen

pausa

# ============================================================
#  EJERCICIO 6 — Escalar a 3 réplicas
# ============================================================

titulo "6️⃣  Escalando la app — aquí es donde K8s enamora"

info "Con un solo comando pasamos de 1 Pod a 3."
info "K8s decide dónde colocar cada uno automáticamente."
echo ""

paso "kubectl scale deployment mi-primer-wagen --replicas=3"
kubectl scale deployment mi-primer-wagen --replicas=3
echo ""

paso "Esperando a que los Pods estén listos..."
kubectl rollout status deployment/mi-primer-wagen
echo ""

paso "kubectl get pods — Ahora somos tres"
echo ""
kubectl get pods
echo ""
ok "3 réplicas corriendo. 1 comando. Eso es Kubernetes."

pausa

# ============================================================
#  EJERCICIO 7 — Limpieza
# ============================================================

titulo "7️⃣  Limpieza"

info "Eliminamos lo que hemos creado para dejar el cluster limpio."
echo ""

paso "kubectl delete deployment mi-primer-wagen"
kubectl delete deployment mi-primer-wagen

paso "kubectl delete service mi-primer-wagen"
kubectl delete service mi-primer-wagen

paso "minikube stop"
minikube stop

echo ""
ok "Cluster parado. Parking cerrado por hoy."

# ============================================================
#  FIN
# ============================================================

echo ""
separador
echo ""
echo -e "  ${BOLD}🏁 Lección 01 completada${RESET}"
echo ""
echo -e "  ${CYAN}Lo que has hecho hoy:${RESET}"
echo "  → Instalado kubectl y minikube"
echo "  → Arrancado tu primer cluster con minikube"
echo "  → Explorado los componentes internos de K8s"
echo "  → Desplegado tu primera app (nginx)"
echo "  → Escalado de 1 a 3 réplicas con un comando"
echo ""
echo -e "  ${CYAN}Siguiente:${RESET}"
echo "  → Lección 02: Los Nodos por dentro"
echo "  → cd ../02-nodos && bash practica.sh"
echo ""
separador
echo ""
