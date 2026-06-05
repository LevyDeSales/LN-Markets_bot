# spec-id: parity-trading-engine
# origem: _reversa_sdd/domain.md regras 4-17
Funcionalidade: Motor de trading

  @paridade @critico
  Cenario: Start idempotente
    Dado o bot ja esta running
    Quando start for chamado novamente
    Entao nenhuma segunda sessao deve ser criada

  @paridade @critico
  Cenario: Inversao fecha antes de abrir
    Dado existe uma posicao long local e remota
    Quando surge sinal short efetivo
    Entao a posicao long deve ser fechada antes de qualquer abertura short

  @paridade @critico
  Cenario: Long only fecha sem reabrir short
    Dado longOnly esta ativo
    E existe uma posicao long
    Quando surge sinal short
    Entao o bot deve fechar a long
    E nao deve abrir short
