# Professional Git Workflow And LN Markets TP/SL Fix Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Lock the repository workflow around `dev -> main`, then fix LN Markets isolated futures TP/SL updates using the documented v3 API without running mainnet automation.

**Architecture:** First apply GitHub repository settings and branch protection with `gh`, keeping `main` and `dev` protected. Then create an isolated worktree from `origin/dev`, commit this plan into the fix branch, write failing HTTP-shape tests for TP/SL, update `LNMarketsAPI`, and promote the fix through PRs. Automated validation stays mock-safe; any real/mainnet check is manual only.

**Tech Stack:** GitHub CLI, Git worktrees, GitHub Actions, Flutter 3.44.1, Dart 3.12.1, `package:http`, Flutter tests, macOS/Xcode debug build without signing.

---

## Current State

Use the non-iCloud repo:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot
```

Expected baseline before execution:

```text
main = origin/main = dev = origin/dev
HEAD = 5b3feb5 ci: disable macos signing in debug workflow
Latest GitHub Actions for main/dev = success
Only local pending file = docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md
```

## File Structure

- Modify through GitHub API only: repository merge settings and branch protection.
- Commit into fix branch: `docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md`.
- Create: `app/test/services/lnmarkets_api_test.dart`.
- Modify: `app/lib/services/lnmarkets_api.dart`.
- Optional create after validation: `docs/superpowers/handoff/2026-06-07-lnmarkets-isolated-tpsl-fix.md`.

Do not modify margin defaults or settings validation for this fix. Live logs showed the API rejects `quantity < 1 USD`; it does not reject every margin below `1000 sats`.

---

### Task 1: Apply GitHub Merge Settings And Branch Protection

**Files:**
- Modify: none

- [ ] **Step 1: Confirm GitHub CLI access**

Run:

```bash
gh auth status
```

Expected:

```text
Logged in to github.com
```

If `gh auth status` reports missing authentication, stop and run `gh auth login` manually.

- [ ] **Step 2: Apply merge settings**

Run:

```bash
gh repo edit LevyDeSales/LN-Markets_bot \
  --enable-squash-merge=true \
  --enable-merge-commit=false \
  --enable-rebase-merge=false \
  --delete-branch-on-merge=true
```

Expected: command exits with code `0`.

- [ ] **Step 3: Verify merge settings**

Run:

```bash
gh repo view LevyDeSales/LN-Markets_bot \
  --json mergeCommitAllowed,rebaseMergeAllowed,squashMergeAllowed,deleteBranchOnMerge \
  | jq
```

Expected:

```json
{
  "deleteBranchOnMerge": true,
  "mergeCommitAllowed": false,
  "rebaseMergeAllowed": false,
  "squashMergeAllowed": true
}
```

- [ ] **Step 4: Protect `main` and `dev`**

Run:

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

Expected: both API calls exit with code `0`.

- [ ] **Step 5: Verify branch protection**

Run:

```bash
for branch in main dev; do
  echo "BRANCH=$branch"
  gh api "repos/LevyDeSales/LN-Markets_bot/branches/$branch/protection" \
    | jq '{
        required_status_checks: .required_status_checks.contexts,
        required_pull_request_reviews: .required_pull_request_reviews.required_approving_review_count,
        allow_force_pushes: .allow_force_pushes.enabled,
        allow_deletions: .allow_deletions.enabled,
        required_conversation_resolution: .required_conversation_resolution.enabled
      }'
done
```

Expected for both branches:

```json
{
  "required_status_checks": [
    "Flutter analyze and tests"
  ],
  "required_pull_request_reviews": 0,
  "allow_force_pushes": false,
  "allow_deletions": false,
  "required_conversation_resolution": true
}
```

- [ ] **Step 6: Commit**

No commit is required for Task 1 because it only changes GitHub repository settings.

---

### Task 2: Create The Fix Worktree From `dev` And Move This Plan Into It

**Files:**
- Commit in fix branch: `docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md`

- [ ] **Step 1: Confirm the main checkout has no unrelated changes**

Run:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot
git status --short --branch
```

Expected:

```text
## main...origin/main
?? docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md
```

If any other changed path appears, stop and inspect it before continuing.

- [ ] **Step 2: Create the isolated worktree from `origin/dev`**

Run:

