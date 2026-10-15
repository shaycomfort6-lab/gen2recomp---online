-- Gen2 compatibility helpers for Gen1Online on Gen2Recomp.
local Compat = {}

local function gv()
  local ok, G = pcall(require, "src.core.GameVersion")
  if ok and G then return G end
  return nil
end

function Compat.isGen2()
  local G = gv()
  if G and G.isGen2 and G.isGen2() then return true end
  if G and G.get then
    local id = tostring(G.get() or ""):lower()
    if id == "gold" or id == "silver" or id == "crystal" then return true end
    if id:find("gold") or id:find("silver") then return true end
  end
  -- Fallbacks: save / boot / data hints (some builds report version late)
  local okG, Game = pcall(require, "src.core.Game")
  if okG and Game then
    local s = Game.save
    if s then
      for _, key in ipairs({ s.version, s.gameVersion, s.rom, s.edition }) do
        if key then
          local v = tostring(key):lower()
          if v:find("gold") or v:find("silver") or v:find("crystal") or v:find("johto") then
            return true
          end
        end
      end
    end
    local bc = Game.bootConfig
    if type(bc) == "function" then
      local ok, res = pcall(bc, Game)
      if ok then bc = res end
    end
    if type(bc) == "table" then
      for _, key in ipairs({ bc.version, bc.game, bc.rom, bc.id, bc.name }) do
        if key then
          local v = tostring(key):lower()
          if v:find("gold") or v:find("silver") or v:find("crystal") then
            return true
          end
        end
      end
    end
    if Game.data and Game.data.meta then
      local m = tostring(Game.data.meta.version or Game.data.meta.game or ""):lower()
      if m:find("gold") or m:find("silver") then return true end
    end
  end
  return false
end

function Compat.isGen1()
  return not Compat.isGen2()
end

function Compat.versionId()
  local G = gv()
  return (G and G.get and G.get()) or "red"
end

function Compat.generation()
  return Compat.isGen2() and 2 or 1
end

-- Gold/Silver: bedroom first (PLAYERS_HOUSE2_F), same role as REDS_HOUSE_2F in Gen1.
-- Outdoor landmark is NEW_BARK_TOWN. Falls back if a map id is missing from data.maps.
function Compat.defaultSpawn(data)
  if not Compat.isGen2() then
    return { map = "REDS_HOUSE_2F", x = 3, y = 6, facing = "up", outdoor = { map = "PALLET_TOWN", x = 5, y = 6 } }
  end
  local candidates = {
    { map = "PLAYERS_HOUSE2_F", x = 3, y = 3, facing = "down" },
    { map = "PLAYERS_HOUSE1_F", x = 7, y = 4, facing = "down" },
    { map = "NEW_BARK_TOWN", x = 14, y = 8, facing = "down" },
  }
  local maps = data and data.maps
  local chosen = candidates[1]
  if maps then
    for _, c in ipairs(candidates) do
      if maps[c.map] then chosen = c break end
    end
  end
  chosen.outdoor = { map = "NEW_BARK_TOWN", x = 14, y = 8 }
  return chosen
end

function Compat.defaultHeal(data)
  local s = Compat.defaultSpawn(data)
  -- Heal at outdoor New Bark so blackout is not stuck in the bedroom forever
  local o = s.outdoor or { map = s.map, x = s.x, y = s.y }
  return { map = o.map or s.map, x = o.x or s.x, y = o.y or s.y }
end

function Compat.defaultSprite()
  if Compat.isGen2() then return "SPRITE_CHRIS" end
  return "SPRITE_RED"
end

local function isTrainerSpriteId(id)
  if type(id) ~= "string" then return false end
  if not id:match("^SPRITE_") then return false end
  -- Never use mon icons / wild sheets / balls for the player or trainers
  if id:match("^SPRITE_MON") then return false end
  if id:match("^SPRITE_WILD") then return false end
  if id:match("^SPRITE_ICON") then return false end
  if id:match("POKE_BALL") or id:match("POKEBALL") then return false end
  if id:match("^SPRITE_STILL") then return false end
  return true
end
Compat.isTrainerSpriteId = isTrainerSpriteId

function Compat.resolveSprite(game, spriteId)
  local sprites = game and game.data and game.data.sprites
  if not sprites then return spriteId or Compat.defaultSprite() end
  local candidates = {
    spriteId,
    Compat.isGen2() and "SPRITE_CHRIS" or nil,
    Compat.isGen2() and "SPRITE_KRIS" or nil,
    Compat.isGen2() and "SPRITE_GOLD" or nil,
    "SPRITE_RED",
    "SPRITE_BLUE",
    "SPRITE_YOUNGSTER",
    "SPRITE_BUG_CATCHER",
    "SPRITE_FALLBACK",
  }
  for _, id in ipairs(candidates) do
    if id and sprites[id] and isTrainerSpriteId(id) then return id end
  end
  for k, _ in pairs(sprites) do
    if isTrainerSpriteId(k) then return k end
  end
  return "SPRITE_RED"
