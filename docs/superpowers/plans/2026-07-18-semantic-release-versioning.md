# Semantic-Release Versioning Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace release-please with semantic-release (fully automatic, no review PR) in `dipalza_web_client`, `dipalza_mobile`, and `dipalza_server`, so every push to `main` with releasable commits produces a version bump, changelog, git tag, GitHub Release, and — for mobile/server — an attached build artifact, with zero manual steps.

**Architecture:** One GitHub Actions job per repo (`release`), triggered on push to `main` (plus a manual `workflow_dispatch` with a `dry_run` input for safe testing). Each job runs `npx semantic-release`, configured via `release.config.js`, with plugins: `commit-analyzer` → `release-notes-generator` → `changelog` → `exec` (repo-specific version bump + build) → `git` (commits the bump directly to `main`) → `github` (creates tag/Release, uploads artifact).

**Tech Stack:** semantic-release v24.x + official plugins (`commit-analyzer`, `release-notes-generator`, `changelog`, `exec`, `git`, `github`, and `npm` for the web client only), Node 20 in CI (build tool only, not a runtime dependency of mobile/server).

## Global Constraints

- Spec: `docs/superpowers/specs/2026-07-18-semantic-release-versioning-design.md` (in `dipalza_mobile`, applies to all 3 repos).
- Every task in this plan is implemented on its own branch and merged via PR — **except** semantic-release's own generated commit, which pushes directly to `main` (the one deliberate, user-approved exception to the "rama + PR siempre" rule). Nothing in this plan authorizes any other direct push to `main`.
- Conventional Commits drive the version bump: `feat` → minor, `fix` → patch, a `BREAKING CHANGE:` footer → major. No other commit types trigger a release.
- The bot's release commit message must be `chore(release): ${nextRelease.version} [skip ci]` — the `[skip ci]` is required to prevent the commit from re-triggering the same workflow.
- Baseline tags (already published, do not touch): `dipalza_mobile` → `v2.1.0`, `dipalza_server` → `v1.1.0`, `dipalza_web_client` → `v1.1.0`.
- **Known risk to watch for during verification:** branch protection on `main` requires PRs; today's manual pushes succeeded only because the human account has bypass/admin rights. The `GITHUB_TOKEN` used by Actions may or may not have the same bypass. If the first live run fails with a protected-branch/permission error when `@semantic-release/git` tries to push, the fix is a GitHub repo setting (Settings → Branches → allow the `github-actions` app in the bypass list), not a code change — flag it to the user rather than trying to work around it in the workflow.
- All file paths below are relative to `/Users/cursor/Dev/dipalza/application_v2.0/<repo>/` — the repo name is given at the start of each task's file paths.

---

## Task Group A: dipalza_web_client

### Task A1: Add semantic-release config and dependencies

**Files:**
- Create: `dipalza_web_client/release.config.js`
- Modify: `dipalza_web_client/package.json` (add `devDependencies`)
- Create: `dipalza_web_client/.github/workflows/release.yml`
- Delete: `dipalza_web_client/.github/workflows/release-please.yml`

**Interfaces:**
- Produces: a `release` GitHub Actions job that runs on push to `main`, publishing via semantic-release. No other task depends on this one's outputs (web_client is independent of mobile/server).

