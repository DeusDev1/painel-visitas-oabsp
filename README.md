# Painel de Visitas às Subseções — OAB/SP

Painel interativo para acompanhamento das visitas realizadas pelo **Presidente** e pelo
**Vice-Presidente** da OAB/SP às **258 Subseções** do Estado de São Paulo, organizadas nas
21 Regiões Administrativas.

O painel mostra, em tempo real, quantas subseções já foram visitadas (como Presidente e como
Vice-Presidente), quais estão pendentes e a cobertura geral, com filtros, busca, visão por
região e um modo de apresentação em tela cheia ("Modo TV").

> **Acesso restrito:** o painel exige login. Sem autenticação, nenhum dado é exibido ou alterado.

---

## Sumário

- [Funcionalidades](#funcionalidades)
- [Tecnologias](#tecnologias)
- [Estrutura do projeto](#estrutura-do-projeto)
- [Como funciona](#como-funciona)
- [Configuração](#configuração)
- [Segurança](#segurança)
- [Publicação (deploy)](#publicação-deploy)
- [Documentação adicional](#documentação-adicional)
- [Autor](#autor)

---

## Funcionalidades

- **Indicadores (KPIs):** total de subseções, visitadas como Presidente, visitadas como
  Vice-Presidente, não visitadas e cobertura (%).
- **Filtros:** todas, não visitadas e visitadas.
- **Busca** por subseção, com botão para limpar o campo.
- **Ordenação:** alfabética (padrão) ou separada por Região Administrativa.
- **Visão por região:** ao selecionar uma região, o painel mostra o mapa ampliado e os
  números daquela região.
- **Edição das visitas:** marcar/desmarcar visita como Presidente e como Vice-Presidente
  (salvo diretamente no Supabase).
- **Exportar CSV** dos dados.
- **Modo TV:** exibição em tela cheia para apresentações, com proporção mapa × lista ajustável.
- **Responsivo:** layout adaptado para desktop e celular.

---

## Tecnologias

- **HTML5, CSS3 e JavaScript** puro (sem framework e sem etapa de build).
- **[Supabase](https://supabase.com/)** — banco de dados PostgreSQL, autenticação (Auth) e
  segurança por linha (Row Level Security).
- **[@supabase/supabase-js](https://github.com/supabase/supabase-js)** carregado via CDN.

Toda a aplicação vive em um único arquivo `index.html` (HTML + CSS + JS), o que facilita a
hospedagem como site estático.

---

## Estrutura do projeto

```text
index.html              Aplicação completa (HTML + CSS + JavaScript)
config.js               Configuração do Supabase (URL + chave publishable/anon)
supabase-rls.sql        Políticas de segurança (RLS) para aplicar no Supabase
GUIA-LOGIN-SUPABASE.md  Passo a passo para criar usuários e ativar o login
DOCUMENTACAO.md         Documentação técnica e de manutenção
RELATORIO-REVISAO.md    Relatório da revisão de código
.gitlab-ci.yml          Publicação automática no GitLab Pages
data/
  dados.js              Placeholder vazio (os dados reais ficam só no Supabase)
  subsecoes.csv         Apenas o cabeçalho (sem dados reais)
assets/
  OAB-SP-logo-preto.png Logotipo
  maps/                 Mapa geral e mapas por região (regiao_01.png … regiao_21.png)
```

---

## Como funciona

1. Ao abrir, o painel exibe a **tela de login** (e-mail e senha).
2. Após autenticar, os dados são carregados da tabela `public.subsecoes` no **Supabase**,
   que é a **única fonte** dos dados reais. A lista de regiões é montada a partir desses
   registros.
3. Os indicadores, filtros, busca e ordenação são calculados no navegador.
4. Ao marcar/desmarcar uma visita, a alteração é gravada no Supabase (com o token do usuário
   logado). O RLS garante, no servidor, que só usuários autenticados podem gravar.

> Não há dados reais em arquivos estáticos. `data/dados.js` e `data/subsecoes.csv` ficam
> vazios de propósito — se tivessem os dados, seriam acessíveis publicamente pelo site.

---

## Configuração

A URL e a chave do Supabase ficam em **`config.js`**:

```js
window.APP_CONFIG = {
  SUPABASE_URL: "https://SEU-PROJETO.supabase.co",   // URL base (sem /rest/v1)
  SUPABASE_ANON_KEY: "sb_publishable_..."            // chave publishable/anon
};
```

Para apontar para outro projeto Supabase, edite apenas o `config.js`. A chave usada é a
**publishable/anon**, própria para frontend.

---

## Segurança

Por ser um site estático, a chave anon **é sempre visível no navegador** — isso é esperado e
não é uma falha. A proteção dos dados **não** vem de esconder a chave, e sim das políticas de
acesso no Supabase (**Row Level Security**).

O modelo é **privado**: só os usuários cadastrados leem e escrevem. Antes de disponibilizar:

1. Siga o **[`GUIA-LOGIN-SUPABASE.md`](GUIA-LOGIN-SUPABASE.md)** para criar os usuários e
   **desligar o cadastro público**.
2. Aplique o script **[`supabase-rls.sql`](supabase-rls.sql)**: leitura e atualização
   **apenas para usuários autenticados** (sem inserção/remoção).
3. Confirme em `config.js` que a chave é a **publishable/anon** — **nunca** a `service_role`
   (que ignora o RLS e daria acesso total).

Mais detalhes na [DOCUMENTACAO.md](DOCUMENTACAO.md#segurança).

---

## Publicação (deploy)

O painel é um site estático e pode ser hospedado em qualquer servidor web. Os dois destinos
usados neste projeto:

- **GitHub Pages** — publica a partir da branch `main` (raiz do repositório).
- **GitLab Pages** — publica via `.gitlab-ci.yml` (requer o GitLab Pages habilitado na
  instância).

O passo a passo completo de cada um está na
[DOCUMENTACAO.md](DOCUMENTACAO.md#publicação-deploy).

---

## Documentação adicional

- **[DOCUMENTACAO.md](DOCUMENTACAO.md)** — documentação técnica e de manutenção (arquitetura,
  modelo de dados, Supabase, deploy, tarefas de manutenção e solução de problemas).
- **[GUIA-LOGIN-SUPABASE.md](GUIA-LOGIN-SUPABASE.md)** — criar usuários e ativar o login.
- **[supabase-rls.sql](supabase-rls.sql)** — políticas de segurança do banco.
- **[RELATORIO-REVISAO.md](RELATORIO-REVISAO.md)** — relatório da revisão de código.

---

## Autor

**Gabriel Antunes** — desenvolvido para uso institucional da OAB/SP com apoio de ferramentas
de inteligência artificial.
