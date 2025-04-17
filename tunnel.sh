trap ctrl_c INT

function ctrl_c() {
  echo "Termination caught. Reverting basic-wordpress to defaults:"
  
  docker exec -ti basic-wordpress wp option set home https://basic.wordpress.test
  docker exec -ti basic-wordpress wp option set siteurl https:/basic.wordpress.test
  docker exec -ti basic-wordpress wp search-replace "$CF_TUNNEL_PUBLIC_URL" 'https://basic.wordpress.test' 

  echo "basic-wordpress restored to defaults. Stopping Cloudflare tunnel."
  docker stop $CF_TUNNEL_HASH
  echo "Done. Enjoy."
  exit 0
}

if docker ps | grep basic-wordpress; then 
  echo "basic-wordpress seems to be running. Proceeding."
else
  echo "Can't detect basic-wordpress container running. Aborting."
  exit 1
fi

CF_TUNNEL_HASH=$(docker run -d cloudflare/cloudflared:latest tunnel --url https://host.docker.internal:443 --no-tls-verify --http-host-header basic.wordpress.test --origin-server-name basic.wordpress.test)
echo "Cloudflare docker container hash: $CF_TUNNEL_HASH"

echo "Waiting 8 seconds to retrieve your public url."
sleep 8

CF_TUNNEL_PUBLIC_URL=$(docker logs $CF_TUNNEL_HASH 2>&1 | grep -E 'INF[ \|]+https' | grep -oE 'https://[^ ]+')

echo "Performing replacements in the docker basic-wordpress container:"
docker exec -ti basic-wordpress wp option set home $CF_TUNNEL_PUBLIC_URL
docker exec -ti basic-wordpress wp option set siteurl $CF_TUNNEL_PUBLIC_URL
docker exec -ti basic-wordpress wp search-replace 'https://basic.wordpress.test' "$CF_TUNNEL_PUBLIC_URL"

echo
echo "Tunnel is set up. You can reach your site at $CF_TUNNEL_PUBLIC_URL"
echo "Please be aware that your are granting public access to a part of your machine. Do not keep this tunnel running for too long."
echo "Press CTRL + C to revert your site to basic.wordpress.test and exit the tunnel."

while true; do sleep 60; done
