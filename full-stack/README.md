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
1. Set up the internal Docker network
2. Start dotCMS and Postgres
3. Start Loki (log aggregation)
4. Start Grafana (log dashboard)
5. Start the frontend pod (React)
6. Start the backend pod (API)
7. Start Nginx as the central router

All logs are routed to Loki and viewable in Grafana.

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

## Directory Structure

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