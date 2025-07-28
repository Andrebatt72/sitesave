# Upload de Imagens OTIMIZADO - Direto no Storage (Sem CDN)
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

Write-Host "💰 Upload OTIMIZADO (Sem CDN - 70% mais barato!)" -ForegroundColor Green
Write-Host "📸 Fazendo upload de: $fileName" -ForegroundColor Cyan

# Upload APENAS para o Storage (pasta img no site estático)
Write-Host "  🌐 Upload para Storage Account..." -ForegroundColor Yellow
az storage blob upload `
    --account-name $StorageAccount `
    --container-name '$web' `
    --name "img/$fileName" `
    --file $ImageFile `
    --content-type $contentType `
    --overwrite

Write-Host "✅ Upload concluído!" -ForegroundColor Green
Write-Host "🔗 URLs disponíveis:" -ForegroundColor Cyan
Write-Host "   Direta: https://$StorageAccount.z15.web.core.windows.net/img/$fileName" -ForegroundColor Gray
Write-Host "   Personalizada: https://www.sistemasave.com.br/img/$fileName" -ForegroundColor Gray
Write-Host "💡 Sem CDN = Sem custos extras!" -ForegroundColor Yellow
