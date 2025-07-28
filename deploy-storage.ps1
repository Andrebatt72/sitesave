# Script para deploy no Azure Storage - URL Personalizada (Storage Account existente)
param(
    [Parameter(Mandatory=$false)]
    [string]$StorageAccountName = "sistemasavestorage",
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    
    [string]$SourcePath = ".",
    
    [switch]$EnableStaticWebsite
)

# Configurar variáveis
$ContainerName = '$web'

Write-Host "🚀 Iniciando deploy para URL personalizada..." -ForegroundColor Green
Write-Host "📦 Storage Account: $StorageAccountName" -ForegroundColor Cyan
Write-Host "🗂️  Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "🌐 URL do site: https://www.sistemasave.com.br" -ForegroundColor Magenta

# Verificar se a Storage Account existe
Write-Host "🔍 Verificando Storage Account..." -ForegroundColor Yellow
$storageExists = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "name" --output tsv 2>$null

if (-not $storageExists) {
    Write-Error "❌ Storage Account '$StorageAccountName' não encontrada no Resource Group '$ResourceGroupName'"
    exit 1
}

# Habilitar site estático se solicitado
if ($EnableStaticWebsite) {
    Write-Host "🌐 Habilitando site estático..." -ForegroundColor Yellow
    az storage blob service-properties update `
        --account-name $StorageAccountName `
        --static-website `
        --index-document "index.html" `
        --404-document "404.html"
}

# Obter chave da storage account
Write-Host "🔑 Obtendo chave de acesso..." -ForegroundColor Yellow
$StorageKey = az storage account keys list `
    --account-name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --query "[0].value" --output tsv

if (-not $StorageKey) {
    Write-Error "❌ Erro ao obter chave da Storage Account"
    exit 1
}

# Upload dos arquivos no container $web para URL personalizada
Write-Host "📁 Fazendo upload para container $web..." -ForegroundColor Yellow

# Verificar se o arquivo index.html existe
if (-not (Test-Path "$SourcePath/index.html")) {
    Write-Error "❌ Arquivo index.html não encontrado em '$SourcePath'"
    exit 1
}

# Upload do index.html
Write-Host "  📄 Uploading index.html..." -ForegroundColor Gray
az storage blob upload `
    --account-name $StorageAccountName `
    --container-name $ContainerName `
    --name "index.html" `
    --file "$SourcePath/index.html" `
    --content-type "text/html" `
    --overwrite

# Upload de imagens para pasta img/ (para URLs personalizadas)
if (Test-Path "$SourcePath/images") {
    Write-Host "  🖼️  Uploading images para pasta img/..." -ForegroundColor Gray
    Get-ChildItem "$SourcePath/images" -File | ForEach-Object {
        $contentType = switch ($_.Extension.ToLower()) {
            ".jpg" { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".png" { "image/png" }
            ".gif" { "image/gif" }
            ".svg" { "image/svg+xml" }
            ".webp" { "image/webp" }
            default { "image/jpeg" }
        }
        
        az storage blob upload `
            --account-name $StorageAccountName `
            --container-name $ContainerName `
            --name "img/$($_.Name)" `
            --file $_.FullName `
            --content-type $contentType `
            --overwrite
    }
}

# Upload de arquivos de imagem na raiz para pasta img/
$imageFiles = Get-ChildItem -Path $SourcePath -File | Where-Object { 
    $_.Extension.ToLower() -in @(".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp") 
}
foreach ($image in $imageFiles) {
    Write-Host "  🖼️  Uploading $($image.Name) para pasta img/..." -ForegroundColor Gray
    $contentType = switch ($image.Extension.ToLower()) {
        ".jpg" { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".png" { "image/png" }
        ".gif" { "image/gif" }
        ".svg" { "image/svg+xml" }
        ".webp" { "image/webp" }
        default { "image/jpeg" }
    }
    
    az storage blob upload `
        --account-name $StorageAccountName `
        --container-name $ContainerName `
        --name "img/$($image.Name)" `
        --file $image.FullName `
        --content-type $contentType `
        --overwrite
}

# Upload de outros arquivos web (CSS, JS, JSON)
$webFiles = Get-ChildItem -Path $SourcePath -File | Where-Object { 
    $_.Name -ne "index.html" -and 
    $_.Name -notlike "*.ps1" -and 
    $_.Extension.ToLower() -notin @(".jpg", ".jpeg", ".png", ".gif", ".svg", ".webp")
}
foreach ($file in $webFiles) {
    Write-Host "  📄 Uploading $($file.Name)..." -ForegroundColor Gray
    $contentType = switch ($file.Extension.ToLower()) {
        ".html" { "text/html" }
        ".css" { "text/css" }
        ".js" { "application/javascript" }
        ".json" { "application/json" }
        ".xml" { "application/xml" }
        ".txt" { "text/plain" }
        default { "application/octet-stream" }
    }
    
    az storage blob upload `
        --account-name $StorageAccountName `
        --container-name $ContainerName `
        --name $file.Name `
        --file $file.FullName `
        --content-type $contentType `
        --overwrite
}

Write-Host "✅ Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "🌐 Site disponível em: https://www.sistemasave.com.br" -ForegroundColor Cyan
Write-Host "🖼️  Imagens disponíveis em: https://www.sistemasave.com.br/img/[nome-da-imagem]" -ForegroundColor Cyan

# Instruções de uso
Write-Host "`n📋 Como usar:" -ForegroundColor Yellow
Write-Host "   • Site principal: https://www.sistemasave.com.br" -ForegroundColor Gray
Write-Host "   • Imagens: https://www.sistemasave.com.br/img/exemplo.jpg" -ForegroundColor Gray
Write-Host "   • Para novas imagens: Use .\upload-image.ps1" -ForegroundColor Gray
