# Test suite

Structured Flutter tests covering unit, widget and golden (visual regression)
layers.

```
test/
├─ flutter_test_config.dart   # runs before every test: loads real fonts
├─ fonts/                     # Roboto-Regular.ttf bundled for deterministic text
├─ helpers/
│  ├─ test_harness.dart       # data factories, theme, golden surface helper
│  └─ fakes.dart              # hand-written repository fakes (no mock package)
├─ unit/                      # pure logic — fastest, no rendering
│  ├─ auth_bloc_test.dart         # login/register/logout/session state machine
│  ├─ course_bloc_test.dart       # catalogue, wishlist optimistic toggle + hydration
│  ├─ feature_blocs_test.dart     # notification, progress, refund, store, preference
│  ├─ models_test.dart            # JSON parse/serialize for all 21 models
│  ├─ data_source_test.dart       # HTTP layer with a mocked Dio adapter
│  └─ data_parsing_test.dart      # JsonUtils + AppConstants URL resolution
├─ widget/                    # rendering + interaction
│  ├─ course_card_test.dart       # student course card (state, badges, taps)
│  ├─ custom_text_field_test.dart # shared input + LoginForm submit behaviour
│  ├─ reusable_widgets_test.dart  # stat card, hub card, teacher course card
│  └─ screens_test.dart           # student dashboard, wishlist, teacher dashboard
└─ golden/                    # pixel comparisons
   ├─ golden_test.dart          # login, dashboard, course cards
   ├─ screens_golden_test.dart  # profile, wishlist, notifications, announcements
   └─ goldens/*.png             # reference images (checked in)
```

## Coverage map

| Layer | What is exercised |
| --- | --- |
| Models | Every `Data/Models` class: happy path, missing fields, wrong types, `toJson` round-trip |
| Data sources | Real data-source classes driven through a fake `HttpClientAdapter` (URL, verb, body, envelope unwrapping, Dio error mapping) |
| BLoCs | `Auth`, `Course`, `Notification`, `Progress`, `Refund`, `Store`, `Preference` — real events, real emitted states, success/error/empty branches |
| Widgets | Course card, text field, login form, stat card, hub card, teacher card |
| Screens | Student dashboard, wishlist, teacher dashboard (loading/loaded/empty states) |
| Golden | Login (idle + loading), student dashboard (populated + empty), 3 course-card variants, student profile, wishlist empty, notifications (populated + empty), announcements |


## Running

```bash
flutter test                        # everything
flutter test test/unit              # unit only
flutter test test/widget            # widget only
flutter test test/golden            # golden only
flutter test --update-goldens test/golden   # regenerate reference PNGs
```

## Golden tests

Golden tests fail when a rendered pixel changes. Run them after any intentional
UI change and regenerate the references:

```bash
flutter test --update-goldens test/golden
```

**Determinism.** Goldens only stay reliable if rendering is identical on every
machine, so the suite pins all of it:

| Source of variation | Controlled by |
| --- | --- |
| Font glyph metrics | `test/flutter_test_config.dart` loads `test/fonts/Roboto-Regular.ttf` (the default test font renders every glyph as a same-width box, which shifts layout) |
| Surface size | `pumpForGolden` pins `tester.view.physicalSize` to 390×844 |
| Device pixel ratio | `pumpForGolden` pins it to 1.0 |
| Network images | Thumbnails are left `null` so `AppNetworkImage` draws its offline placeholder — no live server involved |
| Animations | `pumpForGolden` pumps a fixed duration to reach the resting frame |

The bundled font means CI does not need any system font installed. Set
`GOLDEN_FONT_DIR` to override with another directory of `.ttf` files.

After regenerating goldens, **always review the PNG diffs** before committing —
`--update-goldens` will happily accept a regression as the new baseline.

## Conventions

* Unit tests drive real BLoCs through real events and assert emitted states.
* Fakes implement the domain interfaces and throw on unexpected calls, so a
  missing stub fails loudly instead of returning `null`.
* Widget tests assert user-visible behaviour (text, icons, taps), not internals.
