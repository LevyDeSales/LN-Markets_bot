# spec-id: parity-storage
# origem: _reversa_sdd/domain.md lacuna 1
Funcionalidade: Persistencia local

  @paridade @seguranca
  Cenario: Credenciais migram para storage seguro
    Dado existem credenciais legadas em SharedPreferences
    E o secure storage esta vazio
    Quando o repositorio novo carrega settings
    Entao as credenciais devem ser copiadas para secure storage
    E preferencias nao sensiveis devem permanecer em SharedPreferences

  @paridade @seguranca
  Cenario: Migracao idempotente
    Dado a migracao ja executou uma vez
    Quando a migracao executar novamente
    Entao os valores nao devem ser duplicados nem corrompidos
