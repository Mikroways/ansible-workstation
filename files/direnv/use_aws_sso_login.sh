####################################################################
# Execute, if is needed, the aws sso login command for every profile
#
# Globals:
#   USE_AWS_SSO_LOGIN_DISABLE
#   USE_AWS_SSO_LOGIN_DRY_RUN
# Arguments:
#   Custom ttl in minutes for the sso session, default to 60
####################################################################
use_aws_sso_login() {
  local sso_ttl
  local profiles

  local red
  local yellow
  local green
  local no_color


  sso_ttl=${1:-60}
  profiles=""

  # Define colors
  red="\033[31m"
  yellow="\033[33m"
  green="\033[32m"
  no_color="\033[0m"

  if [ -n "${USE_AWS_SSO_LOGIN_DISABLE:-}" ]; then
    echo -e "${yellow}Disabled auto login by variable 'USE_AWS_SSO_LOGIN_DISABLE'${no_color}"
    return
  fi

  # Retrieve the expiration timestamp
  [ -f "$PWD/.sso-login-expire" ] && sso_login_expire=$(cat "$PWD/.sso-login-expire")

  # Check if the session is expired
  if [ ! "${sso_login_expire:-0}" -lt "$(date +%s)" ]; then
    echo -e "${green}AWS SSO session until $(date -d @"${sso_login_expire}" +%H:%M:%S)${no_color}"
    return
  fi

  # Retrieve all the profiles that match two rules
  profiles=$(env | { grep PROFILE || test $? = 1; } | { grep mw_ || test $? = 1; } | cut -d"=" -f 2 | sort | uniq)

  if [ -z "${profiles}" ]; then
    echo -e "${yellow}No profiles found${no_color}"
    return
  fi

  echo -e "${red}Expired AWS SSO session${no_color}"

  for profile in $profiles; do
    if [ -n "${USE_AWS_SSO_LOGIN_DRY_RUN:-}" ]; then
      echo aws sso login --profile "${profile}"
    else
      aws sso login --profile "${profile}"
    fi
  done

  if [ -n "${USE_AWS_SSO_LOGIN_DRY_RUN:-}" ]; then
    echo "date +%s --date='+${sso_ttl} minutes' > $PWD/.sso-login-expire"
  else
    date +%s --date="+${sso_ttl} minutes" > "$PWD/.sso-login-expire"
  fi
}
