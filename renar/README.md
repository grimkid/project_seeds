# Renar Development Environment

This folder contains scripts and Dockerfiles to manage a local development stack with frontend, backend, and dotCMS pods, each with persistence and secure SSH access.

## Folder Structure

- `frontend/` - Frontend development pod (JDK 21, vim, SSH, ports 8090/8083/8084)
- `backend/`  - Backend development pod (JDK 21, vim, SSH, port 8091/8085)
- `dotcms/`   - dotCMS pod (port 8086, internal Postgres, user provisioning)
- `monitoring/` - Monitoring stack (Loki, Grafana)


## Usage Order

1. **Start dotCMS and Postgres**
   - `cd dotcms`
   - `./boot-dotcms.sh`
   - Wait until dotCMS is up (port 8086)
   - (Optional) Run `./provision-dotcms-users.sh` to reset admin password

2. **Start Loki (log aggregation)**
   - `cd ../monitoring`
   - `./boot-loki.sh`

3. **Start Grafana (monitoring UI)**
   - `./boot-grafana.sh`
   - Wait until Grafana is up (port 8087)

4. **Start the frontend pod**
   - `cd ../frontend`
   - `./boot-frontend-pod.sh`

5. **Start the backend pod**
   - `cd ../backend`
   - `./boot-backend-pod.sh`

6. **Start Nginx (optional)**
   - `cd ../nginx`
   - `./start-nginx.sh`



## Relevant Ports

- **22**: SSH to Ubuntu host
- **8090**: SSH to frontend pod
- **8091**: SSH to backend pod
- **8083, 8084**: Frontend pod app ports
- **8085**: Backend pod app port
- **8086**: dotCMS (admin and public)
- **8089**: Nginx (reverse proxy for Grafana and static content; only public port for monitoring)
- **5432**: Postgres (internal, only for dotCMS)

### Internal-only (not exposed to host)
- **8087**: Grafana (no longer exposed; use nginx on 8089)
- **8088**: Loki (log aggregation, only accessible from internal Docker network)

## Notes
- All pods use the `internal-net` Docker network for internal communication.
- Each pod has a `data` folder for persistence.
- SSH access is only allowed via public key for users `rares` and `seby`.
- dotCMS admin users (mihai, rares, seby, renar) are provisioned by script.
- dotCMS is accessible to everyone on port 8086.
- Postgres is only accessible internally by dotCMS.

## Scripts
- `boot-dotcms.sh` - Builds and runs a custom dotCMS image with Promtail for log shipping, starts Postgres, ensures persistence and network.
- `provision-dotcms-users.sh` - Resets the admin@dotcms.com password via the API.
- `boot-loki.sh` - Runs Loki log aggregation with persistent data, exposes port 8088.
- `boot-grafana.sh` - Runs Grafana with persistent data, sets up admin and users, and provisions Loki as a data source.
- `boot-frontend-pod.sh` - Builds and runs the frontend pod with persistence and correct ports.
- `boot-backend-pod.sh` - Builds and runs the backend pod with persistence and correct ports.

Run the scripts in the order above for a working full-stack dev environment.

## Users:

### For dotcms:
host:8086/dotAdmin
rares@local.com:raresadmin
seby@local.com:sebyadmin
renar@local.com:renaradmin
mihai@keydigital.ro:mihaiadmin

### For grafana:
https://host:8087


## Components

- **dotCMS**: Enterprise CMS running in a custom container with Promtail for log shipping. Exposes port 8086. Logs are shipped to Loki and rotated automatically.
- **Postgres**: Internal database for dotCMS, not exposed outside the Docker network.
- **Loki**: Log aggregation system. Only accessible from inside the internal Docker network (no port exposed to host). Receives logs from Promtail running in the dotCMS container.
- **Promtail**: Log shipping agent, runs inside the dotCMS container, ships logs to Loki.
- **Grafana**: Visualization and monitoring UI. Now only accessible via Nginx reverse proxy (no direct port published). Nginx proxies /grafana/ to Grafana inside the internal Docker network.
- **Frontend Pod**: Development environment for frontend, with SSH and app ports 8090, 8083, 8084.
- **Backend Pod**: Development environment for backend, with SSH and app ports 8091, 8085.
- **Nginx**: Lightweight web server and reverse proxy. Exposes port 8089. Proxies /grafana/ to Grafana (http://172.28.0.20:3000) and serves static content. Start with `./start-nginx.sh` in the `nginx/` folder. Only Nginx is exposed to the LAN; all other services are isolated.
- **internal-net**: Internal Docker network (subnet 172.28.0.0/16) for all containers. Only Nginx is exposed to the LAN via port 8089; all other containers are isolated and only accessible within this network.


## Accessing Grafana

- From your LAN, access Grafana at: `http://<host-lan-ip>:8089/grafana/`
  - Example: `http://192.168.88.32:8089/grafana/`
- Do NOT use the internal Docker IP (172.28.0.20) or port 3000 from outside Docker; access is only via Nginx on port 8089.

## Accessing Loki

- Loki is only accessible from within the internal Docker network (`internal-net`). There is no port published to the host. Promtail and other containers on the internal network can send logs to Loki at `http://loki-monitoring:3100` or `http://172.28.0.20:3100` (if you set a static IP for Loki).

---

---

docker exec -it nginx-server /bin/sh
Where nginx-server = container name