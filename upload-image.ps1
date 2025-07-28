# Script para upload de imagens em ambos os locais
param(
    [Parameter(Mandatory=$true)]
    [string]$ImageFile,
    
    [string]$StorageAccount = "sistemasavestorage"
)

$fileName = Split-Path $ImageFile -Leaf
$extension = [System.IO.Path]::GetExtension($fileName).TrimStart('.').ToLower()

# Determinar content-type
$contentType = switch ($extension) {
    "jpg" { "image/jpeg" }
    "jpeg" { "image/jpeg" }
    "png" { "image/png" }
    "gif" { "image/gif" }
    "svg" { "image/svg+xml" }
    "webp" { "image/webp" }
    default { "image/jpeg" }
}

Write-Host "📸 Fazendo upload de: $fileName" -ForegroundColor Cyan

# 1. Upload para container img (CDN direto)
Write-Host "  📁 Upload para container img..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccount `
    --container-name img `
    --name $fileName `
    --file $ImageFile `
    --content-type $contentType `
    --overwrite

# 2. Upload para pasta img no site estático
Write-Host "  🌐 Upload para site estático..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccount `
    --container-name '$web' `
    --name "img/$fileName" `
    --file $ImageFile `
    --content-type $contentType `
    --overwrite

Write-Host "✅ Upload concluído!" -ForegroundColor Green
Write-Host "🔗 URLs disponíveis:" -ForegroundColor Cyan
Write-Host "   CDN Direto: https://sistemasave-img.azureedge.net/$fileName" -ForegroundColor Gray
Write-Host "   Dominio: https://www.sistemasave.com.br/img/$fileName" -ForegroundColor Gray
