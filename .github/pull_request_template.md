# Pull Request

## Tipo

- [ ] `feat`
- [ ] `fix`
- [ ] `docs`
- [ ] `test`
- [ ] `refactor`
- [ ] `chore`
- [ ] `build`
- [ ] `ci`
- [ ] `hotfix`

## Resumo

Descreva a mudanca em uma ou duas frases.

## Risco De Trading

- [ ] Nao toca em trading, credenciais ou chamadas LN Markets.
- [ ] Usa apenas mocks/fakes/testnet.
- [ ] Pode afetar chamada real da LN Markets e foi revisado com cuidado.
- [ ] Nao executa ordens reais em teste automatizado ou CI.

## Validacao

- [ ] `cd app && flutter pub get`
- [ ] `cd app && flutter analyze`
- [ ] `cd app && flutter test`
- [ ] `cd app && flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true` quando a mudanca afetar macOS/build/runtime.

## Higiene Do Repo

- [ ] Nao inclui credenciais reais, `.env`, tokens, chaves ou passphrases.
- [ ] Nao inclui `.app`, `.apk`, `.ipa`, `.dmg`, builds assinados ou binarios locais.
- [ ] Nao inclui logs com dados sensiveis.
- [ ] O titulo do PR segue Conventional Commits.
