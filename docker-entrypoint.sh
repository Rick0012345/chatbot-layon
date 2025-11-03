#!/usr/bin/env sh
set -e

# Diretório do usuário node
N8N_DIR="/home/node/.n8n"
WORKFLOWS_DIR="/opt/workflows"
IMPORT_MARKER="$N8N_DIR/.import_done"

# Garante que o diretório do n8n exista
mkdir -p "$N8N_DIR"

echo "[entrypoint] Verificando necessidade de importação de workflows..."
if [ ! -f "$IMPORT_MARKER" ]; then
  if [ -d "$WORKFLOWS_DIR" ]; then
    for f in "$WORKFLOWS_DIR"/*.json; do
      if [ -f "$f" ]; then
        echo "[entrypoint] Importando workflow: $f"
        # Importa o workflow no banco padrão (SQLite, por volume) ou no banco configurado via env
        n8n import:workflow --input "$f" || echo "[entrypoint] Falha ao importar $f (seguindo em frente)"
      fi
    done
    # Marca como importado para não repetir nas próximas inicializações
    touch "$IMPORT_MARKER"
  else
    echo "[entrypoint] Diretório de workflows não encontrado: $WORKFLOWS_DIR"
  fi
else
  echo "[entrypoint] Importação já realizada previamente. Pulando..."
fi

echo "[entrypoint] Iniciando n8n..."
exec n8n start