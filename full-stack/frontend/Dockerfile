# Imaginea de bază rămâne la fel
FROM node:20-bullseye

# --- Pas 1: Instalare Dependențe de Sistem (SSH, Supervisor, Promtail) ---
RUN apt-get update && \
    apt-get install -y openssh-server sudo vim curl unzip wget supervisor && \
    wget -O /tmp/promtail.zip "https://github.com/grafana/loki/releases/download/v2.9.7/promtail-linux-amd64.zip" && \
    unzip /tmp/promtail.zip -d /usr/bin/ && \
    mv /usr/bin/promtail-linux-amd64 /usr/bin/promtail && \
    chmod +x /usr/bin/promtail && \
    rm -f /tmp/promtail.zip && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# --- Pas 2: Configurare SSH și Utilizatori (Rămâne neschimbat) ---
RUN useradd -m -s /bin/bash rares && useradd -m -s /bin/bash seby
RUN echo 'rares ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && echo 'seby ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN mkdir -p /home/rares/.ssh /home/seby/.ssh
# ... (liniile tale lungi cu cheile SSH vin aici, neschimbate) ...
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIOu353hHRCzO36DA7XVZ/xMeFdGlatgHEvXD3nYg1Km1cFpR1YudMM0wct451dnGW6l9DpZyZSch6+I4aVRA25QZH4ehxpp0dYzufjJ5FK4epeUCo2FthKYvH3zzJUTEboQvB396Q8fGml02Ajy6GAjq2SL7O0vOtiaMaqpQzqgcwQnICcTwZAuLmHYobyiBSvYJRvbTTZY/7z1iJEd+1H9DB7Pyl3ZSqXnlE9fWGHg6ZlaK1tSVkGDujZglHgRwv/ZKEww3C6y3rJW5wIaKszofdjjPKz85yLf/KaFzHKcc1083t6Xdfo4Q30OfobxB5/Zk9KFWoIlmYflrxgAroGEiDqarnjzE1T/d51Ul26OfpRHMwNDuFiMT3KklQp53hxdQwllqxv71IQrMPtKLSywGv8a9702NzmjNBZit0nBnX+PHI6Kwn9lCCFjnquTo5OB8oSDefsHKJ12X6rFtdyrTcFSDvyLHjuwTSNbAC9VUJ/jVYC3n6LLC7/sNRlKsqp83M9VwTEVyqxVSTGiZmmUlPoiGU2tfimkwVWvNOtt5JMJUB4FJOJRPylBRBU6yga94pqia9gHOmvifU+uAp5yBlQJSWUI/0BtrFXWrbcbrlcaxNcWuGl1DjuI65dRaQxzd57MU1iLH0ZFDkryVaizGNaJPylURAhnnQTyADoQ== rares@ggubuntu' > /home/rares/.ssh/authorized_keys
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkSJWVdf8wzJpNF2YVIuZqg6UZStpBLb/eaqW2k6pEnQsF3KQnodKnCZlSLl954+iX8oePSEtddoT616FNgoI6MV8Qz1TxDa2atc9QPBzUWhE5dEAighlWfnHNF0061aOtfjyw+f0KWTsDS/KhLQom4EWBvvDibKI+0t27LXT9ILI+IrR++dibXaFYaRi0spCiknXG3IDOChb5hM09ITtO7C3r/wRR1ocMmB3h55LPpt2ihjWX4g1JGdGAGuhGhnXiRhHzgeVyc/vq/iIqmqBXp+yDj8HKBUKaLJMFPxDgwaECZor96yslPzhGIUSJqIBTT3bmdkGBmzKsDKggbmF1saEsqqMOomk+QH0vrYXp9bIX5bbK68g30TxqtjVGExz+XcmL4VdVVR1fRTt1FXKt0SHvXfqPgyZLONypa4oH834kqdgyi83gHA8h07MeeAJOqnoZcoL1iYbqIIHbBS2jgFQI3uWgYkodirTJ/1en+vRxOBWwufIvJ8xvj3r84ufaoTP1bUs47ccTpVoLtg97jskfx6d9P3mEdjkiNgD52YXntl49iwXPEe+ZoWJX/WZkYLUM1L9uvDIIruDNmzrJC5kBsC4mRmgjdMca95ruRbrQw3vZutThZg1GAaP/1bZllfW3cQl3hwA5O1UddZ9ZcS9NtECjeh3Xkr+LziODTQ== rares@ggubuntu' > /home/seby/.ssh/authorized_keys
RUN chown -R rares:rares /home/rares/.ssh && chmod 700 /home/rares/.ssh && chmod 600 /home/rares/.ssh/authorized_keys
RUN chown -R seby:seby /home/seby/.ssh && chmod 700 /home/seby/.ssh && chmod 600 /home/seby/.ssh/authorized_keys
RUN /usr/bin/ssh-keygen -A && mkdir -p /run/sshd
RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# --- Pasul 3: Pregătire Aplicație Node.js ---
WORKDIR /app
COPY frontend-platform/package*.json ./
RUN npm install

# --- Pasul 4: Copiere Fișiere de Configurare ---
# Nu mai copiem entrypoint.sh, deoarece supervisor îl înlocuiește
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY promtail-config.yaml /etc/promtail/promtail-config.yaml

# Creează folderul de log-uri pentru supervisor
RUN mkdir -p /app/logs

# --- Pasul 5: Expunere Porturi și Comandă de Start ---
EXPOSE 22 3000

# Comanda finală este să pornim supervisor, care va gestiona restul proceselor
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]