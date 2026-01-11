FROM n8nio/n8n:latest

COPY docker-entrypoint.sh /docker-entrypoint-custom.sh

USER root
RUN chmod +x /docker-entrypoint-custom.sh \
    && mkdir -p /opt/workflows \
    && chown -R node:node /opt/workflows /home/node/.n8n
USER node

ENTRYPOINT ["/docker-entrypoint-custom.sh"]
