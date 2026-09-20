# PPTX Monsters

A 2D mobile game about defeating the PowerPoint features that defeated you.

Each level is a slide. Each boss is a feature — AutoFit, SmartArt, the Slide
Master, the Animation Pane. You fight them from a top-down view inside the
slide, with a character drawn in PowerPoint.

Built with Flutter and the [Flame](https://flame-engine.org) engine.

## Status

The start menu and the navigation around it are in place. Gameplay is not.

- **Start menu** — a title slide in PowerPoint's normal editing view, with
  ribbon, status bar, dashed placeholders and staggered "Fly In" entrances.
- **Slide sorter** — level select, showing the six bosses; only the first is
  unlocked.
- **Slide show** — the arena, staged but not playable: it sets up the top-down
  framing, the projector-black surround and the actors. Movement and combat go
  here next.
- **Design Ideas** — a settings pane with nothing wired up yet.

## Running it

```bash
flutter run
```

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

To preview in a browser instead, add the web platform back with
`flutter create --platforms=web .`.

## How it is put together

```
lib/
  main.dart                  App shell; sets landscape, hosts the GameWidget
  game/
    pptx_monsters_game.dart  FlameGame + RouterComponent; one route per screen
    routes.dart              Route names
    levels.dart              The six bosses
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
