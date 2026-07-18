# Versionado automático con semantic-release (3 repos)

## Contexto

El 2026-07-18 se detectó que `release-please` (herramienta previamente usada en los 3 repos: `dipalza_mobile`, `dipalza_server`, `dipalza_web_client`) falla de forma reproducible en `dipalza_server` — la estrategia Java/Maven standalone genera un "empty change set" seguido de un error 404 al construir el PR de snapshot-bump, sin causa de configuración identificable ni issue upstream que calzara con el síntoma. Además, se encontró que el historial de `main` en `dipalza_mobile` había sido reescrito en algún punto, dejando el tag `v2.0.1` inalcanzable desde `main` y causando que release-please calculara versiones incorrectas silenciosamente durante semanas.

Se decidió reemplazar release-please por **semantic-release** en los 3 repos, operando en modo **totalmente automático** (sin PR de revisión intermedio) — decisión explícita del usuario tras evaluar alternativas (bump manual, bump vía etiqueta de PR, git-cliff). Esto implica una excepción deliberada y acotada a la regla general del proyecto de "todo cambio va por rama + PR": el commit de bump de versión + changelog que genera el propio bot de semantic-release va directo a `main`, sin PR. Cualquier otro cambio (hecho por una persona) sigue yendo por rama + PR.

## Objetivo

En cada uno de los 3 repos, cada push a `main` debe:
1. Analizar los commits nuevos desde el último release (Conventional Commits).
2. Si hay algo liberable (`feat`, `fix`, `BREAKING CHANGE`), calcular la próxima versión semver.
3. Actualizar el archivo de versión del proyecto y `CHANGELOG.md`, commitear ese cambio directo a `main`.
4. Crear el tag `vX.Y.Z` y el GitHub Release correspondiente, con el changelog generado.
5. Cuando aplique (mobile, server), adjuntar el artefacto de build (APK / JAR) al Release.
6. Si no hay nada liberable, no hacer nada (salida silenciosa, sin error).

## Punto de partida

No se resetean tags existentes. Cada repo ya tiene su último release real correctamente publicado como baseline (trabajo hecho el 2026-07-18):

| Repo | Tag/Release base |
|---|---|
| dipalza_mobile | `v2.1.0` (con APK adjunto) |
| dipalza_server | `v1.1.0` (con JAR adjunto) |
| dipalza_web_client | `v1.1.0` |

semantic-release toma el último tag como referencia y calcula hacia adelante desde ahí en su primera corrida real (cuando llegue el próximo commit `feat`/`fix` a `main`).

## Arquitectura común (los 3 repos)

Un solo job `release` en GitHub Actions, disparado en `push: branches: [main]`. Pasos:

1. Checkout con historial completo (`fetch-depth: 0`) y tags.
2. Setup del runtime necesario para el build (Flutter / Java) — Node se usa transitoriamente solo para ejecutar el CLI de semantic-release, no como runtime de la app.
3. Build del artefacto de release (APK / JAR), **antes** de invocar semantic-release, para poder adjuntarlo si termina generando un release.
4. `npx semantic-release`, con plugins:
   - `@semantic-release/commit-analyzer` — preset Conventional Commits (`feat`→minor, `fix`→patch, `BREAKING CHANGE`→major).
   - `@semantic-release/release-notes-generator`
   - `@semantic-release/changelog` — mantiene `CHANGELOG.md`.
   - `@semantic-release/exec` — corre el comando de bump específico del repo (ver tabla abajo) en la fase `prepare`.
   - `@semantic-release/git` — commitea `CHANGELOG.md` + archivo de versión a `main` con mensaje `chore(release): ${nextRelease.version} [skip ci]`. El `[skip ci]` evita que ese commit dispare el workflow de nuevo.
   - `@semantic-release/github` — crea el tag + GitHub Release, adjunta el artefacto vía `assets` cuando corresponda.

Si `commit-analyzer` determina que no hay nada liberable, semantic-release termina sin crear commit, tag ni release — comportamiento nativo de la herramienta, no requiere lógica adicional nuestra.

## Diferencias por repo

| Repo | Bump de versión | Build previo | Asset adjunto |
|---|---|---|---|
| **dipalza_web_client** | `@semantic-release/npm` (plugin oficial), `npmPublish: false` — bumpea `package.json` | Ninguno | Ninguno |
| **dipalza_mobile** | `exec` → script que reescribe `version:` en `pubspec.yaml` a `${nextRelease.version}+${GITHUB_RUN_NUMBER}` | `flutter build apk --release` (con keystore/signing existente) | `dipalza-release-${version}.apk` |
| **dipalza_server** | `exec` → `mvn versions:set -DnewVersion=${nextRelease.version} -DgenerateBackupPoms=false` (plugin oficial de Maven, evita repetir el problema de hoy con Java) | `./mvnw package -DskipTests -Dfrontend.skip=true` | `dipalza-${version}.jar` |

## Limpieza incluida en esta migración

- Eliminar `.release-please-manifest.json` y workflow `release-please.yml` en `dipalza_mobile`.
- Eliminar workflow `release-please.yml` en `dipalza_web_client` (no tenía manifest/config propios).
- En `dipalza_server`: reemplazar el workflow `release.yml` recién creado hoy (disparado por push de tag, manual) por el nuevo flujo disparado por push a `main`.
- Los PRs de release-please y tags/releases basura generados durante la migración de hoy (`v0.0.0-recalc` en mobile y server) ya fueron limpiados.

## Testing

Para cada repo, tras mergear el setup:
1. Verificar que un push a `main` con commits `feat`/`fix` dispare un release nuevo automáticamente (versión correcta, changelog generado, commit `chore(release)` visible en `main`, tag y GitHub Release creados).
2. Verificar que un push sin commits liberables (solo `docs`/`chore`/`test`) no genere ningún release.
3. En mobile y server, confirmar que el artefacto (APK/JAR) queda adjunto al Release.

## Fuera de alcance

- No se automatiza la publicación a stores (Play Store / App Store) ni el deploy de `dipalza_web_client` — solo el versionado y la creación del Release en GitHub.
- No se migra el historial de `CHANGELOG.md` existente en cada repo más allá de lo que cada herramienta ya haya escrito; semantic-release simplemente sigue agregando entradas nuevas.
