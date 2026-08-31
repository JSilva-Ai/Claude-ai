# LOOP

**The app that makes sure nothing important in your life gets left unfinished.**

A personal life completion engine. The unit of the product is a **loop**:
something started, left unfinished, detected, prioritised, resolved, closed.

This directory holds the Flutter app. **Phase 1 is the Home screen and
nothing else** — no backend, no Gmail or Calendar, no AI engine, no
notifications. What is here is the screen a person will open every morning,
built against mock data behind the interfaces the real sources will implement.

---

## Running it

```bash
flutter pub get
flutter run          # a connected device or simulator
flutter run -d chrome
```

Requires Flutter 3.47 or newer (Dart 3.6+). Built and verified on 3.47.2.

The localizations are generated from the ARB files by `flutter gen-l10n`,
which `flutter run` and `flutter build` do automatically. To regenerate by
hand:

```bash
flutter gen-l10n
```

## Checking it

```bash
dart format lib test
flutter analyze                     # clean
flutter test                        # 32 tests
LOOP_SCREENSHOTS=1 flutter test --update-goldens test/screenshots
```

That last command renders the Home to `build/screenshots/` at three sizes,
three languages, the empty state and at 180% text — it is a tool for looking
at the design, not a test, and it is skipped in a normal run because a golden
compared against a machine's own font rendering fails on somebody else's
laptop for reasons that have nothing to do with the code.

## What is in here

```
lib/
  main.dart                     edge-to-edge, then runApp
  app.dart                      MaterialApp, theme, locales, the two scopes
  core/
    theme/                      colours, spacing, type, motion, ThemeData
    localization/               ARB files, generated delegates, locale control
    animations/                 the staggered entrance
    utils/                      clock, greeting hours, countdown arithmetic
    widgets/                    Pressable, LoopSurface, LoopWordmark, LoopMark
  features/home/
    models/                     UserProfile, LoopSummary, AIInsight,
                                UpcomingItem, HomeSnapshot
    data/                       HomeRepository + the mock implementation
    state/                      HomeController (ChangeNotifier) + HomeScope
    presentation/
      screens/home_screen.dart
      widgets/                  header, greeting, ring, summary card,
                                insight, up next, bottom navigation,
                                loading / error / empty, the two sheets
test/                           unit tests, widget tests, the screenshot tool
```

## Decisions worth knowing about

**State: `ChangeNotifier` behind an `InheritedNotifier`, no package.** At one
screen with one repository, Riverpod or Bloc would buy indirection rather than
capability. `HomeController` is already testable without a widget tree,
already swappable, and already the only file that would change if the project
adopts something else later. A dependency is a version to track and a
convention every future contributor has to learn; it should be earned.

**The ring's number is data, not a sum.** The categories overlap — a loop can
be at risk *and* planned for today, and that is one loop, not two. So
`HomeSnapshot.activeLoops` is explicit, which is why the reference design can
show six active loops above cards reading 3, 2 and 4 without contradicting
itself. Where a source cannot tell distinct loops apart, the open cards are
summed as a fallback.

**Nothing is drawn from a bitmap.** The ring, the loop mark in the AI card and
the one in the navigation bar are `CustomPainter` and a gradient. They are
sharp at any pixel ratio, they cost no asset download, and they follow the
accent colours instead of being baked at the wrong violet.

**No blur anywhere.** The glow behind the header is a radial gradient and the
glow on a card icon is a single `BoxShadow`. A `BackdropFilter` is the most
expensive thing a phone GPU can be asked to do every frame, for an effect a
static gradient reproduces.

**Strings are never in widgets.** Every piece of UI copy is a key in the ARB
files, in all three languages, including the accessibility labels. What is
*not* localized is mock content — "Dentist appointment", the insight sentence
— because that is data, and the engine that will eventually produce it will
produce it in the user's language.

**Countdowns are computed, never stored.** `UpcomingItem` holds a `DateTime`.
"in 4h 18m" is a fact about the moment it is read, so it is derived at render
time and the card refreshes itself once a minute — not once a second, because
the smallest unit it shows is a minute.

**Time is injected.** `Clock` is a constructor argument, so "good evening" and
a four-hour countdown are unit tests rather than whatever the CI machine's
clock happened to say.

**Colour is never the only signal.** Every category carries a colour, an icon
and a word, and every card announces itself as
"AT RISK, Needs your attention, 3 loops". Touch targets are 48pt — the larger
of Apple's 44 and Android's 48 — and `meetsGuideline` asserts it. Reduced
motion is honoured by every animated widget through one helper, and with it on
each one still reaches its final state.

**The accessibility text size is capped in exactly one place**: the bottom
navigation bar, where five labels in a fixed strip cannot grow to 200% without
swallowing the icons. Everywhere else the page reflows and scrolls; at 180% in
Portuguese it still reads.

## Dependencies

| Package | Why |
| --- | --- |
| `flutter_localizations` (SDK) | Material and Cupertino strings for pt and es, and the delegates `gen-l10n` expects. |
| `intl` | Required by the generated localizations; also formats the time on the Up next card, so English gets 2:00 PM and Portuguese gets 14:00 from the locale rather than from a format string we chose. |
| `flutter_lints` (dev) | The standard lint set, plus a few rules in `analysis_options.yaml`. |

Nothing else. No state package, no icon package, no font package, no
animation package.

## The bundle id

`com.newaivisionlabs.loop`, derived from the studio's domain rather than
chosen, matching the convention already used by
`com.newaivisionlabs.voidstriker`. It is permanent once a build has been
uploaded under it, so it is the one value to confirm before that happens.

## Not in this phase

Gmail, Google Calendar, Outlook, documents, notifications, location, the AI
context engine, the commitment graph, the risk and friction engines, the next
action engine, one-tap resolution, family mode, subscriptions. Every tap on
the Home opens a sheet naming the screen that will exist there, which is also
the seam a real route slots into.

The architecture is ready for them in the sense that matters: the widgets
depend on models, the models come from a repository interface, and the
repository is one class away from being an aggregation of real sources. None
of that changes when the data becomes real.
