FROM n8nio/n8n:latest

# Copia workflows reais do repositório para importação automática
COPY ["chatbot postgres 6.0.json", "/opt/workflows/chatbot_postgres_6_0.json"]
COPY ["CRIAR TABELAS.json", "/opt/workflows/CRIAR_TABELAS.json"]
COPY ["inatividade-trigger.json", "/opt/workflows/inatividade_trigger.json"]

# Copia script de entrypoint que importa workflows e inicia o n8n
COPY docker-entrypoint.sh /docker-entrypoint-custom.sh

USER root
RUN chmod +x /docker-entrypoint-custom.sh \
    && mkdir -p /opt/workflows \
    && chown -R node:node /opt/workflows /home/node/.n8n
USER node

ENTRYPOINT ["/docker-entrypoint-custom.sh"]