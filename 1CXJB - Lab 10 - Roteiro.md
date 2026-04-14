# Lab 10 - Roteiro: O Disjuntor (Circuit Breaker & Retry)

No Lab 09, vimos a app "explodir" no Azure. Agora, como sêniores, vamos implementar um mecanismo de segurança para que a falha de um serviço não derrube a experiência do usuário.

---

## 🚀 1. Setup Rápido (Código + Ferramentas Cloud)
Como estamos em uma **nova sessão**, este comando instala o Java, Maven e o **Azure CLI**, além de criar todo o projeto da Aula 04.

**Copie e cole no Terminal do Killercoda:**

```bash
# 1. Instalar JDK 17, Maven e Azure CLI
apt update && apt install -y openjdk-17-jdk maven
curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# 2. Criar estrutura e entrar na pasta
mkdir -p lab-caixa/src/main/java/br/gov/caixa lab-caixa/src/main/resources && cd lab-caixa

# 3. Criar o POM.xml (Completo com Plugin Azure)
cat <<EOF > pom.xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.4</version>
        <relativePath/> 
    </parent>
    <groupId>br.gov.caixa</groupId>
    <artifactId>lab-devops</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties><java.version>17</java.version></properties>
    <dependencies>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-web</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-actuator</artifactId></dependency>
        <dependency><groupId>org.springframework.boot</groupId><artifactId>spring-boot-starter-aop</artifactId></dependency>
        <dependency><groupId>io.github.resilience4j</groupId><artifactId>resilience4j-spring-boot3</artifactId><version>2.1.0</version></dependency>
    </dependencies>
    <build><plugins>
        <plugin><groupId>org.springframework.boot</groupId><artifactId>spring-boot-maven-plugin</artifactId></plugin>
        <plugin><groupId>com.microsoft.azure</groupId><artifactId>azure-webapp-maven-plugin</artifactId><version>2.13.0</version></plugin>
    </plugins></build>
</project>
EOF

# 4. Criar o Código Fonte (Endpoints de Teste e Resiliência)
cat <<EOF > src/main/java/br/gov/caixa/DemoApplication.java
package br.gov.caixa;
import io.micrometer.core.instrument.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.*;

@SpringBootApplication
@RestController
public class DemoApplication {
    private final Counter pixCounter;
    public DemoApplication(MeterRegistry registry) {
        this.pixCounter = Counter.builder("caixa.pix.processado").register(registry);
    }
    public static void main(String[] args) { SpringApplication.run(DemoApplication.class, args); }
    
    @GetMapping("/") public String home() { return "App CAIXA Online!"; }
    @GetMapping("/pix") public String pix() { pixCounter.increment(); return "PIX OK!"; }
    @GetMapping("/bug") public String bug() { throw new RuntimeException("🔥 Falha Crítica!"); }

    @GetMapping("/pix-seguro")
    @CircuitBreaker(name = "backendPix", fallbackMethod = "fallback")
    @Retry(name = "retryPix")
    public String pixSeguro() {
        System.out.println("Tentando processar PIX Seguro...");
        if (Math.random() > 0.5) throw new RuntimeException("Erro temporário.");
        return "PIX com Escudo OK!";
    }
    public String fallback(Exception e) { return "⚠️ Fallback Ativo (Sistema Indisponível)."; }
}
EOF

# 5. Criar application.properties (Configurações)
cat <<EOF > src/main/resources/application.properties
management.endpoints.web.exposure.include=*
management.endpoint.health.show-details=always
resilience4j.circuitbreaker.instances.backendPix.slidingWindowSize=10
resilience4j.circuitbreaker.instances.backendPix.failureRateThreshold=50
resilience4j.circuitbreaker.instances.backendPix.waitDurationInOpenState=10s
resilience4j.retry.instances.retryPix.maxAttempts=3
resilience4j.retry.instances.retryPix.waitDuration=2s
EOF

echo "✅ AMBIENTE PRONTO! Use: mvn spring-boot:run"
```

---

## ☁️ 2. Configuração do Ambiente Azure
Siga estes passos para conectar o terminal à sua conta Azure.

1.  **Autenticação:**
    ```bash
    az login --use-device-code
    ```
    *Acesse o link exibido, digite o código e logue com sua conta @caixa ou pessoal.*

2.  **Configurar o Deploy Maven:**
    ```bash
    mvn azure-webapp:config
    ```
    *   **Subscription:** Selecione sua assinatura.
    *   **OS:** `Linux` | **PricingTier:** `B1` | **Java:** `Java 17` | **Web Container:** `Java SE`

3.  **Deploy da Aplicação:**
    ```bash
    mvn package azure-webapp:deploy
    ```

---

## 👁️ 3. Habilitando o Application Insights (O "Raio-X")
O Azure App Service precisa ser "conectado" ao Application Insights para que você veja os gráficos.

1.  No [Portal Azure](https://portal.azure.com), localize o seu **App Service** (o nome que você escolheu no `mvn config`).
2.  No menu lateral esquerdo, procure a seção **Settings** e clique em **Application Insights**.
3.  Clique no botão **Turn on Application Insights**.
4.  **Configuração:**
    *   Mantenha "Create new resource".
    *   Clique em **Apply** e depois em **Yes**.
5.  Aguarde 1 minuto e sua aplicação passará a enviar logs, métricas e traces automaticamente (sem mexer no código!).

---

## 🔥 4. Teste de Guerra (Circuit Breaker & Retry)

1.  Acesse a URL gerada pelo Azure e adicione `/pix-seguro`.
2.  Dê F5 repetidamente. Note o sistema alternando entre Sucesso e Fallback.
3.  **Observe o Comportamento:** Se você disparar muitos erros, o Circuit Breaker **abre** e as respostas de Fallback passam a ser instantâneas (ele nem tenta executar o código Java).

---

## 🔔 5. Missão Final: Operação DevOps
1.  Vá ao Portal Azure -> **Application Insights** -> **Live Metrics**.
2.  Enquanto você dá F5 no `/pix-seguro`, veja o gráfico de **Request Success Rate** e **Dependency Failures** subir e descer em tempo real.
3.  Isso é Observabilidade: saber exatamente o que está acontecendo sem precisar abrir um arquivo de log.

---
