# Lab 02 - Roteiro: Missão "Resgate no Tempo" (Git Reflog)

Este laboratório simula um erro comum no dia a dia corporativo: a deleção acidental de uma branch de funcionalidade (`feature`) que ainda não foi integrada ao código principal (`main/master`).

---

## 🚀 1. Setup do Ambiente

### **Passo A: Acesse o Terminal**
Acesse o playground oficial: **[Killercoda Ubuntu Playground](https://killercoda.com/playgrounds/scenario/ubuntu)**

### **Passo B: Prepare o Desastre (Copie e cole no Terminal)**
Este comando prepara o "cenário do desastre": cria o repositório, uma classe Java base, realiza um commit de segurança e **deleta a branch** logo em seguida para criar o problema.

```bash
mkdir -p ~/lab-git-caixa && cd ~/lab-git-caixa
git init
git config user.email "dev@caixa.gov.br"
git config user.name "Dev Caixa"

# Criando a base na master
mkdir -p src/main/java/br/gov/caixa
cat <<EOF > src/main/java/br/gov/caixa/PagamentoService.java
package br.gov.caixa;

public class PagamentoService {
    public void processar() {
        System.out.println("Pagamento Base");
    }
}
EOF
git add . && git commit -m "chore: initial commit master"

# Criando a feature de segurança e DELETANDO-A logo em seguida
git checkout -b feature/seguranca-v2
echo "// TODO: Implementar criptografia forte" >> src/main/java/br/gov/caixa/PagamentoService.java
git add . && git commit -m "feat: rascunho de seguranca (branch para ser deletada)"
git checkout master
git branch -D feature/seguranca-v2

echo ""
echo "--------------------------------------------------------"
echo "🔥 DESASTRE ACONTECEU: A branch 'feature/seguranca-v2' foi deletada!"
echo "Sua missão é recuperá-la usando o 'git reflog'."
echo "--------------------------------------------------------"
```

---

## 🎯 2. Sua Missão

### **Passo 1: Verifique o desastre**
Tente listar as branches locais para confirmar que a branch de segurança sumiu:
```bash
git branch
```
*Nota: Você verá apenas a branch `master`.*

### **Passo 2: Consulte o "Diário de Bordo" (Reflog)**
O Git mantém um log de todos os movimentos do `HEAD`. Execute:
```bash
git reflog
```
Localize a linha que descreve o commit da branch deletada:
`HEAD@{1}: commit: feat: rascunho de seguranca (branch para ser deletada)`

### **Passo 3: Identifique o SHA-1**
O código de 7 caracteres no início da linha (ex: `a1b2c3d`) é o identificador único daquele commit. **Anote o seu código.**

### **Passo 4: Realize o Resgate**
Crie a branch novamente apontando exatamente para aquele commit:
```bash
git checkout -b feature/seguranca-v2 <SHA-1-QUE-VOCE-ENCONTROU>
```

### **Passo 5: Validação Final**
Verifique se a branch voltou à lista e se o conteúdo do arquivo Java foi recuperado:
```bash
git branch
cat src/main/java/br/gov/caixa/PagamentoService.java
```

---

## 💡 Por que isso funciona?
O Git nunca deleta um commit imediatamente. Quando você deleta uma branch, o commit fica "órfão" (sem etiqueta), mas ele continua no disco por cerca de 30 dias até que o **Garbage Collection** (coleta de lixo) do Git faça a faxina. O `reflog` é o mapa para encontrar esses commits órfãos antes que eles sumam de vez.
