-- Gen2 Kanto story + Indigo League + Mt. Silver (quests 1017–1026)
-- Map IDs: Gen2Recomp constants (JANINE/BLUE flavor is Gen2-specific)

local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local M = {}

local function spr(data, list)
  local s = data and data.sprites or {}
  for _, id in ipairs(list) do if s[id] then return id end end
  for k, _ in pairs(s) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return list[1] or "SPRITE_YOUNGSTER"
end

local function makeNPC(data, mapId, index, name, sprites, x, y, flag)
  local npc = NPC.new(data, mapId, {
    index = index, name = name, sprite = spr(data, sprites),
    movement = "STAY", range = "DOWN", x = x, y = y,
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
    index = index, name = "ITEM",
    sprite = spr(data, { "SPRITE_POKE_BALL", "SPRITE_POKEBALL" }),
    movement = "STAY", range = "NONE", x = x, y = y,
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

local function qget(h, game, id)
  local q = h.fetchPlayerQuests(game) or {}
  return q[tostring(id)] or q[id] or { state = 0, step_flags = {} }
end

local function cache(h, id, state, flags)
  local c = h.activeQuestsCache
  c[tostring(id)] = c[tostring(id)] or { state = 0, step_flags = {} }
  if state ~= nil then c[tostring(id)].state = state end
  if flags then
    c[tostring(id)].step_flags = c[tostring(id)].step_flags or {}
    for k, v in pairs(flags) do c[tostring(id)].step_flags[k] = v end
  end
end

local function grant(game, item, n)
  game.save.inventory = game.save.inventory or {}
  game.save.inventory[item] = (game.save.inventory[item] or 0) + (n or 1)
end

local function completeSolo(game, h, qid, xp, item, count, msg, unfreeze)
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = qid }) end)
  pcall(function() h.questApiPost({ action = "quest_turn_in", trainerId = tid, questId = qid }) end)
  cache(h, qid, 2, { completed = true })
  if h.awardOnlineXp then pcall(h.awardOnlineXp, game, "quest", xp) end
  if item then grant(game, item, count or 1) end
  game.stack:push(TextBox.new(game, h.wrapText(msg), unfreeze))
end

-- ===== creators =====
function M.createPewterGuide(data)
  return makeNPC(data, "PEWTER_CITY", 91300, "PEWTER GUIDE",
    { "SPRITE_HIKER", "SPRITE_YOUNGSTER" }, 14, 14, "isPewterGuide")
end
function M.createCeruleanAide(data)
  return makeNPC(data, "CERULEAN_CITY", 91301, "SIGNAL AIDE",
    { "SPRITE_LASS", "SPRITE_BEAUTY", "SPRITE_YOUNGSTER" }, 14, 12, "isCeruleanAide")
end
function M.createVermilionClerk(data)
  return makeNPC(data, "VERMILION_CITY", 91302, "PORT CLERK",
    { "SPRITE_SAILOR", "SPRITE_FISHER", "SPRITE_YOUNGSTER" }, 12, 16, "isVermilionClerk")
end
function M.createCeladonClerk(data)
  return makeNPC(data, "CELADON_CITY", 91303, "DEPT CLERK",
    { "SPRITE_CLERK", "SPRITE_BEAUTY", "SPRITE_YOUNGSTER" }, 18, 14, "isCeladonClerk")
end
function M.createNetworkTicket(data)
  return makeBall(data, "CELADON_CITY", 91304, 10, 18, "isNetworkTicket")
end
function M.createJanineAide(data)
  return makeNPC(data, "FUCHSIA_CITY", 91310, "JANINE'S AIDE",
    { "SPRITE_LASS", "SPRITE_COOLTRAINER_F", "SPRITE_YOUNGSTER" }, 14, 12, "isJanineAide")
end
function M.createSaffronNode(data)
  return makeNPC(data, "SAFFRON_CITY", 91311, "PSY NODE",
    { "SPRITE_SUPER_NERD", "SPRITE_SCIENTIST", "SPRITE_YOUNGSTER" }, 16, 14, "isSaffronNode")
