# Configuração completa para www.sistemasave.com.br/img/
param(
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE"
)

Write-Host "🎯 Configurando estrutura para www.sistemasave.com.br/img/" -ForegroundColor Green

# 1. Criar pasta img no container $web (para estrutura do site)
Write-Host "`n📁 Configurando estrutura de pastas..." -ForegroundColor Yellow

# Upload de um arquivo índice na pasta img do $web (para estrutura)
$indexContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Imagens - Sistema Save</title>
    <meta charset="utf-8">
</head>
<body>
    <h1>Diretório de Imagens</h1>
    <p>Este é o diretório de imagens do Sistema Save.</p>
    <p>Para acessar uma imagem específica, use: <code>/img/nome-da-imagem.jpg</code></p>
</body>
</html>
"@

# Salvar temporariamente
$tempFile = "temp-img-index.html"
$indexContent | Out-File -FilePath $tempFile -Encoding UTF8

# Upload para $web/img/index.html
Write-Host "📄 Criando /img/index.html no site..." -ForegroundColor Gray
az storage blob upload `
    --account-name $StorageAccountName `
    --container-name '$web' `
    --name "img/index.html" `
    --file $tempFile `
    --content-type "text/html" `
    --overwrite `
    --auth-mode login

# Remover arquivo temporário
Remove-Item $tempFile -ErrorAction SilentlyContinue

Write-Host "`n🌐 URLs configuradas:" -ForegroundColor Green
Write-Host "📄 Site principal: https://$StorageAccountName.z15.web.core.windows.net/" -ForegroundColor Cyan
Write-Host "📁 Diretório img: https://$StorageAccountName.z15.web.core.windows.net/img/" -ForegroundColor Cyan
Write-Host "📱 CDN site: https://sistemasave-www.azureedge.net/" -ForegroundColor Cyan

Write-Host "`n📋 Configuração DNS necessária:" -ForegroundColor Yellow
Write-Host "Tipo: CNAME" -ForegroundColor White
Write-Host "Nome: www" -ForegroundColor White  
Write-Host "Valor: sistemasave-www.azureedge.net" -ForegroundColor White
Write-Host "TTL: 3600" -ForegroundColor White

Write-Host "`n🎯 Como usar após configurar DNS:" -ForegroundColor Green
Write-Host "✅ Site: https://www.sistemasave.com.br/" -ForegroundColor Cyan
Write-Host "✅ Imagens: https://www.sistemasave.com.br/img/[nome-da-imagem]" -ForegroundColor Cyan

Write-Host "`n💡 Estratégia para imagens:" -ForegroundColor Yellow
Write-Host "1. 📤 Faça upload das imagens para o container 'img'" -ForegroundColor White
Write-Host "2. 🔗 Configure regras no CDN para redirecionar /img/ para o container img" -ForegroundColor White
Write-Host "3. 🌐 Ou copie imagens para $web/img/ para ter tudo em um lugar" -ForegroundColor White

Write-Host "`n📤 Upload de imagens:" -ForegroundColor Yellow
Write-Host "Para container 'img': .\upload-img.ps1 -ImagePath 'imagem.jpg'" -ForegroundColor Gray
Write-Host "Para $web/img/: az storage blob upload --account-name $StorageAccountName --container-name '\$web' --name 'img/imagem.jpg' --file 'imagem.jpg'" -ForegroundColor Gray
