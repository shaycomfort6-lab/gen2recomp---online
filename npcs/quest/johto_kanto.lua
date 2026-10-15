-- Late Johto + Kanto bridge NPCs/items (quests 1009–1016)
-- Map ids match Gen2Recomp data/generated_gen2_gold maps.lua / constants.lua

local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local ChoiceBox = require("src.ui.ChoiceBox")

local M = {}

local function spr(data, list)
  local s = data and data.sprites or {}
  for _, id in ipairs(list) do
    if s[id] then return id end
  end
  for k, _ in pairs(s) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return list[1] or "SPRITE_YOUNGSTER"
end

local function makeNPC(data, mapId, index, name, spriteList, x, y, flag)
  local npc = NPC.new(data, mapId, {
    index = index,
    name = name,
    sprite = spr(data, spriteList),
    movement = "STAY",
    range = "DOWN",
    x = x,
    y = y,
  })
  npc[flag] = true
  npc.facing = "down"
  npc.px, npc.py = x * 16, y * 16
  npc.cellX, npc.cellY = x, y
  npc.targetPx, npc.targetPy = x * 16, y * 16
  return npc
end

local function makeBall(data, mapId, index, x, y, flag)
  local npc = NPC.new(data, mapId, {
    index = index,
    name = "ITEM",
    sprite = spr(data, { "SPRITE_POKE_BALL", "SPRITE_POKEBALL" }),
    movement = "STAY",
    range = "NONE",
    x = x,
    y = y,
  })
  npc[flag] = true
  npc.px, npc.py = x * 16, y * 16
  npc.cellX, npc.cellY = x, y
  npc.targetPx, npc.targetPy = x * 16, y * 16
  return npc
end

local function freeze(npc, game)
  if not npc then return function() end end
  npc.frozen = true
  if game.overworld and game.overworld.player and npc.facePlayer then
    pcall(function() npc:facePlayer(game.overworld.player) end)
  end
  return function() npc.frozen = false end
end

local function qget(helpers, game, id)
  local quests = helpers.fetchPlayerQuests(game) or {}
  return quests[tostring(id)] or quests[id] or { state = 0, step_flags = {} }
end

local function cache(helpers, id, state, flags)
  local c = helpers.activeQuestsCache
  c[tostring(id)] = c[tostring(id)] or { state = 0, step_flags = {} }
  if state ~= nil then c[tostring(id)].state = state end
  if flags then
    c[tostring(id)].step_flags = c[tostring(id)].step_flags or {}
    for k, v in pairs(flags) do c[tostring(id)].step_flags[k] = v end
  end
end

local function grantItems(game, id, n)
  game.save.inventory = game.save.inventory or {}
  game.save.inventory[id] = (game.save.inventory[id] or 0) + (n or 1)
end

local function grantMon(game, species, level)
  pcall(function()
    local Pokemon = require("src.pokemon.Pokemon")
    local Party = require("src.pokemon.Party")
    if not (game.data and game.data.pokemon) then return end
    if not game.data.pokemon[species] then
      for k, _ in pairs(game.data.pokemon) do
        if type(k) == "string" and k:upper():find(species:upper()) then
          species = k
          break
        end
      end
    end
    if game.data.pokemon[species] then
      local mon = Pokemon.new(game.data, species, level)
      if mon then Party.add(game.save.party, mon) end
    end
  end)
end

-- ===== creators =====
function M.createSailorLight(data)
  return makeNPC(data, "OLIVINE_CITY", 91100, "SAILOR LIGHT",
    { "SPRITE_SAILOR", "SPRITE_FISHER", "SPRITE_YOUNGSTER" }, 14, 18, "isSailorLight")
end
function M.createLampOil(data)
  return makeBall(data, "OLIVINE_LIGHTHOUSE1_F", 91101, 6, 6, "isLampOil")
end
function M.createLampOilFallback(data)
  return makeBall(data, "OLIVINE_CITY", 91102, 20, 12, "isLampOil")
end