end

function Compat.avatarList()
  if Compat.isGen2() then
    return {
      { id = "SPRITE_CHRIS", label = "CHRIS / BOY" },
      { id = "SPRITE_KRIS", label = "KRIS / GIRL" },
      { id = "SPRITE_SILVER", label = "RIVAL" },
      { id = "SPRITE_OAK", label = "PROF. OAK" },
      { id = "SPRITE_ELM", label = "PROF. ELM" },
      { id = "SPRITE_COOLTRAINER_M", label = "COOLTRAINER M" },
      { id = "SPRITE_COOLTRAINER_F", label = "COOLTRAINER F" },
      { id = "SPRITE_ROCKET", label = "TEAM ROCKET" },
      { id = "SPRITE_LASS", label = "LASS" },
      { id = "SPRITE_YOUNGSTER", label = "YOUNGSTER" },
      { id = "SPRITE_BLACKBELT", label = "BLACKBELT" },
      { id = "SPRITE_SUPER_NERD", label = "SUPER NERD" },
      { id = "SPRITE_HIKER", label = "HIKER" },
      { id = "SPRITE_BEAUTY", label = "BEAUTY" },
      { id = "SPRITE_BUG_CATCHER", label = "BUG CATCHER" },
      { id = "SPRITE_SWIMMER", label = "SWIMMER" },
      { id = "SPRITE_SAILOR", label = "SAILOR" },
    }
  end
  return {
    { id = "SPRITE_RED", label = "RED / BOY" },
    { id = "SPRITE_BLUE", label = "BLUE / RIVAL" },
    { id = "SPRITE_GIRL", label = "LEAF / GIRL" },
    { id = "SPRITE_OAK", label = "PROF. OAK" },
    { id = "SPRITE_COOLTRAINER_M", label = "COOLTRAINER M" },
    { id = "SPRITE_COOLTRAINER_F", label = "COOLTRAINER F" },
    { id = "SPRITE_ROCKET", label = "TEAM ROCKET" },
    { id = "SPRITE_LASS", label = "LASS" },
    { id = "SPRITE_YOUNGSTER", label = "YOUNGSTER" },
    { id = "SPRITE_BLACKBELT", label = "BLACKBELT" },
    { id = "SPRITE_SUPER_NERD", label = "SUPER NERD" },
    { id = "SPRITE_HIKER", label = "HIKER" },
    { id = "SPRITE_BEAUTY", label = "BEAUTY" },
    { id = "SPRITE_BUG_CATCHER", label = "BUG CATCHER" },
    { id = "SPRITE_SWIMMER", label = "SWIMMER" },
    { id = "SPRITE_SAILOR", label = "SAILOR" },
    { id = "SPRITE_WAITER", label = "GENTLEMAN" },
  }
end

function Compat.defaultFavorite()
  if Compat.isGen2() then return "TYPHLOSION" end
  return "CHARIZARD"
end

function Compat.badgeCap()
  return 8
end

function Compat.onlineSaveSuffix()
  local id = Compat.versionId()
  if id == "blue" then return "_blue" end
  if id == "yellow" then return "_yellow" end
  if id == "gold" then return "_gold" end
  if id == "silver" then return "_silver" end
  return ""
end

function Compat.allSpecies(data)
  local speciesList = {}
  if not (data and data.pokemon) then return speciesList end
  for key, def in pairs(data.pokemon) do
    if type(def) == "table" and type(def.name) == "string" then
      table.insert(speciesList, { id = key, name = def.name, dex = def.dex or def.index or 0 })
    end
  end
  table.sort(speciesList, function(a, b)
    if a.dex ~= b.dex then return (a.dex or 0) < (b.dex or 0) end
    return tostring(a.name) < tostring(b.name)
  end)
  return speciesList
end

function Compat.packMon(Protocol, mon)
  local packed = Protocol.packMon(mon)
  if not packed then return packed end
  packed.extra = packed.extra or {}
  -- Gen2 (and shared) fields Gen2Recomp mons may carry
  local fields = {
    "heldItem", "happiness", "pokerus", "caughtData", "metLevel",
    "metLocation", "metTime", "gender", "form", "item",
  }
  for _, key in ipairs(fields) do
    if mon[key] ~= nil then
      packed.extra[key] = mon[key]
      packed[key] = mon[key]
    end
  end
  local ok, Pokemon = pcall(require, "src.pokemon.Pokemon")
  if ok and Pokemon and Pokemon.isShiny and Pokemon.isShiny(mon) then
    packed.extra.shiny = true
    packed.shiny = true
  end
  packed.generation = Compat.generation()
  packed.versionId = Compat.versionId()
  return packed
