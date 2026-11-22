# v0.2.5-alpha status

## Changes

- Compressed embedded engine/game payloads. One offline HTML, 147,889,357 bytes versus 207,022,249 bytes in v0.2.4 (28.6% smaller).
- Versioned IndexedDB cache for unpacked payloads. Blocked or unavailable storage falls back to the embedded payload. Cache only holds engine/game assets, not save data.
- Loading screen paints before resource loading and scene instantiation. It waits until the startup check is finished, avoiding concurrent heavy loading.
- Startup check reads tutorial and pillar dependencies without instantiating gameplay scenes. Covers 399 textures, 49 materials, 20 particle definitions, 102 sound files and five animation resources. Sounds get a short offline decode, not audible test playback.
- Pillar debris uses a narrow native-particle render test built from its scene data, without running gameplay scripts.
- Audio runtime/worklets unchanged. Both worklet payloads match v0.2.4 byte-for-byte.

## Verified

- Repeated local-file Chrome headless runs reached startup completion, tutorial gameplay, first pillar break, movement and pause.
- Gameplay and pause screenshots inspected.
- Current startup check took about 15-17 seconds in these tests. Overall startup is longer and varies by machine.
- Three pillar-warm runs completed with first-break call times 2-6ms and draw times 41-53ms. These are not a controlled before/after benchmark or a smoothness guarantee.
- Asset-only cache experiment: cold unpack 1,616ms, repeat cache read 266ms. Whole-game launch still performs render preparation because GPU resources do not survive closing the page.
- Storage-blocked run completed through gameplay and pause using embedded fallback.

## Safety limits

- Do not claim every interaction is tested. Only tutorial/pillar dependencies and shared resource files are prepared.
- Arbitrary gameplay-scene instancing remains disabled. It previously caused fatal wasm traps.
- Generic live particle-material simulation remains disabled. It caused hangs after apparently successful startup. The pillar-only test passed repeated longer runs.
- Whole-level eager cache remains disabled. Preparing all playable levels also produced stalls. No unused/test scenes are scanned.
- Audible sound cannot be confirmed in this headless environment. The known worklet/runtime path is unchanged; actual-device listening is still needed.
- First-entry instantiation can still pause on slower hardware. The loading screen moves work behind a visible stage, it does not eliminate all main-thread work.
- v0.2.4 remains available as fallback.

## Next checks

- Longer real-device playthrough across each level, pause/fullscreen/options and save/load.
- Record actual pillar-break frame times on the affected device.
- Expand warmup only with one resource family at a time and full gameplay checks after each change.
