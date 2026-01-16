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
    Write-Error "Arquivos necessários (compose ou env) não encontrados!"
    exit 1
}

# 1. Preparar ambiente remoto
Write-Host "`n[1/3] Criando pasta no servidor..." -ForegroundColor Yellow
Write-Host "Cole a senha agora:" -ForegroundColor White
ssh $user@$ip "mkdir -p $remote_dir"

# 2. Copiar arquivos
Write-Host "`n[2/3] Enviando configurações..." -ForegroundColor Yellow
Write-Host "Cole a senha novamente:" -ForegroundColor White
scp $local_compose $local_env "$($user)@$($ip):$remote_dir/"

# 3. Renomear arquivos e subir container
Write-Host "`n[3/3] Iniciando Chatbot n8n (via Traefik principal)..." -ForegroundColor Yellow
Write-Host "Cole a senha pela última vez:" -ForegroundColor White
ssh $user@$ip "cd $remote_dir && mv .env.chatbot .env && mv docker-compose-chatbot.yml docker-compose.yml && docker compose down && docker compose up -d --build"

Write-Host "`n=== SUCESSO! ===" -ForegroundColor Green
Write-Host "Deploy usando Traefik principal (n8n-docker) com certificado Let's Encrypt." -ForegroundColor Green
Write-Host "`nAcesse agora em:" -ForegroundColor Cyan
Write-Host "https://chatbot.updesigner.72.62.10.128.nip.io" -ForegroundColor Cyan
Write-Host "`n(Nota: Pode levar 1-2 minutos para o n8n iniciar. Aceite o certificado se necessário.)"
Write-Host "Pressione Enter para sair..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
