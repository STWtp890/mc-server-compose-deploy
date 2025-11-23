cd docker-compose || {
  echo "Error: Could not change directory to docker-compose." >&2
  exit 1
}

docker compose -f docker-compose.yml -f docker-compose.forge.yml -f docker-compose.properties.yml up -d || {
  echo "Error: Docker Compose up command failed." >&2
  exit 1
}

exit 0