# Gen2Online

Online multiplayer layer for **[UNDERdecoded/Gen2Recomped](https://github.com/UNDERdecoded/Gen2Recomped)** — a port of Gen1Online adapted for Pokémon **Gold / Silver** (Gen 2).

**Version:** `0.7.0-gen2`

---

## What this is

Gen1Online added GTS, overworld multiplayer, link trade/battle, quests, and accounts to Gen1 recompilations.  
**Gen2Online** keeps that design and rewires it for Gen2Recomp:

| Area | Gen1Online | Gen2Online |
|------|------------|------------|
| Games | Red / Blue / Yellow | **Gold / Silver** (+ Gen1 still possible via same server) |
| Start map | Pallet / Red’s house | **New Bark — `PLAYERS_HOUSE2_F`** |
| Avatars | Red / Blue sprites | **Chris / Kris** (+ trainer fallbacks) |
| Species | 151 | **251** via engine data |
| Party wire format | Gen1 fields | Gen1 + **heldItem, happiness, pokerus, met data, shiny** |
| PVP / GTS | Open | **Same-generation only** (Gen1 ↔ Gen2 blocked) |
| Quests | Kanto-focused | **Johto → Gen2 Kanto → League → Mt. Silver** (27 quests) |
| DayCare | — | Online XP on withdraw |
| National Park | — | Online contest host (quest 1027) |
| Game Corner | Celadon | **Goldenrod** map hooks |

---

## Requirements

- Gen2Recomp with Gold or Silver ROM extracted
- Python 3 (for `gts_server.py`)
- Network permission in the mod manifest

---

## Install

1. Copy this folder to:

   ```text
   Gen2Recomped/mods/gen2online/
   ```

2. Enable the mod (needs `engine_internals` + `network`).

3. Point the client at your server in `main.lua`:

   ```lua
   local GTS_SERVER_URL = "https://gts.yourdomain.com"
   -- or http://127.0.0.1:7779 for local only
   ```

4. Run the server (must match mod version `0.7.0-gen2`):

   ```bash
   python3 gts_server.py
   # PORT=7779 by default; binds 0.0.0.0
   ```

5. In-game: **START → CONNECT TO SERVER**.

---

## Hosting (multiplayer)

Recommended:

- Small VPS (e.g. Contabo / Hetzner / DigitalOcean)
- `gts_server.py` under **systemd**
- **Cloudflare Tunnel** to a stable HTTPS hostname (no public 7779 required)

Example client URL:

```lua
local GTS_SERVER_URL = "https://gts.cedricslabs.com"
```

Persist:

- `gts_database.json`
- `players_backup.json`

Quick tunnel URLs (`*.trycloudflare.com`) change every restart; named tunnels + your domain do not.

---

## Changes from original Gen1Online

### Boot & saves

- Detects Gen2 via `GameVersion.isGen2()` / gold / silver.
- **New Game / online create / redeem / connect** force Gen2 start away from Pallet:
  - Indoor: `PLAYERS_HOUSE2_F` (player’s bedroom)
  - Outdoor landmark: `NEW_BARK_TOWN`
- Hooks `SaveData.newGame` and `OverworldState.enter` so Phase 2B no longer leaves Gold/Silver in `REDS_HOUSE_2F`.
- Online saves remain separate (`save_online_*.lua` style suffixes for gold/silver).
- **RESET / SWITCH** clears online files safely and opens fresh character creation (no longer hardcodes Red’s house).

### Sprites

- Safe sprite loading: never call `SpriteRenderer.new` on missing PNGs.
- Avatar fallback **excludes** `SPRITE_MON_*` / `SPRITE_WILD_*` (fixed “player looks like a Pokémon”).
- Remote players and quest NPCs use `pcall` + human trainer sprite fallbacks.
- Redeem Token uses `NamingScreen` + `game.stack:push` (no global `Screens` dependency).

### GTS & wire format (`gen2_compat.lua`)

- `packMon` / `unpackMon` / `packParty` carry Gen2 fields.
- GTS deposits tag `generation`.
- Browse / trade reject cross-gen listings.
- PVP rejects Gen1 ↔ Gen2 parties.

### Link trade & battle

- Same Gen1Online room/challenge model.
- **Bug fixed:** some `sync_pos` posts omitted `modVersion`, so the server returned `VERSION_MISMATCH` even when both sides showed `0.7.0-gen2`.
  - Background HTTP thread injects `modVersion` if missing.
  - All `sync_pos` payloads include version.
  - Server accepts `X-Mod-Version` header as fallback and is lenient on `0.7.x-gen2`.

### Quests (IDs 1001–1027)

Online **side** storyline (does not replace ROM gym/E4 AI):

**Johto (1001–1016)**  
Welcome, Sprout Tower, Cherrygrove, Route 29, Slowpoke Well, Underground, Burned Tower, Lake of Rage, Olivine, Cianwood, Radio Tower, Ice Path, Dragon’s Den, Tohjo, Viridian customs, Indigo report.

**Gen2 Kanto (1017–1024)**  
Pewter → Cerulean → Vermilion → Celadon → **Fuchsia (Janine)** → Saffron → Cinnabar → **Viridian (Blue)**.

**League (1025)**  
Victory Road + Will / Koga / Bruno / Karen / Lance seals (fallback spawns in Indigo PC if room maps are stubs).

**Mt. Silver (1026)**  
Silver Cave emblem + Summit Trainer finale.

**National Park (1027)**  
Online contest host checkpoint.

Guide **Mira** in New Bark tracks the board.

### Other Gen2 hooks

- Goldenrod Game Corner registration.
- DayCare withdraw → small online XP.
- Time-of-day line on connect.
- Gen2 trade NPC hooks where applicable.

### Server (`gts_server.py`)

- `MOD_VERSION = "0.7.0-gen2"`.
- Quest defs through **1027**.
- Generation-aware deposits / profiles.
- Same multi-threaded GTS + overworld + challenge rooms model as Gen1Online.

---

## What is *not* replaced

Still provided by **Gen2Recomp + ROM extract**:

- Real gym / Elite Four / Red battles and AI  
- Full map geometry (stub maps stay limited until extract is complete)  
- Day/night engine, Pokégear, breeding rules, Bug Contest scoring  

This mod is the **online layer** on top.

---

## Troubleshooting

| Symptom | Fix |
|--------|-----|
| VERSION MISMATCH with same `0.7.0-gen2` | Update **both** client `main.lua` and VPS `gts_server.py` to 0.7 package; restart `gen2online-gts` |
| Spawn in Pallet online | Use latest mod; **RESET / SWITCH** online character once |
| Redeem Token crash (`Screens` nil) | Use latest `main.lua` (NamingScreen path) |
| Player sprite is a Pokémon | Use latest sprite fallback logic |
| Can’t connect | Check `GTS_SERVER_URL`, server process, Cloudflare tunnel / DNS |
| Empty Oak’s desk | You’re on Gen1 maps; Gold/Silver should start in New Bark / Elm path |

---

## File layout

```text
gen2online/
  main.lua              # Mod entry, net, GTS UI, hooks
  gen2_compat.lua       # Gen2 detection, spawn, packMon, filters
  gts_server.py         # Shared multiplayer server
  manifest.json
  INSTALL.md
  quests/               # 1001–1027 definitions
  npcs/                 # Mira, Johto/Kanto/League/Silver hosts
  transforms.lua
  ...
```

---

## Credits

- Original online design: **Gen1Online**
- Engine: **Gen2Recomp** (UNDERdecoded)
- Gen2 adaptations, Johto–Kanto online questline, spawn/sprite/version fixes: this package

---

## License / ROM data

Ship only **scaffolds and your own code**. Do not commit extracted Nintendo map/graphics data. Players supply their own ROMs through Gen2Recomp’s legal extract pipeline.