end

function Compat.unpackMon(Protocol, data, packed, opts)
  local mon, err = Protocol.unpackMon(data, packed, opts)
  if not mon then return mon, err end
  local extra = (packed and packed.extra) or {}
  local fields = {
    "heldItem", "happiness", "pokerus", "caughtData", "metLevel",
    "metLocation", "metTime", "gender", "form", "item",
  }
  for _, key in ipairs(fields) do
    if packed[key] ~= nil then mon[key] = packed[key]
    elseif extra[key] ~= nil then mon[key] = extra[key] end
  end
  return mon, err
end

-- Listing is same-generation only (GTS safety for Gen1 vs Gen2 clients).
function Compat.listingGenerationOk(listing)
  if not listing then return false end
  local myGen = Compat.generation()
  local gen = tonumber(listing.generation)
  if not gen and listing.offeredMon then
    gen = tonumber(listing.offeredMon.generation)
  end
  if not gen then
    -- Legacy Gen1Online listings: treat as Gen1
    gen = 1
  end
  return gen == myGen, myGen, gen
end

function Compat.timeOfDayLabel(game)
  local tod = nil
  pcall(function()
    if game and game.overworld and game.overworld.timeOfDay then
      tod = game.overworld:timeOfDay()
    end
  end)
  if type(tod) == "string" and tod ~= "" then return tod:upper() end
  -- Gen2Recomp often uses hour-based slots
  local hour = tonumber(os.date("%H")) or 12
  if hour >= 4 and hour < 10 then return "MORNING"
  elseif hour >= 10 and hour < 18 then return "DAY"
  elseif hour >= 18 and hour < 20 then return "EVENING"
  else return "NIGHT"
  end
end

function Compat.packParty(Protocol, party)
  local mons = {}
  for _, mon in ipairs(party or {}) do
    table.insert(mons, Compat.packMon(Protocol, mon))
  end
  return mons
end

-- Reject cross-generation PVP (Gen1 client vs Gen2 client).
function Compat.pvpGenerationOk(remotePackedParty)
  local myGen = Compat.generation()
  if not remotePackedParty or #remotePackedParty == 0 then
    return true, myGen, myGen
  end
  local theirGen = nil
  for _, mon in ipairs(remotePackedParty) do
    if type(mon) == "table" and mon.generation then
      theirGen = tonumber(mon.generation) or theirGen
      break
    end
  end
  if not theirGen then
    -- Legacy Gen1Online packets omit generation; treat as Gen1.
    theirGen = 1
  end
  if theirGen ~= myGen then
    return false, myGen, theirGen
  end
  return true, myGen, theirGen
end

function Compat.clientMeta()
  return {
    generation = Compat.generation(),
    versionId = Compat.versionId(),
    modId = "gen2online",
  }
end

-- Force overworld / save position to New Bark when on Gen2 (online bootstrap).
function Compat.isKantoBootMap(mapId)
  mapId = tostring(mapId or "")
  return mapId == "PALLET_TOWN" or mapId == "REDS_HOUSE_1F" or mapId == "REDS_HOUSE_2F"
    or mapId == "BLUES_HOUSE" or mapId == "OAKS_LAB"
end

-- Force overworld / save position to New Bark on Gen2.
-- Gen2Recomp Phase 2B still defaults SaveData.newGame to REDS_HOUSE_2F/Pallet.
function Compat.ensureGen2Start(save, overworld, opts)
  if not Compat.isGen2() then return end
  opts = opts or {}
  local data = opts.data
  local sp = Compat.defaultSpawn(data)
  local force = opts.force
  local outdoor = sp.outdoor or { map = sp.map, x = sp.x, y = sp.y }
  if save then
    save.player = save.player or {}
    local cur = save.player.map
    if force or not cur or Compat.isKantoBootMap(cur) then
      save.player.map = sp.map
      save.player.x = sp.x
      save.player.y = sp.y
      save.player.facing = sp.facing or "down"
    end
    if force or not save.lastHeal or Compat.isKantoBootMap(save.lastHeal.map) then
      local heal = Compat.defaultHeal(data)
      save.lastHeal = { map = heal.map, x = heal.x, y = heal.y }
    end
    if force or not save.lastOutdoor or Compat.isKantoBootMap(save.lastOutdoor.id or save.lastOutdoor.map) then
      save.lastOutdoor = { id = outdoor.map, x = outdoor.x, y = outdoor.y }
    end
  end
  if overworld and overworld.setMap then
    local om = overworld.map and overworld.map.id
    if force or not om or Compat.isKantoBootMap(om) then
      pcall(function()
        overworld:setMap(sp.map, sp.x, sp.y, sp.facing or "down")
      end)
      overworld.lastOutdoor = { id = outdoor.map, x = outdoor.x, y = outdoor.y }
    end
  end
end

return Compat
