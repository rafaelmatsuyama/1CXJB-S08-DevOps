# Lab 05 - Roteiro: O Quality Gate (CI em Java)

Este laboratório demonstra como criar uma esteira de Integração Contínua (CI) para garantir que código com erro de compilação ou testes falhando nunca chegue à branch principal.

---

## 🛠️ Escolha seu Caminho de Execução

---

## 🚀 Opção A: GitHub Actions (Via Codespaces)
*Ideal para quem tem acesso ao GitHub e deseja ver a automação na nuvem.*

### **Passo 1: Iniciar o Ambiente**
1. No seu repositório no GitHub, clique no botão verde **"<> Code"**.
2. Selecione a aba **"Codespaces"** e clique em **"Create codespace on main"**.
3. Aguarde o carregamento do editor no navegador. 
   *(Nota: O Maven já vem pré-instalado no Codespaces, não é necessário rodar `apt install`)*.

### **Passo 2: Criar a Estrutura do Projeto**
Execute no terminal do Codespaces (na raiz do projeto):
```bash
# Criar pastas para o código de teste
mkdir -p src/test/java/br/gov/caixa

# Criar POM (JUnit 5 + Surefire)
cat <<EOF > pom.xml
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>br.gov.caixa</groupId>
    <artifactId>lab-ci</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# Criar o Teste Unitário
cat <<EOF > src/test/java/br/gov/caixa/AppTest.java
package br.gov.caixa;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class AppTest {
    @Test
    void testIntegracaoValida() {
        assertTrue(true);
    }
}
EOF
```

### **Passo 3: Configurar a Esteira (Workflow)**
1. Crie a pasta: `mkdir -p .github/workflows`
2. Crie o arquivo `.github/workflows/ci-java.yml`:
```yaml
name: Java CI (Maven)
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up JDK 17
      uses: actions/setup-java@v3
      with:
        java-version: '17'
        distribution: 'temurin'
        cache: maven
    - name: Build and Test
      run: mvn -B package --file pom.xml
```

### **Passo 4: Subir e Validar**
1. Envie as alterações:
```bash
git add .
git commit -m "feat: setup ci quality gate"
git push origin main
```
2. Vá até a aba **Actions** no seu GitHub e veja o "check verde".

---

## 🖥️ Opção B: Simulação Manual (Via Killercoda)
*Ideal para quem está em ambiente restrito ou sem acesso ao GitHub Actions.*

### **Passo 1: Instalar Ferramentas e Criar Estrutura**
Acesse o [Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu) e execute:
```bash
# 1. Instalar o Maven
apt update && apt install -y maven

# 2. Criar pastas
mkdir -p src/test/java/br/gov/caixa

# 3. Criar POM (Igual ao da Opção A)
cat <<EOF > pom.xml
<project>
    <modelVersion>4.0.0</modelVersion>
    <groupId>br.gov.caixa</groupId>
    <artifactId>lab-ci</artifactId>
    <version>1.0-SNAPSHOT</version>
    <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>
    <dependencies>
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>5.10.0</version>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>3.2.5</version>
            </plugin>
        </plugins>
    </build>
</project>
EOF

# 4. Criar o Teste Unitário
cat <<EOF > src/test/java/br/gov/caixa/AppTest.java
package br.gov.caixa;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertTrue;

public class AppTest {
    @Test
    void testIntegracaoValida() {
        assertTrue(true);
    }
}
EOF
```

### **Passo 2: Criar o Robô de Esteira (Script)**
```bash
cat <<EOF > pipeline.sh
#!/bin/bash
echo "🚀 [CI/CD] Iniciando Esteira de Qualidade..."

echo "Step 1: Validando Compilação (Compile)..."
mvn compile
if [ \$? -ne 0 ]; then
    echo "❌ [FALHA] Código não compila. Bloqueando Integração."
    exit 1
fi

echo "Step 2: Executando Testes Unitários (Test)..."
mvn test
if [ \$? -ne 0 ]; then
    echo "❌ [FALHA] Testes falharam. Bloqueando Integração."
    exit 1
fi

echo "✅ [SUCESSO] O código passou em todos os gates de qualidade!"
EOF
chmod +x pipeline.sh
```

### **Passo 3: Validar a Esteira**
Execute: `./pipeline.sh`

---

## 🔥 O Cenário de Erro (Para ambas as opções)

1. No arquivo `src/test/java/br/gov/caixa/AppTest.java`, altere para `assertTrue(false)`.
2. Tente rodar o CI novamente (fazendo `git push` ou rodando `./pipeline.sh`).
3. Veja o "Gate" (GitHub ou Script) **barrar** a integração.
