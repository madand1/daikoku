#!/bin/bash

# ============================================================
#  🚗 PROYECTO DAIKOKU — Lección 04
#  Tu primer Pod desde cero
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
echo -e "  ${BOLD}Lección 04 — Tu primer Pod desde cero${RESET}"
echo -e "  ${CYAN}github.com/madand1/daikoku${RESET}"
echo ""
separador
echo ""

# ============================================================
#  COMPROBACIONES
# ============================================================

titulo "0️⃣  Comprobando requisitos"

if ! command -v kubectl &>/dev/null; then error "kubectl no encontrado. Completa la Lección 01."; exit 1; fi
ok "kubectl: $(kubectl version --client --short 2>/dev/null | head -1)"
if ! command -v minikube &>/dev/null; then error "minikube no encontrado. Completa la Lección 01."; exit 1; fi
ok "minikube: $(minikube version --short 2>/dev/null)"

paso "Arrancando el cluster..."
minikube start --quiet
ok "Cluster listo."
pausa

# ============================================================
#  EJERCICIO 1 — Pod completo con todos los campos
# ============================================================

titulo "1️⃣  Pod completo — todos los campos importantes"

info "Vamos a crear un Pod con todo lo que se usa en producción:"
echo "    → variables de entorno"
echo "    → límites de recursos"
echo "    → health checks"
echo ""

paso "Creando manifiesto completo..."
cat > /tmp/wagen-completo.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: wagen-completo
  labels:
    app: mi-app
    version: "1.0"
    entorno: desarrollo
  annotations:
    descripcion: "Pod de práctica - Daikoku Lección 04"
spec:
  containers:
    - name: app
      image: nginx:1.25
      ports:
        - containerPort: 80
          name: http
      env:
        - name: ENTORNO
          value: "desarrollo"
        - name: VERSION
          value: "1.0"
        - name: PROYECTO
          value: "daikoku"
      resources:
        requests:
          memory: "64Mi"
          cpu: "100m"
        limits:
          memory: "128Mi"
          cpu: "500m"
      livenessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 10
        periodSeconds: 10
      readinessProbe:
        httpGet:
          path: /
          port: 80
        initialDelaySeconds: 5
        periodSeconds: 5
  restartPolicy: Always
EOF

paso "kubectl apply -f wagen-completo.yaml"
kubectl apply -f /tmp/wagen-completo.yaml
echo ""

paso "Esperando a que el Pod esté Ready..."
kubectl wait --for=condition=Ready pod/wagen-completo --timeout=90s
echo ""
kubectl get pod wagen-completo -o wide
echo ""
ok "Pod corriendo con todos los campos configurados."
pausa

# ============================================================
#  EJERCICIO 2 — Variables de entorno
# ============================================================

titulo "2️⃣  Variables de entorno — leerlas desde dentro"

info "Las variables de entorno permiten configurar el contenedor"
info "sin tocar el código ni la imagen."
echo ""

paso "Leyendo las variables desde dentro del contenedor:"
echo ""
kubectl exec wagen-completo -- env | grep -E "ENTORNO|VERSION|PROYECTO"
echo ""
info "Esas variables las definiste en el YAML bajo 'env:'."
info "El contenedor las ve como si fueran variables del sistema."
pausa

# ============================================================
#  EJERCICIO 3 — Health checks en acción
# ============================================================

titulo "3️⃣  Health checks — liveness y readiness"

info "K8s comprueba periódicamente si el Pod está sano."
echo ""
echo "    livenessProbe  → ¿sigue vivo? Si falla: reinicia"
echo "    readinessProbe → ¿listo para tráfico? Si falla: sale de rotación"
echo ""

paso "Viendo el estado de las probes en describe:"
kubectl describe pod wagen-completo | grep -A15 "Liveness\|Readiness"
echo ""

paso "Condiciones actuales del Pod:"
kubectl get pod wagen-completo -o jsonpath='{.status.conditions[*].type}' && echo ""
kubectl get pod wagen-completo -o jsonpath='{.status.conditions[*].status}' && echo ""
echo ""
info "Ready=True significa que el Pod pasó el readinessProbe"
info "y está en rotación para recibir tráfico."
pausa

# ============================================================
#  EJERCICIO 4 — Init containers
# ============================================================

titulo "4️⃣  Init containers — preparando el Wagen antes de salir"

info "Los init containers se ejecutan ANTES que el contenedor principal."
info "Deben terminar con éxito para que el Pod arranque."
echo ""

