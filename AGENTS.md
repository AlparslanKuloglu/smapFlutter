# SMAP – Agent and contributor rules

Binding rules for anyone changing this repo: developers and AI agents alike. They are short on purpose; the reasoning,
recipes and examples are in `docs/DEVELOPING.md` (Turkish) and its chapters under `docs/dev/`. The way work is split,
reviewed and merged is in `docs/WORKFLOW.md`.

## Working here
- Respond in Turkish; code, identifiers and doc comments in English (UI copy quoted in Turkish).
- Work on one task at a time, in your task's worktree/branch (`tool/wt.sh <id>` → `../smapFlutter-wt/<id>`, branch
  `task/<id>`), and only on the files your task owns (`docs/gorevler/<id>.md`). Commit with Conventional Commits (a
  Turkish summary is fine). Never push or open a PR unless the person responsible asks for it.
- Never open credential files (`*.jks`, `*.keystore`, `key.properties`, `google-services*.json`, `GoogleService-Info.plist`,
  `.env*`, `*.p8`, `*adminsdk*.json`) and never copy secret values anywhere.
- Never sign in with a real account or send requests that write to the live server (smaptr.com) while testing. Use the
  shell preview (`--dart-define=SHELL_PREVIEW=student|coach`), the gallery, and temporary fake repositories that are not
  committed.
- Simulators: never touch a simulator that holds someone's real session (no uninstall, no reinstall). Create your own on the
  newest runtime (`xcrun simctl create "SMAP-<ID>" "iPhone 17 Pro" com.apple.CoreSimulator.SimRuntime.iOS-26-2`), and when
  the task ends delete it and your worktree's Xcode DerivedData folder (details in `docs/WORKFLOW.md` §8).
- Irreversible or bulk actions (deleting many files or assets, history rewrites) need the owner's approval: list them with
  evidence in your report instead.

## Sources of truth (all in this repo)
- Master plan and decisions K1–K16: `docs/SMAP_Ana_Plan.md` (wins over everything below).
- Corrections to the UI guide: `docs/SMAP_UI_Rehberi_Duzeltmeler.md` (wins over the guide).
- Flutter spec (tokens, components C01–C86, routes, screens, backend dependencies): `docs/spec/SMAP_Flutter_Spec.md` and its
  parts `docs/spec/0*.md`. Decisions and assumptions: `docs/spec/06_kararlar_varsayimlar.md`.
- UI guide (house rules, folder layout, decomposition examples): `docs/SMAP_UI_Uygulama_Rehberi.md`.
- Design boards: `docs/design/` (see its README). Image `docs/design/panolar/png/SMAP-NN_<board>.png`; text, rules and
  assumptions `docs/design/panolar/SMAP-NN/<board>/text.txt`; exact CSS `…/board.html`; flows `docs/design/panolar/AKIS.md`.
  Handoff boards on page SMAP-11 (11.12 tokens, 11.13 components, 11.14 screen–component map, 11.15 motion/haptics,
  11.16 assumptions, plus the Tur 12 addenda and T12.1–T12.30) win over earlier boards; a board tagged "Yerine geçtiği
  kare" replaces the frame it names. Old-app screenshots and briefs (`docs/design/tasarim-paketi/`, `brifler/`) are NOT targets.
- Status, open questions to the backend: `docs/DURUM.md`, `docs/Backend_Sorulari_Ek.md`.

## Architecture
- Feature-first MVVM with stacked; get_it with a `session` scope; auto_route (`XxxView` → `XxxRoute`); dart_mappable DTOs;
  repositories return `Either<AppException, T>`; one `NetworkService` (Dio). No Provider/ChangeNotifier screens.
- Screen = `lib/features/<f>/presentation/<screen>/{<screen>_view.dart, <screen>_viewmodel.dart, widgets/ (part files), sheets/}`.
- Pure logic in `lib/features/<f>/application/` (unit-tested). Domain constants stay in their feature, never in `core/`.
- ViewModels are context-free: navigation via an injected navigator/`AppRouter`, toasts via `ToastText` lambdas, sheets via
  `XSheet.show()` behind a `*Dialogs` interface. VMs are never registered in get_it; services come from `locator` in
  `viewModelBuilder`.
- A screen that holds Back with `PopScope(canPop: false)` closes itself with `router.pop()`, never `maybePop()` (that asks
  the same `PopScope` again and loops forever).
- Tab screens leave room for the bar with `AppBottomBar.heightOf(context)`; never compute insets yourself.
- Do not remove a feature that works against the real backend (owner rule). Only dead, unreachable, mock or "coming soon"
  code may be removed, with evidence (`grep`, `dart run tool/unreachable_files.dart`). Features waiting on the backend sit
  behind `lib/core/config/feature_flags.dart`.

## Shared files — only the coordinator commits these
`pubspec.yaml`, `pubspec.lock`, `build.yaml`, `analysis_options.yaml`, `l10n.yaml`, `lib/l10n/app_tr.arb` and the generated
`lib/l10n/app_localizations*.dart` (built by `dart run tool/merge_arb.dart && flutter gen-l10n`),
`lib/app/router/app_router.dart` (+ `app_router.gr.dart`), `lib/app/router/routes/shell_routes.dart`,
`lib/app/shell/*_shell_view.dart`, `lib/dependency_injection/injection_container.dart`, `lib/gen/assets.gen.dart`,
`lib/features/debug/gallery_registry.dart`, `lib/core/services/device_preferences.dart`, platform manifests (`Info.plist`,
`AndroidManifest.xml`, `build.gradle*`) unless your task explicitly owns them. If you need a change there, try it locally,
revert it before committing, and describe it under "Koordinatöre notlar" in your report.
Your feature exposes: `<f>_routes.dart` (route lists), `<f>_module.dart` (DI registrations), `lib/l10n/arb/<f>_tr.arb`
(strings), a gallery page under `lib/features/debug/pages/` — the coordinator wires them in.

