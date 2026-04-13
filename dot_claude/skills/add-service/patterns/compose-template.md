# Compose Templates

Reference templates for all patterns. Choose the appropriate one and adapt — do not copy verbatim.

---

## Pattern 1: Full (app + Postgres + Redis)

Based on docmost. Use when app requires both a relational DB and a cache/queue.

```yaml
services:
  <service>:
    image: <image>:<tag>
    container_name: <service>
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_healthy
    ports:
      - "5XXXX:<internal-port>"
    env_file:
      - .env
    volumes:
      - /home/dvitto/services/<service>/<config-dir>:/path/in/container/config
      - /mnt/services/<service>/<data-dir>:/path/in/container/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:<internal-port>/<health-path>"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      - "cup.notify=true"
      - "kuma.<service>.http.name=<Service Name>"
      - "kuma.<service>.http.url=http://192.168.1.2:<port>"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:16-alpine
    container_name: <service>-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: <service>
      POSTGRES_USER: <service>
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - /mnt/services/<service>/db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U <service>"]
      interval: 10s
      timeout: 5s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  redis:
    image: redis:7.2-alpine
    container_name: <service>-redis
    restart: unless-stopped
    volumes:
      - /mnt/services/<service>/redis_data:/data
    command: redis-server --save 60 1 --loglevel warning
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Pattern 2: Minimal (single container, no sidecar)

Use for stateless services or services with embedded storage.

```yaml
services:
  <service>:
    image: <image>:<tag>
    container_name: <service>
    restart: unless-stopped
    ports:
      - "5XXXX:<internal-port>"
    env_file:
      - .env
    volumes:
      - /home/dvitto/services/<service>/config:/path/in/container/config
      - /mnt/services/<service>/data:/path/in/container/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:<internal-port>/<health-path>"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      - "cup.notify=true"
      - "kuma.<service>.http.name=<Service Name>"
      - "kuma.<service>.http.url=http://192.168.1.2:<port>"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Pattern 3: App + Postgres only (no Redis)

Based on vikunja. Use when app needs a DB but no cache.

```yaml
services:
  <service>:
    image: <image>:<tag>
    container_name: <service>
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy
    ports:
      - "5XXXX:<internal-port>"
    env_file:
      - .env
    volumes:
      - /mnt/services/<service>/files:/path/in/container/files
    healthcheck:
      test: ["CMD-SHELL", "nc -z localhost <port> || exit 1"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 20s
    labels:
      - "cup.notify=true"
      - "kuma.<service>.http.name=<Service Name>"
      - "kuma.<service>.http.url=http://192.168.1.2:<port>"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:16-alpine
    container_name: <service>-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: <service>
      POSTGRES_USER: <service>
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - /mnt/services/<service>/db_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U <service>"]
      interval: 10s
      timeout: 5s
      retries: 5
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## Pattern 4: With external network

Use only when the service needs to communicate with containers in another compose stack (e.g. arr-suite integration). Most services do NOT need this.

```yaml
services:
  <service>:
    image: <image>:<tag>
    container_name: <service>
    restart: unless-stopped
    ports:
      - "5XXXX:<internal-port>"
    env_file:
      - .env
    volumes:
      - /home/dvitto/services/<service>/config:/config
      - /mnt/services/<service>/data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:<internal-port>/<health-path>"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      - "cup.notify=true"
      - "kuma.<service>.http.name=<Service Name>"
      - "kuma.<service>.http.url=http://192.168.1.2:<port>"
    networks:
      - default
      - arr-network
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

networks:
  arr-network:
    external: true
```

---

## Pattern 5: network_mode host (rare — plex-style)

Only for services that require direct host network access (e.g. discovery protocols, DLNA). Do not use unless explicitly required by the service.

```yaml
services:
  <service>:
    image: <image>:<tag>
    container_name: <service>
    restart: unless-stopped
    network_mode: host
    env_file:
      - .env
    volumes:
      - /home/dvitto/services/<service>/config:/config
      - /mnt/services/<service>/data:/data
    healthcheck:
      test: ["CMD", "curl", "-f", "http://127.0.0.1:<internal-port>/<health-path>"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    labels:
      - "cup.notify=true"
      - "kuma.<service>.http.name=<Service Name>"
      - "kuma.<service>.http.url=http://127.0.0.1:<port>"
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

Note: `ports:` is incompatible with `network_mode: host`. Kuma URL uses `127.0.0.1` (not `192.168.1.2`) for host-network services. — remove the `ports` section entirely.

---

## Key Annotations

- **`restart: unless-stopped`** — always this, never `always` or `on-failure`. `restart: always` breaks Sablier.
- **Healthcheck mandatory** — every app container must have one. Use TCP fallback (`nc -z localhost <port>`) when no HTTP endpoint is available.
- **Labels block** — on app container only. Never on sidecars (db, redis, mariadb) or locally-built images.
- **Kuma URL** — always `http://192.168.1.2:<port>`. Exception: `network_mode: host` → use `http://127.0.0.1:<port>`.
- **Logging block** — every container, no exceptions (app + all sidecars)
- **Bind mounts only** — no `volumes:` section at the top level with named volumes
- **`env_file: - .env`** on the app container for secrets and config
- **Inline `environment:`** on sidecar containers for their specific vars (referencing `${VAR}` from .env)
- **`depends_on: condition: service_healthy`** — only when the dependency has a healthcheck defined; use `depends_on: - <service>` (list form) if no healthcheck
- **Sidecar names** — always `<service>-db`, `<service>-redis`, `<service>-mariadb`
- **`compress` flag** — do NOT add to logging options; the Docker daemon handles this globally via `/etc/docker/daemon.json`
- **`start_period`** in healthcheck — include when app needs time to initialize (databases, JVM, etc.)

---

## MariaDB sidecar (alternative to Postgres)

Use `mariadb:11-lts` only when the app docs specifically require MySQL/MariaDB compatibility.

```yaml
  db:
    image: mariadb:11-lts
    container_name: <service>-mariadb
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${DB_ROOT_PASSWORD}
      MYSQL_DATABASE: <service>
      MYSQL_USER: <service>
      MYSQL_PASSWORD: ${DB_PASSWORD}
    volumes:
      - /mnt/services/<service>/db_data:/var/lib/mysql
    healthcheck:
      test: ["CMD", "healthcheck.sh", "--connect", "--innodb_initialized"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 30s
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```
