---
name: sablier
description: Use when the user wants to add or remove a service from Sablier on-demand container management. Invoked as `/sablier add <service>` or `/sablier remove <service>`.
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

Manage Sablier on-demand container management for an existing deployed service.

**Usage:**
- `/sablier add <service>` — bring a service under Sablier management
- `/sablier remove <service>` — remove a service from Sablier management

Parse the argument to determine the mode (add/remove) and the service name.

---

## Key paths

| Purpose | Path |
|---|---|
| Sablier SERVICES list | `/home/dvitto/services/sablier/setup-npm.py` |
| NPM sqlite DB | `/mnt/services/nginx/data/database.sqlite` |
| Homepage config | `/home/dvitto/services/homepage/config/services.yaml` |
| Service compose file | `~/services/<service>/compose.yml` (try both `compose.yml` and `docker-compose.yml`) |

---

## ADD — `/sablier add <service>`

### Step 1 — Read compose file

Read `~/services/<service>/compose.yml` (or `docker-compose.yml`). Extract:
- All `container_name:` values (main container + any sidecars)
- The published host port from `ports:` (left side of the mapping, e.g. `52013:8080` → `52013`)

If the compose file doesn't exist, tell the user and stop.

### Step 2 — Find NPM proxy host ID

Run:
```bash
sqlite3 /mnt/services/nginx/data/database.sqlite \
  "SELECT id, domain_names FROM proxy_host WHERE domain_names LIKE '%<service>%';"
```

Use the returned `id`. If nothing is returned or multiple rows match, ask the user to clarify.

### Step 3 — Derive display name

Capitalise the service directory name, replacing hyphens with spaces:
- `visit-book` → `Visit Book`
- `secretapi` → `Secretapi` (fine as-is unless you can infer better from compose labels)

If the name looks wrong, ask the user.

### Step 4 — Add to SERVICES in setup-npm.py

Edit `/home/dvitto/services/sablier/setup-npm.py`. Append to the `SERVICES` list, maintaining column alignment with existing entries:

```python
(npm_id, "container,container-db",  "Display Name"),
```

Comma-separate multiple container names within the string. Keep the closing `]` on its own line.

### Step 5 — Update kuma label to internal IP

In the service's `compose.yml`, find any label matching `kuma.*.http.url=https://*`. Change it to use the internal IP and port:

```yaml
- "kuma.<service>.http.url=http://192.168.1.2:<port>"
```

If it already uses an internal IP, skip. If no kuma label exists, skip.

### Step 6 — Check homepage config for icon URLs

Read `/home/dvitto/services/homepage/config/services.yaml`. If any `icon:` value points to the service's public domain (e.g. `https://<service>.patilla.es/...`), replace it with an MDI icon:

```yaml
icon: mdi-<sensible-icon>
```

Browse [materialdesignicons.com](https://materialdesignicons.com) mentally — pick something thematically appropriate.

### Step 7 — Redeploy service to apply new labels

```bash
cd ~/services/<service> && docker compose up -d
```

This recreates the container with updated kuma labels. Uptime-kuma will auto-discover the new internal-IP monitor.

### Step 8 — Prompt user for manual steps

Print this message and wait for confirmation before proceeding:

```
Manual steps required before continuing:

  1. Open the kuma UI and delete any monitor for <service> that still points to
     https://<service>.patilla.es — the new internal-IP monitor is already there.

  2. Close any open browser tabs for <service> (WebSocket reconnects will
     immediately re-wake the container after it's stopped).

Ready to update NPM config and stop the container(s)? [y/N]
```

### Step 9 — Run setup

On yes:

```bash
cd ~/services/sablier && just setup
```

(`just setup` only updates changed services, so only the new service will be touched.)

Print a summary when done:
```
Done. <service> is now managed by Sablier.
  Containers stopped: <container names>
  Loading page: matrix theme, 30-minute idle timeout
```

---

## REMOVE — `/sablier remove <service>`

### Step 1 — Run just remove

```bash
cd ~/services/sablier && just remove <service>
```

This clears the NPM Advanced config and starts the containers back up. Accept any prompts.

### Step 2 — Remove from SERVICES

Edit `/home/dvitto/services/sablier/setup-npm.py` and delete the tuple matching `<service>` from the `SERVICES` list.

### Step 3 — Inform user

Print:
```
Done. <service> has been removed from Sablier management.

  NPM config cleared, containers started.
  Kuma label left as internal IP (house standard) — no change needed.
  The monitor will show "down" when the container is stopped intentionally.
```

---

## Notes

- **Never use Sablier for** DNS, reverse proxy, monitoring, VPN, or other core infrastructure — only for rarely-used user-facing services.
- **`restart: unless-stopped` is required.** If the service uses `restart: always`, warn the user — Docker will restart the container immediately after Sablier stops it, breaking the whole setup.
- **`docker compose down` removes containers; `docker stop` suspends them.** Sablier can start a stopped container but cannot create one from scratch. If containers go missing, recreate with `docker compose up -d` first.
