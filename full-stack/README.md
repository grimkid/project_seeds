# Full-Stack: Modern Fullstack Project Boilerplate

This repository provides a fullstack project template with a modern architecture:

- **Backend**: Serves dynamic data (API, business logic)
- **Frontend**: React app for the user interface
- **dotCMS**: Headless CMS for static resources and content
- **Grafana + Loki**: Centralized logging and observability for all services
- **Nginx**: Central router and reverse proxy for all HTTP(S) traffic

## Quick Start: Boot the Entire Stack

To start all services in the correct order, run:

```bash
cd full-stack
./boot-all.sh
```


This will:
1. Set up the internal Docker network (see below)
2. Start dotCMS and Postgres
3. Start Loki (log aggregation)
4. Start Grafana (log dashboard)
5. Start the frontend pod (React)
6. Start the backend pod (API)
7. Start Nginx as the central router

All logs are routed to Loki and viewable in Grafana.

## Internal Docker Network

The script `docker-network/init-internal-network.sh` creates a custom Docker network named `internal-net` with a fixed subnet and gateway. This ensures all services can communicate securely and predictably by container name, and are isolated from the host network.

You do not need to run this script manually—`boot-all.sh` will call it automatically. If you ever need to recreate the network (for example, after a full cleanup), you can run:

```bash
cd docker-network
./init-internal-network.sh
```

**Network details:**
- Name: `internal-net`
- Subnet: `172.28.0.0/16`
- Gateway: `172.28.0.1`

All containers in the stack are attached to this network for secure, internal-only communication.

## Architecture Overview


```
                ┌────────────┐
                │   Grafana  │
                └─────▲──────┘
                      │
                      │
┌────────────┐   ┌─────┴─────┐   ┌────────────┐
│  Frontend  │<->│   Nginx   │<->│   Backend  │
└────────────┘   └─────▲─────┘   └────────────┘
                      │
                      │
                ┌─────┴─────┐
                │   dotCMS  │
                └───────────┘
```

- **Nginx** is the central hub: all HTTP(S) traffic flows through it. It routes requests to the frontend, backend, dotCMS, and Grafana. All services are only accessible via Nginx.
- **Frontend** communicates with the backend (for dynamic data) and dotCMS (for static content) through Nginx.
- **Grafana** is also accessed through Nginx and receives logs from all services, including Nginx itself.

- **Frontend** (React):
  - Receives static content (images, assets, etc.) from dotCMS (via Nginx)
  - Fetches dynamic data from the backend API (via Nginx)
  - Routed via Nginx

- **Backend**:
  - Serves dynamic data (REST/GraphQL API)
  - Routed via Nginx

- **dotCMS**:
  - Provides static resources and content management
  - Routed via Nginx

- **Grafana + Loki**:
  - Collects and displays logs from all services (dotCMS, backend, frontend, Nginx)
  - Access Grafana via Nginx


## Routing Logic (Nginx)

- Requests with header `c: fe` are routed to the frontend pod
- Requests with header `c: be` are routed to the backend pod
- Requests for `/dotAdmin/`, `/c/portal/`, `/dotcms-webcomponents/` are proxied to dotCMS
- Requests for `/grafana/` are proxied to Grafana
- All other requests are routed based on cookies, referer, or fallback to static/404

## Logging & Observability

- All logs (Nginx, dotCMS, backend, frontend) are collected by Promtail and sent to Loki
- Grafana provides a unified dashboard for querying and visualizing logs

## Development & Customization

- Each service (backend, frontend, dotCMS) has its own boot script and Dockerfile
- To rebuild or restart a service, use the corresponding script in its directory
- To clean up all containers, images, and networks, use `clean-all.sh` or `soft-clean-all.sh`


## Offline Docker Image Caching

To support offline or reproducible deployments, the `image-cache` directory contains scripts to save and erase all required Docker images as `.tar` files:

- `image-cache/save-images.sh`: Pulls all required images and saves them as tarballs in the `image-cache` directory. Run this script on a machine with internet access to prepare images for offline use.

  ```bash
  cd image-cache
  ./save-images.sh
  ```

- `image-cache/erase-images.sh`: Removes all cached image tarballs from the `image-cache` directory.

  ```bash
  cd image-cache
  ./erase-images.sh
  ```

When you run `boot-all.sh`, the stack will automatically load images from the cache if available, making it possible to deploy the stack without internet access after the initial image download.



## Loki Boot Script and Log Aggregation

The script `monitoring/boot-loki.sh` boots the Loki log aggregation service, which collects logs from all stack components (Nginx, dotCMS, backend, frontend) via Promtail and makes them available to Grafana.

- **Container name:** `loki-monitoring`
- **Image:** `grafana/loki:2.9.7`
- **Internal IP:** Dynamic (on `internal-net`)
- **Ports:**
  - 3100 (HTTP API, internal only)
  - 9096 (gRPC, internal only)
