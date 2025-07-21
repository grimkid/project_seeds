FROM dotcms/dotcms:24.12.27_lts_v8_6031d3b
# Install logrotate as root
USER root
RUN apt-get update && apt-get install -y logrotate && rm -rf /var/lib/apt/lists/*
# Copy logrotate config
COPY logrotate-dotcms.conf /etc/logrotate.d/dotcms
# Copy context.xml and set ownership for dotcms user
COPY context.xml /srv/dotserver/tomcat/conf/context.xml
RUN chown 10001:10001 /srv/dotserver/tomcat/conf/context.xml && chmod 666 /srv/dotserver/tomcat/conf/context.xml
# Switch back to dotcms user
USER dotcms
