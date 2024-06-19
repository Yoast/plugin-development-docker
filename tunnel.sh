CF_TUNNEL_HASH=$(docker run -d cloudflare/cloudflared:latest tunnel --url https://host.docker.internal:443 --no-tls-verify --http-host-header basic.wordpress.test --origin-server-name basic.wordpress.test)

echo "Sleeping 5"
sleep 5

CF_TUNNEL_PUBLIC_URL=$(docker logs $CF_TUNNEL_HASH 2>&1 | grep -E 'INF[ \|]+https' | grep -oE 'https://[^ ]+')

echo "Cloudflare docker container hash: $CF_TUNNEL_HASH"
echo "Cloudflare tunnel public url: $CF_TUNNEL_PUBLIC_URL"
echo

echo "Performing replacements in the docker basic-wordpress container:"
docker exec -ti basic-wordpress wp option set home $CF_TUNNEL_PUBLIC_URL
docker exec -ti basic-wordpress wp option set siteurl $CF_TUNNEL_PUBLIC_URL
docker exec -ti basic-wordpress wp search-replace 'https://basic.wordpress.test' "$CF_TUNNEL_PUBLIC_URL"

echo "Trapping CTRL + C to revert basic-wordpress container to defaults. Enjoy."
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

while true; do sleep 60; done
