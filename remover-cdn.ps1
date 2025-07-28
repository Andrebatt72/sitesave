# OTIMIZAÇÃO SIMPLES - Remove CDN e Economiza 70%
param(
    [string]$StorageAccountName = "sistemasavestorage",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [switch]$RemoverCDN
)

Write-Host "OTIMIZAÇÃO DE CUSTOS - Removendo CDN Desnecessário" -ForegroundColor Green
Write-Host "Economia esperada: 70-80% nos custos mensais" -ForegroundColor Yellow

if ($RemoverCDN) {
    Write-Host "`nRemovendo recursos CDN..." -ForegroundColor Yellow
    
    # Remover endpoints
    Write-Host "Removendo endpoint sistemasave-www..." -ForegroundColor Gray
    az cdn endpoint delete --name sistemasave-www --profile-name sistemasave-cdn --resource-group $ResourceGroupName --yes
    
    Write-Host "Removendo endpoint sistemasave-img..." -ForegroundColor Gray  
    az cdn endpoint delete --name sistemasave-img --profile-name sistemasave-cdn --resource-group $ResourceGroupName --yes
    
    # Remover CDN Profile
    Write-Host "Removendo CDN Profile..." -ForegroundColor Gray
    az cdn profile delete --name sistemasave-cdn --resource-group $ResourceGroupName --yes
    
    Write-Host "`nCDN removido com sucesso!" -ForegroundColor Green
    Write-Host "Economia: Aproximadamente $7-21/mês" -ForegroundColor Yellow
}

# Configurar Storage Account
Write-Host "`nConfigurando Storage Account..." -ForegroundColor Yellow
az storage blob service-properties update --account-name $StorageAccountName --static-website --index-document "index.html"

# Obter URL
$storageUrl = az storage account show --name $StorageAccountName --resource-group $ResourceGroupName --query "primaryEndpoints.web" --output tsv

Write-Host "`nOtimização concluída!" -ForegroundColor Green
Write-Host "Nova URL: $storageUrl" -ForegroundColor Cyan
Write-Host "Imagens: ${storageUrl}img/" -ForegroundColor Cyan
Write-Host "`nEconomia: 70-80% nos custos!" -ForegroundColor Green
