####################################################################
# Report the state of the OKD session of the current directory
#
# A diferencia de use_aws_sso_login, por defecto NO loguea solo: `oc
# login --web` abre una pestaña del navegador sin excepción, mientras
# que `aws sso login` reutiliza la sesión cacheada. Se habilita con
# USE_OKD_SESSION_AUTOLOGIN.
#
# Globals:
#   KUBECONFIG
#   USE_OKD_SESSION_DISABLE
#   USE_OKD_SESSION_AUTOLOGIN
#   USE_OKD_SESSION_DRY_RUN
# Arguments:
#   Label shown in the message, default "OKD"
#   Custom ttl in minutes for the session, default to 1440 (24h)
####################################################################
use_okd_session() {
  local label
  local ttl
  local kubeconfig
  local issued
  local expires
  local now
  local left

  local red
  local yellow
  local green
  local no_color

  label=${1:-OKD}
  ttl=${2:-1440}
  kubeconfig=${KUBECONFIG:-$PWD/.kube/config}

  # Define colors
  red="\033[31m"
  yellow="\033[33m"
  green="\033[32m"
  no_color="\033[0m"

  if [ -n "${USE_OKD_SESSION_DISABLE:-}" ]; then
    echo -e "${yellow}${label}: chequeo desactivado por 'USE_OKD_SESSION_DISABLE'${no_color}"
    return
  fi

  # Sin archivo o sin token nunca hubo login: no es un error, es el primer uso
  if [ ! -s "${kubeconfig}" ] || ! grep -qs '^[[:space:]]*token:' "${kubeconfig}"; then
    echo -e "${yellow}${label}: sin sesión${no_color} · oc login --web"
    return
  fi

  # El token de OpenShift es opaco y no lleva su vencimiento adentro. La fecha
  # del kubeconfig es cuando `oc login` lo escribió, que es cuando se emitió.
  issued=$(stat -c %Y "${kubeconfig}" 2>/dev/null)
  if [ -z "${issued:-}" ]; then
    echo -e "${yellow}${label}: no pude leer la fecha de ${kubeconfig}${no_color}"
    return
  fi

  expires=$(( issued + ttl * 60 ))
  now=$(date +%s)

  if [ "${now}" -lt "${expires}" ]; then
    left=$(( expires - now ))
    echo -e "${green}${label}: sesión hasta $(date -d @"${expires}" '+%H:%M') · faltan $(( left / 3600 ))h $(( left % 3600 / 60 ))m${no_color}"
    return
  fi

  echo -e "${red}${label}: sesión vencida${no_color} · oc login --web"

  [ -z "${USE_OKD_SESSION_AUTOLOGIN:-}" ] && return

  if [ -n "${USE_OKD_SESSION_DRY_RUN:-}" ]; then
    echo oc login --web
  else
    oc login --web
  fi
}
