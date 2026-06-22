#!/bin/bash

# ============================================================
#  🚗 PROYECTO DAIKOKU — Lección 03
#  Pods: Los pasajeros del Wagen
#  github.com/madand1/daikoku
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

titulo()    { echo ""; echo -e "${BOLD}${BLUE}╔══════════════════════════════════════════╗${RESET}"; echo -e "${BOLD}${BLUE}║  $1${RESET}"; echo -e "${BOLD}${BLUE}╚══════════════════════════════════════════╝${RESET}"; echo ""; }
paso()      { echo -e "${BOLD}${CYAN}▶ $1${RESET}"; }
info()      { echo -e "${YELLOW}  💡 $1${RESET}"; }
ok()        { echo -e "${GREEN}  ✅ $1${RESET}"; }
error()     { echo -e "${RED}  ❌ $1${RESET}"; }
separador() { echo -e "${BLUE}  ────────────────────────────────────────${RESET}"; }
pausa()     { echo ""; echo -e "${YELLOW}  Pulsa ENTER para continuar...${RESET}"; read -r; }

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
echo -e "  ${BOLD}Lección 03 — Pods: Los pasajeros del Wagen${RESET}"
echo -e "  ${CYAN}github.com/madand1/daikoku${RESET}"
echo ""
separador
echo ""

# ============================================================
#  COMPROBACIONES
# ============================================================

titulo "0️⃣  Comprobando requisitos"

if ! command -v kubectl &>/dev/null; then error "kubectl no encontrado. Completa primero la Lección 01."; exit 1; fi
ok "kubectl: $(kubectl version --client --short 2>/dev/null | head -1)"
if ! command -v minikube &>/dev/null; then error "minikube no encontrado. Completa primero la Lección 01."; exit 1; fi
ok "minikube: $(minikube version --short 2>/dev/null)"

paso "Arrancando el cluster..."
minikube start --quiet
ok "Cluster listo."
pausa

# ============================================================
#  EJERCICIO 1 — Crear el primer Pod con YAML
# ============================================================

titulo "1️⃣  Creando tu primer Pod con YAML"

info "En K8s todo se define en YAML — el 'plano del coche'."
info "Describes cómo quieres el Pod y K8s lo construye."
echo ""

paso "Creando el manifiesto YAML..."
cat > /tmp/daikoku-pod.yaml << 'EOF'
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
      resources:
        requests:
          memory: "64Mi"
          cpu: "250m"
        limits:
          memory: "128Mi"
          cpu: "500m"
EOF

echo ""
info "El manifiesto tiene cuatro bloques clave:"
echo "    apiVersion → versión de la API de K8s"
echo "    kind       → tipo de objeto (Pod, Deployment, Service...)"
echo "    metadata   → nombre y etiquetas del Pod"
echo "    spec       → qué contenedores tiene y cómo se configuran"
echo ""

paso "Aplicando el manifiesto al cluster..."
kubectl apply -f /tmp/daikoku-pod.yaml
echo ""

paso "Esperando a que el Pod arranque..."
kubectl wait --for=condition=Ready pod/mi-primer-pod --timeout=60s
echo ""

paso "kubectl get pods — ¿Está corriendo?"
kubectl get pods -o wide
echo ""
ok "Pod corriendo. El pasajero está dentro del Wagen."
pausa

# ============================================================
#  EJERCICIO 2 — Inspeccionar el Pod
# ============================================================

titulo "2️⃣  Inspeccionando el Pod — kubectl describe"

info "describe pod es el comando más completo para ver qué pasa."
info "Fíjate en: Status, IP, Node, Containers y Events."
echo ""

paso "kubectl describe pod mi-primer-pod"
kubectl describe pod mi-primer-pod
echo ""

separador
info "La sección Events al final es clave para depurar problemas:"
echo "    Scheduled  → K8s asignó el Pod a un Node"
echo "    Pulling    → descargando la imagen"
echo "    Pulled     → imagen descargada"
echo "    Created    → contenedor creado"
echo "    Started    → contenedor arrancado"
pausa

# ============================================================
#  EJERCICIO 3 — Logs del contenedor
# ============================================================

titulo "3️⃣  Viendo los logs del contenedor"

info "kubectl logs es tu ventana al interior del contenedor."
info "Equivale a ver la consola de salida del proceso principal."
echo ""

paso "kubectl logs mi-primer-pod"
kubectl logs mi-primer-pod
echo ""

paso "kubectl logs mi-primer-pod --follow (10 segundos)"
info "Con --follow ves los logs en tiempo real. Ctrl+C para salir."
echo ""
timeout 10 kubectl logs mi-primer-pod --follow 2>/dev/null || true
echo ""
ok "Logs vistos. Muy útil para depurar cuando algo falla."
pausa

# ============================================================
#  EJERCICIO 4 — Entrar dentro del Pod
# ============================================================

titulo "4️⃣  Entrando dentro del Pod — kubectl exec"

info "kubectl exec permite ejecutar comandos dentro del contenedor."
info "Como hacer SSH pero dentro de un contenedor."
echo ""

paso "kubectl exec mi-primer-pod -- nginx -v"
kubectl exec mi-primer-pod -- nginx -v
echo ""

