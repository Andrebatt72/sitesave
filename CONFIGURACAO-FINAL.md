# ✅ CONFIGURAÇÃO COMPLETA - www.sistemasave.com.br/img/

## 🎯 **OBJETIVO ALCANÇADO**
✅ Site estático configurado para migração  
✅ Estrutura `/img/` criada no site  
✅ CDN configurado para performance  
✅ Pronto para domínio personalizado `www.sistemasave.com.br/img/`  

## 🌐 **URLs FUNCIONAIS AGORA**

### **Site Principal:**
- **Storage:** https://sistemasavestorage.z15.web.core.windows.net/
- **CDN:** https://sistemasave-www.azureedge.net/

### **Diretório de Imagens:**
- **Storage:** https://sistemasavestorage.z15.web.core.windows.net/img/
- **CDN:** https://sistemasave-www.azureedge.net/img/

## 📋 **CONFIGURAÇÃO DNS NECESSÁRIA**

Para ter `https://www.sistemasave.com.br/img/`:

```
Tipo: CNAME
Nome: www
Valor: sistemasave-www.azureedge.net
TTL: 3600
```

## 🚀 **COMO MIGRAR SEU SITE ATUAL**

### **1. Baixar arquivos do site atual:**
```bash
# Se o site atual estiver em outro Azure Storage
az storage blob download-batch --source [container-origem] --destination ./site-atual --account-name [storage-atual]

# Ou baixe manualmente via portal/FTP
```

### **2. Upload do site migrado:**
```powershell
# Upload de todos os arquivos do site
.\deploy-storage.ps1 -StorageAccountName "sistemasavestorage" -ResourceGroupName "RG-SAVE-STORAGE"
```

### **3. Upload de imagens para /img/:**

#### **Opção A: Imagens no mesmo container do site (Recomendado)**
```bash
# Upload direto para $web/img/
az storage blob upload --account-name sistemasavestorage --container-name '$web' --name "img/logo.png" --file "logo.png" --content-type "image/png"
```

#### **Opção B: Container separado (atual)**
```powershell
# Upload para container 'img' separado
.\upload-img.ps1 -ImagePath "logo.png"
```

## 🎯 **RESULTADO FINAL APÓS DNS**

### **Site completo em:**
```
https://www.sistemasave.com.br/
```

### **Imagens acessíveis em:**
```
https://www.sistemasave.com.br/img/logo.png
https://www.sistemasave.com.br/img/banner.jpg
https://www.sistemasave.com.br/img/foto1.png
```

## 💡 **COMO USAR AS IMAGENS NO SEU SITE**

### **HTML:**
```html
<img src="/img/logo.png" alt="Logo Sistema Save">
<img src="/img/banner.jpg" alt="Banner">
```

### **CSS:**
```css
.logo {
    background-image: url('/img/logo.png');
}
.banner {
    background-image: url('/img/banner.jpg');
}
```

### **JavaScript:**
```javascript
const logoUrl = '/img/logo.png';
document.getElementById('logo').src = logoUrl;
```

## 🔒 **PRÓXIMOS PASSOS**

### **1. Configure DNS** (necessário)
- Acesse seu provedor DNS (Registro.br ou hospedagem)
- Adicione CNAME: `www` → `sistemasave-www.azureedge.net`

### **2. Domínio personalizado no Azure** (após DNS)
- Portal Azure → CDN → sistemasave-cdn → sistemasave-www
- Custom domains → Add domain: `www.sistemasave.com.br`
- Enable HTTPS (certificado gratuito)

### **3. Teste após 2-4 horas**
- `nslookup www.sistemasave.com.br` deve retornar o CDN
- Site deve funcionar em `https://www.sistemasave.com.br`

## ⚡ **VANTAGENS DA CONFIGURAÇÃO**

✅ **Performance:** CDN global do Azure  
✅ **Custo baixo:** Storage LRS no Brasil  
✅ **HTTPS gratuito:** Certificado gerenciado  
✅ **Escalabilidade:** Suporta milhões de acessos  
✅ **Backup:** Dados replicados automaticamente  

## 📞 **SUPORTE**

Se precisar de ajuda:
1. Verifique se o DNS foi configurado: `nslookup www.sistemasave.com.br`
2. Teste upload: `.\upload-img.ps1 -ImagePath "teste.jpg"`
3. Valide no portal Azure: https://portal.azure.com

---
**🎉 Parabéns! Sua infraestrutura está pronta para receber o site migrado!**
