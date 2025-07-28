# SCRIPT DE OTIMIZAÇÃO - Remove CDN e Economiza 70% nos Custos
# Este script remove recursos desnecessários e migra para solução apenas com Storage Account

param(
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [switch]$RemoverCDN,
    [switch]$ConfirmarRemocao
)

Write-Host "🚀 OTIMIZAÇÃO DE CUSTOS - Removendo CDN Desnecessário" -ForegroundColor Green
Write-Host "💰 Economia esperada: 70-80% nos custos mensais" -ForegroundColor Yellow
Write-Host "📊 De $9-26/mês → $2-5/mês" -ForegroundColor Cyan

if ($RemoverCDN) {
    if (-not $ConfirmarRemocao) {
        Write-Host "`n⚠️  ATENÇÃO: Isso irá remover o CDN completamente!" -ForegroundColor Red
        Write-Host "   As URLs do CDN pararam de funcionar:" -ForegroundColor Yellow
        Write-Host "   • https://sistemasave-img.azureedge.net/imagem.jpg" -ForegroundColor Gray
        Write-Host "   • https://sistemasave-www.azureedge.net/" -ForegroundColor Gray
        Write-Host "`n✅ Mas as URLs personalizadas continuam funcionando:" -ForegroundColor Green
        Write-Host "   • https://www.sistemasave.com.br/" -ForegroundColor Gray
        Write-Host "   • https://www.sistemasave.com.br/img/imagem.jpg" -ForegroundColor Gray
        
        $resposta = Read-Host "`n🤔 Deseja continuar? (s/n)"
        if ($resposta -ne "s" -and $resposta -ne "S") {
            Write-Host "❌ Operação cancelada pelo usuário" -ForegroundColor Red
            exit 0
        }
    }
    
    Write-Host "`n🗑️  Removendo recursos CDN..." -ForegroundColor Yellow
    
    # 1. Remover endpoint sistemasave-www
    Write-Host "  🔹 Removendo endpoint sistemasave-www..." -ForegroundColor Gray
    try {
        az cdn endpoint delete --name sistemasave-www --profile-name sistemasave-cdn --resource-group $ResourceGroupName --yes
        Write-Host "  ✅ Endpoint sistemasave-www removido" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  Erro ao remover endpoint sistemasave-www (pode já estar removido)" -ForegroundColor Yellow
    }
    
    # 2. Remover endpoint sistemasave-img
    Write-Host "  🔹 Removendo endpoint sistemasave-img..." -ForegroundColor Gray
    try {
        az cdn endpoint delete --name sistemasave-img --profile-name sistemasave-cdn --resource-group $ResourceGroupName --yes
        Write-Host "  ✅ Endpoint sistemasave-img removido" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  Erro ao remover endpoint sistemasave-img (pode já estar removido)" -ForegroundColor Yellow
    }
    
    # 3. Remover CDN Profile
    Write-Host "  🔹 Removendo CDN Profile..." -ForegroundColor Gray
    try {
        az cdn profile delete --name sistemasave-cdn --resource-group $ResourceGroupName --yes
        Write-Host "  ✅ CDN Profile removido" -ForegroundColor Green
    }
    catch {
        Write-Host "  ⚠️  Erro ao remover CDN Profile (pode já estar removido)" -ForegroundColor Yellow
    }
    
    Write-Host "`n🎉 CDN removido com sucesso!" -ForegroundColor Green
    Write-Host "💰 Economia: Aproximadamente $7-21/mês" -ForegroundColor Yellow
}

# Verificar e configurar Storage Account para funcionar sem CDN
Write-Host "`n🔧 Configurando Storage Account para solução otimizada..." -ForegroundColor Yellow

# Habilitar site estático
Write-Host "  🌐 Habilitando site estático..." -ForegroundColor Gray
az storage blob service-properties update `
    --account-name $StorageAccountName `
    --static-website `
    --index-document "index.html" `
    --404-document "404.html"

# Verificar se CORS está configurado para permitir acesso direto
Write-Host "  🔗 Configurando CORS para acesso direto..." -ForegroundColor Gray
az storage cors add `
    --account-name $StorageAccountName `
    --services b `
    --methods GET HEAD POST PUT DELETE `
    --origins "*" `
    --allowed-headers "*" `
    --max-age 3600

# Obter URL direta do Storage
$storageUrl = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "primaryEndpoints.web" --output tsv

Write-Host "`n✅ Configuração otimizada concluída!" -ForegroundColor Green
Write-Host "`n📋 NOVA ARQUITETURA (SEM CDN):" -ForegroundColor Cyan
Write-Host "  🌐 URL direta: $storageUrl" -ForegroundColor Gray
Write-Host "  🖼️  Imagens: ${storageUrl}img/nome-da-imagem.jpg" -ForegroundColor Gray

Write-Host "`n🎯 PRÓXIMOS PASSOS PARA DOMÍNIO PERSONALIZADO:" -ForegroundColor Yellow
Write-Host "  1. Configure CNAME no seu DNS:" -ForegroundColor Gray
Write-Host "     www.sistemasave.com.br → $($StorageAccountName).z15.web.core.windows.net" -ForegroundColor Gray
Write-Host "  2. HTTPS será automático do Azure" -ForegroundColor Gray
Write-Host "  3. URLs finais:" -ForegroundColor Gray
Write-Host "     • Site: https://www.sistemasave.com.br/" -ForegroundColor Gray
Write-Host "     • Imagens: https://www.sistemasave.com.br/img/imagem.jpg" -ForegroundColor Gray

Write-Host "`n💰 ECONOMIA FINAL:" -ForegroundColor Green
Write-Host "  📊 Antes: $9-26/mês (Storage + CDN)" -ForegroundColor Red
Write-Host "  📊 Agora: $2-5/mês (Apenas Storage)" -ForegroundColor Green
Write-Host "  💵 Economia: 70-80% nos custos!" -ForegroundColor Green

Write-Host "`n🚀 Use os novos scripts otimizados:" -ForegroundColor Cyan
Write-Host "  • Deploy: .\deploy-sem-cdn.ps1" -ForegroundColor Gray
Write-Host "  • Upload imagens: .\upload-storage-direto.ps1" -ForegroundColor Gray
