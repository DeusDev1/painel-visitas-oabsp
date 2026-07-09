-- =============================================================================
-- Row Level Security (RLS) para a tabela public.subsecoes
-- Modelo: PAINEL PRIVADO — só usuários logados (Supabase Auth) leem e escrevem.
-- =============================================================================
-- Contexto: o painel é uma página estática que usa a chave "publishable"/anon do
-- Supabase. Essa chave é SEMPRE visível no navegador — a proteção dos dados vem
-- destas políticas + do login.
--
-- Objetivo:
--   * Anônimo (sem login): NÃO vê e NÃO altera nada.
--   * Usuário autenticado (os 3 logins): leitura e escrita completas.
--
-- Rode este script no SQL Editor do Supabase (Dashboard > SQL Editor).
-- =============================================================================

-- 1) Habilita RLS (bloqueia tudo por padrão até existirem políticas).
alter table public.subsecoes enable row level security;

-- 2) Remove políticas antigas (evita duplicidade ao reaplicar).
drop policy if exists "leitura_publica_subsecoes"    on public.subsecoes;
drop policy if exists "leitura_autenticada"          on public.subsecoes;
drop policy if exists "escrita_autenticada_update"   on public.subsecoes;
drop policy if exists "escrita_autenticada_insert"   on public.subsecoes;
drop policy if exists "escrita_autenticada_delete"   on public.subsecoes;

-- 3) Leitura apenas para usuários autenticados.
create policy "leitura_autenticada"
  on public.subsecoes
  for select
  to authenticated
  using (true);

-- 4) Escrita apenas para usuários autenticados.
create policy "escrita_autenticada_update"
  on public.subsecoes
  for update
  to authenticated
  using (true)
  with check (true);

create policy "escrita_autenticada_insert"
  on public.subsecoes
  for insert
  to authenticated
  with check (true);

create policy "escrita_autenticada_delete"
  on public.subsecoes
  for delete
  to authenticated
  using (true);

-- =============================================================================
-- Depois de aplicar: quem não estiver logado recebe uma lista vazia da API e o
-- painel exibirá a tela de login. Os 3 usuários criados no Auth terão acesso
-- total (ler, marcar visitas e exportar CSV).
-- =============================================================================
