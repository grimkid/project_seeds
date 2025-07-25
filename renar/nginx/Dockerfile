
# Use the official Debian-based Nginx image as a base
FROM nginx:latest

# Install Promtail (glibc binary, v2.9.7)
RUN apt-get update && \
    apt-get install -y curl unzip wget && \
    wget -O /tmp/promtail.zip "https://github.com/grafana/loki/releases/download/v2.9.7/promtail-linux-amd64.zip" && \
    unzip /tmp/promtail.zip -d /usr/bin/ && \
    mv /usr/bin/promtail-linux-amd64 /usr/bin/promtail && \
    chmod +x /usr/bin/promtail && \
    rm -f /tmp/promtail.zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy Promtail config
COPY promtail-config.yaml /etc/promtail-config.yaml
COPY data/html/default.conf /etc/nginx/conf.d/default.conf
# Expose port 80
EXPOSE 80

# Start both Nginx and Promtail
CMD /bin/sh -c "nginx -g 'daemon off;' & /usr/bin/promtail -config.file=/etc/promtail-config.yaml"
