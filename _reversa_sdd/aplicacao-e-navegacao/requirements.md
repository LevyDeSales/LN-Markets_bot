# Requirements — Aplicacao e Navegacao

## Objetivo

🟢 **CONFIRMADO** Inicializar o app Flutter, carregar configuracoes locais, aplicar idioma salvo, criar servicos compartilhados e controlar a transicao Splash -> Home.

## Requisitos Funcionais

| ID | Prioridade | Requisito | Evidencia | Confianca |
|---|---|---|---|---|
| RF-APP-01 | Must | O app deve chamar `WidgetsFlutterBinding.ensureInitialized()` antes de carregar servicos async. | `app/lib/main.dart:14-22` | 🟢 |
| RF-APP-02 | Must | O app deve fixar orientacao portrait. | `app/lib/main.dart:15-16` | 🟢 |
| RF-APP-03 | Must | O app deve inicializar `ForegroundService`, `SettingsService`, `LogService`, `TraderService` e `RemoteConfigService`. | `app/lib/main.dart:18-29` | 🟢 |
| RF-APP-04 | Must | O idioma ativo deve vir de `settings.language`. | `app/lib/main.dart:21-23` | 🟢 |
| RF-APP-05 | Must | A tela inicial deve exibir Splash ate `onDone`, depois `HomeScreen`. | `app/lib/main.dart:54-71` | 🟢 |
| RF-APP-06 | Should | Se faltarem credenciais, HomeScreen deve abrir a aba Settings. | `app/lib/screens/home_screen.dart:37-43` | 🟢 |
| RF-APP-07 | Should | O layout deve alternar entre mobile e desktop no breakpoint de 600px. | `app/lib/screens/home_screen.dart:34-67` | 🟢 |
| RF-APP-08 | Should | A navegacao deve conter Dashboard, Settings, Logs, Sponsors e About. | `app/lib/screens/home_screen.dart:48-58` | 🟢 |

## Requisitos Nao Funcionais

| ID | Requisito | Evidencia | Confianca |
|---|---|---|---|
| RNF-APP-01 | Startup deve tolerar config remota lenta porque `RemoteConfigService.init()` nao e aguardado. | `app/lib/main.dart:28-29` | 🟢 |
| RNF-APP-02 | A UI deve reagir a tamanho de tela sem trocar rota. | `app/lib/screens/home_screen.dart:60-67` | 🟢 |

## Criterios de Aceitacao

### CA-APP-01 — Inicializacao normal

Dado que existem configuracoes locais carregaveis  
Quando o usuario abre o app  
Entao o app inicializa servicos, aplica idioma salvo e mostra Splash antes da Home.

### CA-APP-02 — Usuario sem credenciais

Dado que `settings.hasCredentials` e falso  
Quando HomeScreen inicializa  
Entao a aba ativa deve ser Settings.

### CA-APP-03 — Layout responsivo

Dado uma largura menor que 600px  
Quando HomeScreen renderiza  
Entao deve usar bottom navigation.

Dado uma largura maior ou igual a 600px  
Quando HomeScreen renderiza  
Entao deve usar sidebar desktop.