```bash
MAIN=/Users/levy/Developer/LNbot/LN-Markets_bot
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3

cd "$MAIN"
git fetch origin

if git show-ref --verify --quiet refs/heads/fix/lnmarkets-isolated-tpsl-v3; then
  echo "Branch fix/lnmarkets-isolated-tpsl-v3 already exists. Stop and inspect."
  exit 1
fi

if [ -e "$WT" ]; then
  echo "Worktree path already exists: $WT. Stop and inspect."
  exit 1
fi

mkdir -p /Users/levy/.config/superpowers/worktrees/LN-Markets_bot
git worktree add "$WT" -b fix/lnmarkets-isolated-tpsl-v3 origin/dev
```

Expected:

```text
Preparing worktree (new branch 'fix/lnmarkets-isolated-tpsl-v3')
HEAD is now at 5b3feb5 ci: disable macos signing in debug workflow
```

- [ ] **Step 3: Copy this plan into the fix worktree**

Run:

```bash
MAIN=/Users/levy/Developer/LNbot/LN-Markets_bot
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
PLAN=docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md

mkdir -p "$WT/docs/superpowers/plans"
cp "$MAIN/$PLAN" "$WT/$PLAN"
cmp "$MAIN/$PLAN" "$WT/$PLAN"
```

Expected: `cmp` exits with code `0`.

- [ ] **Step 4: Commit the plan in the fix branch**

Run:

```bash
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
PLAN=docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md

cd "$WT"
git add "$PLAN"
git commit -m "docs: add isolated tpsl fix plan"
```

Expected:

```text
[fix/lnmarkets-isolated-tpsl-v3 <hash>] docs: add isolated tpsl fix plan
```

- [ ] **Step 5: Resolve the local pending plan from `main`**

Run:

```bash
MAIN=/Users/levy/Developer/LNbot/LN-Markets_bot
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
PLAN=docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md

cmp "$MAIN/$PLAN" "$WT/$PLAN"
rm "$MAIN/$PLAN"
git -C "$MAIN" status --short --branch
```

Expected:

```text
## main...origin/main
```

---

### Task 3: Add Failing Tests For LN Markets TP/SL Request Shape

**Files:**
- Create: `app/test/services/lnmarkets_api_test.dart`

- [ ] **Step 1: Create the test file**

Create `app/test/services/lnmarkets_api_test.dart`:

```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:lnmarkets_bot/services/lnmarkets_api.dart';
import 'package:lnmarkets_bot/services/settings_service.dart';
import 'package:lnmarkets_bot/src/settings/credentials_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('setStopLoss uses documented isolated futures PUT endpoint', () async {
    final settings = await _buildSettings();
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.setStopLoss('trade-id', 61000.25);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'PUT');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade/stoploss',
    );
    expect(jsonDecode(request.body), {
      'id': 'trade-id',
      'value': 61000.25,
    });
    expect(request.body, isNot(contains('stoploss')));
    expect(request.headers['Content-Type'], contains('application/json'));
    expect(request.headers['LNM-ACCESS-KEY'], 'key');
    expect(request.headers['LNM-ACCESS-PASSPHRASE'], 'passphrase');
    expect(request.headers['LNM-ACCESS-SIGNATURE'], isNotEmpty);
    expect(request.headers['LNM-ACCESS-TIMESTAMP'], isNotEmpty);
  });

  test('setTakeProfit uses documented isolated futures PUT endpoint', () async {
    final settings = await _buildSettings();
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.setTakeProfit('trade-id', 63123.86);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'PUT');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade/takeprofit',
    );
    expect(jsonDecode(request.body), {
      'id': 'trade-id',
      'value': 63123.86,
    });
    expect(request.body, isNot(contains('takeprofit')));
    expect(request.headers['Content-Type'], contains('application/json'));
    expect(request.headers['LNM-ACCESS-KEY'], 'key');
    expect(request.headers['LNM-ACCESS-PASSPHRASE'], 'passphrase');
    expect(request.headers['LNM-ACCESS-SIGNATURE'], isNotEmpty);
    expect(request.headers['LNM-ACCESS-TIMESTAMP'], isNotEmpty);
  });

  test('openPosition forwards sub-1000 sat margin without local clamp',
      () async {
    final settings = await _buildSettings();
    settings.leverage = 3;
    settings.marginSats = 50000;
    final client = RecordingClient();
    final api = LNMarketsAPI(settings, client: client);

    await api.openPosition('long', marginSats: 500);

    expect(client.requests, hasLength(1));
    final request = client.requests.single;
    expect(request.method, 'POST');
    expect(
      request.url.toString(),
      'https://api.lnmarkets.com/v3/futures/isolated/trade',
    );
    expect(jsonDecode(request.body), {
      'type': 'market',
      'side': 'long',
      'margin': 500,
      'leverage': 3,
    });
  });
}

Future<SettingsService> _buildSettings() async {
  SharedPreferences.setMockInitialValues({'network': 'mainnet'});
  final settings =
      SettingsService(credentialsStore: MemoryCredentialsStore());
  await settings.load();
  settings.apiKey = 'key';
  settings.apiSecret = 'secret';
  settings.apiPassphrase = 'passphrase';
  settings.network = 'mainnet';
  return settings;
}

class RecordingClient extends http.BaseClient {
  final List<http.Request> requests = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final recorded = http.Request(request.method, request.url);
    recorded.headers.addAll(request.headers);
    if (request is http.Request) {
      recorded.body = request.body;
    }
    requests.add(recorded);

    return http.StreamedResponse(
      Stream<List<int>>.value(utf8.encode('{}')),
      200,
      headers: {'Content-Type': 'application/json'},
    );
  }
}
```

