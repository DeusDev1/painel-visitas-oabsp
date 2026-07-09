// Configuração do painel — carregada antes do restante do app.
// A chave é a "publishable"/anon do Supabase (uso em frontend, pública por natureza).
// A segurança dos dados é garantida por login (Supabase Auth) + Row Level Security
// (ver supabase-rls.sql). Sem login, o painel não exibe nem altera nada.
window.APP_CONFIG = {
  // URL base do projeto (SEM /rest/v1 no final)
  SUPABASE_URL: "https://vreylwrxmczdwueoznti.supabase.co",
  SUPABASE_ANON_KEY: "sb_publishable_C01sEooTDzpcd1gQkmZPsA_LvmGCfMv"
};
