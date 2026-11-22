# RodentShells

Play the **RATSHOT** demo in a browser tab, as one single HTML file:
double-click `RodentShells.html` and play. Works offline, no install,
no server - school Chromebook friendly.

Progress saves move around as copy-paste codes, so nothing depends on
browser storage being allowed.

## What's in here

- `RodentShells.html` (in Releases) - the whole game in one file.
- `tools/` - the pipeline that builds it (Godot web runtime + the demo's
  own .pck, bundled and compressed into the html).
- The port also renames the in-game title art from RATSHOT to
  **RodentShell** - a personal rename, original art style kept.

## Source material

Built from the free RATSHOT Steam demo (3 files: exe, .pck, steam dll).
Only the .pck is needed; the engine is replaced by the official Godot
4.7.1 web runtime. Get the original demo and wishlist the real game:
https://store.steampowered.com/app/3980250/RATSHOT/

## Legal

RATSHOT is (c) RetroCrow, published by Mace Face Games. This is a
personal-use port for the repo owner, in the same spirit as the owner's
other personal ports: it redistributes the free demo for private play,
with no claim of ownership or affiliation. If you're the developer and
want this changed or taken down, open an issue and it comes down
immediately. Go wishlist the real game - it's great.
