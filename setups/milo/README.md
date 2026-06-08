# Milo infra

Docker bundle for homelab hosting the Milo Go API with PostgreSQL + pgvector and Redis.

## Services

| Service | Image/build | Purpose | Host port |
|---|---|---|---|
| `api` | `ghcr.io/vasujain275/milo:<version>` | Milo Go API | `7007 -> 8080` |
| `postgres` | `pgvector/pgvector:pg16` | Primary database + vector extension | internal only |
| `redis` | `redis:7-alpine` | Cache/readiness/supporting runtime | internal only |

Persistent volumes:

- `postgres_data` -> Postgres data
- `redis_data` -> Redis append-only data

## First run

```bash
cd infra
cp .env.example .env
$EDITOR .env
```

Fill at least:

- `MILO_VERSION` — image tag to deploy, example `v0.1.0`
- `POSTGRES_PASSWORD`
- `GOOGLE_CLIENT_ID` — Google **Web Application** OAuth client ID
- `JWT_SECRET` — `openssl rand -base64 32`
- `TOKEN_ENCRYPT_KEY` — `openssl rand -base64 32`
- `TMDB_API_KEY` — needed for movie-backed Discover data
- optional `GHCR_USERNAME` — defaults to `vasujain275` for `deploy.sh`

Start stack:

```bash
docker compose pull api
docker compose up -d
```

Or use the homelab deploy helper:

```bash
chmod +x deploy.sh
printf '%s' '<github-classic-token-with-read:packages>' > GHCR_TOKEN
./deploy.sh
```

Run database migrations with the API image:

```bash
docker compose run --rm api migrate up
```

Check status:

```bash
docker compose ps
docker compose logs -f api
curl http://localhost:7007/health
curl http://localhost:7007/ready
```

## Cloudflare Tunnel

Expose the API through Cloudflare Tunnel to:

```text
milo-api.vasujain.me -> http://localhost:7007
```

Example named tunnel ingress snippet:

```yaml
tunnel: <tunnel-id-or-name>
credentials-file: /path/to/<tunnel-id>.json

ingress:
  - hostname: milo-api.vasujain.me
    service: http://localhost:7007
  - service: http_status:404
```

After DNS/tunnel is live, the API base URL is:

```text
https://milo-api.vasujain.me
```

For the Flutter app, pass this as:

```bash
flutter run \
  --dart-define=GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com \
  --dart-define=API_BASE_URL=https://milo-api.vasujain.me
```

## Common operations

```bash
# Start / stop
cd infra
docker compose up -d
docker compose down

# Pull a newer released API image
docker compose pull api

# Restart stack on the selected image tag
docker compose up -d

# Full redeploy helper for homelab
./deploy.sh

# Run migrations
docker compose run --rm api migrate up

# Show logs
docker compose logs -f api
docker compose logs -f postgres
docker compose logs -f redis
```

## deploy.sh behavior

`deploy.sh` is meant to live on the homelab next to:

- `docker-compose.yml`
- `.env`
- `GHCR_TOKEN`

Flow:

1. reads `.env`
2. checks if GHCR access already works for `MILO_IMAGE:MILO_VERSION`
3. if not, logs in to `ghcr.io` using `GHCR_TOKEN`
4. runs `docker compose down`
5. runs `docker compose pull`
6. runs `docker compose up -d`
7. prints `docker compose ps`

`GHCR_TOKEN` should contain a GitHub token with package read access for the private repo image.

## Backup and restore

Backup Postgres:

```bash
cd infra
docker compose exec -T postgres sh -c 'pg_dump -U "$POSTGRES_USER" "$POSTGRES_DB"' > milo-postgres-$(date +%F).sql
```

Restore Postgres into an empty database:

```bash
cd infra
docker compose exec -T postgres sh -c 'psql -U "$POSTGRES_USER" "$POSTGRES_DB"' < milo-postgres-YYYY-MM-DD.sql
```

Backup Redis append-only data by stopping the stack and copying the `redis_data` Docker volume, or by using your host's normal Docker volume backup tooling.

## Notes

- `infra/docker-compose.yml` is the main homelab stack.
- The API image comes from GHCR: `ghcr.io/vasujain275/milo`.
- Change `MILO_VERSION` in `infra/.env` to roll forward or pin a specific release.
- `infra/pg/` is kept for the older Postgres-only local development flow.
- The API listens on container port `8080`; compose publishes it on host port `7007` by default.
- Postgres and Redis are not published on host ports; only containers on the Compose network can reach them.
- Do not commit `infra/.env`; it contains secrets.
- Do not commit `infra/GHCR_TOKEN`; it grants private image pull access.