end
function M.createPsyCrystal(data)
  return makeBall(data, "SAFFRON_CITY", 91312, 8, 18, "isPsyCrystal")
end
function M.createCinnabarAide(data)
  return makeNPC(data, "CINNABAR_ISLAND", 91313, "ISLAND AIDE",
    { "SPRITE_SCIENTIST", "SPRITE_SUPER_NERD", "SPRITE_YOUNGSTER" }, 10, 10, "isCinnabarAide")
end
function M.createVolcanicAsh(data)
  return makeBall(data, "CINNABAR_ISLAND", 91314, 14, 12, "isVolcanicAsh")
end
function M.createBlueFan(data)
  return makeNPC(data, "VIRIDIAN_CITY", 91315, "BLUE'S FAN",
    { "SPRITE_YOUNGSTER", "SPRITE_COOLTRAINER_M", "SPRITE_RED" }, 12, 18, "isBlueFan")
end

-- League seals / stamps
function M.createVRStamp(data)
  return makeBall(data, "VICTORY_ROAD", 91320, 10, 10, "isVRStamp")
end
function M.createVRStampGate(data)
  return makeBall(data, "VICTORY_ROAD_GATE", 91321, 6, 6, "isVRStamp")
end
function M.createWillSeal(data)
  return makeBall(data, "WILLS_ROOM", 91322, 5, 5, "isWillSeal")
end
function M.createKogaSeal(data)
  return makeBall(data, "KOGAS_ROOM", 91323, 5, 5, "isKogaSeal")
end
function M.createBrunoSeal(data)
  return makeBall(data, "BRUNOS_ROOM", 91324, 5, 5, "isBrunoSeal")
end
function M.createKarenSeal(data)
  return makeBall(data, "KARENS_ROOM", 91325, 5, 5, "isKarenSeal")
end
function M.createLanceSeal(data)
  return makeBall(data, "LANCES_ROOM", 91326, 5, 5, "isLanceSeal")
end
function M.createChampClerk(data)
  return makeNPC(data, "INDIGO_PLATEAU_POKECENTER1_F", 91327, "LEAGUE CLERK",
    { "SPRITE_NURSE", "SPRITE_CLERK", "SPRITE_YOUNGSTER" }, 10, 6, "isLeagueClerk")
end
-- Fallbacks in Indigo PC if E4 maps stubbed
function M.createWillSealFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91328, 3, 8, "isWillSeal")
end
function M.createKogaSealFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91329, 4, 8, "isKogaSeal")
end
function M.createBrunoSealFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91330, 5, 8, "isBrunoSeal")
end
function M.createKarenSealFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91331, 6, 8, "isKarenSeal")
end
function M.createLanceSealFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91332, 7, 8, "isLanceSeal")
end
function M.createVRStampFB(data)
  return makeBall(data, "INDIGO_PLATEAU_POKECENTER1_F", 91333, 8, 8, "isVRStamp")
end

-- Mt. Silver
function M.createSilverEmblem(data)
  return makeBall(data, "SILVER_CAVE_ROOM3", 91340, 8, 8, "isSilverEmblem")
end
function M.createSilverEmblemR1(data)
  return makeBall(data, "SILVER_CAVE_ROOM1", 91341, 6, 6, "isSilverEmblem")
end
function M.createSilverEmblemOutside(data)
  return makeBall(data, "SILVER_CAVE_OUTSIDE", 91342, 10, 10, "isSilverEmblem")
end
function M.createSummitTrainer(data)
  return makeNPC(data, "SILVER_CAVE_ROOM3", 91343, "SUMMIT TRAINER",
    { "SPRITE_RED", "SPRITE_COOLTRAINER_M", "SPRITE_YOUNGSTER" }, 10, 6, "isSummitTrainer")
