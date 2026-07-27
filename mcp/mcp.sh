#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.json"

echo "=== Building wordpress-mcp Docker image ==="
if docker image inspect wordpress-mcp >/dev/null 2>&1; then
  echo "Image already exists, skipping build."
else
  docker build -t wordpress-mcp -f "${SCRIPT_DIR}/Dockerfile" "${SCRIPT_DIR}"
fi

echo ""
echo "=== Checking WP_API_PASSWORD in config.json ==="
# Extract the WP_API_PASSWORD value from config.json
WP_API_PASSWORD=$(grep '"WP_API_PASSWORD"' "${CONFIG_FILE}" | sed -E 's/.*"WP_API_PASSWORD"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')

if [ -z "$WP_API_PASSWORD" ]; then
  echo "Error: WP_API_PASSWORD is not set in config.json."
  echo "Please set your WordPress application password in ${CONFIG_FILE}."
  exit 1
fi
echo "WP_API_PASSWORD is set."

echo ""
echo "=== Checking mcp-adapter plugin ==="
PLUGIN_OUTPUT=$(docker exec -ti basic-wordpress wp plugin list --format=json 2>/dev/null || true)

if echo "$PLUGIN_OUTPUT" | grep -q '"name":"mcp-adapter"'; then
  echo "mcp-adapter plugin is installed."
else
  echo "Installing mcp-adapter plugin..."
  docker exec -ti basic-wordpress wp plugin install https://github.com/WordPress/mcp-adapter/releases/latest/download/mcp-adapter.zip --activate
  echo "mcp-adapter plugin installed and activated."
fi

echo ""
echo -e "\033[0;31mPress Ctrl+C in this terminal to stop the MCP container.\033[0m"
echo "=== Starting wordpress-mcp container ==="
docker run --rm -it --network yoast-docker -p 127.0.0.1:8365:8365 -v "${CONFIG_FILE}:/config.json" wordpress-mcp
