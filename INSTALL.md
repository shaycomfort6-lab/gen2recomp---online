# Installing Gen2Online on Gen2Recomp

## Requirements
- [UNDERdecoded/Gen2Recomped](https://github.com/UNDERdecoded/Gen2Recomped)
- Gold or Silver ROM extracted via the project's tools (for full maps)
- Python 3 for `gts_server.py`

## Steps
1. Copy this folder to `Gen2Recomped/mods/gen2online/`
2. Enable the mod in-game (needs `engine_internals` + `network`)
3. Start the GTS/MMO server from this package:
   ```bash
   python mods/gen2online/gts_server.py
   ```
4. Point the tunnel/URL in `main.lua` (`GTS_SERVER_URL`) at your server if needed
5. Boot **Gold** or **Silver** → START → **CONNECT TO SERVER**
6. You start in **NEW BARK TOWN**; talk to **Guide Mira** for the quest board

## Gen2 systems hooked
| System | Behavior |
|--------|----------|
| `GameVersion.isGen2` | Johto quests, New Bark, avatars |
| GTS | Same-generation listings only |
| PVP | Same-generation only; heldItem/happiness on wire |
| DayCare | Online XP on withdraw |
| National Park | Online contest host (quest 1027) |
| Game Corner | `GOLDENROD_GAME_CORNER` map scripts |
| Time of day | Shown on connect |

## Notes
- Stub maps: quest items also fall back to town/Indigo PC spawns
- Casino table PNGs are optional (from upstream Gen1Online assets)
