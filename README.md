# PPTX Monsters

[![CI](https://github.com/AIvocado633/PPTXmonsters/actions/workflows/ci.yml/badge.svg)](https://github.com/AIvocado633/PPTXmonsters/actions/workflows/ci.yml)

A 2D mobile game about defeating the PowerPoint features that defeated you.

Each level is a slide. Each boss is a feature — AutoFit, SmartArt, the Slide
Master, the Animation Pane. You fight them from a top-down view inside the
slide, with a character drawn in PowerPoint.

Built with Flutter and the [Flame](https://flame-engine.org) engine.

## Status

Slides 1 and 2 are playable end to end. The other four bosses are named but
not built.

- **Start menu** — a title slide in PowerPoint's normal editing view, with
  ribbon, status bar, dashed placeholders and staggered "Fly In" entrances.
- **Slide sorter** — level select, showing all six slides. The two with a
  fight open; the rest stay locked until their boss is built.
- **Slide show** — two fights so far, AutoFit and SmartArt, with twin-stick
  controls (see below).
- **Design Ideas** — a settings pane with nothing wired up yet.

### Controls

Twin-stick: one input moves, the other aims, and pushing the aim in any
direction fires that way immediately — there is no fire button.

|          | Touch             | Keyboard   | Controller  |
| -------- | ----------------- | ---------- | ----------- |
| **Move** | left thumb stick  | WASD       | left stick  |
| **Aim**  | right thumb stick | arrow keys | right stick |

All three work at once, so you can pick up a controller mid-fight. Space still
fires along the way you are walking, for anyone who would rather not aim.
Controllers come through the Flame team's
[`gamepads`](https://pub.dev/packages/gamepads) package, whose normalized
events map every platform's pad onto the same Xbox-style layout.

Each fight is built out of the feature's own behaviour rather than out of a
health bar with a new sprite on it.

### Slide 1 — AutoFit

AutoFit shrinks whatever does not fit, so the fight turns that on both sides.
Every hit the boss lands makes the player smaller; every bullet point that
lands steps the boss down the same ladder of point sizes PowerPoint walks when
AutoFit kicks in, from 54 pt to nothing. Whoever runs out of size first loses
the slide.

Shrinking is not purely a punishment. A smaller player is quicker and a
narrower target, and can squeeze closer to the walls — the trade is that you
have less room left to lose.

### Slide 2 — SmartArt

SmartArt is not one target but six connected shapes. Break one and the
survivors immediately re-lay themselves out into the next layout — cycle,
process, hierarchy, pyramid — closing ranks and throwing your aim away, which
is exactly what SmartArt does to a slide the moment you add or remove a line.
It fights back by throwing its connector arrows at you.

Where AutoFit is one target that gets smaller, SmartArt is many targets that
keep moving: same controls, a completely different problem.

## Running it

```bash
flutter run
```

On Windows there is also a script that builds a standalone copy and starts it,
the way a player would launch the game rather than a developer:

```bat
run-windows.bat
```

With no argument it makes a release build; pass `debug` or `profile` for the
other configurations. Double-clicking it works, and the game keeps running
after the console window closes. For a hot-reload loop use `flutter run -d
windows` instead.

Android, iOS and Windows are configured.

The game is **landscape only**. The layout is a 16:9 slide, letterboxed onto
whatever screen it gets, exactly the way a real deck behaves in slide show
mode. That is locked in three places, all of which are needed:

| Layer | Setting |
| --- | --- |
| Android | `android:screenOrientation="sensorLandscape"` on the activity, so even the launch theme cannot appear in portrait |
| iOS | `Info.plist` declares only the two landscape orientations, on phone and iPad |
| Dart | `Flame.device.setLandscape()` at startup, on mobile only |

`test/orientation_test.dart` guards all three, because re-running
`flutter create` regenerates the platform files from templates that allow
portrait.

On desktop the window stays freely resizable, as desktop windows should be; the
slide just letterboxes inside whatever shape it is given.

```bash
flutter test      # unit and layout tests
flutter analyze   # lints
```

CI runs both on every pull request, alongside debug builds for Android and
Windows — see [`.github/workflows/ci.yml`](.github/workflows/ci.yml). The
workflow pins the Flutter version, so bump it together with `.metadata` when
upgrading the SDK.

To preview in a browser instead, add the web platform back with
`flutter create --platforms=web .`.

## How it is put together

```
lib/
  main.dart                  App shell; sets landscape, hosts the GameWidget
  game/
    pptx_monsters_game.dart  FlameGame + RouterComponent; one route per screen
    routes.dart              Route names
    levels.dart              The six slides, and the boss each one builds
    slide/
      slide_metrics.dart     The 1280x720 design canvas and its margins
      slide_page.dart        Base page: scales and letterboxes the slide
      fly_in.dart            PowerPoint's entrance animation, as an extension
    pages/                   One file per screen
    components/              Ribbon, status bar, placeholders, buttons, actors
    art/pptx_art.dart        Loads PNG frames exported from PowerPoint
    theme/                   Colours and text styles, lifted from the Office UI
assets/images/               Exported artwork (see docs/)
```

Two conventions carry most of the weight:

**Everything is measured in slide units.** Layout code works against a fixed
1280×720 canvas and never sees device pixels; `SlidePage` handles the scaling
and centring. `test/slide_layout_test.dart` holds pages to that canvas.

**Artwork is optional.** `PptxActor` draws a procedural stand-in when its PNG
frames are missing, so the game runs before the art exists.

## Drawing the monsters

The art pipeline is PowerPoint itself — see
[docs/powerpoint-art-pipeline.md](docs/powerpoint-art-pipeline.md).