paso "Creando Pod con init container..."
cat > /tmp/wagen-init.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: wagen-init
spec:
  initContainers:
    - name: preparacion
      image: busybox
      command: ["sh", "-c", "echo '🔧 Init: preparando el Wagen...'; sleep 5; echo '✅ Init completado.'"]
  containers:
    - name: app
      image: nginx:1.25
      ports:
        - containerPort: 80
EOF

kubectl apply -f /tmp/wagen-init.yaml
echo ""
info "Observa cómo el Pod pasa por 'Init' antes de Running:"
echo ""

for i in {1..8}; do
  echo -e "  ${CYAN}$(date '+%H:%M:%S')${RESET}"
  kubectl get pod wagen-init --no-headers 2>/dev/null
  echo ""
  sleep 3
done

echo ""
paso "Logs del init container:"
kubectl logs wagen-init -c preparacion
echo ""
ok "El init terminó, luego arrancó el contenedor principal."
pausa

# ============================================================
#  EJERCICIO 5 — kubectl apply para actualizar
# ============================================================

titulo "5️⃣  Actualizando un Pod con kubectl apply"

info "kubectl apply detecta cambios y actualiza el objeto."
info "No hace falta borrar y volver a crear."
echo ""

paso "Cambiando la versión de la variable VERSION a '2.0'..."
sed -i 's/value: "1.0"/value: "2.0"/' /tmp/wagen-completo.yaml
echo ""

paso "kubectl apply -f wagen-completo.yaml (con el cambio)"
kubectl apply -f /tmp/wagen-completo.yaml
echo ""

paso "Comprobando la nueva variable dentro del contenedor:"
sleep 3
kubectl exec wagen-completo -- env | grep VERSION
echo ""
ok "Variable actualizada sin borrar el Pod."
pausa

# ============================================================
#  EJERCICIO 6 — Depurar un Pod con error
# ============================================================

titulo "6️⃣  Depurando un Pod que falla — flujo de diagnóstico"

info "Creamos un Pod con una imagen que no existe para ver el error."
echo ""

paso "Creando Pod con imagen inexistente..."
cat > /tmp/wagen-error.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: wagen-error
spec:
  containers:
    - name: app
      image: imagen-que-no-existe:latest
EOF

kubectl apply -f /tmp/wagen-error.yaml
sleep 10
echo ""

paso "Paso 1 — kubectl get pods (ver el estado)"
kubectl get pods
echo ""

paso "Paso 2 — kubectl describe pod wagen-error (ver la causa)"
kubectl describe pod wagen-error | tail -20
echo ""
info "Fíjate en los Events: ImagePullBackOff o ErrImagePull"
info "Significa que K8s no puede descargar la imagen."
echo ""

paso "Paso 3 — kubectl logs wagen-error (ver logs si los hay)"
kubectl logs wagen-error 2>&1 || echo "  (No hay logs — el contenedor nunca arrancó)"
echo ""

info "Flujo de diagnóstico siempre:"
echo "    1. kubectl get pods           → ver estado"
echo "    2. kubectl describe pod X     → ver causa exacta"
echo "    3. kubectl logs X             → ver logs del contenedor"
echo "    4. kubectl logs X --previous  → logs del intento anterior"
echo "    5. kubectl exec -it X -- sh   → entrar si el Pod arranca"
pausa

# ============================================================
#  LIMPIEZA
# ============================================================

titulo "🧹 Limpieza"

kubectl delete pod wagen-completo wagen-init wagen-error --ignore-not-found
rm -f /tmp/wagen-completo.yaml /tmp/wagen-init.yaml /tmp/wagen-error.yaml
minikube stop
echo ""
ok "Todo limpio."

# ============================================================
#  FIN
# ============================================================

echo ""
separador
echo ""
echo -e "  ${BOLD}🏁 Lección 04 completada${RESET}"
echo ""
echo -e "  ${CYAN}Lo que has hecho hoy:${RESET}"
echo "  → Escrito un manifiesto YAML completo desde cero"
echo "  → Configurado variables de entorno y leído desde dentro"
echo "  → Visto liveness y readiness probes en acción"
echo "  → Creado y depurado un init container"
echo "  → Actualizado un Pod con kubectl apply"
echo "  → Diagnosticado un Pod con error usando describe y logs"
echo ""
echo -e "  ${CYAN}Con esto termina la Temporada 1 — Fundamentos.${RESET}"
echo ""
echo -e "  ${CYAN}Siguiente → Temporada 2: El taller mecánico${RESET}"
echo "  → Lección 05: Deployments — la fábrica de clones"
echo "  → cd ../05-deployments && bash leccion5.sh"
echo ""
separador
echo ""