- **Data directory:** `monitoring/data-loki` (persisted)
- **Config file:** `monitoring/loki-config.yaml`
- **Integration:**
  - Promtail agents in each service send logs to Loki at `loki-monitoring:3100`
  - Grafana is pre-configured to use Loki as a data source for log queries

You do not need to access Loki directly; all log queries are performed through Grafana's web UI.

---


## dotCMS Boot Script and Content Management

The script `dotcms/boot-dotcms.sh` builds and starts the dotCMS container, which provides headless CMS capabilities and static content for the stack.

- **Container name:** `dotcms-app`
- **Image:** `dotcms/dotcms:24.12.27_lts_v8_6031d3b` (customized via Dockerfile)
- **Internal IP:** Dynamic (on `internal-net`)
- **Ports:**
  - Not exposed directly; all access is routed through Nginx
- **Volumes:**
  - `dotcms/data/dotcms/shared` → `/data/shared` (shared CMS data)
  - `dotcms/data/dotcms/logs` → `/srv/dotserver/tomcat/logs` (dotCMS logs, collected by Promtail)
- **Database:**
  - Uses a Postgres container (`dotcms-postgres`) on the same network
- **Elasticsearch:**
  - Uses a dedicated container (`dotcms-elasticsearch`) for search
- **Log forwarding:**
  - Promtail runs as a sidecar container, forwarding dotCMS logs to Loki
- **Admin credentials:**
  - Username: `admin`
  - Password: `7e2e1b2c-2e2e-4e2e-8e2e-2e2e2e2e2e2e`
  - Access via Nginx at `/dotAdmin/` (e.g., http://localhost:8089/dotAdmin/)

**How to use:**

- dotCMS is started automatically by `boot-all.sh` and is only accessible via Nginx
- All static content and CMS APIs are routed through Nginx
- dotCMS logs are available in Grafana via Loki

---

The script `nginx/start-nginx.sh` builds and starts the Nginx container, which acts as the central router and reverse proxy for the entire stack.

- **Container name:** `nginx-server`
- **Image:** `custom-nginx` (built from `nginx/Dockerfile`)
- **Internal IP:** `172.28.0.10` (on `internal-net`)
- **Ports:**
  - 8089 (host) → 80 (container): All HTTP traffic is accessible at [http://localhost:8089](http://localhost:8089)
- **Volumes:**
  - `nginx/data/html` → `/usr/share/nginx/html` (static content)
  - `nginx/data/log` → `/var/log/nginx` (Nginx logs, collected by Promtail)
- **Log forwarding:**
  - Promtail runs as a sidecar process in the same container, forwarding Nginx logs to Loki
- **Config:**
  - Main config: `nginx/data/html/default.conf`
  - Supervisor config: `nginx/supervisord.conf` (runs both Nginx and Promtail)

**How to use:**

- Nginx is started automatically by `boot-all.sh` and is the only exposed HTTP(S) entrypoint for the stack
- All routing logic (to frontend, backend, dotCMS, Grafana) is handled by Nginx
- Nginx logs are available in Grafana via Loki

---

The script `monitoring/boot-grafana.sh` boots the Grafana monitoring service with the following features:

- **Container name:** `grafana-monitoring`
- **Image:** `grafana/grafana-oss:latest`
- **Internal IP:** `172.28.0.20` (on `internal-net`)
- **Ports:**
  - Exposed via Nginx reverse proxy at [http://localhost:8089/grafana/](http://localhost:8089/grafana/)
- **Provisioning:**
  - Pre-configured Loki data source for logs
  - Data directory: `monitoring/data` (persisted)
- **Admin credentials:**
  - Username: `admin`
  - Password: `e2f1c3b4-5d6e-7f8a-9b0c-1d2e3f4a5b6c`
- **Additional users created automatically:**
  - `rares` (password: `raresadmin`)
  - `seby` (password: `sebyadmin`)
  - `user` (password: `useradmin`)
  - All users are granted admin role

**How to access Grafana:**

- Open [http://localhost:8089/grafana/](http://localhost:8089/grafana/) in your browser (routed through Nginx)
- Log in with any of the above users

Grafana will show logs from all services (dotCMS, backend, frontend, Nginx) via the Loki data source.

---

```
full-stack/
├── backend/           # Backend API service
├── frontend/          # Frontend React app
├── dotcms/            # dotCMS headless CMS
├── monitoring/        # Grafana, Loki, Promtail configs
├── nginx/             # Nginx config and Dockerfile
├── boot-all.sh        # Main stack boot script
├── clean-all.sh       # Full cleanup script
└── ...
```

---

For more details, see the individual service directories and scripts.