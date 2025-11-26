# Repository Guidelines

## Project Structure & Module Organization
- Entry points live in `lib/main.dart` and `lib/init_app.dart`; app routing and bindings are wired there with GetX.
- Feature code is split by concern: `lib/pages/` (screens), `lib/routers/` (routes and navigation observers), `lib/service/` (auth/token lifecycle), `lib/api/` (GetConnect client and config), `lib/models/` (DTOs), `lib/utils/` (logger, prefs, crypto, misc helpers), and `lib/values/` (colors, strings, dimens).
- Shared assets sit under `assets/images/`; keep new assets referenced in `pubspec.yaml`.
- Platform shells are in `android/`, `ios/`, `linux/`, `macos/`, `web/`, `windows/`, and `ohos/`; widget tests live in `test/`.

## Build, Test, and Development Commands
- Install deps: `flutter pub get`.
- Lint/static analysis: `flutter analyze` (uses `analysis_options.yaml`).
- Format: `dart format .` before committing.
- Tests: `flutter test` (runs widget and unit suites in `test/`).
- Run locally: `flutter run -d windows` (desktop) or `flutter run -d chrome` for web; swap `-d` for your target device.
- Release builds: `flutter build apk --release` (Android) or `flutter build windows` / `flutter build macos` as needed.

## Coding Style & Naming Conventions
- Follow Dart style and `flutter_lints`; prefer 2-space indentation, single quotes, trailing commas in widget trees, and explicit types for public APIs.
- File names use snake_case (`image_compressor_page.dart`); classes use `PascalCase`, methods/fields use `camelCase`, constants either `kCamelCase` or scoped static consts (e.g., `AppColors.primary`).
- Keep widgets small and composable; push side effects into `service/` or `utils/` rather than `pages/`.

## Testing Guidelines
- Name tests `*_test.dart` and mirror the source path under `test/`.
- For widgets, wrap with minimal shells that mirror `MyApp` configuration; prefer deterministic tests (no network calls—stub via injected services).
- Aim for coverage on business logic in `service/` and `utils/` before UI polish; add regression tests alongside bug fixes.

## Commit & Pull Request Guidelines
- No history is present here; use Conventional Commit prefixes (`feat:`, `fix:`, `chore:`, `docs:`, `test:`) for clarity.
- Before sending a PR, run `flutter analyze`, `dart format .`, and `flutter test`; mention results in the description.
- Reference related issues, summarize behavior changes, and attach screenshots/GIFs for UI updates.
- Keep PRs scoped and focused; prefer small, reviewable changes with inline comments explaining non-obvious decisions.

## Security & Configuration Tips
- Do not commit secrets or tokens; `OauthService` pulls credentials from `shared_preferences`, so avoid logging auth headers.
- Keep API endpoints and keys centralized in `lib/api/api_config.dart`; use env-specific configs instead of hardcoding in widgets.


## 2025