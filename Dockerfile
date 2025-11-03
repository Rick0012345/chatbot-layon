FROM n8nio/n8n:latest

# Copia workflows para importação automática
COPY ["CHATBOT BASICO LAYON.json", "/opt/workflows/CHATBOT_BASICO_LAYON.json"]
COPY ["SUPER IMPORTANTE WORKFLOW PRECIOSO.json", "/opt/workflows/SUPER_IMPORTANTE_WORKFLOW_PRECIOSO.json"]
COPY ["chatbot-finalizado.json", "/opt/workflows/chatbot-finalizado.json"]

# Copia script de entrypoint que importa workflows e inicia o n8n
COPY docker-entrypoint.sh /docker-entrypoint-custom.sh

USER root
RUN chmod +x /docker-entrypoint-custom.sh \
    && mkdir -p /opt/workflows \
    && chown -R node:node /opt/workflows /home/node/.n8n
USER node

ENTRYPOINT ["/docker-entrypoint-custom.sh"]