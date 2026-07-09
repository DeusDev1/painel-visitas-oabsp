# Guia — Ativar login no painel (Supabase Auth)

Passo a passo para deixar o painel com login para os 3 usuários (Presidente, funcionária
do gabinete e você/administrador). Tudo dentro do **plano gratuito** do Supabase.

Tempo estimado: ~10 minutos. Faça na ordem.

---

## Antes de começar

- Tenha acesso ao Dashboard do Supabase do projeto (o mesmo da URL em `config.js`).
- Você vai definir 3 e-mails e 3 senhas. Podem ser e-mails reais (recomendado) ou
  qualquer e-mail válido — como criaremos os usuários já confirmados, o e-mail não
  precisa ser aberto para ativar.

---

## Passo 1 — Criar os 3 usuários

1. No Dashboard, abra **Authentication** (menu lateral) → aba **Users**.
2. Clique em **Add user** → **Create new user**.
3. Preencha **Email** e **Password**.
4. **Marque a opção "Auto Confirm User"** (cria o usuário já confirmado, sem precisar
   validar e-mail). Isso evita qualquer limite de envio de e-mail do plano grátis.
5. Clique em **Create user**.
6. Repita para os 3:
   - Presidente — ex.: `presidente@oabsp...` / senha forte
   - Gabinete — ex.: `gabinete@oabsp...` / senha forte
   - Administrador (você) — seu e-mail / senha forte

Anote as senhas com segurança e entregue a cada pessoa a sua.

---

## Passo 2 — Desligar o cadastro público (importante)

Assim ninguém consegue criar conta sozinho — só existirão os 3 que você criou.

1. **Authentication** → **Sign In / Providers** (ou **Providers** → **Email**).
2. Deixe **Email** habilitado como método de login.
3. **Desative** a opção de permitir novos cadastros — o nome varia conforme a versão do
   painel: procure por **"Allow new users to sign up"** / **"Enable sign ups"** e deixe
   **desligado (off)**.

> Observação: o painel não tem tela de "criar conta" — apenas login. Desligar o cadastro
> é uma camada extra de segurança na API.

---

## Passo 3 — Aplicar a segurança nos dados (RLS)

1. Abra **SQL Editor** no Dashboard.
2. Cole todo o conteúdo do arquivo **`supabase-rls.sql`** (está no projeto).
3. Clique em **Run**.

Isso garante: quem não está logado **não vê nem altera** nada; os 3 usuários têm acesso
total.

---

## Passo 4 — Conferir o `config.js`

Abra `config.js` e confirme:

- `SUPABASE_URL` é a URL base do projeto, **sem** `/rest/v1` no final
  (ex.: `https://SEUPROJETO.supabase.co`).
- `SUPABASE_ANON_KEY` é a chave **publishable/anon** (nunca a `service_role`).

A URL e a chave você encontra em **Project Settings → API**.

---

## Passo 5 — Testar

1. Abra o painel (localmente ou já publicado).
2. Deve aparecer a **tela de login**. Sem logar, nada de dados aparece. ✔
3. Entre com um dos usuários → o painel carrega normalmente.
4. Marque uma visita em uma subseção e recarregue a página: a alteração deve persistir. ✔
5. Teste especificamente **Estrela d'Oeste** (valida a correção de nomes com apóstrofo). ✔
6. Clique em **Sair** → volta para a tela de login. ✔

---

## Como funciona (resumo técnico)

- O painel usa a biblioteca `@supabase/supabase-js` (carregada via CDN) para login e
  para ler/gravar dados.
- Ao logar, o Supabase devolve um token de sessão que o navegador guarda — por isso o
  Presidente não precisa logar toda vez.
- Toda gravação vai com esse token; o RLS confere no servidor que é um usuário válido.
- "Gerar relatório" = botão **Exportar CSV** (abre no Excel), disponível para os 3.

## Trocar senha de um usuário

**Authentication → Users →** clique no usuário → **Reset password** (ou edite e defina
nova senha). Também dá para o próprio usuário redefinir, mas para simplicidade o
administrador pode gerenciar por aqui.
