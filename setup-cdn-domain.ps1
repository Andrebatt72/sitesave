# Script para configurar Azure CDN com domínio personalizado para imagens
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [string]$CdnProfileName = "sistemasave-cdn",
    [string]$CdnEndpointName = "sistemasave-images",
    [string]$CustomDomain = "img.sistemasave.com.br",
    [string]$ContainerName = "images"
)

Write-Host "🚀 Configurando Azure CDN para hospedagem de imagens..." -ForegroundColor Green

# Verificar se a Storage Account existe
$storageAccount = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "primaryEndpoints.blob" --output tsv 2>$null
if (-not $storageAccount) {
    Write-Error "❌ Storage Account '$StorageAccountName' não encontrada"
    exit 1
}

$originUrl = $storageAccount.TrimEnd('/') + "/$ContainerName"

# Criar perfil CDN
Write-Host "📡 Criando perfil CDN..." -ForegroundColor Yellow
az cdn profile create `
    --name $CdnProfileName `
    --resource-group $ResourceGroupName `
    --sku "Standard_Microsoft" `
    --location "global"

# Criar endpoint CDN
Write-Host "🌐 Criando endpoint CDN..." -ForegroundColor Yellow
az cdn endpoint create `
    --name $CdnEndpointName `
    --profile-name $CdnProfileName `
    --resource-group $ResourceGroupName `
    --origin $originUrl `
    --origin-host-header "$StorageAccountName.blob.core.windows.net" `
    --origin-path "/$ContainerName" `
    --query-string-caching-behavior "IgnoreQueryString" `
    --content-types-to-compress "image/jpeg,image/png,image/gif,image/svg+xml,image/webp"

# Configurar regras de cache otimizadas para imagens
Write-Host "⚙️ Configurando cache otimizado para imagens..." -ForegroundColor Yellow
az cdn endpoint rule add `
    --name $CdnEndpointName `
    --profile-name $CdnProfileName `
    --resource-group $ResourceGroupName `
    --rule-name "ImageCacheRule" `
    --order 1 `
    --match-variable "UrlFileExtension" `
    --operator "Equal" `
    --match-values "jpg,jpeg,png,gif,svg,webp,bmp,ico" `
    --action-name "CacheExpiration" `
    --cache-behavior "Override" `
    --cache-duration "365.00:00:00"

Write-Host "✅ CDN configurado com sucesso!" -ForegroundColor Green

$cdnEndpointUrl = "https://$CdnEndpointName.azureedge.net"
Write-Host "🌐 URL do CDN: $cdnEndpointUrl" -ForegroundColor Cyan

Write-Host "`n📋 Próximos passos manuais:" -ForegroundColor Yellow
Write-Host "1. 🌍 Configure DNS:" -ForegroundColor White
Write-Host "   Tipo: CNAME" -ForegroundColor Gray
Write-Host "   Nome: img" -ForegroundColor Gray
Write-Host "   Valor: $CdnEndpointName.azureedge.net" -ForegroundColor Gray
Write-Host "   TTL: 3600" -ForegroundColor Gray

Write-Host "`n2. 🔒 Adicione domínio personalizado no Portal Azure:" -ForegroundColor White
Write-Host "   - Vá para o CDN endpoint no portal" -ForegroundColor Gray
Write-Host "   - Clique em 'Custom domains'" -ForegroundColor Gray
Write-Host "   - Adicione: $CustomDomain" -ForegroundColor Gray
Write-Host "   - Habilite HTTPS com certificado gerenciado" -ForegroundColor Gray

Write-Host "`n🎯 Resultado final:" -ForegroundColor Yellow
Write-Host "   URL de acesso: https://$CustomDomain/[nome-da-imagem]" -ForegroundColor Cyan
Write-Host "   Exemplo: https://$CustomDomain/logo.png" -ForegroundColor Cyan