- [ ] **Step 2: Run the new test and verify it fails**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3/app
flutter test test/services/lnmarkets_api_test.dart
```

Expected before implementation:

```text
Error: No named parameter with the name 'client'.
```

If the constructor has already been changed, the expected failure is:

```text
Expected: 'PUT'
Actual: 'POST'
```

---

### Task 4: Implement The Documented Isolated Futures TP/SL API

**Files:**
- Modify: `app/lib/services/lnmarkets_api.dart`

- [ ] **Step 1: Add an injectable HTTP client**

In `app/lib/services/lnmarkets_api.dart`, replace:

```dart
class LNMarketsAPI {
  final SettingsService settings;
  LNMarketsAPI(this.settings);
```

with:

```dart
class LNMarketsAPI {
  final SettingsService settings;
  final http.Client _client;

  LNMarketsAPI(this.settings, {http.Client? client})
      : _client = client ?? http.Client();
```

- [ ] **Step 2: Route existing GET/POST calls through the injected client**

In `_get`, replace:

```dart
    final resp = await http
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));
```

with:

```dart
    final resp = await _client
        .get(url, headers: headers)
        .timeout(const Duration(seconds: 15));
```

In `_post`, replace:

```dart
    final resp = await http
        .post(url, headers: headers, body: bodyStr)
        .timeout(const Duration(seconds: 15));
```

with:

```dart
    final resp = await _client
        .post(url, headers: headers, body: bodyStr)
        .timeout(const Duration(seconds: 15));
```

- [ ] **Step 3: Add a PUT helper**

Add this method immediately after `_post`:

```dart
  Future<dynamic> _put(String path, Map<String, dynamic> body) async {
    final bodyStr = jsonEncode(body);
    final headers = {
      ..._authHeaders('PUT', path, params: bodyStr),
      'Content-Type': 'application/json',
    };
    final url = Uri.parse('${settings.baseUrl}$path');
    final resp = await _client
        .put(url, headers: headers, body: bodyStr)
        .timeout(const Duration(seconds: 15));
    return _parse(resp);
  }
```

- [ ] **Step 4: Change TP/SL methods to documented PUT body shape**

Replace:

```dart
  Future<void> setTakeProfit(String id, double price) async => await _post(
      '/v3/futures/isolated/trade/takeprofit', {'id': id, 'takeprofit': price});

  Future<void> setStopLoss(String id, double price) async => await _post(
      '/v3/futures/isolated/trade/stoploss', {'id': id, 'stoploss': price});
```

with:

```dart
  Future<void> setTakeProfit(String id, double price) async => await _put(
      '/v3/futures/isolated/trade/takeprofit', {'id': id, 'value': price});

  Future<void> setStopLoss(String id, double price) async => await _put(
      '/v3/futures/isolated/trade/stoploss', {'id': id, 'value': price});
```

- [ ] **Step 5: Run the targeted test and verify it passes**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3/app
flutter test test/services/lnmarkets_api_test.dart
```

Expected:

```text
All tests passed!
```

- [ ] **Step 6: Commit the fix**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
git add app/lib/services/lnmarkets_api.dart app/test/services/lnmarkets_api_test.dart
git commit -m "fix: use isolated futures tpsl update endpoints"
```

Expected:

```text
[fix/lnmarkets-isolated-tpsl-v3 <hash>] fix: use isolated futures tpsl update endpoints
```

---

### Task 5: Validate The Fix Without Mainnet Automation

**Files:**
- Modify: none expected

- [ ] **Step 1: Run analyzer**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3/app
flutter analyze
```

Expected:

```text
No issues found!
```