end
function M.createSummitTrainerOutside(data)
  return makeNPC(data, "SILVER_CAVE_OUTSIDE", 91344, "SUMMIT TRAINER",
    { "SPRITE_RED", "SPRITE_COOLTRAINER_M", "SPRITE_YOUNGSTER" }, 12, 8, "isSummitTrainer")
end
function M.createSummitTrainerR28(data)
  return makeNPC(data, "ROUTE28", 91345, "SUMMIT TRAINER",
    { "SPRITE_RED", "SPRITE_COOLTRAINER_M", "SPRITE_YOUNGSTER" }, 10, 10, "isSummitTrainer")
end

-- ===== interactions: Kanto cities =====
local function simpleCity(game, npc, h, qid, xp, item, n, doneMsg, startMsg)
  local unfreeze = freeze(npc, game)
  local q = qget(h, game, qid)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText(doneMsg), unfreeze))
    return
  end
  completeSolo(game, h, qid, xp, item, n, startMsg, unfreeze)
end

function M.interactPewterGuide(game, npc, h)
  simpleCity(game, npc, h, 1017, 500, "GUARD_SPEC", 3,
    "Pewter leg already logged.",
    "Welcome to Gen2 Kanto! Pewter checkpoint logged. (+3 GUARD SPEC., +500 XP)\\fCerulean is next.")
end
function M.interactCeruleanAide(game, npc, h)
  simpleCity(game, npc, h, 1018, 500, "X_ACCURACY", 3,
    "Cerulean relay is stable.",
    "Cerulean signal locked. (+3 X ACCURACY, +500 XP)\\fHead to Vermilion Port.")
end
function M.interactVermilionClerk(game, npc, h)
  simpleCity(game, npc, h, 1019, 500, "MAX_REPEL", 3,
    "Port already stamped.",
    "Johto→Kanto port pass stamped. (+3 MAX REPEL, +500 XP)\\fCeladon Dept. Store is next.")
end

function M.interactNetworkTicket(game, h)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["NETWORK_TICKET"] or 0) > 0 then
    game.stack:push(TextBox.new(game, h.wrapText("You already have a NETWORK TICKET.")))
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1020 }) end)
  pcall(function() h.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1020, itemId = "NETWORK_TICKET" }) end)
  game.save.inventory["NETWORK_TICKET"] = 1
  cache(h, 1020, 1, { get_ticket = true })
  game.stack:push(TextBox.new(game, h.wrapText("Obtained NETWORK TICKET!")))
end

function M.interactCeladonClerk(game, npc, h)
  local unfreeze = freeze(npc, game)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(h, game, 1020)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("Celadon node is online."), unfreeze))
    return
  end
  if (inv["NETWORK_TICKET"] or 0) > 0 then
    inv["NETWORK_TICKET"] = nil
    completeSolo(game, h, 1020, 600, "PP_UP", 1,
      "Network ticket filed! (+1 PP UP, +600 XP)\\fNext: Fuchsia — Janine's city (Gen2).", unfreeze)
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1020 }) end)
  cache(h, 1020, 1, { started = true })
  game.stack:push(TextBox.new(game, h.wrapText("Find a NETWORK TICKET in Celadon and bring it here."), unfreeze))
end

function M.interactJanineAide(game, npc, h)
  simpleCity(game, npc, h, 1021, 700, "ANTIDOTE", 10,
    "Janine's dojo brief already done.",
    "In Gold/Silver, Janine leads Fuchsia Gym — Koga moved to the Elite Four!\\f(+10 ANTIDOTE, +700 XP)\\fSaffron is next.")
end

function M.interactPsyCrystal(game, h)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["PSY_CRYSTAL"] or 0) > 0 then
    game.stack:push(TextBox.new(game, h.wrapText("You already have a PSY CRYSTAL.")))
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1022 }) end)
  pcall(function() h.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1022, itemId = "PSY_CRYSTAL" }) end)
  game.save.inventory["PSY_CRYSTAL"] = 1
  cache(h, 1022, 1, { get_crystal = true })
  game.stack:push(TextBox.new(game, h.wrapText("Obtained PSY CRYSTAL!")))
