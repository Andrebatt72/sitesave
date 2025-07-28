# Exemplo de uso do script de deploy

# Para usar o script, execute um dos comandos abaixo:

# 1. Deploy básico (Storage Account já configurada para site estático)
.\deploy-storage.ps1 -StorageAccountName "savesitestorage" -ResourceGroupName "save-rg"

# 2. Deploy e habilitar site estático (primeira vez)
.\deploy-storage.ps1 -StorageAccountName "savesitestorage" -ResourceGroupName "save-rg" -EnableStaticWebsite

# 3. Deploy especificando caminho dos arquivos
.\deploy-storage.ps1 -StorageAccountName "savesitestorage" -ResourceGroupName "save-rg" -SourcePath "C:\MeuSite"

# Parâmetros:
# -StorageAccountName: Nome da Storage Account existente
# -ResourceGroupName: Nome do Resource Group onde está a Storage Account
# -SourcePath: Caminho dos arquivos (padrão é o diretório atual)
# -EnableStaticWebsite: Habilita site estático na Storage Account

# Exemplo real para seu caso:
# .\deploy-storage.ps1 -StorageAccountName "suastorageaccount" -ResourceGroupName "seu-resource-group"
