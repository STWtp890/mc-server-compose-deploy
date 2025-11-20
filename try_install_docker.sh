# 1. Docker Compose Check
if ! [ -x "$(command -v docker compose)" ]; then
  # 2. Docker Check
  if ! [ -x "$(command -v docker)" ]; then
    echo 'Docker is not installed.' >&2
    echo 'Trying to install docker automatically...' >&2
    command -v apt-get >/dev/null 2>&1 && {
      sudo apt-get update
      sudo apt-get install -y docker.io
      sudo systemctl start docker
      sudo systemctl enable docker
    } || {
      echo 'Error: Docker auto-installation failed. Please install Docker manually.' >&2
      exit 1
    }

  fi
  echo 'Error: docker-compose is not installed.' >&2
  echo 'Trying to install docker-compose automatically...' >&2
  command -v apt-get >/dev/null 2>&1 && {
    sudo apt-get update
    sudo apt-get install -y docker-compose
  } || {
    echo 'Error: docker-compose auto-installation failed. Please install docker-compose manually.' >&2
    exit 1
  }
fi