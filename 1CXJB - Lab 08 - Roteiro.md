# Lab 08 - Roteiro: Métricas de Negócio (Micrometer)

Neste laboratório, vamos aprender que a Observabilidade não serve apenas para a Infraestrutura. Vamos criar um contador personalizado para monitorar "Transações PIX" usando o **Micrometer**, o padrão do ecossistema Java moderno.

---

## 🚀 1. O Cenário "Mundo Real"

O servidor pode estar com CPU e Memória perfeitos, mas se as transações de negócio estiverem falhando ou não estiverem ocorrendo, o sistema está "morto" para a CAIXA. 

**Missão:** Criar um contador que rastreia cada vez que um endpoint de "Pagamento" é chamado.

---

## 💻 2. Implementação (Killercoda)

Assumimos que você está na pasta `lab-actuator` do Lab 06/07.

### **Passo 1: Injetar o MeterRegistry**
Vamos alterar nossa classe `DemoApplication.java` para incluir um contador.

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
        // Criando (ou recuperando) um contador chamado 'caixa.pix.processado'
        this.pixCounter = Counter.builder("caixa.pix.processado")
                .description("Total de transações PIX processadas")
                .register(registry);
    }

    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
    
    @GetMapping("/")
    public String home() {
        return "App CAIXA - Monitoramento de Negócio!";
    }

    @GetMapping("/pix")
    public String processarPix() {
        // Incrementando a métrica de negócio
        pixCounter.increment();
        return "PIX Processado com Sucesso!";
    }
}
EOF
```

---

## 🎯 3. Validação das Métricas

### **Passo 1: Rodar e Gerar Dados**
Rode a aplicação:
```bash
mvn spring-boot:run
```

Em outro terminal, dispare alguns "pagamentos":
```bash
curl localhost:8080/pix
curl localhost:8080/pix
curl localhost:8080/pix
```

### **Passo 2: Inspecionar o Actuator**
Agora, veja se a sua métrica customizada aparece na lista oficial do Spring:
```bash
curl localhost:8080/actuator/metrics/caixa.pix.processado
```
*Você deverá ver algo como:* `"value": 3.0`

### **Passo 3: Atualizar a Nuvem (Redeploy)**
Para que o Azure conheça sua nova métrica de negócio, precisamos enviar o código atualizado:
```bash
mvn package azure-webapp:deploy -DskipTests
```

---

## 🔍 4. Conexão com a Nuvem (Azure)

O ponto mais importante para um Dev Sênior: **Você não precisa configurar nada no Azure para essa métrica aparecer lá.**

Como o Azure App Insights (ativado no Lab 07) "escuta" o Micrometer, ele automaticamente enviará a métrica `caixa.pix.processado` para a nuvem.

1. Vá ao **Portal Azure** -> **Application Insights**.
2. Procure por **Metrics** no menu lateral.
3. No seletor de métrica, procure por `caixa.pix.processado`.
4. Você poderá criar um gráfico de "Transações por Minuto" baseado nesse contador!

---

## 💡 Por que isso funciona?
O **Micrometer** atua como uma fachada (Facade). Você programa para a interface do Micrometer e, em tempo de execução, os dados são enviados para o console, para o Prometheus ou para o Azure App Insights de forma transparente. Isso garante que seu código Java não fique "preso" a um fornecedor de nuvem específico.


