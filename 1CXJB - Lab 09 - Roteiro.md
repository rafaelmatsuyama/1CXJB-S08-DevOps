# Lab 09 - Roteiro: Dashboards & Alertas (O Fim do "Acho que...")

Neste laboratório final, vamos sair do código e focar na **operação**. Vamos aprender a visualizar a saúde interna da JVM na nuvem e configurar um alerta para nos avisar antes que o cliente ligue reclamando.

---

## 🚀 1. Visualizando a "Saúde Profunda" (JVM)

Graças ao Agente Java que ativamos no Lab 07, o Azure já possui um dashboard completo da sua JVM.

### **Passo 1: Investigação de Performance**
1. No **Portal Azure**, acesse o seu recurso de **Application Insights**.
2. No menu lateral, procure por **Investigate** -> **Performance**.
3. Clique na aba **Role: Web** (ou o nome da sua app).
4. Note que você tem gráficos de tempo de resposta médio.
5. Agora, clique em **Metrics** (no topo ou lateral) e procure por métricas começando com `jvm/`:
   *   `jvm/memory/used`: Memória Heap em uso.
   *   `jvm/threads/live`: Quantidade de Threads ativas.
   *   `jvm/gc/pause`: Tempo parado por Garbage Collection.

---

## 💥 2. Simulando o Caos (Erro 500)

Para testar um alerta, precisamos de um erro real. Vamos adicionar um endpoint que "quebra" de propósito.

### **Passo 1: Adicionar Endpoint de Erro (Killercoda)**
Pare a aplicação (`Ctrl+C`) e atualize o `DemoApplication.java`:

```bash
cat <<EOF > src/main/java/br/gov/caixa/DemoApplication.java
package br.gov.caixa;

import io.micrometer.core.instrument.Counter;
import io.micrometer.core.instrument.MeterRegistry;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {

    private final Counter pixCounter;

    public DemoApplication(MeterRegistry registry) {
        this.pixCounter = Counter.builder("caixa.pix.processado")
                .description("Total de transações PIX processadas")
                .register(registry);
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
    
    @GetMapping("/")
    public String home() { return "App Monitorada!"; }

    @GetMapping("/pix")
    public String processarPix() {
        pixCounter.increment();
        return "PIX OK!";
    }

    @GetMapping("/bug")
    public String simularErro() {
        throw new RuntimeException("🔥 Falha Crítica no Processamento!");
    }
}
EOF
```

### **Passo 2: Build e Deploy**
```bash
mvn package azure-webapp:deploy
```

---

## 🔔 3. Criando um Alerta de Disponibilidade

Vamos configurar o Azure para nos avisar se houver muitas falhas.

### **Passo 1: Configurar a Regra**
1. No Application Insights, vá em **Monitoring** -> **Alerts**.
2. Clique em **+ Create** -> **Alert rule**.
3. Em **Signal name**, procure por **Failed requests**.
4. Configure a **Threshold** (Limite): 
   *   Operator: `Greater than`
   *   Threshold value: `5`
   *   Aggregation granularity: `1 minute`
5. Em **Actions**, você poderia criar um grupo para enviar E-mail/SMS (opcional para o lab).
6. Dê um nome ao alerta: `Alerta_Erro_Caixa` e clique em **Create**.

---

## 🔥 4. Teste de Fogo

1. Dispare 10 acessos ao endpoint de erro:
```bash
APP_URL="SUA_URL_AQUI"
for i in {1..10}; do curl -s $APP_URL/bug; echo "Erro disparado $i"; done
```
2. Vá ao Portal Azure -> **Application Insights** -> **Failures**.
3. Veja o gráfico de erros subir e clique em **Top 3 response codes** (500).
4. Você conseguirá ver o **Stack Trace** exato da `RuntimeException` que criamos!

---

## 🧹 5. Limpeza do Ambiente (Importante!)

Para evitar o consumo desnecessário dos seus créditos de estudante, sempre delete os recursos ao final do exercício.

### **Passo Único: Deleção via Portal Azure**
1. No [Portal do Azure](https://portal.azure.com), procure por **Resource groups** na barra de busca superior.
2. Localize e clique no **Resource Group** que você criou (o nome está no seu `pom.xml`).
3. No menu superior do grupo, clique em **Delete resource group**.
4. Para confirmar, digite exatamente o **nome do grupo de recursos** no campo solicitado.
5. Clique no botão **Delete** na parte inferior para confirmar a remoção de todos os serviços (App Service, App Insights, Plan).

*Nota: A deleção pode levar alguns minutos para ser processada pela Azure.*

---

## 💡 Por que isso funciona?
A Observabilidade moderna transforma "Logs e Erros" em dados estruturados. Em vez de você entrar no servidor e dar um `tail -f` no arquivo de log, você usa **Smart Detection** e **Alertas** que te avisam proativamente onde o erro está, incluindo a linha exata do código Java.
