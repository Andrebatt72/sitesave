# 🖼️ Sistema de Hospedagem de Imagens - Sistema Save

## ✅ **Configuração Atual**

- **Storage Account:** `sistemasavestorage`
- **Container:** `img` (acesso público habilitado)
- **CDN Profile:** `sistemasave-cdn`
- **CDN Endpoint:** `sistemasave-img.azureedge.net`

## 🌐 **URLs de Acesso**

### URL Direta (Storage)
```
https://sistemasavestorage.blob.core.windows.net/img/[nome-da-imagem]
```

### URL CDN (Mais rápida)
```
https://sistemasave-img.azureedge.net/[nome-da-imagem]
```

### URL Final (Após configurar DNS)
```
https://www.sistemasave.com.br/img/[nome-da-imagem]
```

## 📋 **Próximos Passos para Domínio Personalizado**

### 1. 🌍 Configurar DNS
No seu provedor de DNS (onde está registrado sistemasave.com.br):

```
Tipo: CNAME
Nome: img
Valor: sistemasave-img.azureedge.net
TTL: 3600
```

### 2. 🔒 Adicionar Domínio Personalizado no Azure

1. Acesse o [Portal Azure](https://portal.azure.com)
2. Vá para **CDN profiles** > `sistemasave-cdn`
3. Clique no endpoint `sistemasave-img`
4. No menu lateral, clique em **Custom domains**
5. Clique **+ Custom domain**
6. Digite: `img.sistemasave.com.br`
7. Clique **Add**
8. Após validação, habilite **HTTPS** com certificado gerenciado

### 3. 🔗 Configurar Redirecionamento (Opcional)

Para que `www.sistemasave.com.br/img/` redirecione corretamente, configure:

```
Tipo: CNAME  
Nome: www
Valor: sistemasave-img.azureedge.net
```

## 📤 **Como Fazer Upload de Imagens**

### Usando o Script PowerShell:
```powershell
.\upload-img.ps1 -ImagePath "caminho\para\sua\imagem.jpg"
```

### Usando Azure CLI diretamente:
```bash
az storage blob upload \
  --account-name sistemasavestorage \
  --container-name img \
  --name minha-imagem.jpg \
  --file caminho/para/imagem.jpg \
  --content-type image/jpeg \
  --auth-mode login
```

### Usando Azure Storage Explorer:
1. Abra o Azure Storage Explorer
2. Conecte-se à conta `sistemasavestorage`
3. Navegue até o container `img`
4. Arraste e solte suas imagens

## 🎯 **Exemplo de Uso**

### HTML:
```html
<img src="https://www.sistemasave.com.br/img/logo.png" alt="Logo">
```

### CSS:
```css
.hero {
    background-image: url('https://www.sistemasave.com.br/img/background.jpg');
}
```

### Markdown:
```markdown
![Imagem](https://www.sistemasave.com.br/img/exemplo.png)
```

## 🔧 **Tipos de Arquivo Suportados**

- ✅ JPG/JPEG
- ✅ PNG  
- ✅ GIF
- ✅ SVG
- ✅ WebP
- ✅ BMP
- ✅ ICO

## 📊 **Vantagens da Configuração Atual**

- 🚀 **CDN:** Cache global para carregamento rápido
- 🔒 **HTTPS:** Certificado SSL gratuito
- 💰 **Custo baixo:** Storage LRS no Brasil Sul
- 🌍 **Domínio personalizado:** img.sistemasave.com.br
- 📱 **Responsivo:** Funciona em todos os dispositivos

## 🛠️ **Comandos Úteis**

### Listar imagens no container:
```bash
az storage blob list --account-name sistemasavestorage --container-name img --auth-mode login --output table
```

### Excluir uma imagem:
```bash
az storage blob delete --account-name sistemasavestorage --container-name img --name nome-da-imagem.jpg --auth-mode login
```

### Limpar cache do CDN:
```bash
az cdn endpoint purge --content-paths "/*" --name sistemasave-img --profile-name sistemasave-cdn --resource-group RG-SAVE-STORAGE
```

## 📞 **Suporte**

Se precisar de ajuda ou tiver dúvidas, entre em contato com a equipe de TI da Sistema Save.
