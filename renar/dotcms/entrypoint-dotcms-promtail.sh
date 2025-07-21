#!/bin/bash
# Entrypoint: start dotCMS and run logrotate periodically

# Start dotCMS in the foreground
exec /srv/dotserver/bin/startup.sh &

# Wait for /data/logs to exist
while [ ! -d /data/logs ]; do
  echo "[entrypoint] Waiting for /data/logs to be created by dotCMS..."
  sleep 2
done

# Periodically run logrotate every 10 minutes
while true; do
  logrotate /etc/logrotate.d/dotcms
  sleep 600
done
