# Lab 06 - Roteiro: Anatomia do Actuator (Local)

Este laboratório demonstra como abrir a "caixa-preta" de uma aplicação Java Spring Boot usando o **Spring Boot Actuator**. Vamos configurar e inspecionar os endpoints de saúde e métricas antes de conectá-los à nuvem.

---

## 🚀 1. Setup do Ambiente (Killercoda)

### **Passo A: Acesse o Terminal**
Acesse o playground oficial: **[Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu)**

### **Passo B: Preparar o Projeto (Copie e cole no Terminal)**
Este comando instala o **JDK 17 (LTS)**, o Maven e cria a estrutura do projeto.

```bash
# 1. Instalar o JDK 17 e Maven
apt update && apt install -y openjdk-17-jdk maven

# 2. Criar pastas do projeto
mkdir -p lab-actuator/src/main/java/br/gov/caixa
mkdir -p lab-actuator/src/main/resources
cd lab-actuator

# 3. Criar o POM.xml com Actuator e Web (Java 17 + Spring Boot 3.2)
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
    <artifactId>lab-actuator</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <java.version>17</java.version>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 4. Criar a classe principal
cat <<EOF > src/main/java/br/gov/caixa/DemoApplication.java
package br.gov.caixa;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@SpringBootApplication
@RestController
public class DemoApplication {
    public static void main(String[] args) {
        SpringApplication.run(DemoApplication.class, args);
    }
    
    @GetMapping("/")
    public String home() {
        return "App CAIXA Rodando no Java 17!";
    }
}
EOF

# 5. Criar arquivo de propriedades
touch src/main/resources/application.properties
```

---

## 🎯 2. Sua Missão

### **Passo 1: Rodar a Aplicação**
No terminal, dentro da pasta `lab-actuator`, execute:
```bash
mvn spring-boot:run
```
Aguarde o log indicar: `Started DemoApplication in ... seconds`.

### **Passo 2: Testar o Endpoint Padrão**
Abra um **novo terminal** no Killercoda e execute:
```bash
curl localhost:8080/actuator/health
```
*Você deve ver:* `{"status":"UP"}`.

### **Passo 3: Tentar acessar as métricas (Bloqueado)**
Tente acessar o endpoint de métricas:
```bash
curl localhost:8080/actuator/metrics
```
*Resultado esperado:* **404 Not Found**.

### **Passo 4: Cirurgia de Configuração (Exposição Total)**
Pare a aplicação (Ctrl+C no primeiro terminal) e edite o arquivo de propriedades:
```bash
echo "management.endpoints.web.exposure.include=*" >> src/main/resources/application.properties
echo "management.endpoint.health.show-details=always" >> src/main/resources/application.properties
```

### **Passo 5: Validar a Transparência**
Rode a aplicação novamente: `mvn spring-boot:run`.
No segundo terminal, teste os novos acessos:
1. **Saúde detalhada:** `curl localhost:8080/actuator/health` 
2. **Lista de Métricas:** `curl localhost:8080/actuator/metrics`
3. **Métrica de Memória:** `curl localhost:8080/actuator/metrics/jvm.memory.used`

---

## 🔥 Desafio Sênior: Custom Health Indicator

No ambiente da CAIXA, não basta o servidor estar "UP". Se o sistema de mensageria estiver fora, a aplicação é inútil.

1. Pare a aplicação.
2. Crie uma classe de saúde customizada:
```bash
cat <<EOF > src/main/java/br/gov/caixa/CaixaHealthIndicator.java
package br.gov.caixa;
import org.springframework.boot.actuate.health.Health;
import org.springframework.boot.actuate.health.HealthIndicator;
import org.springframework.stereotype.Component;

@Component
public class CaixaHealthIndicator implements HealthIndicator {
    @Override
    public Health health() {
        // Simulação: Verificar se um serviço externo responde
        boolean erroNoIntegrador = false; 
        if (erroNoIntegrador) {
            return Health.down().withDetail("erro", "Integrador fora do ar").build();
        }
        return Health.up().withDetail("sistema", "Sistemas CAIXA operacionais").build();
    }
}
EOF
```
3. Rode novamente e verifique o `actuator/health`. Note a nova seção `caixa`.

---

## 💡 Por que isso funciona?
O Actuator utiliza o **Micrometer** por baixo dos panos. Ele coleta dados brutos da JVM e do ambiente e os expõe via HTTP/JSON. No próximo laboratório, o **Azure Application Insights** apenas "assina" esses dados, transformando esses JSONs em gráficos bonitos no portal Cloud.
