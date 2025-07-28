# Script para configurar dominio personalizado no Azure CDN
param(
    [Parameter(Mandatory=$true)]
    [string]$Domain,  # Ex: www.sistemasave.com.br
    
    [string]$ProfileName = "sistemasave-cdn",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [string]$EndpointName = "sistemasave-www"
)

Write-Host "🌐 Configurando domínio personalizado no Azure CDN..." -ForegroundColor Green
Write-Host "📦 CDN Profile: $ProfileName" -ForegroundColor Cyan
Write-Host "🔗 Endpoint: $EndpointName" -ForegroundColor Cyan
Write-Host "🌍 Domínio: $Domain" -ForegroundColor Cyan

# Verificar se o endpoint existe
Write-Host "🔍 Verificando endpoint CDN..." -ForegroundColor Yellow
$endpointExists = az cdn endpoint show --name $EndpointName --profile-name $ProfileName --resource-group $ResourceGroupName --query "name" --output tsv 2>$null

if (-not $endpointExists) {
    Write-Error "❌ Endpoint '$EndpointName' não encontrado"
    exit 1
}

# Verificar registros DNS antes de prosseguir
Write-Host "🔍 Verificando configuração DNS..." -ForegroundColor Yellow
Write-Host "   Certifique-se de que o CNAME está configurado:" -ForegroundColor Gray
Write-Host "   $Domain → $EndpointName.azureedge.net" -ForegroundColor Gray

Read-Host "   Pressione ENTER quando o DNS estiver configurado"

# Adicionar domínio personalizado
Write-Host "➕ Adicionando domínio personalizado..." -ForegroundColor Yellow
try {
    az cdn custom-domain create `
        --endpoint-name $EndpointName `
        --name ($Domain -replace '\.', '-') `
        --profile-name $ProfileName `
        --resource-group $ResourceGroupName `
        --hostname $Domain
    
    Write-Host "✅ Domínio personalizado adicionado com sucesso!" -ForegroundColor Green
} catch {
    Write-Error "❌ Erro ao adicionar domínio personalizado: $_"
    exit 1
}

# Verificar status do domínio
Write-Host "🔍 Verificando status do domínio..." -ForegroundColor Yellow
az cdn custom-domain show `
    --endpoint-name $EndpointName `
    --name ($Domain -replace '\.', '-') `
    --profile-name $ProfileName `
    --resource-group $ResourceGroupName `
    --query "{Domain:hostName, Status:customHttpsProvisioningState, ValidationState:resourceState}" `
    --output table

Write-Host "`n🎉 Configuração DNS concluída!" -ForegroundColor Green
Write-Host "🌐 Seu site estará disponível em: https://$Domain" -ForegroundColor Cyan
Write-Host "`n📋 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Aguarde a propagação DNS (até 48h)" -ForegroundColor Gray
Write-Host "   2. HTTPS será habilitado automaticamente" -ForegroundColor Gray
Write-Host "   3. Teste o acesso: https://$Domain" -ForegroundColor Gray