end

function M.interactSaffronNode(game, npc, h)
  local unfreeze = freeze(npc, game)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(h, game, 1022)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("Saffron psy-net is calibrated."), unfreeze))
    return
  end
  if (inv["PSY_CRYSTAL"] or 0) > 0 then
    inv["PSY_CRYSTAL"] = nil
    completeSolo(game, h, 1022, 700, "UP_GRADE", 1,
      "Psy-net calibrated. (+1 UP-GRADE, +700 XP)\\fCinnabar Island next.", unfreeze)
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1022 }) end)
  cache(h, 1022, 1, { started = true })
  game.stack:push(TextBox.new(game, h.wrapText("Bring a PSY CRYSTAL from the city."), unfreeze))
end

function M.interactVolcanicAsh(game, h)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["VOLCANIC_ASH"] or 0) > 0 then
    game.stack:push(TextBox.new(game, h.wrapText("You already have VOLCANIC ASH.")))
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1023 }) end)
  pcall(function() h.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1023, itemId = "VOLCANIC_ASH" }) end)
  game.save.inventory["VOLCANIC_ASH"] = 1
  cache(h, 1023, 1, { get_ash = true })
  game.stack:push(TextBox.new(game, h.wrapText("Obtained VOLCANIC ASH!")))
end

function M.interactCinnabarAide(game, npc, h)
  local unfreeze = freeze(npc, game)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(h, game, 1023)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("Cinnabar report filed."), unfreeze))
    return
  end
  if (inv["VOLCANIC_ASH"] or 0) > 0 then
    inv["VOLCANIC_ASH"] = nil
    completeSolo(game, h, 1023, 700, "ESCAPE_ROPE", 5,
      "Ash sample logged. (+5 ESCAPE ROPE, +700 XP)\\fViridian — Blue holds the gym in Gen2!", unfreeze)
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1023 }) end)
  cache(h, 1023, 1, { started = true })
  game.stack:push(TextBox.new(game, h.wrapText("Collect VOLCANIC ASH on the island."), unfreeze))
end

function M.interactBlueFan(game, npc, h)
  simpleCity(game, npc, h, 1024, 800, "MAX_POTION", 3,
    "Blue's legend already heard.",
    "In Gold/Silver, BLUE is Viridian's Gym Leader — the Champion path starts here!\\f(+3 MAX POTION, +800 XP)\\fVictory Road & the Elite Four await.")
end

-- ===== League seals =====
local sealItems = {
  isVRStamp = { item = "VR_STAMP", flag = "vr_stamp", label = "VICTORY ROAD STAMP" },
  isWillSeal = { item = "WILL_SEAL", flag = "will", label = "WILL'S SEAL" },
  isKogaSeal = { item = "KOGA_SEAL", flag = "koga", label = "KOGA'S SEAL" },
  isBrunoSeal = { item = "BRUNO_SEAL", flag = "bruno", label = "BRUNO'S SEAL" },
  isKarenSeal = { item = "KAREN_SEAL", flag = "karen", label = "KAREN'S SEAL" },
  isLanceSeal = { item = "LANCE_SEAL", flag = "lance", label = "LANCE'S SEAL" },
}

function M.interactSeal(game, h, flagKey)
  local meta = sealItems[flagKey]
  if not meta then return end
  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory
  if (inv[meta.item] or 0) > 0 then
    game.stack:push(TextBox.new(game, h.wrapText("You already hold the " .. meta.label .. ".")))
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1025 }) end)
  pcall(function() h.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1025, itemId = meta.item }) end)
  inv[meta.item] = 1
  cache(h, 1025, 1, { [meta.flag] = true })
  game.stack:push(TextBox.new(game, h.wrapText("Obtained " .. meta.label .. "!")))
end

