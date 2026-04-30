#! /bin/bash
#
# Manages Cloudflare tunnel for WordPress development environment.
# Starts a Cloudflare tunnel, updates WordPress database with the tunnel URL,
# and provides cleanup functionality on termination.
#

trap ctrl_c INT SIGINT SIGTERM

## Set Vars
CF_TUNNEL_PUBLIC_URL=''
CF_TUNNEL_HASH=''
PRECHECK_HOME_OPTION=''
WAIT_FOR_CF_URL=12

#######################################
# Signal handler for cleanup on termination.
# Reverts WordPress database to default URL and stops the Cloudflare tunnel.
# Globals:
#   CF_TUNNEL_PUBLIC_URL - The public URL of the Cloudflare tunnel
#   CF_TUNNEL_HASH - The Docker container hash of the tunnel
# Arguments:
#   None (signal handler)
# Returns:
#   Exits with status 0 after cleanup.
#######################################
function ctrl_c() {
  echo
  echo "Termination caught. Reverting site to basic.wordpress.test."
  do_database_actions "$CF_TUNNEL_PUBLIC_URL" "https://basic.wordpress.test"
  echo "Site basic-wordpress restored to defaults. Stopping Cloudflare tunnel."
  kill_tunnel
  echo "Cloudflare tunnel stopped."
  exit 0
}

#######################################
# Print error message to stderr in red color.
# Globals:
#   None
# Arguments:
#    $1 - Error message to print
# Outputs:
#   Writes error message to stderr in red color.
# Returns:
#   None (uses printf)
#######################################
function echoerr() { 
  printf "\033[0;31m%s\n\033[0m" "$*" >&2
}

#######################################
# Print verbose message to stderr in cyan color.
# Globals:
#   None
# Arguments:
#    $1 - Verbose message to print
# Outputs:
#   Writes message to stderr in cyan color.
# Returns:
#   None (uses printf)
#######################################
function echoverb() { 
  printf "\033[0;36m%s\n\033[0m" "$*" >&2
}

#######################################
# Display a text box with the given string centered.
# Uses terminal colors for visual formatting.
# Globals:
#   None
# Arguments:
#    $1 - String to display in the box
# Outputs:
#   Writes formatted box to stdout.
# Returns:
#   None (uses echo and tput)
#######################################
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

#######################################
# Update WordPress database with new home and siteurl values.
# Performs search-replace of old URL with new URL in the database.
# Globals:
#   None
# Arguments:
#    $1 - REPLACE_FROM: The old URL to replace
#    $2 - REPLACE_TO: The new URL to use
# Outputs:
#   Modifies WordPress database options via wp_cli.
# Returns:
#   Exit status from wp_cli commands.
#######################################
function do_database_actions() {
  local REPLACE_FROM="$1"
  local REPLACE_TO="$2"
  wp_cli option set home "$REPLACE_TO"
  wp_cli option set siteurl "$REPLACE_TO"
  wp_cli search-replace "$REPLACE_FROM" "$REPLACE_TO" 
}

#######################################
# Stop the Cloudflare tunnel Docker container.
# Suppresses output unless verbose mode is enabled.
# Globals:
#   CF_TUNNEL_HASH - The Docker container hash of the tunnel
# Arguments:
#   None
# Outputs:
#   None (output suppressed or sent to stdout/stderr)
# Returns:
#   Exit status from docker stop command.
#######################################
function kill_tunnel() {
  docker stop "$CF_TUNNEL_HASH" &>$([[ ! $_VERBOSE ]] && echo '/dev/null' || echo '/dev/stdout')
}

#######################################
# Execute wp-cli commands inside the basic-wordpress Docker container.
# Adds --quiet flag when verbose mode is disabled.
# Globals:
#    _VERBOSE - Controls quiet mode for wp-cli
# Arguments:
#    $@ - Arguments passed to wp-cli
# Outputs:
#   Command output from wp-cli (unless quiet mode)
# Returns:
#   Exit status from wp-cli command.
#######################################
function wp_cli() {
  docker exec -ti basic-wordpress wp "$@" $([[ ! $_VERBOSE ]] && echo '--quiet')
  return $?
}

#######################################
# Verify that the basic-wordpress Docker container is running.
# Exits with error if container is not detected.
# Globals:
#    _VERBOSE - Controls verbose output
# Arguments:
#   None
# Outputs:
#   Success message to stdout if container is running.
#   Error message to stderr if container is not running.
# Returns:
#   Exits with 1 if container is not running.
#######################################
function pre_check_wp_container() {
  if docker ps | grep $([[ ! $_VERBOSE ]] && echo '-q') basic-wordpress; then 
    echo "Container basic-wordpress seems to be running. Proceeding."
  else
    echoerr "Can't detect basic-wordpress container running. Aborting."
    exit 1
  fi
}