function M.createPharmacyAide(data)
  return makeNPC(data, "CIANWOOD_CITY", 91110, "PHARMACY AIDE",
    { "SPRITE_BEAUTY", "SPRITE_LASS", "SPRITE_COOLTRAINER_F", "SPRITE_YOUNGSTER" }, 12, 14, "isPharmacyAide")
end

function M.createDirector(data)
  return makeNPC(data, "RADIO_TOWER1_F", 91120, "DIRECTOR",
    { "SPRITE_GENTLEMAN", "SPRITE_SUPER_NERD", "SPRITE_OAK", "SPRITE_YOUNGSTER" }, 8, 6, "isRadioDirector")
end
function M.createCardKey(data)
  return makeBall(data, "RADIO_TOWER2_F", 91121, 5, 5, "isCardKey")
end
function M.createTxCore(data)
  return makeBall(data, "RADIO_TOWER3_F", 91122, 7, 5, "isTxCore")
end
function M.createCardKeyFallback(data)
  return makeBall(data, "GOLDENROD_CITY", 91123, 8, 16, "isCardKey")
end
function M.createTxCoreFallback(data)
  return makeBall(data, "GOLDENROD_CITY", 91124, 24, 16, "isTxCore")
end

function M.createDenGuard(data)
  return makeNPC(data, "BLACKTHORN_CITY", 91130, "DEN GUARD",
    { "SPRITE_COOLTRAINER_M", "SPRITE_BLACKBELT", "SPRITE_YOUNGSTER" }, 14, 12, "isDenGuard")
end
function M.createIceBeacon(data)
  return makeBall(data, "ICE_PATH1_F", 91131, 8, 8, "isIceBeacon")
end
function M.createIceBeaconFallback(data)
  return makeBall(data, "BLACKTHORN_CITY", 91132, 10, 18, "isIceBeacon")
end

function M.createElder(data)
  return makeNPC(data, "BLACKTHORN_CITY", 91140, "ELDER",
    { "SPRITE_SAGE", "SPRITE_ELDER", "SPRITE_SUPER_NERD", "SPRITE_OAK" }, 18, 10, "isDragonElder")
end
function M.createDragonToken(data)
  return makeBall(data, "DRAGONS_DEN_B1_F", 91141, 10, 10, "isDragonToken")
end
function M.createDragonTokenFallback(data)
  return makeBall(data, "BLACKTHORN_CITY", 91142, 22, 18, "isDragonToken")
end

function M.createFallsGuide(data)
  return makeNPC(data, "TOHJO_FALLS", 91150, "FALLS GUIDE",
    { "SPRITE_HIKER", "SPRITE_FISHER", "SPRITE_YOUNGSTER" }, 10, 10, "isFallsGuide")
end
function M.createGateRanger(data)
  return makeNPC(data, "ROUTE26", 91151, "GATE RANGER",
    { "SPRITE_OFFICER", "SPRITE_YOUNGSTER", "SPRITE_HIKER" }, 12, 20, "isGateRanger")
end

function M.createCustomsClerk(data)
  return makeNPC(data, "VIRIDIAN_CITY", 91160, "CUSTOMS CLERK",
    { "SPRITE_CLERK", "SPRITE_GENTLEMAN", "SPRITE_YOUNGSTER" }, 16, 14, "isCustomsClerk")
end

function M.createIndigoClerk(data)
  return makeNPC(data, "INDIGO_PLATEAU_POKECENTER1_F", 91170, "INDIGO CLERK",
    { "SPRITE_NURSE", "SPRITE_CLERK", "SPRITE_YOUNGSTER" }, 6, 6, "isIndigoClerk")
end
function M.createOakAide(data)
  return makeNPC(data, "PALLET_TOWN", 91171, "OAK'S AIDE",
    { "SPRITE_SCIENTIST", "SPRITE_SUPER_NERD", "SPRITE_OAK", "SPRITE_YOUNGSTER" }, 8, 8, "isOakAide")
end