paso "kubectl exec mi-primer-pod -- ls /etc/nginx"
kubectl exec mi-primer-pod -- ls /etc/nginx
echo ""

paso "Entrando en modo interactivo..."
info "Ejecutamos una sesión bash dentro del Pod."
info "Escribe 'exit' cuando quieras salir."
echo ""
kubectl exec -it mi-primer-pod -- /bin/bash
echo ""
ok "Has salido del Pod. De vuelta en tu máquina."
pausa

# ============================================================
#  EJERCICIO 5 — Port-forward: acceder a la app
# ============================================================

titulo "5️⃣  Accediendo a la app — port-forward"

info "kubectl port-forward redirige un puerto local al Pod."
info "Así puedes acceder a la app sin exponer un Service."
echo ""

paso "Abriendo túnel localhost:8080 → Pod:80 (10 segundos)..."
info "Abre http://localhost:8080 en el navegador ahora."
echo ""
timeout 10 kubectl port-forward pod/mi-primer-pod 8080:80 &
PF_PID=$!
sleep 10
kill $PF_PID 2>/dev/null
echo ""
ok "Túnel cerrado."
pausa

# ============================================================
#  EJERCICIO 6 — Pod multi-contenedor
# ============================================================

titulo "6️⃣  Pod con dos contenedores — patrón Sidecar"

info "Un Pod puede tener varios contenedores que comparten red y disco."
info "El contenedor secundario se llama 'sidecar'."
info "Aquí: nginx (app) + un sidecar que escribe logs."
echo ""

paso "Creando Pod multi-contenedor..."
cat > /tmp/daikoku-sidecar.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: pod-sidecar
  labels:
    proyecto: daikoku
spec:
  containers:
    - name: nginx
      image: nginx:1.25
      ports:
        - containerPort: 80
    - name: logger
      image: busybox
      command: ["sh", "-c", "while true; do echo '[sidecar] $(date) - app corriendo'; sleep 5; done"]
EOF

kubectl apply -f /tmp/daikoku-sidecar.yaml
echo ""
kubectl wait --for=condition=Ready pod/pod-sidecar --timeout=60s
echo ""

paso "Los dos contenedores en el mismo Pod:"
kubectl get pod pod-sidecar -o jsonpath='{.spec.containers[*].name}' && echo ""
echo ""

paso "Logs del contenedor principal (nginx):"
kubectl logs pod-sidecar -c nginx
echo ""

paso "Logs del sidecar (logger):"
kubectl logs pod-sidecar -c logger
echo ""
info "Dos contenedores, un solo Pod, misma IP, mismo disco."
pausa

# ============================================================
#  EJERCICIO 7 — Ciclo de vida: ver un Pod fallar
# ============================================================

titulo "7️⃣  Ciclo de vida — qué pasa cuando un Pod falla"

info "Creamos un Pod que falla a propósito para ver cómo K8s reacciona."
echo ""

paso "Creando Pod con restart policy OnFailure..."
cat > /tmp/daikoku-fail.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: pod-que-falla
spec:
  restartPolicy: OnFailure
  containers:
    - name: falla
      image: busybox
      command: ["sh", "-c", "echo 'Arrancando...'; sleep 5; exit 1"]
EOF

kubectl apply -f /tmp/daikoku-fail.yaml
echo ""
info "Monitorizando durante 40 segundos..."
echo ""

for i in {1..8}; do
  echo -e "  ${CYAN}$(date '+%H:%M:%S')${RESET}"
  kubectl get pod pod-que-falla --no-headers 2>/dev/null
  echo ""
  sleep 5
done

echo ""
info "Has visto el Pod pasar por: Pending → Running → Error → CrashLoopBackOff"
info "CrashLoopBackOff = K8s sigue intentando arrancar el Pod con backoff exponencial"
pausa

# ============================================================
#  LIMPIEZA
# ============================================================

titulo "🧹 Limpieza"

kubectl delete pod mi-primer-pod pod-sidecar pod-que-falla --ignore-not-found
rm -f /tmp/daikoku-pod.yaml /tmp/daikoku-sidecar.yaml /tmp/daikoku-fail.yaml
minikube stop
echo ""
ok "Todo limpio. Parking cerrado."

# ============================================================
#  FIN
# ============================================================

echo ""
separador
echo ""
echo -e "  ${BOLD}🏁 Lección 03 completada${RESET}"
echo ""
echo -e "  ${CYAN}Lo que has hecho hoy:${RESET}"
echo "  → Creado tu primer Pod desde YAML"
echo "  → Inspeccionado un Pod con describe y logs"
echo "  → Entrado dentro del contenedor con exec"
echo "  → Accedido a la app con port-forward"
echo "  → Creado un Pod con patrón Sidecar"
echo "  → Visto el ciclo de vida y CrashLoopBackOff en tiempo real"
echo ""
echo -e "  ${CYAN}Siguiente:${RESET}"
echo "  → Lección 04: Tu primer Pod desde cero, paso a paso"
echo "  → cd ../04-primer-pod && bash leccion4.sh"
echo ""
separador
echo ""
