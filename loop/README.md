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
flutter test                        # 60 tests
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
    widgets/                    Pressable, LoopSurface, LoopWordmark,
                                LoopMark, LoopCompletion
  features/home/
    models/                     UserProfile, LoopSummary, LoopItem,
                                AIInsight, UpcomingItem, HomeSnapshot
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

**Depth is a surface, not a shadow.** On a near-black ground a grey drop
shadow reads as dirt, so the only shadows in the app are coloured glows on the
three things meant to look lit, and they all come from `LoopElevation`. Cards
are separated by their border and by which rung of the surface ladder they sit
on (page → surface → muted → raised).

**A loop closing is one 720 ms gesture**, in `LoopCompletion`: the circle
draws shut, the check strokes through it with a tenth of the timeline
overlapping so there is no stutter between them, the mark settles by four
percent, and the word lands last. One controller, one painter, one opacity —
no filter, no clip, nothing animated that would force a repaint of anything
around it. This will eventually play several times a day, which is the reason
it is short.

**`LoopItem` exists before anything renders it.** The Home draws counts, and
counts are all four cards need — but everything the product is eventually
about is a property of the individual loop and not of the count: who is
waiting on whom, when it stops being recoverable, how long it has been silent,
what the one next move is. Defining that shape late would mean discovering
late that the summary was the wrong thing to build on.

**Contrast is a test, not an opinion.** Every text colour is asserted at 4.5:1
against every ground it is actually painted on — including the tinted card,
where the accent is washed over the surface at 16% and the maths changes. Two
colours failed that bar and were fixed at the token: the violet has a separate
`aiText` value for labels (the fill measured 3.68:1 on its own card, and
lifting the fill would have changed the ring and the create button), and the
tertiary grey went from 4.01:1 to 4.61:1 in its worst case. The hierarchy
between secondary and tertiary text is now carried by size and weight rather
than by luminance; that is the trade the guideline forces.

**A tablet gets a tablet layout.** `LoopLayout` resolves the window into
compact / medium / expanded from the width the page is actually given — so a
split-screen window gets the phone layout, correctly. Wider windows get bigger
gutters, a bigger ring, the four states in two columns (open on the left,
settled on the right), and a column centred vertically between the header and
the navigation bar rather than stacked at the top with half a tablet of
nothing underneath.

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

**The language preference has a seam, not a store.** `LocalePreferences` is
an interface with two methods; `LocaleController` already reads it at startup
and writes through it on every choice. The implementation that ships forgets,
because remembering means a plugin — a platform channel, a version to track, a
native build to keep working — which is more than this phase should spend to
persist one string. Real storage is one class and one argument in `app.dart`.

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

## Brand assets

`branding/` is where the official icon and splash art go. It is empty and
documented rather than absent, so that adding them is a drop-in: the file
names, the sizes, the iOS no-alpha rule and the Android adaptive safe zone are
written down there. All four platform icon slots currently hold Flutter's
placeholder.

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
