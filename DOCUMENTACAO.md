# Documentação Técnica — Painel de Visitas às Subseções (OAB/SP)

Guia de arquitetura, configuração, segurança, publicação e manutenção do painel.
Para uma visão geral, veja o [README.md](README.md).

---

## Índice

1. [Arquitetura](#arquitetura)
2. [Modelo de dados](#modelo-de-dados)
3. [Configuração do Supabase](#configuração-do-supabase)
4. [Segurança](#segurança)
5. [Publicação (deploy)](#publicação-deploy)
6. [Fluxo de trabalho com Git](#fluxo-de-trabalho-com-git)
7. [Tarefas de manutenção](#tarefas-de-manutenção)
8. [Solução de problemas](#solução-de-problemas)
9. [Versionamento](#versionamento)

---

## Arquitetura

O painel é uma **aplicação estática de página única** (`index.html`, com HTML, CSS e
JavaScript juntos) que conversa com o **Supabase** para autenticação e dados.

```text
Navegador (index.html)
   │  login (e-mail/senha)
   ▼
Supabase Auth  ──►  devolve um token de sessão (guardado no navegador)
   │
   │  chamadas com o token
   ▼
Supabase (PostgreSQL + Row Level Security)
   └─ tabela public.subsecoes  ← única fonte dos dados reais
```

Pontos-chave:

- **Sem build e sem servidor próprio:** é só um site estático + Supabase.
- **Dados só no Supabase:** os arquivos `data/dados.js` e `data/subsecoes.csv` ficam vazios
  de propósito. A lista de regiões é reconstruída a partir dos registros carregados do banco.
- **Biblioteca:** `@supabase/supabase-js` via CDN (`jsdelivr`).

---

## Modelo de dados

Tabela **`public.subsecoes`** (uma linha por subseção — 258 no total):

| Coluna          | Tipo      | Descrição                                                        |
| --------------- | --------- | ---------------------------------------------------------------- |
| `id`            | uuid/int  | Identificador único (usado para gravar alterações).              |
| `regiao`        | text      | Nome da região (ex.: "1ª Região").                               |
| `numero_regiao` | int       | Número da região (1 a 21).                                       |
| `subsecao`      | text      | Nome da subseção (ex.: "Santos").                                |
| `presidente`    | boolean   | `true` se visitada como Presidente.                              |
| `vp`            | boolean   | `true` se visitada como Vice-Presidente.                         |
| `classificacao` | text      | Rótulo derivado (ver abaixo).                                    |
| `updated_at`    | timestamp | Data/hora da última alteração.                                   |

**Regra da `classificacao`** (recalculada a cada alteração):

- `presidente = true` **e** `vp = true` → `"VP + Presidente"`
- `presidente = true` **ou** `vp = true` → `"Visitada"`
- caso contrário → `"Não visitada"`

> O painel converte automaticamente entre `true/false` (banco) e `Sim/Não` (tela).

---

## Configuração do Supabase

A conexão fica em **`config.js`**:

```js
window.APP_CONFIG = {
  SUPABASE_URL: "https://SEU-PROJETO.supabase.co",  // Project Settings → API (sem /rest/v1)
  SUPABASE_ANON_KEY: "sb_publishable_..."           // chave publishable/anon
};
```

- **`SUPABASE_URL`**: a URL base do projeto, **sem** `/rest/v1` no final.
- **`SUPABASE_ANON_KEY`**: a chave **publishable/anon** (começa com `sb_publishable_`).
  Nunca use a `service_role` aqui.

---

## Segurança

A proteção dos dados vem de **login (Supabase Auth) + Row Level Security (RLS)**, não de
esconder a chave (que, num site estático, é sempre visível no navegador).

### 1. Criar os usuários

No Dashboard do Supabase: **Authentication → Users → Add user → Create new user**, marcando
**"Auto Confirm User"** (cria o usuário já confirmado, sem depender de e-mail). Crie um
usuário para cada pessoa que vai acessar (ex.: Presidente, gabinete, administrador).
Passo a passo detalhado em [GUIA-LOGIN-SUPABASE.md](GUIA-LOGIN-SUPABASE.md).

### 2. Desligar o cadastro público

**Authentication → Sign In / Providers → Email**: mantenha o Email habilitado como login,
mas **desative** "Allow new users to sign up". Assim só existem os usuários criados manualmente.

> Importante: as políticas de RLS dão acesso a **qualquer** usuário autenticado. Por isso o
> cadastro público **precisa** ficar desligado.

### 3. Aplicar o RLS

No **SQL Editor**, rode o conteúdo de [`supabase-rls.sql`](supabase-rls.sql). Ele:

- habilita o RLS na tabela `public.subsecoes`;
- cria política de **leitura** para autenticados;
- cria política de **atualização** para autenticados;
- **não** cria políticas de inserção/remoção (a lista de subseções é fixa).

Resultado: sem login, ninguém lê nem altera nada.

### Verificações rápidas (SQL Editor)

```sql
-- RLS ligado? (esperado: rowsecurity = true)
select tablename, rowsecurity from pg_tables where tablename = 'subsecoes';

-- Políticas existentes (esperado: leitura + atualização, só autenticadas)
select policyname, cmd from pg_policies where tablename = 'subsecoes';

-- Um visitante anônimo enxerga algo? (esperado: 0)
set role anon;
select count(*) from public.subsecoes;
reset role;
```

---

## Publicação (deploy)

O painel é estático; qualquer servidor web serve. Abaixo, os dois destinos usados.

### GitHub Pages

1. **Settings → Pages** → em "Build and deployment", Source = **Deploy from a branch**,
   Branch = **`main`** / **/(root)**.
2. A cada `push` na `main`, o GitHub roda o "pages-build-deployment" (aba **Actions**).
3. Quando ficar verde, o site fica em `https://SEU-USUARIO.github.io/painel-visitas-oabsp/`.

> No plano gratuito do GitHub, o Pages só funciona em repositório **público**. Como a
> proteção dos dados é feita pelo Supabase (login + RLS), manter o repositório público não
> expõe dados.

### GitLab Pages

1. O arquivo [`.gitlab-ci.yml`](.gitlab-ci.yml) já está no projeto: ele copia os arquivos do
   app para `public/` e publica.
2. O **GitLab Pages precisa estar habilitado na instância** (no servidor da OAB, é uma
   configuração do administrador do GitLab).
3. Com o Pages habilitado e um pipeline verde, a URL aparece em **Configurações → Pages**
   (ou **Implantação → Pages**).

> Se, após habilitar o Pages, a URL não aparecer, rode um **novo pipeline**
> (**Compilação → Pipelines → Novo pipeline**, branch `main`).

---

## Fluxo de trabalho com Git

O projeto tem **dois destinos (remotes)** configurados:

- `github` → repositório pessoal no GitHub (GitHub Pages).
- `origin` → repositório da OAB no GitLab.

Para publicar uma alteração, dentro da pasta do projeto:

```bash
git add .
git commit -m "descrição da alteração"

git push github main --force   # GitHub pessoal (histórico próprio → --force)
git push origin main           # GitLab da OAB
```

Conferir os destinos: `git remote -v`.

> O `--force` no `github` existe porque aquele repositório tem um histórico diferente; ele
> **não** apaga as releases (que ficam vinculadas às tags).

---

## Tarefas de manutenção

### Adicionar um novo usuário

**Authentication → Users → Add user**, com **"Auto Confirm User"** marcado. Nada mais precisa
ser alterado — o RLS e o painel já funcionam para qualquer usuário criado.

### Trocar a senha de um usuário

No **SQL Editor** (troque e-mail e senha):

```sql
update auth.users
set encrypted_password = crypt('NOVA_SENHA', gen_salt('bf'))
where email = 'usuario@exemplo.com';
```

Se `crypt`/`gen_salt` não existirem, use `extensions.crypt(...)` e `extensions.gen_salt('bf')`.

### Atualizar as visitas

Dia a dia: pelo próprio painel (marcar/desmarcar Presidente e Vice-Presidente).

Em massa (ex.: correção de vários registros), pelo **SQL Editor**:

```sql
update public.subsecoes
set presidente = true, vp = false,
    classificacao = 'Visitada', updated_at = now()
where subsecao = 'Nome da Subseção';
```

> Mantenha a `classificacao` coerente com `presidente`/`vp` (ver [Modelo de dados](#modelo-de-dados)).

### Adicionar ou remover uma subseção

A lista é fixa (o RLS não permite insert/delete pela aplicação). Para alterar a lista, faça
direto no Supabase (**Table Editor** ou SQL com credenciais de administrador) e garanta que
exista a imagem de mapa correspondente em `assets/maps/` para a região.

---

## Solução de problemas

| Sintoma                                             | Causa provável / solução                                                                 |
| --------------------------------------------------- | ---------------------------------------------------------------------------------------- |
| O painel abre e volta para o login / sem dados      | Supabase indisponível, sem sessão, ou RLS bloqueando. Faça login novamente.              |
| Login não funciona                                  | Usuário não criado, ou senha incorreta. Verifique em Authentication → Users.             |
| Alterações não salvam                               | Sessão expirada (faça login de novo) ou RLS sem política de update. Reaplique o RLS.     |
| Visitante sem login vê os dados                     | Falta aplicar o `supabase-rls.sql` (ou existem políticas públicas antigas). Reaplique.   |
| GitHub Pages em 404                                 | Deploy ainda rodando (aguarde 1–2 min) ou Pages não configurado em Settings → Pages.     |
| GitLab Pages não aparece / 404                      | Pages não habilitado na instância (falar com o administrador do GitLab) ou pipeline não rodado. |
| Mapa da região não aparece                          | Falta a imagem `assets/maps/regiao_NN.png` correspondente ao número da região.           |

---

## Versionamento

As versões são marcadas com **tags** e publicadas como **Releases** no GitHub.

Criar uma tag e enviá-la:

```bash
git tag -a v2.1.0 -m "Descrição da versão"
git push github v2.1.0
git push origin v2.1.0
```

Depois, no GitHub, crie a Release a partir da tag (**Releases → Draft a new release**).

---

*Documentação mantida junto ao código. Para dúvidas de uso do login, veja
[GUIA-LOGIN-SUPABASE.md](GUIA-LOGIN-SUPABASE.md).*
