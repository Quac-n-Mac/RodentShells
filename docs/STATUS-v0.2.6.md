# v0.2.6-alpha status

## Changes

- First-use action lag warmup (shoot / jump / slide). The startup check now also:
  - Scans player.tscn, FX scenes (fxdust, fxgunshot, fxboost, fxhit2, fxslice, crack and variants) and bullet scenes for resources (data-only, same safe pattern as v0.2.5). +10 textures, +2 materials, +1 particle definition.
  - Instantiates 8 tiny FX scenes once behind the overlay and renders them, so scene setup, animation players and particle materials are ready before gameplay.
  - Draws every collected SpriteFrames frame on the hidden stage (GPU texture upload), instead of only touching RIDs.
  - Plays every collected short sound (<=4s, 163 clips) once at -80 dB through the real audio path, so the first in-game play does not initialise the playback pipeline. Long music streams stay on the offline decode path - routing a long OGG through live playback hung the warmup in testing.

## Measured (headless Chrome 157, SwiftShader, scripted first calls after tutorial load)

First-call time of each player action, before -> after:

- jump: 5.8 ms -> 1.7 ms (repeat: 0.8 ms)
- slide: 23.1 ms -> 7.8 ms (repeat: 11-14 ms)
- shoot: 1.1 ms -> 1.1 ms (work is async over following frames)

Startup check duration in this environment: 17.5s -> 34.3s (software rendering; on real hardware v0.2.5 measured 15-17s).

## Safety limits

- Frame-time spikes are not measurable in this software-rendered test environment (700-2000 ms baseline frames); only main-thread call times are reliable. Real-device frame spikes still need confirmation on Kacper's Chromebook.
- crack.tscn is resource-warmed but not instantiated (its _ready needs Global.rockColour and floor raycasts).
- Long audio (>4s) is not routed through live playback (hang risk, see above).
- v0.2.5 remains available as fallback.
