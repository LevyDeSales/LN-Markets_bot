# spec-id: parity-indicators
# origem: _reversa_sdd/domain.md regras 8-11
Funcionalidade: Indicadores Trend Tabajara 3.0

  @paridade @critico
  Cenario: Usa penultimo candle fechado
    Dado uma serie de candles suficiente para EMA sinal
    Quando o indicador calcula a tendencia
    Entao o preco usado deve ser o penultimo candle

  @paridade @critico
  Cenario: Long exige filtros positivos
    Dado EMA rapida acima da EMA lenta
    E preco acima da EMA sinal
    Quando BB ou MACD falhar
    Entao o motor nao deve abrir long
