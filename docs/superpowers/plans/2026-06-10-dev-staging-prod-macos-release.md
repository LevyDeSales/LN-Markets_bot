# Dev Staging Prod macOS Release Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Establish the `feature/* -> dev -> staging -> main` promotion loop and publish installable macOS arm64 releases from GitHub tags.

**Architecture:** `main` remains production. `staging` is the protected pre-production branch. CI validates pull requests and pushes; release artifacts are produced only from `vX.Y.Z` tags pointing at `main`.

**Tech Stack:** GitHub Actions, Flutter, CocoaPods, macOS arm64 GitHub-hosted runners, `ditto`, `hdiutil`, `gh`.

---

### Task 1: Branch Promotion CI

**Files:**
- Modify: `.github/workflows/ci.yml`
- Modify: `CONTRIBUTING.md`
- Modify: `.github/pull_request_template.md`

- [ ] Update CI triggers to include `staging`.
- [ ] Run macOS debug mock-safe build on pushes to protected branches and on PRs to `staging` or `main`.
- [ ] Document the `feature/* -> dev -> staging -> main` flow and branch protection commands.
- [ ] Add PR checklist entries for target branch and promotion checks.

### Task 2: macOS Release Workflow

**Files:**
- Create: `.github/workflows/release-macos.yml`
- Create: `docs/release/macos.md`
- Modify: `README.md`

- [ ] Add a tag-triggered `macOS Release` workflow for `v*.*.*`.
- [ ] Validate the tag points at `origin/main`.
- [ ] Validate the tag version matches `app/pubspec.yaml`.
- [ ] Build unsigned macOS release artifacts on a macOS arm64 runner.
- [ ] Publish `.zip`, `.dmg`, and `SHA256SUMS.txt` to GitHub Releases.
- [ ] Document installation, unsigned app behavior, and release commands.

### Task 3: Validation And Publish

**Files:**
- All files above.

- [ ] Run `cd app && flutter pub get`.
- [ ] Run `cd app && flutter analyze`.
- [ ] Run `cd app && flutter test`.
- [ ] Run `cd app && flutter build macos --debug --dart-define=LNMBOT_MOCK_MODE=true`.
- [ ] Commit as `ci: add staging promotion and macos release workflow`.
- [ ] Push branch and open draft PR to `dev`.
- [ ] Create/protect `staging` from `main`.
