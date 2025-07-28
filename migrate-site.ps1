# Script para migrar site estático e configurar hospedagem de imagens
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceSiteUrl,  # URL do site estático atual no Azure
    
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [string]$WebContainer = '$web',
    [string]$ImgContainer = "img"
)

Write-Host "🚀 Migrando site estático para Storage Account..." -ForegroundColor Green
Write-Host "📦 Storage: $StorageAccountName" -ForegroundColor Cyan
Write-Host "🌐 Site origem: $SourceSiteUrl" -ForegroundColor Cyan

# 1. Habilitar site estático na Storage Account
Write-Host "`n📁 Habilitando site estático..." -ForegroundColor Yellow
az storage blob service-properties update `
    --account-name $StorageAccountName `
    --static-website `
    --index-document "index.html" `
    --404-document "404.html"

# 2. Verificar containers
Write-Host "`n📁 Verificando containers..." -ForegroundColor Yellow

# Container para site ($web)
Write-Host "  - Container site ($WebContainer): " -NoNewline
$webExists = az storage container exists --account-name $StorageAccountName --name $WebContainer --auth-mode login --output tsv
if ($webExists -eq "True") {
    Write-Host "✅ Existe" -ForegroundColor Green
} else {
    Write-Host "❌ Não existe - será criado automaticamente" -ForegroundColor Yellow
}

# Container para imagens
Write-Host "  - Container imagens ($ImgContainer): " -NoNewline
$imgExists = az storage container exists --account-name $StorageAccountName --name $ImgContainer --auth-mode login --output tsv
if ($imgExists -eq "True") {
    Write-Host "✅ Existe" -ForegroundColor Green
} else {
    Write-Host "🔧 Criando..." -ForegroundColor Yellow
    az storage container create --account-name $StorageAccountName --name $ImgContainer --public-access blob --auth-mode login
}

# 3. URLs finais
Write-Host "`n🌐 URLs após migração:" -ForegroundColor Green
$siteUrl = "https://$StorageAccountName.z15.web.core.windows.net/"
$imgCdnUrl = "https://sistemasave-img.azureedge.net/"

Write-Host "📄 Site principal: $siteUrl" -ForegroundColor Cyan
Write-Host "🖼️  Imagens (CDN): $imgCdnUrl" -ForegroundColor Cyan

# 4. Instruções para migração manual
Write-Host "`n📋 Como completar a migração:" -ForegroundColor Yellow
Write-Host "1. 📥 Baixe os arquivos do site atual:" -ForegroundColor White
Write-Host "   - Acesse: $SourceSiteUrl" -ForegroundColor Gray
Write-Host "   - Use ferramentas como wget ou copie manualmente" -ForegroundColor Gray

Write-Host "`n2. 📤 Upload dos arquivos do site:" -ForegroundColor White
Write-Host "   .\deploy-storage.ps1 -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName" -ForegroundColor Gray

Write-Host "`n3. 📤 Upload das imagens:" -ForegroundColor White
Write-Host "   .\upload-img.ps1 -ImagePath 'caminho\para\imagem.jpg'" -ForegroundColor Gray

Write-Host "`n4. 🌍 Configurar DNS:" -ForegroundColor White
Write-Host "   Tipo: CNAME" -ForegroundColor Gray
Write-Host "   Nome: www" -ForegroundColor Gray
Write-Host "   Valor: sistemasave-www.azureedge.net" -ForegroundColor Gray

Write-Host "`n5. 🔒 Domínio personalizado no Azure:" -ForegroundColor White
Write-Host "   - Portal Azure > CDN > sistemasave-cdn > sistemasave-www" -ForegroundColor Gray
Write-Host "   - Adicionar: www.sistemasave.com.br" -ForegroundColor Gray
Write-Host "   - Habilitar HTTPS" -ForegroundColor Gray

Write-Host "`n🎯 Resultado final:" -ForegroundColor Green
Write-Host "✅ Site: https://www.sistemasave.com.br/" -ForegroundColor Cyan
Write-Host "✅ Imagens: https://www.sistemasave.com.br (acessando via CDN do site principal)" -ForegroundColor Cyan

Write-Host "`n💡 Dica para imagens:" -ForegroundColor Yellow
Write-Host "No seu site, use caminhos relativos para imagens:" -ForegroundColor White
Write-Host "❌ <img src='https://sistemaimg.../img/logo.png'>" -ForegroundColor Red
Write-Host "✅ <img src='/img/logo.png'>" -ForegroundColor Green
Write-Host "Assim o CDN do site principal servirá as imagens automaticamente!" -ForegroundColor Gray