-- ===== interactions =====
function M.interactSailorLight(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q9 = qget(helpers, game, 1009)
  local q10 = qget(helpers, game, 1010)

  if (q10.state or 0) ~= 2 and (inv["SECRET_MEDICINE"] or 0) > 0 then
    inv["SECRET_MEDICINE"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1010 }) end)
    cache(helpers, 1010, 2, { deliver_olivine = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 700) end
    grantItems(game, "FULL_HEAL", 3)
    game.stack:push(TextBox.new(game, wrapText("Medicine received — the Amphy will recover! (+3 FULL HEAL, +700 XP)"), unfreeze))
    return
  end

  if (q9.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The lighthouse beam is steady. If you sail to Cianwood, the pharmacy may need a runner."), unfreeze))
    return
  end
  if (inv["LAMP_OIL"] or 0) > 0 then
    inv["LAMP_OIL"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1009 }) end)
    cache(helpers, 1009, 2, { deliver_oil = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 700) end
    grantItems(game, "SUPER_REPEL", 3)
    game.stack:push(TextBox.new(game, wrapText("Lamp oil poured! (+3 SUPER REPEL, +700 XP)"), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1009 }) end)
  cache(helpers, 1009, 1, { started = true })
  game.stack:push(TextBox.new(game, wrapText("Fetch LAMP OIL from OLIVINE LIGHTHOUSE and bring it back here!"), unfreeze))
end

function M.interactLampOil(game, helpers)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["LAMP_OIL"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have LAMP OIL.")))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1009 }) end)
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1009, itemId = "LAMP_OIL" }) end)
  game.save.inventory["LAMP_OIL"] = 1
  cache(helpers, 1009, 1, { get_oil = true })
  game.stack:push(TextBox.new(game, wrapText("Obtained LAMP OIL!")))
end

function M.interactPharmacyAide(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local q = qget(helpers, game, 1010)
  game.save.inventory = game.save.inventory or {}
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Glad the medicine reached Olivine."), unfreeze))
    return
  end
  if (game.save.inventory["SECRET_MEDICINE"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("Deliver SECRET MEDICINE to SAILOR LIGHT in OLIVINE CITY!"), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1010 }) end)
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1010, itemId = "SECRET_MEDICINE" }) end)
  game.save.inventory["SECRET_MEDICINE"] = 1
  cache(helpers, 1010, 1, { get_medicine = true })
  game.stack:push(TextBox.new(game, wrapText("Take this SECRET MEDICINE across the sea to SAILOR LIGHT in Olivine!"), unfreeze))
end

function M.interactDirector(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local q = qget(helpers, game, 1011)
  local inv = game.save.inventory or {}
  game.save.inventory = inv

  if (q.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("Rocket jamming the tower! Two trainers needed. Accept the siege quest?"), function()
      game.stack:push(ChoiceBox.new(game, function(yes)
        if yes then
          pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1011 }) end)
          cache(helpers, 1011, 1, { part_a_obtained = false, part_b_obtained = false })
          game.stack:push(TextBox.new(game, wrapText("Recover CARD KEY and TRANSMITTER CORE on the upper floors. One each — return together!"), unfreeze))
        else
          game.stack:push(TextBox.new(game, wrapText("We need a team…"), unfreeze))
        end
      end))
    end))
    return
  end
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Broadcasts are clear again. Thank you!"), unfreeze))
    return
  end
  local hasA = (inv["CARD_KEY"] or 0) > 0
  local hasB = (inv["TX_CORE"] or 0) > 0
  if hasA and hasB then
    game.stack:push(TextBox.new(game, wrapText("Split the parts with your partner!"), unfreeze))
    return
  end
  if not hasA and not hasB then
    game.stack:push(TextBox.new(game, wrapText("Bring CARD KEY or TRANSMITTER CORE — partner holds the other."), unfreeze))
    return
  end
  local res
  pcall(function()
    res = helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1011, p1Inventory = inv })
  end)
  if res and res.success == false then
    game.stack:push(TextBox.new(game, wrapText(tostring(res.message or res.error or "Need a party partner.")), unfreeze))
    return
  end
  inv["CARD_KEY"] = nil
  inv["TX_CORE"] = nil
  cache(helpers, 1011, 2, { completed = true })
  local xp = (res and res.data and res.data.rewardXp) or 1200
  if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", xp) end
  grantMon(game, "MAGNETON", 25)
  game.stack:push(TextBox.new(game, wrapText("Tower secured! MAGNETON (Lv25) and +" .. tostring(xp) .. " XP!"), unfreeze))