function M.interactLeagueClerk(game, npc, h)
  local unfreeze = freeze(npc, game)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(h, game, 1025)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("Champion path recorded. Mt. Silver waits beyond…"), unfreeze))
    return
  end
  local need = { "VR_STAMP", "WILL_SEAL", "KOGA_SEAL", "BRUNO_SEAL", "KAREN_SEAL", "LANCE_SEAL" }
  local missing = {}
  for _, id in ipairs(need) do
    if (inv[id] or 0) < 1 then missing[#missing + 1] = id:gsub("_", " ") end
  end
  if #missing > 0 then
    local tid = h.getTrainerId(game.save)
    pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1025 }) end)
    cache(h, 1025, 1, { started = true })
    game.stack:push(TextBox.new(game, h.wrapText(
      "Bring all League seals:\\fVictory Road, Will, Koga, Bruno, Karen, Lance.\\fMissing: " .. table.concat(missing, ", ")
    ), unfreeze))
    return
  end
  for _, id in ipairs(need) do inv[id] = nil end
  inv["CHAMP_SEAL"] = 1
  completeSolo(game, h, 1025, 2000, "RARE_CANDY", 3,
    "INDIGO LEAGUE online path complete!\\f(+3 RARE CANDY, +2000 XP)\\fClimb MT. SILVER for the final chapter.", unfreeze)
end

-- ===== Mt. Silver =====
function M.interactSilverEmblem(game, h)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["SILVER_EMBLEM"] or 0) > 0 then
    game.stack:push(TextBox.new(game, h.wrapText("You already have the SILVER EMBLEM.")))
    return
  end
  local tid = h.getTrainerId(game.save)
  pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1026 }) end)
  pcall(function() h.questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1026, itemId = "SILVER_EMBLEM" }) end)
  game.save.inventory["SILVER_EMBLEM"] = 1
  cache(h, 1026, 1, { emblem = true, enter_silver = true })
  game.stack:push(TextBox.new(game, h.wrapText("Obtained SILVER EMBLEM! Seek the Summit Trainer.")))
end

function M.interactSummitTrainer(game, npc, h)
  local unfreeze = freeze(npc, game)
  local inv = game.save.inventory or {}
  game.save.inventory = inv
  local q = qget(h, game, 1026)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("…The peak is quiet. You have already proven yourself."), unfreeze))
    return
  end
  if (inv["SILVER_EMBLEM"] or 0) < 1 then
    local tid = h.getTrainerId(game.save)
    pcall(function() h.questApiPost({ action = "quest_accept", trainerId = tid, questId = 1026 }) end)
    cache(h, 1026, 1, { enter_silver = true })
    game.stack:push(TextBox.new(game, h.wrapText("…Bring the SILVER EMBLEM from deeper in the cave."), unfreeze))
    return
  end
  inv["SILVER_EMBLEM"] = nil
  completeSolo(game, h, 1026, 2500, "MASTER_BALL", 1,
    "…You climbed from NEW BARK to MT. SILVER.\\fThe online legend is complete.\\f(+1 MASTER BALL, +2500 XP)", unfreeze)
end


function M.createContestHost(data)
  return makeNPC(data, "NATIONAL_PARK", 91350, "CONTEST HOST",
    { "SPRITE_OFFICER", "SPRITE_YOUNGSTER", "SPRITE_BUG_CATCHER" }, 12, 12, "isContestHost")
end
function M.createContestHostGate(data)
  return makeNPC(data, "ROUTE35_NATIONAL_PARK_GATE", 91351, "CONTEST HOST",
    { "SPRITE_OFFICER", "SPRITE_YOUNGSTER" }, 6, 6, "isContestHost")
end

function M.interactContestHost(game, npc, h)
  local unfreeze = freeze(npc, game)
  local q = qget(h, game, 1027)
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, h.wrapText("Contest registration is on file. Catch bugs the old-fashioned way!"), unfreeze))
    return
  end
  completeSolo(game, h, 1027, 600, "NET_BALL", 5,
    "Online Bug Contest checkpoint cleared!\f(+5 NET BALL, +600 XP)\fReal contest rules still use the park scripts.", unfreeze)
end

return M

