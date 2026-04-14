# Lab 07 - Roteiro: O Salto para a Nuvem (Azure App Service)

Neste laboratório, vamos realizar o deploy da nossa aplicação Java para o **Azure App Service** usando o Maven Plugin oficial da Microsoft. Também vamos garantir que a telemetria esteja fluindo para o **Application Insights**.

---

## 🚀 1. Preparação (Killercoda)

Este laboratório assume que você já tem a pasta `lab-actuator` criada no Lab 06.

### **Passo A: Instalar e Logar na Azure CLI**
No terminal do Killercoda, execute o comando para instalar a CLI e depois o login:

```bash
# 1. Instalar a CLI do Azure (Script oficial Microsoft)
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 2. Login via Código de Dispositivo
az login --use-device-code
```
1. Acesse o link exibido no terminal (geralmente [microsoft.com/devicelogin](https://microsoft.com/devicelogin)).
2. Digite o código de 8 caracteres fornecido.
3. Faça login com sua conta **Azure for Students**.

---

## 📦 2. Configurando o Maven Plugin

Em vez de configurar o XML manualmente, vamos usar o modo interativo do plugin para gerar as configurações ideais para o App Service.

### **Passo 1: Gerar Configuração**
Certifique-se de estar na pasta `lab-actuator` e execute:
```bash
mvn com.microsoft.azure:azure-webapp-maven-plugin:2.13.0:config
```

### **Passo 2: Escolha as Opções (Importante!)**
Siga estas escolhas no menu interativo:
1.  **Subscription:** Escolha a sua (geralmente a única disponível).
2.  **Webapp:** Selecione `CREATE NEW`.
3.  **OS:** Escolha `Linux`.
4.  **Java Version:** Escolha `Java 17` (Para manter compatibilidade com o Lab 06).
5.  **Pricing Tier:** Escolha `F1` (Free) ou `B1`.
6.  **Confirm:** Digite `Y` para salvar no `pom.xml`.

---

## 🚢 3. O Grande Deploy

Com o `pom.xml` atualizado, vamos realizar o build e o deploy em um único comando.

### **Passo 1: Executar Deploy**
```bash
mvn package azure-webapp:deploy
```
*Aguarde cerca de 2 a 3 minutos. O plugin criará o Resource Group, o App Service Plan e o Web App automaticamente.*

### **Passo 2: Validar a URL**
Ao final do log, você verá a URL da sua aplicação (ex: `https://lab-actuator-123.azurewebsites.net`).
Acesse-a no seu navegador e verifique se aparece: **"App CAIXA Rodando no Java 17!"**.

---

## 🔍 4. Ativando o Application Insights (Via Portal Azure)

O "pulo do gato" para o desenvolvedor sênior é a observabilidade nativa sem precisar alterar o código.

### **Passo 1: Ativação Visual**
1. No [Portal do Azure](https://portal.azure.com), localize o seu **App Service**.
2. No menu lateral esquerdo, sob a seção **Settings**, clique em **Application Insights**.
3. Clique no botão **Turn on Application Insights**.
4. Mantenha a opção **Create new resource** selecionada (ele criará um com o mesmo nome da sua app).
5. Certifique-se de que a opção **Java** está selecionada e a versão do agente está em **Recommended**.
6. Role até o fim e clique em **Apply**, confirmando a reinicialização da app com **Yes**.

### **Passo 2: O Teste de Estresse**
No terminal (Killercoda), dispare uma carga de acessos para gerar métricas:
```bash
# Substitua pela sua URL final (pegue no log do deploy ou no portal)
APP_URL="https://sua-app-caixa.azurewebsites.net"

# Rode este loop para gerar tráfego
for i in {1..50}; do curl -s $APP_URL/actuator/health > /dev/null; echo "Acesso $i"; done
```

---

## 🎯 5. Inspeção no Portal Azure

1. Vá ao [Portal do Azure](https://portal.azure.com).
2. Localize seu **App Service**.
3. No menu lateral, procure por **Application Insights**.
4. Clique em **Live Metrics** (Métricas ao vivo). 
5. Você verá o consumo de CPU, Memória e as requisições HTTP em tempo real!

---

## 💡 Por que isso funciona?
O Azure App Service possui um **Agente de Telemetria** (Java Agent) que intercepta as chamadas do Micrometer/Actuator e as envia para o Application Insights sem que você precise escrever código Java para isso. É a implementação perfeita do conceito de **Sidecar/Agent** em Cloud.

