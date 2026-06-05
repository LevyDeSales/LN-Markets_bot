# ⚡ LN Markets Bot — Mac ARM / Flutter

> Bot de trading automatizado para Bitcoin Futures na [LN Markets](https://lnmarkets.com), migrado para **Flutter macOS ARM** com modo mock-safe para validação local.

<p align="center">
  <img src="assets/icon/icon.png" width="120" alt="LN Markets Bot"/>
</p>

## ✅ Estado Atual

- App Flutter canônico: `app/`
- Modo seguro de teste: `LNMBOT_MOCK_MODE=true`
- Testes automatizados usam mocks/fakes e não usam credenciais reais.
- O padrão de rede para novas configurações é `testnet`.

## 📱 Download

Baixe o APK diretamente na aba [Releases](../../releases/latest).

---

## 🤖 Estratégia — Trend Tabajara 3.0

Baseada na estratégia criada por **André Machado**, utiliza cruzamento de médias exponenciais:

| EMA | Período |
|-----|---------|
| EMA Rápida | 9 |
| EMA Lenta  | 21 |
| EMA Filtro | 50 |

**Lógica:**
- **LONG** → EMA9 cruza acima da EMA21 **e** preço está acima da EMA50
- **SHORT** → EMA9 cruza abaixo da EMA21 **e** preço está abaixo da EMA50
- Usa a penúltima vela para evitar ruído da vela ainda aberta

---

## ✨ Funcionalidades

- 🔐 Credenciais de API armazenadas localmente com segurança
- 📊 Dashboard com status da posição (LONG/SHORT/parado)
- 📈 Timeframes: 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 12h, 1d
- 🎯 Take Profit e Stop Loss configuráveis (%)
- 💰 P&L em tempo real (realizado + não-realizado)
- 📋 Log em tempo real com níveis (INFO / WARN / ERROR)
- 🌐 Idiomas: Português 🇧🇷 | English 🇺🇸 | Français 🇫🇷

---

## ⚙️ Configuração

1. Abra o app e vá em **Configurações**
2. Insira suas chaves de API da LN Markets:
   - **Key**, **Secret** e **Passphrase**
3. Configure os parâmetros de trading (alavancagem, quantidade, timeframe, TP/SL)
4. Volte ao **Dashboard** e pressione ▶ para iniciar

> Ainda não tem conta? [Assista ao tutorial →](https://youtu.be/Lo1VRofjogk?si=HdKO8aYM5CnWhHyy)

---

## 🧪 Validação Local Sem Trading Real

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

Para abrir o app no macOS usando apenas mocks:

```bash
cd app
flutter run -d macos --dart-define=LNMBOT_MOCK_MODE=true
```

Esse modo injeta clientes fake, não inicializa chamadas remotas de mercado no shell de smoke e não usa credenciais reais.

## 🏗️ Build macOS Debug

```bash
# Pré-requisitos: Flutter SDK, CocoaPods e Xcode completo com licença aceita
cd app
flutter build macos --debug
```

Se o Xcode estiver em um volume externo, use:

```bash
cd app
DEVELOPER_DIR=/Volumes/SSD-500GB-1/Applications/Xcode.app/Contents/Developer flutter build macos --debug
```

Antes do build, talvez seja necessário rodar com senha:

```bash
sudo xcodebuild -license accept
sudo xcodebuild -runFirstLaunch
```

## 🔧 Setup Seguro

O script `setup.sh` agora opera diretamente sobre `app/` e não copia mais fontes legadas da raiz para dentro do app.

```bash
./setup.sh
```

Para incluir build macOS debug no script:

```bash
BUILD_MACOS_DEBUG=1 ./setup.sh
```

## ⚠️ Aviso De Risco

> **Este software é fornecido apenas para fins educacionais.**
> Trading de Bitcoin Futures envolve risco elevado de perda de capital.
> Nunca invista mais do que pode perder. O autor não se responsabiliza por perdas financeiras.

---

## 🙏 Agradecimentos

| Nome | Contribuição |
|------|-------------|
| [Fabio Akita](https://twitter.com/AkitaOnRails) | Dev lendário brasileiro |
| [BitDov](https://twitter.com/BitDov) | Educação Bitcoin de qualidade |
| [Daniel Fraga](https://twitter.com/DanielFragaBTC) | Liberdade e filosofia Bitcoin |
| [Renato Amoedo](https://twitter.com/RenatoAmoedo) | Empreendedorismo e inovação |
| [Allan Schramm](https://twitter.com/AllanSchramm) | Comunidade e análise técnica |
| [Marcell Pechmann](https://twitter.com/MarcellPechmann) | Educação financeira e Bitcoin |

---

## 📄 Licença

MIT — veja [LICENSE](LICENSE) para detalhes.
