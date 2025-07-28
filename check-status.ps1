# Script para verificar status atual da configuracao DNS/HTTPS
param(
    [string]$Domain = "www.sistemasave.com.br"
)

Write-Host "🔍 Verificando status de: $Domain" -ForegroundColor Cyan
Write-Host "📅 Data/Hora: $(Get-Date)" -ForegroundColor Gray

# 1. Verificar DNS
Write-Host "`n📡 DNS Status:" -ForegroundColor Yellow
try {
    nslookup $Domain
} catch {
    Write-Host "❌ Erro na consulta DNS" -ForegroundColor Red
}

# 2. Status no Azure CDN
Write-Host "`n☁️ Azure CDN Status:" -ForegroundColor Yellow
az cdn custom-domain show `
    --endpoint-name "sistemasave-www" `
    --name "www-sistemasave-com-br" `
    --profile-name "sistemasave-cdn" `
    --resource-group "RG-SAVE-STORAGE" `
    --query "{Domain:hostName, HttpsStatus:customHttpsProvisioningState, HttpsSubstate:customHttpsProvisioningSubstate, ResourceState:resourceState}" `
    --output table

# 3. Teste de conectividade
Write-Host "`n🌐 Teste de Conectividade:" -ForegroundColor Yellow

# HTTP
try {
    $httpResponse = Invoke-WebRequest -Uri "http://$Domain" -Method Head -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ HTTP: $($httpResponse.StatusCode) - Funcionando" -ForegroundColor Green
} catch {
    Write-Host "❌ HTTP: Nao disponivel - $($_.Exception.Message)" -ForegroundColor Red
}

# HTTPS
try {
    $httpsResponse = Invoke-WebRequest -Uri "https://$Domain" -Method Head -TimeoutSec 10 -ErrorAction Stop
    Write-Host "✅ HTTPS: $($httpsResponse.StatusCode) - Funcionando" -ForegroundColor Green
} catch {
    Write-Host "⏳ HTTPS: Ainda nao disponivel (normal durante configuracao)" -ForegroundColor Yellow
}

# 4. Endpoints disponiveis
Write-Host "`n🔗 URLs Disponiveis:" -ForegroundColor Yellow
Write-Host "   🌐 Site Principal: http://$Domain (e https quando pronto)" -ForegroundColor Cyan
Write-Host "   📁 Imagens: http://$Domain/img/nome-do-arquivo.jpg" -ForegroundColor Cyan
Write-Host "   📊 CDN Direto: https://sistemasave-www.azureedge.net" -ForegroundColor Gray

Write-Host "`n✅ Verificacao concluida!" -ForegroundColor Green
