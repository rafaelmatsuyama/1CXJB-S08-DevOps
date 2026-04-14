# Lab 03 - Roteiro: Missão "Cirurgia de Código" (Rebase & Conflitos Java)

Este laboratório simula a necessidade de integrar uma funcionalidade (`feature`) em uma linha principal (`master`) que já avançou. Em vez de um "merge", utilizaremos o **Rebase** para manter o histórico linear e limpo, resolvendo conflitos em arquivos de configuração (`pom.xml`) e lógica Java.

---

## 🚀 1. Setup do Ambiente

### **Passo A: Acesse o Terminal**
Acesse o playground oficial: **[Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu)**

### **Passo B: Prepare o Cenário (Copie e cole no Terminal)**
Este comando cria o repositório, uma classe Java e gera commits conflitantes propositais entre a `master` e a sua branch de trabalho.

```bash
mkdir -p ~/lab-rebase-java && cd ~/lab-rebase-java
git init
git config user.email "dev@caixa.gov.br"
git config user.name "Dev Caixa"

# 1. Base na Master (Versão 1)
cat <<EOF > pom.xml
<project>
    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
            <version>3.2.0</version>
        </dependency>
    </dependencies>
</project>
EOF

mkdir -p src/main/java/br/gov/caixa
cat <<EOF > src/main/java/br/gov/caixa/PagamentoService.java
package br.gov.caixa;

public class PagamentoService {
    public void processar() {
        System.out.println("Processando...");
    }
}
EOF
git add . && git commit -m "chore: initial commit base"

# 2. Master avança (Versão 2 - Refatoração e Update oficial)
sed -i 's/3.2.0/3.2.4/g' pom.xml
sed -i 's/Processando.../[LOG] Processando pagamento master v2/g' src/main/java/br/gov/caixa/PagamentoService.java
git add . && git commit -m "fix: atualiza versao do spring e log base"

# 3. Você cria sua feature a partir da versão base (Versão 1)
git checkout -b feature/ajuste-taxas HEAD~1
sed -i 's/3.2.0/3.1.5/g' pom.xml
sed -i 's/Processando.../Processando com taxas calculadas/g' src/main/java/br/gov/caixa/PagamentoService.java
git add . && git commit -m "feat: implementa calculo de taxas"

echo ""
echo "--------------------------------------------------------"
echo "🚑 OPERAÇÃO NECESSÁRIA: Sua branch 'feature/ajuste-taxas' está atrasada."
echo "Missão: Fazer um 'git rebase master' e resolver os conflitos."
echo "DICA: Use a aba 'Editor' do Killercoda para ver os arquivos."
echo "--------------------------------------------------------"
```

---

## 🎯 2. Sua Missão

### **Passo 1: Inicie o Rebase**
Tente trazer sua branch para o topo da master:
```bash
git rebase master
```
*O Git irá parar o processo e avisar que existem conflitos.*

### **Passo 2: A Cirurgia (Killercoda Editor)**
Abra a aba **Editor** (ao lado do Terminal no Killercoda) e abra os arquivos:

1.  **No `pom.xml`:** Você verá as marcas de conflito. Escolha manter a versão **3.2.4** (que é a versão oficial da master). Remova as linhas de marcação do Git (`<<<<`, `====`, `>>>>`).
2.  **No `PagamentoService.java`:** Mescle as ideias. Mantenha o prefixo `[LOG]` da master, mas inclua a mensagem de `taxas calculadas` da sua feature.

### **Passo 3: Conclua a Operação**
Após salvar os arquivos no Editor, volte ao Terminal e digite:
```bash
git add .
git rebase --continue
```

### **Passo 4: Validação (Healthy Branch)**
Verifique se o seu histórico agora é uma linha reta (sem commits de merge extras):
```bash
git log --oneline --graph --all
```
E valide se o código Java ainda é válido (simulação de build):
```bash
# Se tivéssemos Maven completo rodaríamos 'mvn compile'. 
# Por agora, apenas verifique o conteúdo:
cat src/main/java/br/gov/caixa/PagamentoService.java
```

---

## 💡 Por que Rebase?
Diferente do `merge`, o `rebase` reescreve o histórico para que pareça que você começou a trabalhar **hoje** a partir da versão mais atual da master. Isso evita a "teia de aranha" de commits de merge e facilita muito a leitura do histórico em projetos de grande escala.
