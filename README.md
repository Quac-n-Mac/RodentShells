# RodentShells

Play **RodentShells** in a browser tab, as one single HTML file:
double-click `RodentShells.html` and play. Works offline, no install,
no server - school Chromebook friendly.

Progress saves move around as copy-paste codes, so nothing depends on
browser storage being allowed.

## How to play

1. Grab `RodentShells.html` from the latest
   [Release](https://github.com/Quac-n-Mac/RodentShells/releases).
2. Open it in Chrome or Edge (double-click works - no server needed).
3. Click the game once so it has keyboard focus, then play.
4. Press **F6** to copy your save code; **F7** to paste it back on any
   other copy of the file.

### Chromebook / Google Drive

Save `RodentShells.html` in your Google Drive, open it with "Open with >
Preview" or download it and double-click. One file, nothing else to
install or unblock.

## What's in here

- `RodentShells.html` (in Releases) - the whole game in one file:
  the Godot 4.7.1 web runtime plus the full game data, compressed and
  unpacked in your browser at startup.
- `tools/` - the pipeline that builds the html (`build.sh`: pack,
  compress, bundle, boot-test).

## Controls

Keyboard and mouse recommended (gun recoil is the movement). Touch
controls appear automatically on touchscreens.

## Building it yourself

```
tools/build.sh path/to/game.pck dist/RodentShells.html
```

The script downloads the matching official Godot web runtime, bundles it
with the game data, and smoke-tests the result in headless Chrome.

---

*Disclosure: this may or may not be RatShot. RodentShells is a
personal-use port based on the free RatShot demo. RatShot is (c)
RetroCrow, published by Mace Face Games - not affiliated, no ownership
claimed. If you're the developer and want this changed or taken down,
open an issue and it comes down immediately. Wishlist the real game:*
https://store.steampowered.com/app/3980250/RATSHOT/
