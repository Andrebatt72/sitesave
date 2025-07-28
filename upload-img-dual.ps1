# Script para upload de imagens em ambos os locais
# Para que funcionem tanto o CDN direto quanto o caminho /img/
param(
    [Parameter(Mandatory=$true)]
    [string]$ImageFile,
    
    [string]$StorageAccount = "sistemasavestorage",
    [string]$ResourceGroup = "RG-SAVE-STORAGE"
)

$fileName = Split-Path $ImageFile -Leaf

Write-Host "📸 Fazendo upload de: $fileName" -ForegroundColor Cyan

# 1. Upload para container img (CDN direto)
Write-Host "  📁 Upload para container img..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccount `
    --container-name img `
    --name $fileName `
    --file $ImageFile `
    --content-type "image/$(if($fileName -match '\.(.+)$') {$matches[1]} else {'jpeg'})" `
    --overwrite

# 2. Upload para pasta img no site estático (domínio personalizado)
Write-Host "  🌐 Upload para site estático..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccount `
    --container-name '$web' `
    --name "img/$fileName" `
    --file $ImageFile `
    --content-type "image/$(if($fileName -match '\.(.+)$') {$matches[1]} else {'jpeg'})" `
    --overwrite

Write-Host "✅ Upload concluído!" -ForegroundColor Green
Write-Host "🔗 URLs disponíveis:" -ForegroundColor Cyan
Write-Host "   CDN Direto: https://sistemasave-img.azureedge.net/$fileName" -ForegroundColor Gray
Write-Host "   Dominio Personalizado: https://www.sistemasave.com.br/img/$fileName" -ForegroundColor Gray
