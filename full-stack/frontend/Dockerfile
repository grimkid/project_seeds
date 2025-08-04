# PĂSTRĂM: Imaginea de bază Debian
FROM node:20-bullseye

# PĂSTRĂM: Instalarea uneltelor și curățarea
RUN apt-get update && \
    apt-get install -y openssh-server sudo vim && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# PĂSTRĂM: Crearea utilizatorilor și configurarea sudo
RUN useradd -m -s /bin/bash rares && \
    useradd -m -s /bin/bash seby
RUN echo 'rares ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    echo 'seby ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# PĂSTRĂM: Configurarea cheilor SSH
# (Codul tău pentru chei SSH rămâne aici, neschimbat)
RUN mkdir -p /home/rares/.ssh /home/seby/.ssh && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDIOu353hHRCzO36DA7XVZ/xMeFdGlatgHEvXD3nYg1Km1cFpR1YudMM0wct451dnGW6l9DpZyZSch6+I4aVRA25QZH4ehxpp0dYzufjJ5FK4epeUCo2FthKYvH3zzJUTEboQvB396Q8fGml02Ajy6GAjq2SL7O0vOtiaMaqpQzqgcwQnICcTwZAuLmHYobyiBSvYJRvbTTZY/7z1iJEd+1H9DB7Pyl3ZSqXnlE9fWGHg6ZlaK1tSVkGDujZglHgRwv/ZKEww3C6y3rJW5wIaKszofdjjPKz85yLf/KaFzHKcc1083t6Xdfo4Q30OfobxB5/Zk9KFWoIlmYflrxgAroGEiDqarnjzE1T/d51Ul26OfpRHMwNDuFiMT3KklQp53hxdQwllqxv71IQrMPtKLSywGv8a9702NzmjNBZit0nBnX+PHI6Kwn9lCCFjnquTo5OB8oSDefsHKJ12X6rFtdyrTcFSDvyLHjuwTSNbAC9VUJ/jVYC3n6LLC7/sNRlKsqp83M9VwTEVyqxVSTGiZmmUlPoiGU2tfimkwVWvNOtt5JMJUB4FJOJRPylBRBU6yga94pqia9gHOmvifU+uAp5yBlQJSWUI/0BtrFXWrbcbrlcaxNcWuGl1DjuI65dRaQxzd57MU1iLH0ZFDkryVaizGNaJPylURAhnnQTyADoQ== rares@ggubuntu' > /home/rares/.ssh/authorized_keys && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCkSJWVdf8wzJpNF2YVIuZqg6UZStpBLb/eaqW2k6pEnQsF3KQnodKnCZlSLl954+iX8oePSEtddoT616FNgoI6MV8Qz1TxDa2atc9QPBzUWhE5dEAighlWfnHNF0061aOtfjyw+f0KWTsDS/KhLQom4EWBvvDibKI+0t27LXT9ILI+IrR++dibXaFYaRi0spCiknXG3IDOChb5hM09ITtO7C3r/wRR1ocMmB3h55LPpt2ihjWX4g1JGdGAGuhGhnXiRhHzgeVyc/vq/iIqmqBXp+yDj8HKBUKaLJMFPxDgwaECZor96yslPzhGIUSJqIBTT3bmdkGBmzKsDKggbmF1saEsqqMOomk+QH0vrYXp9bIX5bbK68g30TxqtjVGExz+XcmL4VdVVR1fRTt1FXKt0SHvXfqPgyZLONypa4oH834kqdgyi83gHA8h07MeeAJOqnoZcoL1iYbqIIHbBS2jgFQI3uWgYkodirTJ/1en+vRxOBWwufIvJ8xvj3r84ufaoTP1bUs47ccTpVoLtg97jskfx6d9P3mEdjkiNgD52YXntl49iwXPEe+ZoWJX/WZkYLUM1L9uvDIIruDNmzrJC5kBsC4mRmgjdMca95ruRbrQw3vZutThZg1GAaP/1bZllfW3cQl3hwA5O1UddZ9ZcS9NtECjeh3Xkr+LziODTQ== rares@ggubuntu' > /home/seby/.ssh/authorized_keys && \
    chown -R rares:rares /home/rares/.ssh && chmod 700 /home/rares/.ssh && chmod 600 /home/rares/.ssh/authorized_keys && \
    chown -R seby:seby /home/seby/.ssh && chmod 700 /home/seby/.ssh && chmod 600 /home/seby/.ssh/authorized_keys

# PĂSTRĂM: SSH config
RUN /usr/bin/ssh-keygen -A
# Creăm directorul necesar pentru serverul SSH înainte de a-l configura
RUN mkdir -p /run/sshd

RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# --- OPTIMIZARE: Mutăm instalarea dependențelor aici ---
WORKDIR /app

# Copiem DOAR fișierele de manifest. Docker va folosi cache pentru acest pas.
COPY frontend-platform/package*.json ./

# Rulăm npm install. Acest pas va fi sărit la build-uri viitoare dacă package.json nu se schimbă.
RUN npm install

# Copiem scriptul de entrypoint și îi dăm drepturi de execuție
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# --- SFÂRȘIT OPTIMIZARE ---

# PĂSTRĂM: Expunerea porturilor
EXPOSE 22 3000

# PĂSTRĂM: Entrypoint-ul tău custom
ENTRYPOINT ["entrypoint.sh"]