#######################################
# Restore WordPress database to pre-tunnel state.
# Replaces the previous tunnel URL with the default WordPress URL.
# Globals:
#   PRECHECK_HOME_OPTION - The previous home URL from the database
# Arguments:
#   None
# Outputs:
#   Status messages to stdout/stderr.
# Returns:
#   Exits with 1 if restoration fails.
#######################################
function attempt_restore() {
  echo "Attempting restore of old tunnel remnants..."
  
  if [[ $(do_database_actions "$PRECHECK_HOME_OPTION" "https://basic.wordpress.test") -eq 0 ]]; then
    echo "Restored to basic settings."
  else
    echoerr "Restoration failed, verify manually or clean with 'clean.sh'. Aborting." 
    exit 1
  fi
}

#######################################
# Pre-check the WordPress database home option before starting tunnel.
# Detects previous tunnel URLs and prompts for restoration if needed.
# Globals:
#   PRECHECK_HOME_OPTION - Set to the current home option value
#    _VERBOSE - Controls verbose output
# Arguments:
#   None
# Outputs:
#   Status messages and prompts to stdout/stderr.
# Returns:
#   Exits with 1 if database is not in expected state.
#######################################
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

#######################################
# Extract the Cloudflare tunnel public URL from container logs.
# Parses log output to find the HTTPS URL provided by Cloudflare.
# Globals:
#   WAIT_FOR_CF_URL - Maximum seconds to wait for URL
#   CF_TUNNEL_HASH - The Docker container hash to check logs from
# Arguments:
#   None
# Outputs:
#   Writes the extracted URL to stdout (if found).
# Returns:
#   Exits with 0 when URL is found, otherwise exits with non-zero.
#######################################
function cf_timed_check () {
  timeout "$WAIT_FOR_CF_URL" docker logs -f "$CF_TUNNEL_HASH" 2>&1 | \
    while read -r line; do
       [[ "$line" =~ INF[\ \|]+https ]] && echo "$line" | grep -E 'INF[ \|]+https' | grep -oE 'https://[^ ]+' && exit 0
    done
}

#######################################
# Start the Cloudflare tunnel Docker container and retrieve the public URL.
# Waits for Cloudflare to provide the tunnel URL from container logs.
# Globals:
#   CF_TUNNEL_HASH - Set to the Docker container hash on success
#   CF_TUNNEL_PUBLIC_URL - Set to the public tunnel URL on success
#   WAIT_FOR_CF_URL - Maximum seconds to wait for URL
#    _VERBOSE - Controls verbose output
# Arguments:
#   None
# Outputs:
#   Status messages to stdout/stderr.
# Returns:
#   Exits with 1 if tunnel cannot be started or URL not retrieved.
#######################################
function start_cf_container() {
  if ! CF_TUNNEL_HASH=$(docker run -d cloudflare/cloudflared:latest tunnel --url https://host.docker.internal:443 --no-tls-verify --http-host-header basic.wordpress.test --origin-server-name basic.wordpress.test); then
    echoerr "Could not start a proper tunnel container. Aborting."
  fi

  [[ "$_VERBOSE" ]] && echoverb "Tunnel container hash: $CF_TUNNEL_HASH"

  echo "Waiting a maximum of $WAIT_FOR_CF_URL seconds for Cloudflare to provide us with your URL."
  CF_TUNNEL_PUBLIC_URL="$(cf_timed_check)"

  [[ "$CF_TUNNEL_PUBLIC_URL" == '' ]] && echoerr "Could not retrieve a tunnel URL from Cloudflare. Dumping Cloudflare container logs and aborting." && docker logs --tail 20 "$CF_TUNNEL_HASH" && kill_tunnel && exit 1
}

#######################################
# Main entry point for the tunnel management script.
# Orchestrates container verification, database checks, tunnel startup,
# and URL display to the user.
# Globals:
#   CF_TUNNEL_PUBLIC_URL - Set by start_cf_container
#   CF_TUNNEL_HASH - Set by start_cf_container
# Arguments:
#   None
# Outputs:
#   Status messages and tunnel URL to stdout/stderr.
# Returns:
#   Runs indefinitely until interrupted (via ctrl_c handler).
#######################################
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
  echo "Be aware that your are granting public access to a part of your machine. Do not keep this tunnel running longer than necessary."
  echo "Press CTRL + C to revert your site to basic.wordpress.test and exit the tunnel."

  while true; do sleep 60; done
}

# Parse command-line arguments for optional flags.
# Supports --verbose/-v for verbose output and --restore/-r for pre-check only mode.
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

# If --restore flag was provided, only run pre-checks and optionally restore.
if [[ "$_RUN_RESTORE" ]]; then 
  echo "Only running pre-checks and potentially restore."
  pre_check_wp_container
  pre_check_wp_database
  echo "Done."
  exit 0
fi

main
