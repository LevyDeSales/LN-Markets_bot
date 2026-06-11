# macOS Release

Este projeto publica builds macOS pela aba
[Releases](../../releases/latest). O app canônico fica em `app/`.

## Fluxo

1. Trabalhe em branch curta a partir de `dev`.
2. Abra PR para `dev` e aguarde `flutter analyze` e `flutter test`.
3. Promova `dev -> staging` por PR.
4. Promova `staging -> main` por PR.
5. Crie uma tag `vX.Y.Z` apontando para o commit atual de `main`.

O workflow `macOS Release` valida que a tag aponta para `origin/main`, confere
se `vX.Y.Z` bate com `version: X.Y.Z+N` em `app/pubspec.yaml`, roda analyze/test
e gera artefatos macOS arm64.

## Artefatos

- `LN-Markets-Bot-macOS-arm64-vX.Y.Z.zip`
- `LN-Markets-Bot-macOS-arm64-vX.Y.Z.dmg`
- `SHA256SUMS.txt`

Os artefatos iniciais são unsigned. Eles servem para instalar e validar no Mac
do Levy, mas ainda não substituem uma distribuição notarizada com Developer ID.

## Instalação

1. Baixe o `.dmg` ou `.zip` do release.
2. Se usar `.dmg`, abra o arquivo e copie `lnmarkets_bot.app` para
   `Applications`.
3. Se o macOS bloquear por assinatura, use Control-click > Open ou libere em
   System Settings > Privacy & Security.
4. Valide primeiro em testnet ou com baixo risco operacional.

## Segurança

- CI nunca recebe credenciais LN Markets.
- CI não executa o app contra mainnet.
- Testes automatizados usam mocks/fakes/testnet.
- Builds `.app`, `.dmg`, `.zip`, `.apk`, `.ipa`, logs sensíveis e `.env` não
  devem ser commitados.

## Comandos De Release

```bash
git fetch origin
git switch main
git pull --ff-only
git tag v3.3.1
git push origin v3.3.1
```

Se precisar corrigir um release, prefira novo patch version (`v3.3.2`) em vez
de sobrescrever tag publicada.
