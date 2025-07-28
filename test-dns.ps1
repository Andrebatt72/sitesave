# Script para testar configuração DNS
param(
    [string]$Domain = "img.sistemasave.com.br",
    [string]$ExpectedValue = "sistemasave-img.azureedge.net"
)

Write-Host "🔍 Testando configuração DNS..." -ForegroundColor Green
Write-Host "Domínio: $Domain" -ForegroundColor Cyan
Write-Host "Valor esperado: $ExpectedValue" -ForegroundColor Cyan
Write-Host ""

# Teste 1: nslookup local
Write-Host "📡 Teste 1: DNS Local" -ForegroundColor Yellow
try {
    $result = nslookup $Domain 2>$null
    if ($result -match $ExpectedValue) {
        Write-Host "✅ DNS configurado corretamente!" -ForegroundColor Green
        $dnsConfigured = $true
    } else {
        Write-Host "❌ DNS ainda não propagado ou não configurado" -ForegroundColor Red
        Write-Host "Resultado: $result" -ForegroundColor Gray
        $dnsConfigured = $false
    }
} catch {
    Write-Host "❌ Erro no teste DNS local" -ForegroundColor Red
    $dnsConfigured = $false
}

Write-Host ""

# Teste 2: Teste HTTP (se DNS estiver configurado)
if ($dnsConfigured) {
    Write-Host "🌐 Teste 2: Conectividade HTTP" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "https://$Domain" -Method HEAD -TimeoutSec 10 -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ HTTPS funcionando!" -ForegroundColor Green
        } else {
            Write-Host "⚠️  DNS configurado, mas HTTPS ainda não disponível" -ForegroundColor Yellow
            Write-Host "Status: $($response.StatusCode)" -ForegroundColor Gray
        }
    } catch {
        Write-Host "⚠️  DNS configurado, mas HTTPS ainda não disponível" -ForegroundColor Yellow
        Write-Host "Isso é normal - configure o domínio personalizado no Azure CDN" -ForegroundColor Gray
    }
}

Write-Host ""

# Instruções próximos passos
if ($dnsConfigured) {
    Write-Host "🎯 Próximos Passos:" -ForegroundColor Green
    Write-Host "1. Aguarde até 30 minutos para propagação completa" -ForegroundColor White
    Write-Host "2. Configure domínio personalizado no Azure CDN:" -ForegroundColor White
    Write-Host "   - Portal Azure > CDN > sistemasave-cdn > sistemasave-img" -ForegroundColor Gray
    Write-Host "   - Custom domains > Add domain: img.sistemasave.com.br" -ForegroundColor Gray
    Write-Host "   - Habilite HTTPS com certificado gerenciado" -ForegroundColor Gray
} else {
    Write-Host "📋 O que fazer:" -ForegroundColor Yellow
    Write-Host "1. Configure o DNS conforme instruções em CONFIGURACAO-DNS.md" -ForegroundColor White
    Write-Host "2. Aguarde 2-4 horas para propagação" -ForegroundColor White
    Write-Host "3. Execute este script novamente para testar" -ForegroundColor White
}

Write-Host ""
Write-Host "🔗 Testes online adicionais:" -ForegroundColor Cyan
Write-Host "- https://dnschecker.org/ (Digite: $Domain)" -ForegroundColor Gray
Write-Host "- https://www.whatsmydns.net/ (Digite: $Domain, Tipo: CNAME)" -ForegroundColor Gray
