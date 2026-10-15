-- Sprout Tower / Violet relic pickups (quest 1002)
-- Map ids from Gen2Recomp: SPROUT_TOWER1_F, SPROUT_TOWER2_F, VIOLET_CITY

local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Items = {}

local function ballSprite(data)
  local sprites = data and data.sprites or {}
  for _, id in ipairs({ "SPRITE_POKE_BALL", "SPRITE_POKEBALL", "SPRITE_BALL" }) do
    if sprites[id] then return id end
  end
  return "SPRITE_POKE_BALL"
end

local function makeBall(data, mapId, index, flag, x, y)
  local npc = NPC.new(data, mapId, {
    index = index,
    name = "RELIC",
    sprite = ballSprite(data),
    movement = "STAY",
    range = "NONE",
    x = x,
    y = y,
  })
  npc[flag] = true
  npc.px = x * 16
  npc.py = y * 16
  npc.cellX = x
  npc.cellY = y
  npc.targetPx = x * 16
  npc.targetPy = y * 16
  return npc
end

function Items.createBellNPC(data)
  return makeBall(data, "SPROUT_TOWER1_F", 91011, "isSproutBell", 5, 7)
end
function Items.createScrollNPC(data)
  return makeBall(data, "SPROUT_TOWER2_F", 91012, "isSproutScroll", 8, 5)
end
function Items.createBellFallbackNPC(data)
  return makeBall(data, "VIOLET_CITY", 91013, "isSproutBell", 10, 12)
end
function Items.createScrollFallbackNPC(data)
  return makeBall(data, "VIOLET_CITY", 91014, "isSproutScroll", 22, 14)
end
-- Tower 3F alternate if extract only exposes higher floors as enterable
function Items.createBellTower3NPC(data)
  return makeBall(data, "SPROUT_TOWER3_F", 91015, "isSproutBell", 5, 5)
end

function Items.interact(game, itemId, itemName, helpers)
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache

  local tid = getTrainerId(game.save)
  local quests = fetchPlayerQuests(game) or {}
  local q2 = quests["1002"] or quests[1002] or { state = 0, step_flags = {} }

  if (q2.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("A sealed relic. GUIDE MIRA in NEW BARK TOWN may know more.")))
    return
  end
  if (q2.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The pedestal is empty.")))
    return
  end

  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory

  if itemId == "SPROUT_BELL" and (inv["SAGE_SCROLL"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You can't carry both relics — split them with your partner!")))
    return
  end
  if itemId == "SAGE_SCROLL" and (inv["SPROUT_BELL"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You can't carry both relics — split them with your partner!")))
    return
  end
  if (inv[itemId] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have the " .. itemName .. ".")))
    return
  end

  local res = nil
  local ok, r = pcall(function()
    return questApiPost({
      action = "quest_pickup",
      trainerId = tid,
      questId = 1002,
      itemId = itemId,
    })
  end)
  if ok then res = r end

  if res and res.success == false then
    game.stack:push(TextBox.new(game, wrapText(tostring(res.message or res.error or "Cannot take this relic."))))
    return
  end

  inv[itemId] = 1
  activeQuestsCache["1002"] = activeQuestsCache["1002"] or { state = 1, step_flags = {} }
  activeQuestsCache["1002"].state = 1
  if itemId == "SPROUT_BELL" then
    activeQuestsCache["1002"].step_flags.part_a_obtained = true
  else
    activeQuestsCache["1002"].step_flags.part_b_obtained = true
  end
  game.stack:push(TextBox.new(game, wrapText(string.format("Obtained %s!", itemName))))
end

return Items
