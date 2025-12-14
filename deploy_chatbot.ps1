# Configuração para parar o script se houver erro
$ErrorActionPreference = "Stop"

# Dados fixos
$ip = "72.62.10.128"
$user = "root"
$remote_dir = "~/chatbot-n8n"
$local_compose = "docker-compose-chatbot.yml"
$local_env = ".env.chatbot"

Write-Host "=== Iniciando Deploy do Chatbot no IP $ip ===" -ForegroundColor Green
Write-Host "Nota: A senha da VPS é: Nk@Nzqf9knAt-tB" -ForegroundColor Cyan
Write-Host "Copie a senha acima para colar quando for solicitado." -ForegroundColor Gray
Write-Host "---------------------------------------------------"

# Verificar arquivos
if (-not (Test-Path $local_compose) -or -not (Test-Path $local_env)) {
    Write-Error "Arquivos de configuração (compose ou env) não encontrados!"
    exit 1
}

# 1. Preparar ambiente remoto e liberar portas
Write-Host "`n[1/3] Criando pasta e liberando portas..." -ForegroundColor Yellow
Write-Host "Cole a senha agora:" -ForegroundColor White
# Tenta liberar porta 5679 (HTTP Traefik) e 8443 (HTTPS Traefik) se UFW estiver ativo
ssh $user@$ip "mkdir -p $remote_dir; if command -v ufw >/dev/null; then ufw allow 5679/tcp; ufw allow 8443/tcp; fi"

# 2. Copiar arquivos
Write-Host "`n[2/3] Enviando configurações..." -ForegroundColor Yellow
Write-Host "Cole a senha novamente:" -ForegroundColor White
scp $local_compose $local_env "$($user)@$($ip):$remote_dir/"

# 3. Renomear arquivos e subir container
Write-Host "`n[3/3] Iniciando Chatbot n8n (com Traefik)..." -ForegroundColor Yellow
Write-Host "Cole a senha pela última vez:" -ForegroundColor White
ssh $user@$ip "cd $remote_dir && mv .env.chatbot .env && mv docker-compose-chatbot.yml docker-compose.yml && docker compose down && docker compose up -d"

Write-Host "`n=== SUCESSO! ===" -ForegroundColor Green
Write-Host "Deploy baseado na arquitetura do Assistente Financeiro (Traefik + n8n + Postgres)."
Write-Host "`nAcesse agora em:" -ForegroundColor Cyan
Write-Host "https://chatbot.72.62.10.128.nip.io:8443" -ForegroundColor Cyan
Write-Host "`n(Nota: Pode levar 1-2 minutos para o n8n iniciar. Aceite o certificado se necessário.)"
Write-Host "Pressione Enter para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
