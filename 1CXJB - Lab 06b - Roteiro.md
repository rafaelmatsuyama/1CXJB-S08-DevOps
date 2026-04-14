# Lab 06b - Roteiro: Anatomia do Quarkus (Observabilidade Nativa)

Este laboratório demonstra como o **Quarkus** lida com a Observabilidade usando o padrão MicroProfile. Vamos explorar o SmallRye Health (Liveness/Readiness) e o Micrometer de forma nativa.

---

## 🚀 1. Setup do Ambiente (Killercoda)

### **Passo A: Acesse o Terminal**
Acesse o playground oficial: **[Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu)**

### **Passo B: Criar o Projeto Quarkus (Copie e cole no Terminal)**
Diferente do Spring, o Quarkus possui um gerador via Maven que já baixa as extensões necessárias (Health e Micrometer).

```bash
# 1. Instalar o JDK 17 e Maven (Caso não tenha feito no Lab 06)
apt update && apt install -y openjdk-17-jdk maven

# 2. Gerar Projeto Quarkus (Adicionando o Registry Prometheus para habilitar o endpoint /q/metrics)
mvn io.quarkus.platform:quarkus-maven-plugin:3.2.10.Final:create \
    -DplatformVersion=3.2.10.Final \
    -DprojectGroupId=br.gov.caixa \
    -DprojectArtifactId=lab-quarkus-obs \
    -Dextensions="resteasy-reactive,smallrye-health,micrometer,micrometer-registry-prometheus" \
    -DnoCode

cd lab-quarkus-obs

# 3. Criar o Resource (Controller)
mkdir -p src/main/java/br/gov/caixa
cat <<EOF > src/main/java/br/gov/caixa/PixResource.java
package br.gov.caixa;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;

@Path("/")
public class PixResource {

    @GET
    @Produces(MediaType.TEXT_PLAIN)
    public String home() {
        return "Quarkus CAIXA Rodando!";
    }
}
EOF
```

---

## 🎯 2. Sua Missão

### **Passo 1: Rodar em Modo Dev (A "Mágica" do Quarkus)**
No terminal, execute:
```bash
mvn quarkus:dev
```
*Note a velocidade de inicialização (Startup time) em comparação ao Spring Boot.*

### **Passo 2: Inspecionar Saúde (Liveness & Readiness)**
Abra um **novo terminal** e execute os comandos:
1. **Saúde Geral:** `curl localhost:8080/q/health`
2. **Estou Vivo? (Liveness):** `curl localhost:8080/q/health/live`
3. **Estou Pronto? (Readiness):** `curl localhost:8080/q/health/ready`

*Diferença Sênior:* O Quarkus separa nativamente se a app está "viva" de se ela está "pronta para receber tráfego" (ex: banco de dados conectado).

### **Passo 3: Inspecionar Métricas (Prometheus/Micrometer)**
Diferente do JSON do Spring, o Quarkus expõe métricas no formato **Prometheus** (texto puro). 

1. **Ver lista completa:**
```bash
curl localhost:8080/q/metrics
```

2. **Filtrar métrica específica (ex: Memória Heap):**
Para encontrar uma agulha no palheiro, use o `grep`:
```bash
curl -s localhost:8080/q/metrics | grep jvm_memory_used_bytes
```

---

## 🔥 Desafio Sênior: Custom Readiness Check

No Quarkus, criar um check de saúde é apenas uma questão de implementar uma interface e usar um qualificador CDI.

1. **Sem parar a aplicação** (o Quarkus fará o Hot Reload), crie o arquivo:
```bash
cat <<EOF > src/main/java/br/gov/caixa/DatabaseHealthCheck.java
package br.gov.caixa;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;
import jakarta.enterprise.context.ApplicationScoped;

@Readiness
@ApplicationScoped
public class DatabaseHealthCheck implements HealthCheck {
    @Override
    public HealthCheckResponse call() {
        return HealthCheckResponse.up("Banco de Dados CAIXA");
    }
}
EOF
```
2. Teste novamente o `curl localhost:8080/q/health/ready`. Note que o Quarkus já incluiu o novo check instantaneamente!

---

## 💡 Por que isso funciona?
O Quarkus utiliza o **SmallRye Health**, uma implementação do **MicroProfile Health**. Ele é desenhado para ambientes de Nuvem e Kubernetes, onde o orquestrador precisa saber exatamente se deve reiniciar o container ou apenas parar de enviar usuários para ele.
