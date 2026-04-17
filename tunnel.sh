#! /bin/bash

trap ctrl_c INT SIGINT SIGTERM

## Set Vars
CF_TUNNEL_PUBLIC_URL=''
CF_TUNNEL_HASH=''
PRECHECK_HOME_OPTION=''
WAIT_FOR_CF_URL=12

function ctrl_c() {
  echo
  echo "Termination caught. Reverting site to basic.wordpress.test."
  do_database_actions "$CF_TUNNEL_PUBLIC_URL" "https://basic.wordpress.test"
  echo "Site basic-wordpress restored to defaults. Stopping Cloudflare tunnel."
  kill_tunnel
  echo "Cloudflare tunnel stopped."
  exit 0
}

function echoerr() { 
  printf "\033[0;31m%s\n\033[0m" "$*" >&2
}

function echoverb() { 
  printf "\033[0;36m%s\n\033[0m" "$*" >&2
}

function box_out() {
  local s="$*"
  tput setaf 5
  echo "+-${s//?/-}-+
| ${s//?/ } |
| $(tput setaf 4)$s$(tput setaf 5) |
| ${s//?/ } |
+-${s//?/-}-+"
  tput sgr 0
}

function do_database_actions() {
  local REPLACE_FROM="$1"
  local REPLACE_TO="$2"
  wp_cli option set home "$REPLACE_TO"
  wp_cli option set siteurl "$REPLACE_TO"
  wp_cli search-replace "$REPLACE_FROM" "$REPLACE_TO" 
}

function kill_tunnel() {
  docker stop "$CF_TUNNEL_HASH" &>$([[ ! $_VERBOSE ]] && echo '/dev/null' || echo '/dev/stdout')
}

function wp_cli() {
  docker exec -ti basic-wordpress wp "$@" $([[ ! $_VERBOSE ]] && echo '--quiet')
  return $?
}

function pre_check_wp_container() {
  if docker ps | grep $([[ ! $_VERBOSE ]] && echo '-q') basic-wordpress; then 
    echo "Container basic-wordpress seems to be running. Proceeding."
  else
    echoerr "Can't detect basic-wordpress container running. Aborting."
    exit 1
  fi
}

function attempt_restore() {
  echo "Attempting restore of old tunnel remnants..."
  
  if [[ $(do_database_actions "$PRECHECK_HOME_OPTION" "https://basic.wordpress.test") -eq 0 ]]; then
    echo "Restored to basic settings."
  else
    echoerr "Restoration failed, verify manually or clean with 'clean.sh'. Aborting." 
    exit 1
  fi
}

function pre_check_wp_database() {
  PRECHECK_HOME_OPTION=$(wp_cli option get home | tr -d '[:space:]')

  if [[ "$PRECHECK_HOME_OPTION" != "https://basic.wordpress.test" ]]; then
    if [[ "$PRECHECK_HOME_OPTION" =~ .+trycloudflare.com$ ]]; then
      echo "Previous 'trycloudflare.com' URL found in the database. This indicates a tunnel was started and not terminated properly. Attempt restore?"
      select yn in "Yes" "No"; do
        case $yn in
            Yes ) attempt_restore; break;;
            No ) echoerr "Aborting."; exit 1;;
        esac
    done
    else
      echoerr "Default home option (basic.wordpress.test) not found. Running a search-replace may corrupt the database. Please run 'clean.sh' to clean your environment and try again. Aborting."
      exit 1
    fi
  fi
  [[ "$_VERBOSE" ]] && echoverb "Default database option found, we can continue."
}

function start_cf_container() {
  if ! CF_TUNNEL_HASH=$(docker run -d cloudflare/cloudflared:latest tunnel --url https://host.docker.internal:443 --no-tls-verify --http-host-header basic.wordpress.test --origin-server-name basic.wordpress.test); then
    echoerr "Could not start a proper tunnel container. Aborting."
  fi

  [[ "$_VERBOSE" ]] && echoverb "Tunnel container hash: $CF_TUNNEL_HASH"

  echo "Waiting a maximum of $WAIT_FOR_CF_URL seconds for Cloudflare to provide us with your URL."
  CF_TUNNEL_PUBLIC_URL="$(timeout "$WAIT_FOR_CF_URL" docker logs -f "$CF_TUNNEL_HASH" 2>&1 | while read -r line; do [[ "$line" =~ INF[\ \|]+https ]] && echo "$line" | grep -E 'INF[ \|]+https' | grep -oE 'https://[^ ]+' && exit 0; done)"

  [[ "$CF_TUNNEL_PUBLIC_URL" == '' ]] && echoerr "Could not retrieve a tunnel URL from Cloudflare. Dumping Cloudflare container logs and aborting." && docker logs --tail 20 "$CF_TUNNEL_HASH" && kill_tunnel && exit 1
}

function main() {
  pre_check_wp_container
  pre_check_wp_database
  start_cf_container

  echo "Performing replacements in the docker basic-wordpress container..."
  do_database_actions "https://basic.wordpress.test" "$CF_TUNNEL_PUBLIC_URL"

  echo
  echo "Tunnel is set up. Here is your public URL:"
  box_out "$CF_TUNNEL_PUBLIC_URL"
  echo 
  echo "Please be aware that your are granting public access to a part of your machine. Do not keep this tunnel running for too long."
  echo "Press CTRL + C to revert your site to basic.wordpress.test and exit the tunnel."

  while true; do sleep 60; done
}

while test $# -gt 0; do
  case "$1" in
    -v|--verbose)
      _VERBOSE=true
      shift
      ;;
    -r|--restore)
      _RUN_RESTORE=true
      shift
      ;;
    *)
      break
      ;;
  esac
done

if [[ "$_RUN_RESTORE" ]]; then 
  echo "Only running pre-checks and potentially restore."
  pre_check_wp_container
  pre_check_wp_database
  echo "Done."
  exit 0
fi

main