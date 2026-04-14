# Lab 11 - Roteiro: O Casco do Navio (Bulkhead & Isolamento)

O Bulkhead é inspirado nos compartimentos estanques de um navio. Se um compartimento inunda, o navio não afunda. No Java, usamos isso para limitar quantas threads uma funcionalidade pode usar.

---

## 🚀 1. Implementação do Isolamento (Aceleração)

Copie e cole este comando no Terminal do Killercoda para adicionar o endpoint de relatórios e configurar o Bulkhead no código.

**Passo A: Atualizar o Código Fonte (Sleep de 30s)**
```bash
cat <<EOF > src/main/java/br/gov/caixa/DemoApplication.java
package br.gov.caixa;
import io.micrometer.core.instrument.*;
import io.github.resilience4j.circuitbreaker.annotation.CircuitBreaker;
import io.github.resilience4j.retry.annotation.Retry;
import io.github.resilience4j.bulkhead.annotation.Bulkhead;
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
        if (Math.random() > 0.5) throw new RuntimeException("Erro temporário.");
        return "PIX com Escudo OK!";
    }
    public String fallback(Exception e) { return "⚠️ Fallback Ativo."; }

    @GetMapping("/relatorio-pesado")
    @Bulkhead(name = "relatorioBulkhead", fallbackMethod = "fallbackRelatorio")
    public String gerarRelatorio() throws InterruptedException {
        System.out.println("Iniciando processamento de relatório pesado (30s)...");
        Thread.sleep(30000); // 30 segundos de processamento para facilitar o teste
        return "📊 Relatório Gerado com Sucesso!";
    }
    public String fallbackRelatorio(Exception e) {
        return "⚠️ Servidor de Relatórios Ocupado (Bulkhead ativo).";
    }
}
EOF
```

**Passo B: Atualizar as Configurações**
```bash
cat <<EOF >> src/main/resources/application.properties

# Resilience4j - Bulkhead (Limita a 2 threads simultâneas)
resilience4j.bulkhead.instances.relatorioBulkhead.maxConcurrentCalls=2
resilience4j.bulkhead.instances.relatorioBulkhead.maxWaitDuration=0
EOF
```

---

## 🔥 2. Teste de Guerra (Sentindo o Bulkhead)

1.  Rode a aplicação localmente: `mvn spring-boot:run`.
2.  **Abra um NOVO terminal** no Killercoda e execute o comando abaixo para disparar 3 requisições simultâneas:

```bash
# Dispara 3 requisições em paralelo. As 2 primeiras ocupam as threads, a 3ª falha na hora.
curl -s localhost:8080/relatorio-pesado & \
curl -s localhost:8080/relatorio-pesado & \
curl -s localhost:8080/relatorio-pesado & \
wait
```

3.  **O que observar no terminal?**
    *   As duas primeiras linhas demorarão **30 segundos** para responder.
    *   A terceira linha responderá **IMEDIATAMENTE** com a mensagem de Fallback: `⚠️ Servidor de Relatórios Ocupado (Bulkhead ativo).`.
    *   Isso prova que o sistema recusou a 3ª tarefa antes mesmo de tentar processá-la, protegendo os recursos.

---

## 🔔 3. Missão Final: Estabilidade do Sistema
Enquanto os relatórios pesados estão rodando, prove que o sistema não travou:

```bash
curl localhost:8080/
```

**Resultado:** O "App CAIXA Online!" carrega instantaneamente. O Bulkhead garantiu que o "relatório guloso" não roubasse todas as threads da aplicação.

---
