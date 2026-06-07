# Contributing

Este repositório usa um fluxo simples, com histórico limpo e validação
automática antes de promover código. O app canônico fica em `app/`.

## Branches

- `main` é produção/release. Não faça push direto.
- `dev` é integração. Não faça push direto.
- Todo trabalho entra por PR a partir de uma branch curta.
- Use `dev` como base para trabalho comum.
- Use `main` como base apenas para `hotfix/*`.

Nomes aceitos:

- `feat/<descricao-curta>`
- `fix/<descricao-curta>`
- `docs/<descricao-curta>`
- `test/<descricao-curta>`
- `refactor/<descricao-curta>`
- `chore/<descricao-curta>`
- `hotfix/<descricao-curta>`

Fluxo padrão:

```bash
git fetch origin
git switch dev
git pull --ff-only
git switch -c feat/minha-mudanca
```

Antes de abrir PR:

```bash
git fetch origin
git rebase origin/dev
git push -u origin feat/minha-mudanca
```

Se precisar reescrever a sua branch antes do PR, use apenas:

```bash
git push --force-with-lease
```

Nunca force-push em `main` ou `dev`.

## Commits

Use Conventional Commits:

- `feat: adiciona nova funcionalidade`
- `fix: corrige comportamento quebrado`
- `docs: atualiza documentacao`
- `test: adiciona ou ajusta testes`
- `refactor: reorganiza codigo sem mudar comportamento`
- `chore: altera manutencao do projeto`
- `build: ajusta build ou dependencias`
- `ci: ajusta automacoes`

Cada commit deve ser atomico: uma mudanca coerente, facil de revisar e
reverter. Em PRs, o merge padrao e squash merge, entao o titulo do PR tambem
deve seguir Conventional Commits.

## Pull Requests

- PRs de feature/fix/docs/test/refactor/chore entram em `dev`.
- PRs de release entram de `dev` para `main`.
- `hotfix/*` pode entrar em `main` quando corrigir producao; depois, replique
  a correcao em `dev`.
- Merge padrao: squash merge.
- Antes de mergear, os checks obrigatorios precisam estar verdes.

Comandos locais recomendados:

```bash
cd app
flutter pub get
flutter analyze
flutter test
```

Para validar build macOS sem trading real:

```bash
cd app
flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true
```

## Regras De Seguranca

Nao commite:

- credenciais reais da LN Markets;
- arquivos `.env` ou variantes;
- chaves, secrets, passphrases ou tokens;
- builds assinados, `.app`, `.apk`, `.ipa`, `.dmg` ou binarios locais;
- testes que executem ordens reais;
- logs com dados sensiveis.

Testes automatizados devem usar mocks, fakes ou testnet. Qualquer validacao
mainnet precisa ser manual, explicita e fora da CI.

## Criacao Inicial Do `dev`

Se `dev` ainda nao existir no remoto:

```bash
git fetch origin
git switch main
git pull --ff-only
git switch -c dev
git push -u origin dev
```

## Protecao De Branches

Configure o repositório para permitir squash merge e bloquear pushes diretos:

```bash
gh repo edit LevyDeSales/LN-Markets_bot \
  --enable-squash-merge=true \
  --enable-merge-commit=false \
  --enable-rebase-merge=false
```

Depois que o workflow `CI` rodar pelo menos uma vez, proteja `main` e `dev`:

```bash
for branch in main dev; do
  gh api --method PUT "repos/LevyDeSales/LN-Markets_bot/branches/$branch/protection" \
    --input - <<'JSON'
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Flutter analyze and tests"]
  },
  "enforce_admins": false,
  "required_pull_request_reviews": {
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": false,
    "required_approving_review_count": 0
  },
  "restrictions": null,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
JSON
done
```

Esses comandos exigem permissao admin no GitHub. Se a API rejeitar algum campo,
aplique a mesma politica pela interface do GitHub em Settings > Branches.