- [ ] **Step 1: Create the branch**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
git checkout main && git pull origin main
git checkout -b ci/semantic-release
```

- [ ] **Step 2: Write `release.config.js`**

```javascript
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/npm', { npmPublish: false }],
    ['@semantic-release/git', {
      assets: ['package.json', 'package-lock.json', 'CHANGELOG.md'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    '@semantic-release/github'
  ]
};
```

- [ ] **Step 3: Add devDependencies to `package.json`**

Add these keys inside the existing `"devDependencies"` object (do not touch `"dependencies"`):

```json
    "semantic-release": "^24.2.0",
    "@semantic-release/changelog": "^6.0.3",
    "@semantic-release/commit-analyzer": "^13.0.0",
    "@semantic-release/exec": "^6.0.3",
    "@semantic-release/git": "^10.0.1",
    "@semantic-release/github": "^10.3.5",
    "@semantic-release/npm": "^12.0.1",
    "@semantic-release/release-notes-generator": "^14.0.0"
```

- [ ] **Step 4: Install to generate/update the lockfile**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
npm install
```

Expected: `package-lock.json` updates with the new packages; no errors.

- [ ] **Step 5: Delete the old release-please workflow**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
git rm .github/workflows/release-please.yml
```

- [ ] **Step 6: Write the new workflow**

```yaml
name: Release

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      dry_run:
        description: 'Ejecutar en modo dry-run (no publica nada)'
        type: boolean
        default: true

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install dependencies
        run: npm ci

      - name: Run semantic-release
        run: npx semantic-release ${{ inputs.dry_run && '--dry-run' || '' }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 7: Commit and push**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
git add release.config.js package.json package-lock.json .github/workflows/release.yml
git rm .github/workflows/release-please.yml 2>/dev/null || true
git commit -m "ci: reemplaza release-please por semantic-release"
git push -u origin ci/semantic-release
```

- [ ] **Step 8: Open the PR**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
gh pr create --title "ci: reemplaza release-please por semantic-release" --body "Ver docs/superpowers/specs/2026-07-18-semantic-release-versioning-design.md en dipalza_mobile para el diseño completo. Este PR agrega semantic-release (modo full-auto) y quita release-please."
```

Report the PR URL to the user and wait for them to merge it (branch protection blocks the agent from merging).

### Task A2: Verify with a dry run

**Files:** none (verification only)

**Interfaces:**
- Consumes: the merged workflow from Task A1.

- [ ] **Step 1: After the user confirms the PR is merged, trigger a dry run**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
git checkout main && git pull origin main
gh workflow run release.yml -f dry_run=true
```

- [ ] **Step 2: Wait for it to complete and inspect the log**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_web_client
RUN_ID=$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')
until [ "$(gh run view "$RUN_ID" --json status --jq .status)" = "completed" ]; do sleep 8; done
gh run view "$RUN_ID" --log | grep -iE "next release version|would have generated|error"
```

Expected: either `There are no relevant changes, so no new version is released` (correct — no releasable commits since `v1.1.0`) or a line like `The next release version is X.Y.Z` with no `error` lines. If it fails with a token/permission error, stop and report it — do not attempt to change permissions unilaterally.

- [ ] **Step 3: Report the result to the user**

Summarize what the dry run printed (no-op vs. computed version) before moving to Task Group B.

---

## Task Group B: dipalza_mobile

### Task B1: Add semantic-release config, bump script, and dependencies

**Files:**
- Create: `dipalza_mobile/package.json`
- Create: `dipalza_mobile/release.config.js`
- Create: `dipalza_mobile/scripts/bump_pubspec_version.sh`
- Create: `dipalza_mobile/.github/workflows/release.yml`
- Delete: `dipalza_mobile/.github/workflows/release-please.yml`
- Delete: `dipalza_mobile/.release-please-manifest.json`
- Modify: `dipalza_mobile/.gitignore` (add `node_modules/`)

**Interfaces:**
- Produces: a `release` job that bumps `pubspec.yaml`, builds the APK for the version being released, and publishes it. Independent of Task Groups A and C.

- [ ] **Step 1: Create the branch**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
git checkout main && git pull origin main
git checkout -b ci/semantic-release
```

- [ ] **Step 2: Add `node_modules/` to `.gitignore`**

Append this line to `dipalza_mobile/.gitignore`:

```
node_modules/
```

- [ ] **Step 3: Create `package.json`** (this repo has none yet — it exists solely to run semantic-release in CI, it is not part of the Flutter app)

```json
{
  "name": "dipalza-mobile-release-tooling",
  "private": true,
  "devDependencies": {
    "semantic-release": "^24.2.0",
    "@semantic-release/changelog": "^6.0.3",
    "@semantic-release/commit-analyzer": "^13.0.0",
    "@semantic-release/exec": "^6.0.3",
    "@semantic-release/git": "^10.0.1",
    "@semantic-release/github": "^10.3.5",
    "@semantic-release/release-notes-generator": "^14.0.0"
  }
}
```

- [ ] **Step 4: Install to generate the lockfile**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
npm install
```

Expected: creates `package-lock.json`, no errors.

- [ ] **Step 5: Write the version-bump script**

```bash
mkdir -p /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile/scripts
```

Content of `dipalza_mobile/scripts/bump_pubspec_version.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
BUILD_NUMBER="${GITHUB_RUN_NUMBER:-1}"

sed -i.bak "s/^version: .*/version: ${VERSION}+${BUILD_NUMBER}/" pubspec.yaml
rm -f pubspec.yaml.bak

echo "pubspec.yaml version set to ${VERSION}+${BUILD_NUMBER}"
```

```bash
chmod +x /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile/scripts/bump_pubspec_version.sh
```

- [ ] **Step 6: Write `release.config.js`**

```javascript
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/exec', {
      prepareCmd: 'bash scripts/bump_pubspec_version.sh ${nextRelease.version}',
      publishCmd: 'flutter build apk --release && cp build/app/outputs/flutter-apk/app-release.apk build/app/outputs/flutter-apk/dipalza-release-${nextRelease.version}.apk'
    }],
    ['@semantic-release/git', {
      assets: ['pubspec.yaml', 'CHANGELOG.md'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    ['@semantic-release/github', {
      assets: [{ path: 'build/app/outputs/flutter-apk/dipalza-release-*.apk' }]
    }]
  ]
};
```

- [ ] **Step 7: Delete the old release-please files**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
git rm .github/workflows/release-please.yml .release-please-manifest.json
```

- [ ] **Step 8: Write the new workflow**

```yaml
name: Release

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      dry_run:
        description: 'Ejecutar en modo dry-run (no publica nada)'
        type: boolean
        default: true

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install release tooling
        run: npm ci

      - name: Set up Java 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true

      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE }}" | base64 --decode > android/app/release.keystore

      - name: Create key.properties
        run: |
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.ANDROID_STORE_PASSWORD }}
          keyPassword=${{ secrets.ANDROID_KEY_PASSWORD }}
          keyAlias=${{ secrets.ANDROID_KEY_ALIAS }}
          storeFile=release.keystore
          EOF

      - name: Install Flutter dependencies
        run: flutter pub get

      - name: Run semantic-release
        run: npx semantic-release ${{ inputs.dry_run && '--dry-run' || '' }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 9: Commit and push**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
git add .gitignore package.json package-lock.json release.config.js scripts/bump_pubspec_version.sh .github/workflows/release.yml
git commit -m "ci: reemplaza release-please por semantic-release"
git push -u origin ci/semantic-release
```

- [ ] **Step 10: Open the PR**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
gh pr create --title "ci: reemplaza release-please por semantic-release" --body "Ver docs/superpowers/specs/2026-07-18-semantic-release-versioning-design.md para el diseño completo. Este PR agrega semantic-release (modo full-auto) y quita release-please."
```

Report the PR URL to the user and wait for them to merge it.

### Task B2: Verify with a dry run

**Files:** none (verification only)

**Interfaces:**
- Consumes: the merged workflow from Task B1.

- [ ] **Step 1: After the user confirms the PR is merged, trigger a dry run**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
git checkout main && git pull origin main
gh workflow run release.yml -f dry_run=true
```

- [ ] **Step 2: Wait for it to complete and inspect the log**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_mobile
RUN_ID=$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')
until [ "$(gh run view "$RUN_ID" --json status --jq .status)" = "completed" ]; do sleep 8; done
gh run view "$RUN_ID" --log | grep -iE "next release version|would have generated|error"
```

Expected: `There are no relevant changes...` (no-op, correct baseline) or a computed next version with no `error` lines.

- [ ] **Step 3: Report the result to the user**

---

## Task Group C: dipalza_server

### Task C1: Replace today's manual tag-triggered workflow with semantic-release

**Files:**
- Create: `dipalza_server/package.json`
- Create: `dipalza_server/release.config.js`
- Modify: `dipalza_server/.github/workflows/release.yml` (replace contents — this file already exists from today's earlier manual-tag setup)
- Modify: `dipalza_server/.gitignore` (add `node_modules/`)

**Interfaces:**
- Produces: a `release` job that bumps `dipalza/pom.xml` via `mvn versions:set`, builds the JAR for the version being released, and publishes it. Independent of Task Groups A and B.

- [ ] **Step 1: Create the branch**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
git checkout main && git pull origin main
git checkout -b ci/semantic-release
```

- [ ] **Step 2: Add `node_modules/` to `.gitignore`**

Append this line to `dipalza_server/.gitignore`:

```
node_modules/
```

- [ ] **Step 3: Create `package.json`** (release tooling only, not part of the Spring Boot app)

```json
{
  "name": "dipalza-server-release-tooling",
  "private": true,
  "devDependencies": {
    "semantic-release": "^24.2.0",
    "@semantic-release/changelog": "^6.0.3",
    "@semantic-release/commit-analyzer": "^13.0.0",
    "@semantic-release/exec": "^6.0.3",
    "@semantic-release/git": "^10.0.1",
    "@semantic-release/github": "^10.3.5",
    "@semantic-release/release-notes-generator": "^14.0.0"
  }
}
```

- [ ] **Step 4: Install to generate the lockfile**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
npm install
```

- [ ] **Step 5: Write `release.config.js`**

```javascript
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    ['@semantic-release/exec', {
      prepareCmd: 'cd dipalza && mvn versions:set -DnewVersion=${nextRelease.version} -DgenerateBackupPoms=false',
      publishCmd: 'cd dipalza && ./mvnw package -DskipTests -Dfrontend.skip=true'
    }],
    ['@semantic-release/git', {
      assets: ['dipalza/pom.xml', 'CHANGELOG.md'],
      message: 'chore(release): ${nextRelease.version} [skip ci]\n\n${nextRelease.notes}'
    }],
    ['@semantic-release/github', {
      assets: [{ path: 'dipalza/target/dipalza-*.jar' }]
    }]
  ]
};
```

- [ ] **Step 6: Replace the workflow contents**

Replace the full contents of `dipalza_server/.github/workflows/release.yml` with:

```yaml
name: Release

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      dry_run:
        description: 'Ejecutar en modo dry-run (no publica nada)'
        type: boolean
        default: true

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - uses: actions/setup-node@v4
        with:
          node-version: 20

      - name: Install release tooling
        run: npm ci

      - name: Set up Java 21
        uses: actions/setup-java@v4
        with:
          java-version: '21'
          distribution: 'temurin'
          cache: maven

      - name: Run semantic-release
        run: npx semantic-release ${{ inputs.dry_run && '--dry-run' || '' }}
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

- [ ] **Step 7: Commit and push**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
git add .gitignore package.json package-lock.json release.config.js .github/workflows/release.yml
git commit -m "ci: reemplaza el flujo manual por tag con semantic-release"
git push -u origin ci/semantic-release
```

- [ ] **Step 8: Open the PR**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
gh pr create --title "ci: reemplaza flujo manual por semantic-release" --body "Ver docs/superpowers/specs/2026-07-18-semantic-release-versioning-design.md (repo dipalza_mobile) para el diseño completo. Reemplaza el flujo disparado por push de tag (armado hoy como parche temporal) por semantic-release full-auto disparado en push a main."
```

Report the PR URL to the user and wait for them to merge it.

### Task C2: Verify with a dry run

**Files:** none (verification only)

**Interfaces:**
- Consumes: the merged workflow from Task C1.

- [ ] **Step 1: After the user confirms the PR is merged, trigger a dry run**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
git checkout main && git pull origin main
gh workflow run release.yml -f dry_run=true
```

- [ ] **Step 2: Wait for it to complete and inspect the log**

```bash
cd /Users/cursor/Dev/dipalza/application_v2.0/dipalza_server
RUN_ID=$(gh run list --workflow release.yml --limit 1 --json databaseId --jq '.[0].databaseId')
until [ "$(gh run view "$RUN_ID" --json status --jq .status)" = "completed" ]; do sleep 8; done
gh run view "$RUN_ID" --log | grep -iE "next release version|would have generated|error"
```

Expected: `There are no relevant changes...` (no-op, correct baseline) or a computed next version with no `error` lines.

- [ ] **Step 3: Report the result to the user**

Summarize the outcome across all three repos before closing out the migration.
