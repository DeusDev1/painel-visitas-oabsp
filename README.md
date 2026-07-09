# Painel de Visitas às Subseções — OAB/SP

Painel interativo para acompanhamento das visitas realizadas pelo Presidente e pelo
Vice-Presidente da OAB/SP às Subseções do Estado de São Paulo.

## Tecnologias

- HTML5, CSS3 e JavaScript (sem framework, sem build)
- Supabase (banco de dados e API REST) para persistência dos dados

## Funcionamento

- O acesso exige **login** (Supabase Auth). Sem login, o painel não exibe nem altera dados.
- Após o login, os dados são carregados da tabela `public.subsecoes` no Supabase.
- Caso o Supabase esteja indisponível, o painel abre com os dados locais de `data/dados.js`
  (somente leitura — alterações não são salvas nesse modo).
- KPIs, filtros (todas / não visitadas / visitadas), busca e ordenação (alfabética ou por
  Região Administrativa) são calculados no navegador.
- "Modo TV" para exibição em tela cheia.

## Estrutura do projeto

```text
assets/            imagens (logo e mapas por região)
data/dados.js      dados locais de fallback (regiões + registros)
data/subsecoes.csv fonte tabular dos dados
config.js          configuração do Supabase (URL + chave publishable)
supabase-rls.sql   políticas de segurança (RLS) — leitura/escrita só autenticados
GUIA-LOGIN-SUPABASE.md  passo a passo para criar os 3 usuários e ativar o login
index.html         aplicação (HTML + CSS + JS em arquivo único)
```

## Configuração

A URL e a chave do Supabase ficam em `config.js`. A chave usada é a **publishable/anon**,
apropriada para frontend. Para trocar de projeto/chave, edite apenas `config.js`.

## Segurança (leia antes de publicar)

Por ser um site estático, a chave anon **é sempre visível no navegador** — isso é esperado.
A proteção dos dados **não** vem de esconder a chave, e sim das políticas de acesso no
Supabase (Row Level Security).

O painel usa **login (Supabase Auth)** e o modelo é privado: só os usuários cadastrados
leem e escrevem. Para ativar:

1. Seguir o **`GUIA-LOGIN-SUPABASE.md`** para criar os usuários e desligar o cadastro público.
2. Aplicar o script **`supabase-rls.sql`**: leitura e escrita **apenas para autenticados**.
3. Conferir em `config.js` que a chave é a **publishable/anon** (nunca a `service_role`).

## Autor

Gabriel Antunes — desenvolvido para uso institucional da OAB/SP com apoio de ferramentas
de inteligência artificial.
