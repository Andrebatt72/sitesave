# Script para monitorar o progresso da configuracao HTTPS
param(
    [string]$Domain = "www.sistemasave.com.br",
    [string]$ProfileName = "sistemasave-cdn",
    [string]$ResourceGroupName = "RG-SAVE-STORAGE",
    [string]$EndpointName = "sistemasave-www",
    [string]$CustomDomainName = "www-sistemasave-com-br",
    [int]$IntervalSeconds = 60
)

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Test-DomainConnectivity {
    param([string]$Url, [string]$Protocol)
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 10 -ErrorAction Stop
        Write-ColorText "✅ $Protocol - Status: $($response.StatusCode)" "Green"
        return $true
    } catch {
        Write-ColorText "❌ $Protocol - Erro: $($_.Exception.Message)" "Red"
        return $false
    }
}

Write-ColorText "🔍 Monitor de Configuracao DNS/HTTPS" "Cyan"
Write-ColorText "📋 Dominio: $Domain" "Yellow"
Write-ColorText "⏱️  Verificando a cada $IntervalSeconds segundos..." "Yellow"
Write-ColorText "💡 Pressione Ctrl+C para parar" "Gray"

$iteration = 1

do {
    Write-ColorText "`n🔄 === Verificacao #$iteration - $(Get-Date -Format 'HH:mm:ss') ===" "Cyan"
    
    # 1. Verificar DNS
    Write-ColorText "`n📡 Verificando DNS..." "Yellow"
    try {
        $dnsResult = nslookup $Domain 2>$null
        if ($dnsResult -match "azureedge.net") {
            Write-ColorText "✅ DNS configurado corretamente" "Green"
        } else {
            Write-ColorText "❌ DNS nao configurado" "Red"
        }
    } catch {
        Write-ColorText "❌ Erro na verificacao DNS" "Red"
    }
    
    # 2. Verificar status no Azure CDN
    Write-ColorText "`n☁️ Verificando status no Azure CDN..." "Yellow"
    try {
        $cdnStatus = az cdn custom-domain show `
            --endpoint-name $EndpointName `
            --name $CustomDomainName `
            --profile-name $ProfileName `
            --resource-group $ResourceGroupName `
            --query "{HttpsStatus:customHttpsProvisioningState, HttpsSubstate:customHttpsProvisioningSubstate, ResourceState:resourceState}" `
            --output json | ConvertFrom-Json
        
        Write-ColorText "   📊 Status HTTPS: $($cdnStatus.HttpsStatus)" "Cyan"
        Write-ColorText "   📊 Substatus: $($cdnStatus.HttpsSubstate)" "Cyan"
        Write-ColorText "   📊 Estado: $($cdnStatus.ResourceState)" "Cyan"
        
        # Interpretar status
        switch ($cdnStatus.HttpsStatus) {
            "Enabled" { 
                Write-ColorText "   🎉 HTTPS HABILITADO!" "Green"
                $httpsReady = $true
            }
            "Enabling" { 
                Write-ColorText "   ⏳ HTTPS sendo configurado..." "Yellow"
                $httpsReady = $false
            }
            "Disabled" { 
                Write-ColorText "   ❌ HTTPS desabilitado" "Red"
                $httpsReady = $false
            }
            default { 
                Write-ColorText "   ❓ Status desconhecido: $($cdnStatus.HttpsStatus)" "Gray"
                $httpsReady = $false
            }
        }
    } catch {
        Write-ColorText "❌ Erro ao verificar status CDN" "Red"
        $httpsReady = $false
    }
    
    # 3. Testar conectividade HTTP
    Write-ColorText "`n🌐 Testando conectividade..." "Yellow"
    $httpWorks = Test-DomainConnectivity "http://$Domain" "HTTP"
    
    # 4. Testar conectividade HTTPS (se estiver habilitado)
    if ($httpsReady) {
        $httpsWorks = Test-DomainConnectivity "https://$Domain" "HTTPS"
    } else {
        Write-ColorText "⏳ HTTPS - Aguardando configuracao..." "Yellow"
        $httpsWorks = $false
    }
    
    # 5. Resumo do status
    Write-ColorText "`n📋 RESUMO:" "Cyan"
    Write-ColorText "   DNS: $(if($dnsResult -match 'azureedge.net') {'✅'} else {'❌'})" "White"
    Write-ColorText "   HTTP: $(if($httpWorks) {'✅'} else {'❌'})" "White"
    Write-ColorText "   HTTPS: $(if($httpsWorks) {'✅'} elseif($httpsReady) {'⚠️'} else {'⏳'})" "White"
    
    # 6. Verificar se esta tudo pronto
    if ($httpWorks -and $httpsWorks) {
        Write-ColorText "`n🎉 CONFIGURACAO COMPLETA!" "Green"
        Write-ColorText "✅ Site disponivel em: https://$Domain" "Green"
        Write-ColorText "✅ Imagens disponiveis em: https://$Domain/img/" "Green"
        break
    }
    
    # Aguardar proximo ciclo
    if ($iteration -lt 999) {  # Evitar loop infinito
        Write-ColorText "`n⏱️  Aguardando $IntervalSeconds segundos para proxima verificacao..." "Gray"
        Start-Sleep -Seconds $IntervalSeconds
    }
    
    $iteration++
    
} while ($iteration -le 60)  # Maximo 60 verificacoes (1 hora se intervalo = 60s)

Write-ColorText "`n🏁 Monitoramento finalizado." "Cyan"