- [ ] **Step 2: Run all tests**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3/app
flutter test
```

Expected:

```text
All tests passed!
```

- [ ] **Step 3: Build macOS debug app without signing**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3/app
flutter build macos --debug --config-only --dart-define=LNMBOT_MOCK_MODE=true
xcodebuild \
  -workspace macos/Runner.xcworkspace \
  -scheme Runner \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY=- \
  build
```

Expected:

```text
** BUILD SUCCEEDED **
```

- [ ] **Step 4: Check for accidental secrets or build artifacts**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
git status --short
rg -n "apiSecret|api_key|api_secret|passphrase|LNM-ACCESS|BEGIN .*PRIVATE|\\.env" \
  app docs .github CONTRIBUTING.md README.md
```

Expected:

```text
git status --short
```

prints nothing, or only intentional uncommitted handoff docs if Task 6 has not run yet.

The `rg` command may show source-code identifiers and documentation references, but it must not show real credential values.

---

### Task 6: Push Feature Branch And Open PR To `dev`

**Files:**
- Modify: none expected

- [ ] **Step 1: Push the fix branch**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
git push -u origin fix/lnmarkets-isolated-tpsl-v3
```

Expected:

```text
branch 'fix/lnmarkets-isolated-tpsl-v3' set up to track 'origin/fix/lnmarkets-isolated-tpsl-v3'
```

- [ ] **Step 2: Create the PR into `dev`**

Run:

```bash
cd /Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
gh pr create \
  --base dev \
  --head fix/lnmarkets-isolated-tpsl-v3 \
  --title "fix: use isolated futures tpsl update endpoints" \
  --body "$(cat <<'EOF'
## Summary
- Fixes LN Markets isolated futures stoploss/takeprofit updates to use documented PUT endpoints.
- Sends `{id, value}` for TP/SL updates instead of POST bodies with `takeprofit` or `stoploss`.
- Preserves sub-1000-sat margin behavior; tests only assert request shape and do not call mainnet.

## Test Plan
- [x] cd app && flutter analyze
- [x] cd app && flutter test
- [x] macOS debug build without signing via xcodebuild

## Trading Safety
- No automated mainnet calls.
- No real credentials in tests.
- Manual real validation must be done by Levy after merge.
EOF
)"
```

Expected: GitHub prints the PR URL.

- [ ] **Step 3: Wait for PR checks**

Run:

```bash
gh pr checks --repo LevyDeSales/LN-Markets_bot --watch
```

Expected:

```text
Flutter analyze and tests	pass
```

The macOS debug build runs on push to `dev` and `main`, not on PR.

- [ ] **Step 4: Merge PR into `dev` after approval**

Only run this after Levy approves the PR or explicitly authorizes the merge in Codex:

```bash
gh pr merge \
  --repo LevyDeSales/LN-Markets_bot \
  --squash \
  --delete-branch
```

Expected: PR is merged into `dev`, and GitHub deletes `origin/fix/lnmarkets-isolated-tpsl-v3`.

- [ ] **Step 5: Verify `dev` CI is green**

Run:

```bash
gh run list --repo LevyDeSales/LN-Markets_bot --branch dev --limit 3
```

Expected latest run:

```text
completed	success	...	CI	dev	push
```

---

### Task 7: Promote `dev` To `main`

**Files:**
- Modify: none expected

- [ ] **Step 1: Create the release PR from `dev` to `main`**

Run:

```bash
gh pr create \
  --repo LevyDeSales/LN-Markets_bot \
  --base main \
  --head dev \
  --title "chore: promote dev after isolated tpsl fix" \
  --body "$(cat <<'EOF'
## Summary
- Promotes the isolated futures TP/SL API fix from dev to main.
- Keeps the release path aligned with the documented dev -> main workflow.

## Test Plan
- [x] CI passed on dev.
- [x] No automated mainnet calls.

## Trading Safety
- Manual real validation remains Levy-only after main is updated.
EOF
)"
```

Expected: GitHub prints the PR URL.

- [ ] **Step 2: Wait for release PR checks**

Run:

```bash
gh pr checks --repo LevyDeSales/LN-Markets_bot --watch
```

Expected:

```text
Flutter analyze and tests	pass
```

- [ ] **Step 3: Squash merge `dev` into `main` after approval**

Only run this after Levy approves the promotion:

```bash
gh pr merge \
  --repo LevyDeSales/LN-Markets_bot \
  --squash
```

Expected: `main` receives the release squash commit.

- [ ] **Step 4: Verify `main` CI is green**

Run:

