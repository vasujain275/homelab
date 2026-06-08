#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"
ENV_FILE="$SCRIPT_DIR/.env"
TOKEN_FILE="$SCRIPT_DIR/GHCR_TOKEN"
DEFAULT_IMAGE="ghcr.io/vasujain275/milo"
GHCR_USERNAME="${GHCR_USERNAME:-vasujain275}"

usage() {
  echo "Usage: $0 [image-tag]" >&2
  echo "If image-tag is omitted, deploys latest regardless of MILO_VERSION in .env." >&2
}

if [[ $# -gt 1 ]]; then
  usage
  exit 1
fi

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found" >&2
  exit 1
fi

if docker compose version >/dev/null 2>&1; then
  COMPOSE_CMD=(docker compose)
elif command -v docker-compose >/dev/null 2>&1; then
  COMPOSE_CMD=(docker-compose)
else
  echo "docker compose not found" >&2
  exit 1
fi

if [[ ! -f "$COMPOSE_FILE" ]]; then
  echo "missing compose file: $COMPOSE_FILE" >&2
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "missing env file: $ENV_FILE" >&2
  exit 1
fi

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

MILO_IMAGE="${MILO_IMAGE:-$DEFAULT_IMAGE}"
if [[ $# -eq 1 ]]; then
  MILO_VERSION="$1"
else
  MILO_VERSION="latest"
fi
export MILO_IMAGE MILO_VERSION
IMAGE_REF="${MILO_IMAGE}:${MILO_VERSION}"

echo "Deploying $IMAGE_REF"

ensure_ghcr_auth() {
  echo "Checking GHCR access for $IMAGE_REF"
  if docker manifest inspect "$IMAGE_REF" >/dev/null 2>&1; then
    echo "GHCR auth already works"
    return 0
  fi

  if [[ ! -s "$TOKEN_FILE" ]]; then
    echo "GHCR auth failed and token file missing: $TOKEN_FILE" >&2
    exit 1
  fi

  echo "Logging in to GHCR as $GHCR_USERNAME using $TOKEN_FILE"
  docker login ghcr.io -u "$GHCR_USERNAME" --password-stdin < "$TOKEN_FILE"

  if ! docker manifest inspect "$IMAGE_REF" >/dev/null 2>&1; then
    echo "GHCR auth still failing for $IMAGE_REF after login" >&2
    exit 1
  fi
}

main() {
  ensure_ghcr_auth

  echo "Stopping stack"
  "${COMPOSE_CMD[@]}" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" down

  echo "Pulling images"
  "${COMPOSE_CMD[@]}" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" pull

  echo "Starting stack"
  "${COMPOSE_CMD[@]}" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" up -d

  echo "Deploy complete"
  "${COMPOSE_CMD[@]}" --env-file "$ENV_FILE" -f "$COMPOSE_FILE" ps
}

main "$@"
