# Script para configurar redirecionamento de imagens
# Configura www.sistemasave.com.br/img/* -> sistemasave-img.azureedge.net/*

Write-Host "🔧 Configurando redirecionamento para imagens..." -ForegroundColor Yellow

# Criar regra de redirecionamento no CDN principal
az cdn endpoint rule add `
    --name sistemasave-www `
    --profile-name sistemasave-cdn `
    --resource-group RG-SAVE-STORAGE `
    --rule-name "img-redirect" `
    --order 1 `
    --match-variable RequestUri `
    --operator BeginsWith `
    --match-values "/img/" `
    --action-name "UrlRewrite" `
    --destination "https://sistemasave-img.azureedge.net{uri_path}"

Write-Host "✅ Regra configurada! Aguarde propagação (5-10 min)" -ForegroundColor Green
