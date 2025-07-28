# Script para upload de imagens para o container img
param(
    [Parameter(Mandatory=$true)]
    [string]$ImagePath,
    
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ContainerName = "img"
)

if (-not (Test-Path $ImagePath)) {
    Write-Error "Arquivo nao encontrado: $ImagePath"
    exit 1
}

$file = Get-Item $ImagePath
$fileName = $file.Name

# Determinar content-type
$contentType = switch ($file.Extension.ToLower()) {
    ".jpg" { "image/jpeg" }
    ".jpeg" { "image/jpeg" }
    ".png" { "image/png" }
    ".gif" { "image/gif" }
    ".svg" { "image/svg+xml" }
    ".webp" { "image/webp" }
    default { "image/jpeg" }
}

Write-Host "Upload da imagem: $fileName"
Write-Host "Content-Type: $contentType"

# Upload da imagem
az storage blob upload `
    --account-name $StorageAccountName `
    --container-name $ContainerName `
    --name $fileName `
    --file $ImagePath `
    --content-type $contentType `
    --overwrite `
    --auth-mode login

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Sucesso! Imagem disponivel em:"
    Write-Host "URL Direta: https://$StorageAccountName.blob.core.windows.net/$ContainerName/$fileName"
    Write-Host "URL CDN: https://sistemasave-img.azureedge.net/$fileName"
    Write-Host "URL Final (quando configurar DNS): https://www.sistemasave.com.br/img/$fileName"
} else {
    Write-Error "Erro no upload!"
}