## UI rules (enforced by `tool/ui_rules.sh` and `flutter analyze` in CI)
- Colors only via `context.appColors` (SmapColors); text only via `context.appText` (SmapText) + `copyWith(color:)`;
  spacing via `AppSpacing`; radius via `AppRadius`; motion via `context.motion(...)`/`SmapDurations`/`AppMotion`; icons via
  `phosphor_flutter`.
- Forbidden in features/shared UI: `Color(0x…)`, `Colors.*`, `TextStyle(`, `fontSize:`, mihr color/typography getters,
  `Icons.*`, `CupertinoIcons.*`, raw `Duration(...)` in presentation, string literals in `Text`,
  `showDialog`/`AlertDialog`/`showModalBottomSheet`/`SnackBar`, `MaterialPageRoute`, `Navigator.push`,
  `SharedPreferences.getInstance`, `print(`.
- Orange only for the camera button, position indicator, progress and "today". Selection is navy. No white text on orange.
- Cards: no border, no shadow. Blur only on the bottom bar and the sheet scrim. Plain rounded corners (no squircle).
- Clay illustrations (`docs/design/kil/`) only in onboarding, screen-level empty states and store art; at most one per
  screen; decorative (`ExcludeSemantics`); never in rows, chips, tabs or buttons.
- Build from `lib/shared/ui` (`App*`) and feature widgets. Spec names `SmapX` map to `AppX` (generic) or `X` (domain). Keep
  the spec C-number in the doc comment. A missing generic piece goes to `shared/ui` + its gallery page in the same task.
- Class widgets only (no `Widget _buildX()`). Private `_Widgets` in part files, const constructors, one section per part
  file. Limits (checked): screen `_view.dart` ≤ 250 lines, part file ≤ 300, ViewModel ≤ 500, any other presentation/kit
  file ≤ 400.
- Root view is `StackedView` with `reactive => false`; each data section is a `SelectorViewModelWidget` with a record
  selector over immutable values; actions via `getParentViewModel(context, listen: false)`; fast-changing values via
  `ValueNotifier`.
- One `CustomScrollView` per screen (`PinnedHeaderSliver`, `SliverMainAxisGroup`). No `NestedScrollView`, no `sliver_tools`.
- Every section has loading (skeleton mirroring the layout, 15 s timeout), empty, error and offline states. Never render fake
  data; if data is missing, do not draw the field.
- All dialogs are `AppSheet` sheets returning a typed result; the calling VM writes, toasts and undoes (6 s "Geri Al" holds
  like `PendingLearns` / `NoteDeleteHold`).
- mihr_ui dev.3 buttons: pass `tapTargetSize: MaterialTapTargetSize.padded` per instance; avoid theme-level `styleBuilder`.
- Copy: "Vazgeç" (never "İptal"), "Tamam", "Kapat" (a11y only), "Geri Al" (toast only); "sen" tone; no emoji; no ALL CAPS;
  question titles sentence case, screen/sheet titles Turkish title case. Numbers and dates only via `TrFormat`
  (67,5 · 412,63 · 48.215 · %42 · 5 Eki.). Turkish suffixes via `TurkishSuffix` ("Ayşe Demir'e").
- l10n: keys `<feature>_<camelCase>`, shared `common_*`, screen-reader-only `…A11y`. Turkish-aware case folding
  (`TurkishText`); never `toUpperCase()` on Turkish text.
- Accessibility: 48 dp targets; `semanticLabel` + tooltip on icon buttons; single Semantics reading for grouped values;
  header semantics on titles; `liveRegion` for status; text scale 1.3 without breaking; reduce motion → 150 ms fades.
- Haptics: `AppHaptics.selection/medium/success/error` only, on outcomes.
- Every widget's doc comment cites its board and frame (`pano 3.1 kare 2`) and quotes the Turkish copy.

## Definition of done (every task)
- Data + VM tests first, then the view. Delete the legacy files your task replaces (and only those).
- `dart format .` clean, `flutter analyze` zero issues (infos are fatal in CI), `flutter test` green, `tool/ui_rules.sh`
  clean, codegen up to date (`dart run build_runner build -d`; `dart run tool/merge_arb.dart && flutter gen-l10n`),
  `flutter build ios --simulator --debug` builds.
- Tests: unit tests for VMs, services, repositories, pure logic; widget tests only for measured sizes or screen-reader
  sentences. UI is verified in the gallery (`flutter run -t lib/main_gallery.dart`) and on the simulator, side by side with
  the board PNG (light, dark, large text, empty/error/skeleton/offline).
- Report: changed files, before/after list per frame, decisions/assumptions, "Koordinatöre notlar" (routes/DI/ARB/gallery/
  pubspec needs), open questions (missing backend fields go to `docs/Backend_Sorulari_Ek.md`).
