# Script para verificar configuração DNS
param(
    [Parameter(Mandatory=$true)]
    [string]$Domain  # Ex: www.sistemasave.com.br
)

Write-Host "🔍 Verificando configuração DNS para: $Domain" -ForegroundColor Green

# Verificar CNAME
Write-Host "`n📡 Verificando registro CNAME..." -ForegroundColor Yellow
try {
    $cnameRecord = nslookup $Domain 2>$null
    Write-Host $cnameRecord -ForegroundColor Gray
} catch {
    Write-Host "❌ Erro na consulta DNS" -ForegroundColor Red
}

# Verificar conectividade HTTP
Write-Host "`n🌐 Testando conectividade HTTP..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://$Domain" -Method Head -TimeoutSec 10 -ErrorAction SilentlyContinue
    Write-Host "✅ HTTP: $($response.StatusCode) - $($response.StatusDescription)" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTP não disponível" -ForegroundColor Red
}

# Verificar conectividade HTTPS
Write-Host "`n🔒 Testando conectividade HTTPS..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "https://$Domain" -Method Head -TimeoutSec 10 -ErrorAction SilentlyContinue
    Write-Host "✅ HTTPS: $($response.StatusCode) - $($response.StatusDescription)" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTPS não disponível (normal durante propagação)" -ForegroundColor Yellow
}

# Verificar status no Azure CDN
Write-Host "`n☁️ Verificando status no Azure CDN..." -ForegroundColor Yellow
$domainName = $Domain -replace '\.', '-'
az cdn custom-domain show `
    --endpoint-name "sistemasave-www" `
    --name $domainName `
    --profile-name "sistemasave-cdn" `
    --resource-group "RG-SAVE-STORAGE" `
    --query "{Domain:hostName, Status:customHttpsProvisioningState, ValidationState:resourceState}" `
    --output table 2>$null

Write-Host "`n📋 Resumo da verificação concluída!" -ForegroundColor Green
