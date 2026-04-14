#!/bin/bash

# Lab 03 - Setup: Missão "Cirurgia de Código" (Rebase & Conflitos Java)
# Este script prepara um cenário de conflito real em arquivos Java e Maven.

echo "🚀 Preparando o cenário de Rebase (Lab 03)..."

# 1. Criar pasta e iniciar Git
mkdir -p ~/lab-rebase-java && cd ~/lab-rebase-java
rm -rf .git # Limpa se já existir
git init

# 2. Configurar identidade
git config user.email "dev@caixa.gov.br"
git config user.name "Dev Caixa"

# 3. Base na Master (Versão 1 - Estado Inicial)
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
git add .
git commit -m "chore: initial commit base"

# 4. Master avança (Versão 2 - Update oficial da arquitetura)
sed -i 's/3.2.0/3.2.4/g' pom.xml
sed -i 's/Processando.../[LOG] Processando pagamento master v2/g' src/main/java/br/gov/caixa/PagamentoService.java
git add .
git commit -m "fix: atualiza versao do spring e log base"

# 5. Aluno cria feature a partir do passado (Versão 1)
git checkout -b feature/ajuste-taxas HEAD~1
sed -i 's/3.2.0/3.1.5/g' pom.xml
sed -i 's/Processando.../Processando com taxas calculadas/g' src/main/java/br/gov/caixa/PagamentoService.java
git add .
git commit -m "feat: implementa calculo de taxas"

# Feedback visual
echo ""
echo "--------------------------------------------------------"
echo "🚑 OPERAÇÃO NECESSÁRIA: Sua branch 'feature/ajuste-taxas' está atrasada."
echo "Missão: Fazer um 'git rebase master' e resolver os conflitos."
echo "DICA: Use a aba 'Editor' do Killercoda para facilitar a cirurgia."
echo "--------------------------------------------------------"
