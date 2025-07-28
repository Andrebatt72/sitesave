# Script para deploy no Azure Storage (Storage Account existente)
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [string]$SourcePath = ".",
    
    [switch]$EnableStaticWebsite
)

# Configurar variáveis
$ContainerName = '$web'

Write-Host "🚀 Iniciando deploy para Azure Storage existente..." -ForegroundColor Green
Write-Host "📦 Storage Account: $StorageAccountName" -ForegroundColor Cyan
Write-Host "🗂️  Resource Group: $ResourceGroupName" -ForegroundColor Cyan

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

# Upload dos arquivos
Write-Host "📁 Fazendo upload dos arquivos..." -ForegroundColor Yellow

# Verificar se o arquivo index.html existe
if (-not (Test-Path "$SourcePath/index.html")) {
    Write-Error "❌ Arquivo index.html não encontrado em '$SourcePath'"
    exit 1
}

# Upload do index.html
Write-Host "  📄 Uploading index.html..." -ForegroundColor Gray
az storage blob upload `
    --account-name $StorageAccountName `
    --account-key $StorageKey `
    --container-name $ContainerName `
    --name "index.html" `
    --file "$SourcePath/index.html" `
    --content-type "text/html" `
    --overwrite

# Upload de pastas específicas se existirem
$folders = @("css", "js", "images", "img", "fonts", "assets")
foreach ($folder in $folders) {
    if (Test-Path "$SourcePath/$folder") {
        Write-Host "  📁 Uploading $folder files..." -ForegroundColor Gray
        az storage blob upload-batch `
            --account-name $StorageAccountName `
            --account-key $StorageKey `
            --destination $ContainerName `
            --source "$SourcePath/$folder" `
            --destination-path $folder `
            --overwrite
    }
}

# Upload de arquivos na raiz (exceto index.html já enviado)
$rootFiles = Get-ChildItem -Path $SourcePath -File | Where-Object { $_.Name -ne "index.html" -and $_.Name -notlike "*.ps1" -and $_.Name -notlike "*.md" }
foreach ($file in $rootFiles) {
    Write-Host "  📄 Uploading $($file.Name)..." -ForegroundColor Gray
    $contentType = switch ($file.Extension.ToLower()) {
        ".html" { "text/html" }
        ".css" { "text/css" }
        ".js" { "application/javascript" }
        ".json" { "application/json" }
        ".jpg" { "image/jpeg" }
        ".jpeg" { "image/jpeg" }
        ".png" { "image/png" }
        ".gif" { "image/gif" }
        ".svg" { "image/svg+xml" }
        ".ico" { "image/x-icon" }
        ".pdf" { "application/pdf" }
        ".txt" { "text/plain" }
        default { "application/octet-stream" }
    }
    
    az storage blob upload `
        --account-name $StorageAccountName `
        --account-key $StorageKey `
        --container-name $ContainerName `
        --name $file.Name `
        --file $file.FullName `
        --content-type $contentType `
        --overwrite
}

# Obter URL do site estático
Write-Host "🌐 Obtendo URL do site..." -ForegroundColor Yellow
$staticWebsiteUrl = az storage account show `
    --name $StorageAccountName `
    --resource-group $ResourceGroupName `
    --query "primaryEndpoints.web" --output tsv

Write-Host "✅ Deploy concluído com sucesso!" -ForegroundColor Green
Write-Host "🌐 Site disponível em: $staticWebsiteUrl" -ForegroundColor Cyan

# Mostrar instruções para domínio personalizado
Write-Host "`n📋 Para configurar domínio personalizado:" -ForegroundColor Yellow
Write-Host "   1. Configure CNAME: site.saveinformatica.com.br → ${StorageAccountName}.z15.web.core.windows.net" -ForegroundColor Gray
Write-Host "   2. Ou use Azure CDN para HTTPS e melhor performance" -ForegroundColor Gray
