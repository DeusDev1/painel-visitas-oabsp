-- =============================================================================
-- Row Level Security (RLS) para a tabela public.subsecoes
-- Modelo: PAINEL PRIVADO com privilégio mínimo.
--   * Anônimo (sem login): NÃO vê e NÃO altera nada.
--   * Usuário autenticado: pode LER e ATUALIZAR (marcar/desmarcar visitas).
--   * Ninguém insere nem apaga subseções pelo painel (a lista é fixa).
-- Rode no SQL Editor do Supabase (Dashboard > SQL Editor).
-- =============================================================================

-- 1) Habilita RLS (bloqueia tudo por padrão até existirem políticas).
alter table public.subsecoes enable row level security;

-- 2) Remove políticas antigas (evita duplicidade e revoga insert/delete anteriores).
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

-- 4) Atualização apenas para usuários autenticados (marcar/desmarcar visitas).
create policy "escrita_autenticada_update"
  on public.subsecoes
  for update
  to authenticated
  using (true)
  with check (true);

-- Observação: NÃO criamos políticas de INSERT nem DELETE de propósito.
-- Com RLS ativo e sem essas políticas, ninguém consegue inserir ou apagar
-- subseções pela API — o painel só precisa atualizar registros existentes.
-- =============================================================================
