################################################################################
# Retrieve age key files from Bitwarden
#
# Globals:
#   USE_SOPS_DISABLE
# Arguments:
#   Client name
#   Format for the Vaultwarden item, default to '${client} - Age - Private Key'
################################################################################
use_sops() {
  local client
  local format

  local red
  local yellow
  local no_color

  local key_name

  # Rename arguments
  client=$1
  export client
  format=${2:-${client} - Age - Private Key}

  # Define colors
  red="\033[31m"
  yellow="\033[33m"
  no_color="\033[0m"

  # Define variables
  key_name=$(echo $format | envsubst)

  # The SOPS file already exists
  if [ -f "$SOPS_AGE_KEY_FILE" ]; then
    return
  fi

  if [ -n "${USE_SOPS_DISABLE:-}" ]; then
    echo -e "${yellow}Disabled use_sops 'USE_SOPS_DISABLE'${no_color}"
    return
  fi

  if [ -z "$client" ]; then
    echo -e "${red}Missing client${no_color}"
    return
  fi

  if [ -z "$SOPS_AGE_KEY_FILE" ]; then
    echo -e "${red}Missing SOPS_AGE_KEY_FILE variable${no_color}"
    return
  fi

  # Get Bitwarden session token
  if [ -z "$BW_SESSION" ]; then
    BW_SESSION=$(bw unlock --raw)

    # Error in the login
    if [ $? -ne 0 ]; then
      return
    fi

    # Export for bw cli
    export BW_SESSION
  fi

  echo "# created: $(date +%Y-%m-%dT%T%:z)" >> "$SOPS_AGE_KEY_FILE"
  username=$(bw get username "$key_name" 2> /dev/null)
  if [ $? -eq 0 ]; then
    echo "# public key: $username" >> "$SOPS_AGE_KEY_FILE"
  else
    echo -e "${yellow}Public key not found as username at '${key_name}'${no_color}"
  fi

  password=$(bw get password "$key_name" 2> /dev/null)
  if [ $? -eq 0 ]; then
    echo "$password" >> "$SOPS_AGE_KEY_FILE"
  else
    echo -e "${red}Private key not found as password at '${key_name}'${no_color}"
    rm "$SOPS_AGE_KEY_FILE"
  fi
}
