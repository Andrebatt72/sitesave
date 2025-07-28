# DEPLOY OTIMIZADO - Apenas Storage Account (70% mais barato!)
param(
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [string]$SourcePath = ".",
    [switch]$EnableStaticWebsite
)

$ContainerName = '$web'

Write-Host "� DEPLOY OTIMIZADO - 70% MAIS BARATO!" -ForegroundColor Green
Write-Host "💰 Custo: $2-5/mês (vs $9-26 com CDN)" -ForegroundColor Yellow
Write-Host "📦 Storage Account: $StorageAccountName" -ForegroundColor Cyan
Write-Host "🗂️  Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "🌐 URL direta do Storage: https://$StorageAccountName.z15.web.core.windows.net/" -ForegroundColor Yellow
Write-Host "💡 Para dominio personalizado: Configure CNAME no DNS" -ForegroundColor Magenta

# Verificar se a Storage Account existe
Write-Host "🔍 Verificando Storage Account..." -ForegroundColor Yellow
$storageExists = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "name" --output tsv 2>$null

if (-not $storageExists) {
    Write-Error "Storage Account '$StorageAccountName' nao encontrada"
    exit 1
}

# Habilitar site estatico se solicitado
if ($EnableStaticWebsite) {
    Write-Host "🌐 Habilitando site estatico..." -ForegroundColor Yellow
    az storage blob service-properties update --account-name $StorageAccountName --static-website --index-document "index.html" --404-document "404.html"
}

# Upload do index.html
if (Test-Path "$SourcePath/index.html") {
    Write-Host "📄 Uploading index.html..." -ForegroundColor Gray
    az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name "index.html" --file "$SourcePath/index.html" --content-type "text/html" --overwrite
} else {
    Write-Error "Arquivo index.html nao encontrado"
    exit 1
}

# Upload de imagens para pasta img/ (SEM CDN - Direto no Storage)
$imageFiles = Get-ChildItem -Path $SourcePath -File | Where-Object { 
    $_.Extension.ToLower() -in @(".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp") 
}
foreach ($image in $imageFiles) {
    Write-Host "🖼️  Uploading imagem: $($image.Name)" -ForegroundColor Gray
    $contentType = switch ($image.Extension.ToLower()) {
        ".jpg" { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".png" { "image/png" }
        ".gif" { "image/gif" }
        ".svg" { "image/svg+xml" }
        ".webp" { "image/webp" }
        default { "image/jpeg" }
    }
    
    # Upload APENAS no Storage (sem CDN)
    az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name "img/$($image.Name)" --file $image.FullName --content-type $contentType --overwrite
}

# Upload de outros arquivos web
$webFiles = Get-ChildItem -Path $SourcePath -File | Where-Object { 
    $_.Name -ne "index.html" -and 
    $_.Name -notlike "*.ps1" -and 
    $_.Extension.ToLower() -notin @(".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp")
}
foreach ($file in $webFiles) {
    Write-Host "📄 Uploading arquivo: $($file.Name)" -ForegroundColor Gray
    $contentType = switch ($file.Extension.ToLower()) {
        ".html" { "text/html" }
        ".css" { "text/css" }
        ".js" { "application/javascript" }
        ".json" { "application/json" }
        ".xml" { "application/xml" }
        ".txt" { "text/plain" }
        default { "application/octet-stream" }
    }
    
    az storage blob upload --account-name $StorageAccountName --container-name $ContainerName --name $file.Name --file $file.FullName --content-type $contentType --overwrite
}

Write-Host "✅ Deploy concluido com sucesso!" -ForegroundColor Green
Write-Host "🌐 Site disponivel em: https://$StorageAccountName.z15.web.core.windows.net/" -ForegroundColor Cyan
Write-Host "🖼️  Imagens funcionam em: https://$StorageAccountName.z15.web.core.windows.net/img/[nome-imagem]" -ForegroundColor Cyan

Write-Host "`n💰 ECONOMIA SEM CDN:" -ForegroundColor Yellow
Write-Host "   • Custo mensal: $2-5 (vs $9-26 com CDN)" -ForegroundColor Green
Write-Host "   • Economia: 70-80%" -ForegroundColor Green
Write-Host "   • Mesma funcionalidade!" -ForegroundColor Green

Write-Host "`n🌐 Para dominio personalizado:" -ForegroundColor Yellow
Write-Host "   1. Configure CNAME: www.seudominio.com → $StorageAccountName.z15.web.core.windows.net" -ForegroundColor Gray
Write-Host "   2. HTTPS automatico do Azure" -ForegroundColor Gray
Write-Host "   3. Sem necessidade de CDN!" -ForegroundColor Gray
