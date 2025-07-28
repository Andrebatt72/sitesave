# Script utilitário para upload de imagens individuais ou em lote
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    
    [Parameter(ParameterSetName="SingleFile", Mandatory=$true)]
    [string]$ImagePath,
    
    [Parameter(ParameterSetName="Folder", Mandatory=$true)]
    [string]$FolderPath,
    
    [string]$ContainerName = "images",
    
    [switch]$Optimize
)

Write-Host "🚀 Upload de imagens para Azure Storage..." -ForegroundColor Green

function Get-OptimizedContentType {
    param([string]$Extension)
    
    switch ($Extension.ToLower()) {
        ".jpg" { return "image/jpeg" }
        ".jpeg" { return "image/jpeg" }
        ".png" { return "image/png" }
        ".gif" { return "image/gif" }
        ".svg" { return "image/svg+xml" }
        ".webp" { return "image/webp" }
        ".bmp" { return "image/bmp" }
        ".ico" { return "image/x-icon" }
        default { return "image/jpeg" }
    }
}

function Upload-Image {
    param(
        [string]$FilePath,
        [string]$BlobName
    )
    
    $file = Get-Item $FilePath
    $contentType = Get-OptimizedContentType -Extension $file.Extension
    
    Write-Host "  📸 Uploading $BlobName..." -ForegroundColor Gray
    
    $result = az storage blob upload `
        --account-name $StorageAccountName `
        --container-name $ContainerName `
        --name $BlobName `
        --file $FilePath `
        --content-type $contentType `
        --overwrite `
        --auth-mode login `
        --output json | ConvertFrom-Json
    
    if ($result) {
        $imageUrl = "https://$StorageAccountName.blob.core.windows.net/$ContainerName/$BlobName"
        Write-Host "    ✅ Sucesso: $imageUrl" -ForegroundColor Green
        return $imageUrl
    } else {
        Write-Host "    ❌ Erro no upload de $BlobName" -ForegroundColor Red
        return $null
    }
}

# Upload de arquivo único
if ($PSCmdlet.ParameterSetName -eq "SingleFile") {
    if (-not (Test-Path $ImagePath)) {
        Write-Error "❌ Arquivo não encontrado: $ImagePath"
        exit 1
    }
    
    $fileName = [System.IO.Path]::GetFileName($ImagePath)
    $url = Upload-Image -FilePath $ImagePath -BlobName $fileName
    
    if ($url) {
        Write-Host "`n✅ Upload concluído!" -ForegroundColor Green
        Write-Host "🌐 URL: $url" -ForegroundColor Cyan
        Write-Host "🔗 CDN URL: https://img.sistemasave.com.br/$fileName" -ForegroundColor Cyan
    }
}

# Upload de pasta
if ($PSCmdlet.ParameterSetName -eq "Folder") {
    if (-not (Test-Path $FolderPath)) {
        Write-Error "❌ Pasta não encontrada: $FolderPath"
        exit 1
    }
    
    $imageFiles = Get-ChildItem -Path $FolderPath -File -Include "*.jpg", "*.jpeg", "*.png", "*.gif", "*.svg", "*.webp", "*.bmp", "*.ico"
    
    if ($imageFiles.Count -eq 0) {
        Write-Host "ℹ️  Nenhuma imagem encontrada na pasta." -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host "📁 Encontradas $($imageFiles.Count) imagens para upload..." -ForegroundColor Yellow
    
    $uploadedUrls = @()
    $successCount = 0
    
    foreach ($image in $imageFiles) {
        $url = Upload-Image -FilePath $image.FullName -BlobName $image.Name
        if ($url) {
            $uploadedUrls += $url
            $successCount++
        }
    }
    
    Write-Host "`n✅ Upload concluído!" -ForegroundColor Green
    Write-Host "📊 $successCount de $($imageFiles.Count) imagens enviadas com sucesso" -ForegroundColor Cyan
    
    if ($uploadedUrls.Count -gt 0) {
        Write-Host "`n🔗 URLs das imagens:" -ForegroundColor Yellow
        foreach ($url in $uploadedUrls) {
            $fileName = [System.IO.Path]::GetFileName($url)
            Write-Host "  • https://img.sistemasave.com.br/$fileName" -ForegroundColor Gray
        }
    }
}

Write-Host "`n📋 Como usar as imagens:" -ForegroundColor Yellow
Write-Host "  HTML: <img src='https://img.sistemasave.com.br/nome-da-imagem.jpg' alt='Imagem'>" -ForegroundColor Gray
Write-Host "  CSS:  background-image: url('https://img.sistemasave.com.br/nome-da-imagem.jpg');" -ForegroundColor Gray