```bash
gh run list --repo LevyDeSales/LN-Markets_bot --branch main --limit 3
```

Expected latest run:

```text
completed	success	...	CI	main	push
```

- [ ] **Step 5: Sync `dev` history after squash promotion**

Because `dev -> main` uses squash merge, `dev` and `main` can have equivalent files but different commit hashes. Keep the branches operational by merging `main` back into `dev` through a protected PR.

Run:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot
git fetch origin
git switch -c chore/sync-main-into-dev origin/dev
git merge --no-edit origin/main
git push -u origin chore/sync-main-into-dev
gh pr create \
  --repo LevyDeSales/LN-Markets_bot \
  --base dev \
  --head chore/sync-main-into-dev \
  --title "chore: sync main into dev after release" \
  --body "Syncs main back into dev after squash promotion so future dev -> main PRs stay clean."
```

Expected: GitHub prints the sync PR URL. If `git merge --no-edit origin/main` prints `Already up to date.`, do not create the sync PR.

- [ ] **Step 6: Merge the sync PR after checks**

Only run if Step 5 created a sync PR:

```bash
gh pr checks --repo LevyDeSales/LN-Markets_bot --watch
gh pr merge --repo LevyDeSales/LN-Markets_bot --squash --delete-branch
```

Expected: sync PR merges into `dev` and checks stay green.

---

### Task 8: Manual Local Real Validation

**Files:**
- Modify: none expected

- [ ] **Step 1: Pull the promoted `main` locally**

Run:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot
git switch main
git pull --ff-only origin main
cd app
flutter analyze
flutter test
```

Expected:

```text
No issues found!
All tests passed!
```

- [ ] **Step 2: Build and open the local app**

Run:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot/app
flutter build macos --debug
open build/macos/Build/Products/Debug/lnmarkets_bot.app
```

Expected: app opens on macOS.

- [ ] **Step 3: Manual real API check**

Do not automate this step. In the app UI, Levy manually decides whether to use testnet or mainnet.

Safe manual validation checklist:

```text
1. Confirm no bot is already running unexpectedly.
2. Confirm credentials are intentional for the selected network.
3. Use testnet if available.
4. If mainnet is intentionally used, confirm margin * leverage * BTC price / 100000000 is >= 1 USD.
5. Start the bot only if Levy accepts live-trade risk.
6. Watch logs for TP/SL calls after a position opens.
7. Confirm in LN Markets UI/API that TP and trailing SL are attached.
8. Stop the bot after the smoke check.
```

Expected after the fix:

```text
No "LN Markets API 404" for takeprofit or stoploss update endpoints.
No local rejection of sub-1000-sat margin when quantity is >= 1 USD.
```

---

### Task 9: Cleanup Worktrees And Confirm Final State

**Files:**
- Modify: none expected

- [ ] **Step 1: Confirm no local worktree changes remain**

Run:

```bash
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3
git -C "$WT" status --short --branch
```

Expected:

```text
## fix/lnmarkets-isolated-tpsl-v3...origin/fix/lnmarkets-isolated-tpsl-v3
```

If the remote branch was deleted after squash merge, the upstream marker may be gone. The important expectation is no changed files.

- [ ] **Step 2: Remove the completed worktree**

Run:

```bash
MAIN=/Users/levy/Developer/LNbot/LN-Markets_bot
WT=/Users/levy/.config/superpowers/worktrees/LN-Markets_bot/fix-lnmarkets-isolated-tpsl-v3

git -C "$MAIN" worktree remove "$WT"
git -C "$MAIN" worktree prune
```

Expected: command exits with code `0`.

- [ ] **Step 3: Confirm local repo state**

Run:

```bash
cd /Users/levy/Developer/LNbot/LN-Markets_bot
git fetch origin
git status --short --branch
git branch -a --verbose --no-abbrev
gh run list --repo LevyDeSales/LN-Markets_bot --limit 6
```

Expected:

```text
main tracks origin/main
dev tracks origin/dev
no untracked docs/superpowers/plans/2026-06-07-lnmarkets-isolated-tpsl-api.md on main
latest CI for main/dev is success
```

---

## Self-Review

- Spec coverage: merge settings, branch protection, worktree from `dev`, TP/SL endpoint fix, tests-first workflow, PR to `dev`, promotion PR to `main`, squash merge, manual real validation, and local pending plan cleanup are covered.
- Placeholder scan: no placeholder markers, no generic "add tests", no unresolved file paths.
- Type consistency: test code uses `LNMarketsAPI(settings, client: client)`, and Task 4 defines that exact constructor plus `_client` usage.
