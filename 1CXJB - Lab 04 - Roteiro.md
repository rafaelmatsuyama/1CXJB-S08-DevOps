# Lab 04 - Roteiro: O Cirurgião de Código (Git Squash)

Este laboratório foca na limpeza de histórico. Como desenvolvedores sênior, não queremos poluir a branch principal com commits de "tentativa e erro". Vamos aprender a consolidar commits usando o `Interactive Rebase`.

---

## 🚀 1. Setup do Ambiente

Acesse o playground: **[Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu)**

### **Cenário: O Microserviço de Pix**
Vamos simular o desenvolvimento de um serviço de validação de chaves Pix.
```bash
# 1. Configurar identidade
git config --global user.email "dev@caixa.gov.br"
git config --global user.name "Dev Caixa Sênior"

# 2. Criar projeto e arquivo Java
mkdir -p lab-pix-caixa/src/main/java/br/gov/caixa && cd lab-pix-caixa
git init

cat <<EOF > src/main/java/br/gov/caixa/PixValidator.java
package br.gov.caixa;
public class PixValidator {
    public boolean validar(String chave) { return true; }
}
EOF

git add . && git commit -m "feat: initial commit pix validator"

# 3. Criar branch de feature e fazer commits "sujos" (tentativa e erro)
git checkout -b feature/validacao-cpf
echo "// Ajuste log 1" >> src/main/java/br/gov/caixa/PixValidator.java
git add . && git commit -m "fix: ajuste log"
echo "// Ajuste log 2" >> src/main/java/br/gov/caixa/PixValidator.java
git add . && git commit -m "fix: mais um ajuste"
echo "// Ajuste log final" >> src/main/java/br/gov/caixa/PixValidator.java
git add . && git commit -m "fix: agora sim o log ta certo"
```

---

## 🎯 Missão 1: O Squash (Limpeza Profissional)
Você tem 3 commits de "fix" que não agregam valor ao histórico. Vamos transformá-los em um único commit `feat: implementa logging de validacao`.

1. Execute: `git rebase -i HEAD~3`
2. No editor (Killercoda Editor ou Vim):
   - Mantenha o primeiro commit como `pick`.
   - Mude os outros dois de `pick` para `squash` (ou apenas `s`).
3. Salve e feche.
4. Na tela de mensagem que abrir, apague tudo e digite apenas: `feat: implementa logging de auditoria no validador`.
5. **Validação:** Digite `git log --oneline` e veja seu histórico limpo e profissional.

---
**Dica Sênior:** Um histórico limpo facilita a auditoria de código e o rastreamento de bugs (git bisect) em produção.
---