end

local function pickupCoop(game, helpers, questId, itemId, itemName, flag)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local q = qget(helpers, game, questId)
  if (q.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("A sealed device. Speak to the DIRECTOR on Radio Tower 1F.")))
    return
  end
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Empty.")))
    return
  end
  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory
  local other = (itemId == "CARD_KEY") and "TX_CORE" or "CARD_KEY"
  if (inv[other] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You can't carry both tower parts!")))
    return
  end
  if (inv[itemId] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have the " .. itemName .. ".")))
    return
  end
  local res
  pcall(function()
    res = helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = questId, itemId = itemId })
  end)
  if res and res.success == false then
    game.stack:push(TextBox.new(game, wrapText(tostring(res.message or res.error or "Blocked."))))
    return
  end
  inv[itemId] = 1
  cache(helpers, questId, 1, { [flag] = true })
  game.stack:push(TextBox.new(game, wrapText("Obtained " .. itemName .. "!")))
end

function M.interactCardKey(game, helpers)
  pickupCoop(game, helpers, 1011, "CARD_KEY", "CARD KEY", "part_a_obtained")
end
function M.interactTxCore(game, helpers)
  pickupCoop(game, helpers, 1011, "TX_CORE", "TRANSMITTER CORE", "part_b_obtained")
end

function M.interactDenGuard(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(helpers, game, 1012)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Ice Path is marked. Safe travels to the Den."), unfreeze))
    return
  end
  if (inv["ICE_BEACON"] or 0) > 0 then
    inv["ICE_BEACON"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1012 }) end)
    cache(helpers, 1012, 2, { report_blackthorn = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 800) end
    grantItems(game, "MAX_POTION", 2)
    game.stack:push(TextBox.new(game, wrapText("Beacon logged. (+2 MAX POTION, +800 XP)"), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1012 }) end)
  cache(helpers, 1012, 1, { started = true })
  game.stack:push(TextBox.new(game, wrapText("Find the ICE BEACON on ICE PATH 1F and bring word back here."), unfreeze))
end

function M.interactIceBeacon(game, helpers)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["ICE_BEACON"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have the ICE BEACON.")))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1012 }) end)
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1012, itemId = "ICE_BEACON" }) end)
  game.save.inventory["ICE_BEACON"] = 1
  cache(helpers, 1012, 1, { get_beacon = true })
  game.stack:push(TextBox.new(game, wrapText("Obtained ICE BEACON!")))
end

function M.interactElder(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(helpers, game, 1013)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The dragons acknowledge your courage."), unfreeze))
    return
  end
  if (inv["DRAGON_TOKEN"] or 0) > 0 then
    inv["DRAGON_TOKEN"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1013 }) end)
    cache(helpers, 1013, 2, { show_elder = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 1000) end
    grantMon(game, "DRATINI", 10)
    game.stack:push(TextBox.new(game, wrapText("Trial complete. Take this DRATINI (Lv10)! (+1000 XP)"), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1013 }) end)
  cache(helpers, 1013, 1, { started = true })
  game.stack:push(TextBox.new(game, wrapText("Bring a DRAGON TOKEN from DRAGON'S DEN B1F."), unfreeze))
end

function M.interactDragonToken(game, helpers)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["DRAGON_TOKEN"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already hold the DRAGON TOKEN.")))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1013 }) end)
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1013, itemId = "DRAGON_TOKEN" }) end)
  game.save.inventory["DRAGON_TOKEN"] = 1
  cache(helpers, 1013, 1, { get_token = true })
  game.stack:push(TextBox.new(game, wrapText("Obtained DRAGON TOKEN!")))
