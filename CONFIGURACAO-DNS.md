# 🌐 Configuração DNS para img.sistemasave.com.br

## 📋 **Informações Detectadas**
- **Domínio:** sistemasave.com.br
- **Nameservers:** b.sec.dns.br, c.sec.dns.br
- **Provedor:** Registro.br (DNS.br)

## 🎯 **Configuração Necessária**

### **Registro CNAME:**
```
Tipo: CNAME
Nome: img
Valor: sistemasave-img.azureedge.net
TTL: 3600
```

## 🔧 **Como Configurar no Registro.br**

### **Opção 1: Portal do Registro.br**
1. Acesse: https://registro.br/
2. Faça login com sua conta
3. Vá em **"Meus Domínios"**
4. Clique em `sistemasave.com.br`
5. Vá na aba **"DNS"** ou **"Zona DNS"**
6. Clique em **"Adicionar Registro"**
7. Configure:
   - **Tipo:** CNAME
   - **Nome:** img
   - **Valor:** sistemasave-img.azureedge.net
   - **TTL:** 3600
8. Clique **"Salvar"**

### **Opção 2: Se usar painel de hospedagem**
Se o domínio está gerenciado por uma empresa de hospedagem:

#### **cPanel/Plesk:**
1. Acesse o painel da hospedagem
2. Procure por **"Zona DNS"** ou **"DNS Zone Editor"**
3. Adicione o registro CNAME conforme acima

#### **Cloudflare (se migrado):**
1. Acesse https://dash.cloudflare.com/
2. Selecione o domínio `sistemasave.com.br`
3. Vá em **"DNS"** > **"Records"**
4. Clique **"Add record"**
5. Configure conforme acima

## ⏱️ **Tempo de Propagação**
- **Mínimo:** 30 minutos
- **Máximo:** 24-48 horas
- **Típico:** 2-4 horas

## 🔍 **Como Testar a Configuração**

### **1. Teste de DNS:**
```bash
nslookup img.sistemasave.com.br
```

### **2. Teste Online:**
- https://dnschecker.org/
- Digite: `img.sistemasave.com.br`
- Tipo: CNAME

### **3. Teste no Browser:**
Após a propagação, teste:
```
https://img.sistemasave.com.br/
```

## 📞 **Contatos para Suporte**

### **Registro.br:**
- Site: https://registro.br/ajuda/
- Email: info@registro.br
- Telefone: 0800 703 6300

### **Se usar hospedagem terceirizada:**
Entre em contato com sua empresa de hospedagem com estas informações:
- Adicionar CNAME: `img` → `sistemasave-img.azureedge.net`

## ⚠️ **Importantes:**
1. **Não use** `www.img` - apenas `img`
2. **Não adicione** `http://` ou `https://` no valor
3. **Remova** o ponto final (.) se o sistema adicionar automaticamente
4. **Aguarde** a propagação antes de testar

## 🎯 **Resultado Final**
Após a configuração, as imagens ficarão acessíveis em:
```
https://img.sistemasave.com.br/nome-da-imagem.jpg
```

## 📝 **Próximo Passo**
Após configurar o DNS, precisamos adicionar o domínio personalizado no Azure CDN.
Vamos fazer isso depois que o DNS estiver propagado.
