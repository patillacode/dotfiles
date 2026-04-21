---
name: add-service
description: Use when the user wants to "add a service", "deploy a new container", "set up a new docker service", or provides URLs to a self-hosted tool they want to run. Orchestrates full lifecycle: compose.yml, .env, justfiles, /mnt/services data directory, Homepage dashboard registration, and optional nginx/backup guidance.
allowed-tools: Read, Write, Edit, Bash, WebFetch, Glob, Grep
---

You are helping the user add a new dockerized service to their home server. Follow the 4-phase workflow below **exactly**. Do not skip phases or batch file creation without user confirmation.

---

## Non-Negotiable Conventions

These rules are absolute — no exceptions:

- `restart: unless-stopped` — never `always`, never `on-failure`. **`restart: always` is incompatible with Sablier** — it causes containers to restart themselves immediately after Sablier stops them, breaking on-demand wake-up.
- **Every app container MUST have a healthcheck** — no exceptions. If the image has no HTTP endpoint or lacks curl/wget, use a TCP port fallback: `["CMD-SHELL", "nc -z localhost <port> || exit 1"]`. Sidecar images (postgres, redis, mariadb) already include standard healthchecks in their templates.
- Every container gets the logging block:
  ```yaml
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
  ```
- **No named Docker volumes** — bind mounts with absolute paths only
- Config/app files → `/home/dvitto/services/<service>/`
- Data/state files → `/mnt/services/<service>/`
- No logrotate configs for Docker stdout logs — Docker daemon handles rotation automatically
- No `Co-Authored-By` or AI attribution in any commits

---

## Phase 1 — Research

Fetch each URL the user provided using `WebFetch`. From each page extract:

- Docker image name and recommended tag (prefer specific version over `latest` when docs recommend it)
- All environment variables: required vs optional, default values
- Volume paths the container uses internally
- Default exposed port
- Healthcheck command (does the image have `curl` or `wget`?)
- Whether a sidecar DB or cache is needed (postgres, redis, mariadb)
- Whether Homepage has a widget for this service (check https://gethomepage.dev/widgets/services/ mentally — common ones: most *arr apps, plex, immich, etc.)

**Watch out for split frontend/backend architectures** (e.g. Checkmate: `checkmate-client` + `checkmate-server`). These require extra investigation:
- Does the frontend nginx proxy `/api/` to the backend internally, or does the browser call the backend directly?
- Check the actual nginx config inside the image (`docker exec <client> cat /etc/nginx/conf.d/default.conf`) — proxy blocks are sometimes commented out or use wrong ports.
- If the frontend nginx proxies to a hardcoded upstream name (e.g. `server`), add a `networks.default.aliases` entry to the backend service so the name resolves.
- A custom `nginx.conf` volume mount may be required. After changing it, `nginx -s reload` is not always enough — a full container recreate (`docker compose up -d --force-recreate`) may be needed.

Also scan existing port usage to propose a new port in the 5xxxx range:

```bash
grep -rh -E '^\s+- "?[0-9]+:[0-9]+"?' /home/dvitto/services/*/compose.yml /home/dvitto/services/*/compose.yaml 2>/dev/null | grep -oE '[0-9]+:[0-9]+' | cut -d: -f1 | sort -n
```

Find the highest used port in the `5xxxx` range and propose `max + 1`. If no 5xxxx ports exist yet, start at `52000`.

---

## Phase 2 — Interactive Interview (3 rounds via AskUserQuestion)

After research, gather configuration via three batched rounds of questions. Do not ask one question at a time — batch into the rounds below.

### Round 1 — Identity, volumes, env vars

Ask:
1. **Service name** — directory name (e.g. `stirling-pdf`), container name, confirm image:tag
2. **Volume classification** — for each volume path found: is it config (→ `/home/dvitto/services/<service>/`) or data (→ `/mnt/services/<service>/`)? List them and ask the user to confirm the split or adjust
3. **Env var review** — list all env vars found. Ask which ones need values now vs can stay as `CHANGE_ME`. Standard vars to always include: `TZ=Europe/Madrid`, `PUID=1000`, `PGID=1000` (skip if image doesn't use them)

### Round 2 — Infrastructure

Ask:
1. **Sidecar needed?** — postgres:16-alpine / redis:7.2-alpine / mariadb:11-lts / none (propose based on docs findings)
2. **Host port** — confirm the proposed `max + 1` port or let user choose
3. **External network?** — most services: no bridge/external network needed. Only if integrating with arr-suite or similar: `arr-network`. Ask if user wants any.

### Round 3 — Integration

Ask:
1. **Healthcheck** — propose the command from docs. If the image has no HTTP endpoint or lacks curl/wget, propose the TCP fallback: `["CMD-SHELL", "nc -z localhost <port> || exit 1"]`. A healthcheck is mandatory — never omit it.
2. **Homepage** — which group?
   - Media tab: Media Center / Music / Media Management / Downloads
   - Apps tab: Apps
   - Misc tab: Personal Projects / Production Sites
   - Dev tab: Dev
   - Monitoring tab: Monitoring
   - Infrastructure tab: Infrastructure

   Does a homepage widget exist? What icon? (`<service>.png` / `si-<service>.svg` / `mdi-...` / full URL)
3. **Backup script needed?** — yes/no
4. **Nginx subdomain?** — will it get a `<service>.patilla.es` domain via NPM? What's the subdomain?
5. **Uptime Kuma monitor** — AutoKuma labels will be added to compose.yml so the monitor is created automatically. Confirm:
   - **Type**: `http` (default for web UIs) / `port` (TCP port check for non-HTTP or auth-gated services) / skip (background workers with no port). Note: TCP type in labels is `port`, not `tcp`.
   - **Category tag**: which of `infrastructure` / `monitoring` / `media` / `apps` / `dev` / `dashboards` / `misc` fits this service?
6. **Sablier (on-demand wake-up)?** — Should this service be stopped when idle and woken on first request? If yes, see the Sablier automation steps in Phase 4.

   **Never use Sablier for:** DNS (adguard), reverse proxy (nginx), monitoring (kuma, dozzle, beszel), VPN (wireguard), core infra (homepage, syncthing, atuin, cup).

---

## Phase 3 — Show & Confirm Each File

Generate each file's content and **display it to the user before writing**. After showing all files, ask for approval. Revise any file the user requests changes to. Then write in this order:

### 3a. Create directories

```bash
mkdir -p /home/dvitto/services/<service>/just
mkdir -p /mnt/services/<service>/<data-subdirs>
```

### 3b. Write files

**Order:**
1. `/home/dvitto/services/<service>/compose.yml`
2. `/home/dvitto/services/<service>/.env`
3. `/home/dvitto/services/<service>/justfile`
4. `/home/dvitto/services/<service>/just/service.just`
5. `/home/dvitto/services/<service>/just/cli.just` — **only** if the service has a meaningful CLI worth wrapping
6. Homepage labels — already included in `compose.yml` above (step 1). No `services.yaml` edit needed. If the widget needs an API key, add `HOMEPAGE_VAR_<SERVICE>_KEY` to `/home/dvitto/services/homepage/.env` (see Phase 4 checklist).

### File templates

See `patterns/compose-template.md` for compose patterns.
See `patterns/justfile-template.md` for exact justfile content (do not deviate).
See `patterns/homepage-categories.md` for group reference and docker label formats.

### compose.yml rules

- Use `env_file: - .env` for app secrets/config. Use inline `environment:` for sidecar credentials referencing `.env` vars.
- Sidecars named `<service>-db`, `<service>-redis`
- App depends on sidecars with `condition: service_healthy` when sidecars have healthchecks
- Healthcheck on every app container — mandatory. Use TCP fallback (`nc -z localhost <port>`) if no HTTP endpoint available.
- Add labels to the main app container (not sidecars). Combine cup and kuma labels in one block:
  ```yaml
  labels:
    - "cup.notify=true"
    - "kuma.<service>.http.name=<Service Name>"
    - "kuma.<service>.http.url=http://192.168.1.2:<port>"
    - "kuma.<service>.http.tag_names=[{\"name\":\"<category>\"}]"
  ```
  Always use the internal IP URL. Exception: `network_mode: host` services use `http://127.0.0.1:<port>`.

  **Tag categories** (pick one): `infrastructure` / `monitoring` / `media` / `apps` / `dev` / `dashboards` / `misc`

  **Important autokuma label rules:**
  - Use `tag_names` (not `tags`) — autokuma resolves this against its internally managed tag entities
  - Monitor type in labels is `port` for TCP checks (never `tcp`)
  - Tags are defined via labels on the autokuma container itself — no manual setup needed

  **Never add `cup.notify=true` to:**
  - Sidecar containers (db, redis, mariadb) — not in a public registry
  - Locally-built images (`build: .`) — cup can't check them
  - Nextcloud AIO mastercontainer — manages its own updates
- Compress flag is NOT needed in logging block — Docker daemon config handles it globally

### .env rules

- Include a header comment: `# <ServiceName> configuration`
- Group vars: secrets first, then app config, then standard (TZ/PUID/PGID)
- Mark all secrets without known values as `CHANGE_ME`
- Include a comment for each non-obvious variable

---

## Phase 4 — Summary

After all files are written, output a clean checklist:

```
## Files created

- /home/dvitto/services/<service>/compose.yml
- /home/dvitto/services/<service>/.env
- /home/dvitto/services/<service>/justfile
- /home/dvitto/services/<service>/just/service.just
[- /home/dvitto/services/<service>/just/cli.just]
- Homepage labels added to compose.yml (<Group> group)

## Data directories created

- /mnt/services/<service>/...

## Manual steps required (copy-paste ready)

- [ ] Set CHANGE_ME values in /home/dvitto/services/<service>/.env
- [ ] cd /home/dvitto/services/<service> && just up
- [ ] Verify: docker ps | grep <service>
[- [ ] Create proxy host in NPM: <service>.patilla.es → http://192.168.1.2:<port>]
[- [ ] Add HOMEPAGE_VAR_<SERVICE>_KEY to /home/dvitto/services/homepage/.env and restart: cd /home/dvitto/services/homepage && just restart]
[- AutoKuma labels added to compose.yml — monitor will be created automatically on `just up`]
[- [ ] Add backup cron (script already executable):
      (crontab -l; echo "0 3 * * * /mnt/services/<service>/backups/backup-<service>.sh >> /mnt/services/<service>/backups/logs/backup-<service>.log 2>&1") | crontab -]
[- [ ] Add log path to logrotate (requires sudo — Claude cannot edit /etc/logrotate.d/):
      sudo sed -i 's|<last-log-path> {|<last-log-path> /mnt/services/<service>/backups/logs/backup-<service>.log {|' /etc/logrotate.d/backup-logs]
```

Only include lines that are relevant to this specific service.

**IMPORTANT — logrotate limitation:** Claude cannot edit `/etc/logrotate.d/backup-logs` directly (requires sudo). Always output the exact `sudo sed` command the user needs to run manually. Never attempt to write or edit that file.

---

## Sablier Automation (run only if user said yes in Round 3 Q6)

After `docker compose up -d`, use the `/sablier add <service>` skill to handle the full Sablier integration — it covers NPM config, kuma label update, homepage icon check, container stop, and cleanup instructions.

**Before running `/sablier add`**, ensure the compose.yml has `homepage.ping` set to the internal IP:

```yaml
- "homepage.ping=http://192.168.1.2:<port>"
```

This must be added alongside `homepage.href`. Without it, homepage's `statusStyle: dot` polls the public subdomain (`href`) every 60s via `got`, which goes through NPM → Sablier and either wakes stopped containers or keeps running ones alive indefinitely — breaking Sablier's idle management entirely.