end

function M.interactFallsGuide(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  game.save.inventory = game.save.inventory or {}
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1014 }) end)
  game.save.inventory["KANDTO_PASS"] = 1
  -- typo fix: KANTO_PASS
  game.save.inventory["KANDTO_PASS"] = nil
  game.save.inventory["KANTO_PASS"] = 1
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1014, itemId = "KANTO_PASS" }) end)
  cache(helpers, 1014, 1, { visit_falls = true })
  game.stack:push(TextBox.new(game, wrapText("Beyond these falls lies Kanto.\\fTake this KANTO PASS to GATE RANGER on ROUTE 26."), unfreeze))
end

function M.interactGateRanger(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(helpers, game, 1014)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Road to Kanto is open. Mind Victory Road."), unfreeze))
    return
  end
  if (inv["KANTO_PASS"] or 0) > 0 then
    inv["KANTO_PASS"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1014 }) end)
    cache(helpers, 1014, 2, { route26_check = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 900) end
    grantItems(game, "ULTRA_BALL", 5)
    game.stack:push(TextBox.new(game, wrapText("Pass stamped. (+5 ULTRA BALL, +900 XP)\\fNext stop: VIRIDIAN CITY customs."), unfreeze))
    return
  end
  game.stack:push(TextBox.new(game, wrapText("Get a KANTO PASS from FALLS GUIDE at TOHJO FALLS."), unfreeze))
end

function M.interactCustomsClerk(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local q = qget(helpers, game, 1015)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Clearance already filed. Head toward Indigo when ready."), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1015 }) end)
  pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1015 }) end)
  cache(helpers, 1015, 2, { clearance = true, file_customs = true, completed = true })
  if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 900) end
  grantItems(game, "MAX_REVIVE", 1)
  game.stack:push(TextBox.new(game, wrapText("Johto clearance accepted. (+1 MAX REVIVE, +900 XP)\\fFile your expedition at INDIGO PLATEAU next."), unfreeze))
end

function M.interactIndigoClerk(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local q = qget(helpers, game, 1016)
  game.save.inventory = game.save.inventory or {}
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Your Indigo file is complete."), unfreeze))
    return
  end
  pcall(function() helpers.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1016 }) end)
  game.save.inventory["INDIGO_FILE"] = 1
  pcall(function() helpers.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1016, itemId = "INDIGO_FILE" }) end)
  cache(helpers, 1016, 1, { indigo_file = true })
  game.stack:push(TextBox.new(game, wrapText("Expedition filed.\\fDeliver this INDIGO FILE postcard to OAK'S AIDE in PALLET TOWN to close the Johto→Kanto online story!"), unfreeze))
end

function M.interactOakAide(game, npc, helpers)
  local unfreeze = freeze(npc, game)
  local wrapText = helpers.wrapText
  local tid = helpers.getTrainerId(game.save)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(helpers, game, 1016)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Oak smiled at your postcard. Welcome to Kanto Online!"), unfreeze))
    return
  end
  if (inv["INDIGO_FILE"] or 0) > 0 then
    inv["INDIGO_FILE"] = nil
    pcall(function() helpers.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1016 }) end)
    cache(helpers, 1016, 2, { pallet_postcard = true, completed = true })
    if helpers.awardOnlineXp then pcall(helpers.awardOnlineXp, game, "quest", 1500) end
    grantItems(game, "MASTER_BALL", 1)
    game.stack:push(TextBox.new(game, wrapText(
      "Postcard delivered! Johto→Kanto online expedition complete!\\f(+1 MASTER BALL, +1500 XP)\\fYou've walked the whole online road from NEW BARK to PALLET."
    ), unfreeze))
    return
  end
  game.stack:push(TextBox.new(game, wrapText("Bring an INDIGO FILE from the Indigo Plateau Poké Center."), unfreeze))
end

return M
