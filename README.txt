Painel Interativo de Visitas às Subseções - OAB/SP

Versão evoluída no estilo de mapa interativo:
- clique diretamente nas áreas do mapa geral;
- hover com resumo da região;
- seleção também pela lista lateral;
- mapa ampliado real por região;
- filtros: todas, não visitadas, visitadas;
- ordenação alfabética ou por Região Administrativa;
- exportação/importação CSV;
- modo TV.

Observação: as áreas clicáveis são polígonos transparentes aproximados sobre o mapa real da OAB/SP. Se alguma área precisar de ajuste fino, basta reposicionar o polígono correspondente no index.html.


Ajuste aplicado: removido totalmente o bloco 'Subseções não visitadas em destaque'.


Ajustes aplicados: logo OAB/SP no cabeçalho; removida mensagem inferior; removido texto sobre o mapa; redimensionamento do mapa para evitar corte das regiões 20 e 21.


Ajuste aplicado: removida mensagem inferior e incluído botão ← Voltar ao lado dos filtros, visível apenas dentro de uma região.


Ajuste aplicado: painel passou a contabilizar também visitas como Vice-Presidente e visitas em ambas as gestões.


Ajuste aplicado: a subseção passa a ser considerada Visitada quando houver visita como Presidente OU como VP. Quando houver as duas, aparece como VP + Pres.


Integração Supabase:
- O painel agora carrega os dados da tabela public.subsecoes.
- Alterações em VP/Presidente são salvas no Supabase via REST API.
- A chave utilizada é a publishable key, própria para uso no frontend.
- A importação CSV pelo painel foi desabilitada; atualizações em massa devem ser feitas pelo Supabase.


v1.1.1: textos dos indicadores ajustados; card 'Não visitadas' clicável; alerta mobile para pendências dentro do bloco Estado de São Paulo.
