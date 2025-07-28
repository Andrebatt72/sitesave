# Script para configurar hospedagem de imagens no Azure Storage
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    
    [string]$ImagesPath = "images",
    
    [string]$ContainerName = "images"
)

Write-Host "🚀 Configurando hospedagem de imagens no Azure Storage..." -ForegroundColor Green
Write-Host "📦 Storage Account: $StorageAccountName" -ForegroundColor Cyan
Write-Host "🗂️  Resource Group: $ResourceGroupName" -ForegroundColor Cyan
Write-Host "📁 Container: $ContainerName" -ForegroundColor Cyan

# Verificar se a Storage Account existe
Write-Host "🔍 Verificando Storage Account..." -ForegroundColor Yellow
$storageExists = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "name" --output tsv 2>$null

if (-not $storageExists) {
    Write-Error "❌ Storage Account '$StorageAccountName' não encontrada no Resource Group '$ResourceGroupName'"
    exit 1
}

# Criar container para imagens (se não existir)
Write-Host "📁 Criando/verificando container '$ContainerName'..." -ForegroundColor Yellow
az storage container create `
    --account-name $StorageAccountName `
    --name $ContainerName `
    --public-access blob `
    --auth-mode login

# Configurar CORS para permitir acesso direto às imagens
Write-Host "🌐 Configurando CORS para acesso às imagens..." -ForegroundColor Yellow
az storage cors add `
    --account-name $StorageAccountName `
    --services b `
    --methods GET HEAD `
    --origins "*" `
    --allowed-headers "*" `
    --exposed-headers "*" `
    --max-age 3600 `
    --auth-mode login

# Upload de imagens (se existir pasta local)
if (Test-Path $ImagesPath) {
    Write-Host "📸 Fazendo upload das imagens..." -ForegroundColor Yellow
    
    $imageFiles = Get-ChildItem -Path $ImagesPath -File -Include "*.jpg", "*.jpeg", "*.png", "*.gif", "*.svg", "*.webp", "*.bmp", "*.ico"
    
    foreach ($image in $imageFiles) {
        Write-Host "  📄 Uploading $($image.Name)..." -ForegroundColor Gray
        
        $contentType = switch ($image.Extension.ToLower()) {
            ".jpg" { "image/jpeg" }
            ".jpeg" { "image/jpeg" }
            ".png" { "image/png" }
            ".gif" { "image/gif" }
            ".svg" { "image/svg+xml" }
            ".webp" { "image/webp" }
            ".bmp" { "image/bmp" }
            ".ico" { "image/x-icon" }
            default { "image/jpeg" }
        }
        
        az storage blob upload `
            --account-name $StorageAccountName `
            --container-name $ContainerName `
            --name $image.Name `
            --file $image.FullName `
            --content-type $contentType `
            --overwrite `
            --auth-mode login
    }
    
    Write-Host "✅ Upload de $($imageFiles.Count) imagens concluído!" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Pasta '$ImagesPath' não encontrada. Container criado e pronto para receber imagens." -ForegroundColor Yellow
}

# Obter URL do container
Write-Host "🌐 Obtendo informações do container..." -ForegroundColor Yellow
$containerUrl = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/"

Write-Host "`n✅ Configuração concluída com sucesso!" -ForegroundColor Green
Write-Host "🌐 URL base do container: $containerUrl" -ForegroundColor Cyan
Write-Host "📋 Exemplo de acesso a imagem: ${containerUrl}exemplo.jpg" -ForegroundColor Cyan

Write-Host "`n📋 Próximos passos para domínio personalizado:" -ForegroundColor Yellow
Write-Host "   1. Configure Azure CDN para HTTPS e domínio personalizado" -ForegroundColor Gray
Write-Host "   2. CNAME: img.sistemasave.com.br → CDN endpoint" -ForegroundColor Gray
Write-Host "   3. Certificado SSL automático via CDN" -ForegroundColor Gray

Write-Host "`n🔗 Como acessar as imagens:" -ForegroundColor Yellow
Write-Host "   Formato: https://www.sistemasave.com.br/img/[nome-da-imagem]" -ForegroundColor Gray
Write-Host "   Exemplo: https://www.sistemasave.com.br/img/logo.png" -ForegroundColor Gray
