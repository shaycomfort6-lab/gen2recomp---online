-- Slowpoke Well relic pickups (quest 1005)
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local Items = {}

local function ball(data, mapId, index, flag, x, y)
  local sprites = data and data.sprites or {}
  local sprite = "SPRITE_POKE_BALL"
  for _, id in ipairs({"SPRITE_POKE_BALL","SPRITE_POKEBALL"}) do
    if sprites[id] then sprite = id break end
  end
  local npc = NPC.new(data, mapId, {
    index = index, name = "RELIC", sprite = sprite,
    movement = "STAY", range = "NONE", x = x, y = y,
  })
  npc[flag] = true
  npc.px, npc.py = x*16, y*16
  npc.cellX, npc.cellY = x, y
  npc.targetPx, npc.targetPy = x*16, y*16
  return npc
end

function Items.createCharmNPC(data)
  return ball(data, "SLOWPOKE_WELL_B1_F", 91031, "isWellCharm", 6, 8)
end
function Items.createBucketNPC(data)
  return ball(data, "SLOWPOKE_WELL_B2_F", 91032, "isWellBucket", 8, 6)
end
function Items.createCharmFallbackNPC(data)
  return ball(data, "AZALEA_TOWN", 91033, "isWellCharm", 8, 14)
end
function Items.createBucketFallbackNPC(data)
  return ball(data, "AZALEA_TOWN", 91034, "isWellBucket", 22, 14)
end

function Items.interact(game, itemId, itemName, helpers)
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache

  local tid = getTrainerId(game.save)
  local q = (fetchPlayerQuests(game) or {})["1005"] or { state = 0 }
  if (q.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("A sealed well relic. Talk to KURT'S AIDE in AZALEA TOWN.")))
    return
  end
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Empty.")))
    return
  end
  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory
  if itemId == "WELL_CHARM" and (inv["WELL_BUCKET"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You can't carry both well relics!")))
    return
  end
  if itemId == "WELL_BUCKET" and (inv["WELL_CHARM"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You can't carry both well relics!")))
    return
  end
  if (inv[itemId] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have the " .. itemName .. ".")))
    return
  end
  local res
  pcall(function()
    res = questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1005, itemId = itemId })
  end)
  if res and res.success == false then
    game.stack:push(TextBox.new(game, wrapText(tostring(res.message or res.error or "Cannot take this."))))
    return
  end
  inv[itemId] = 1
  activeQuestsCache["1005"] = activeQuestsCache["1005"] or { state = 1, step_flags = {} }
  activeQuestsCache["1005"].state = 1
  if itemId == "WELL_CHARM" then activeQuestsCache["1005"].step_flags.part_a_obtained = true
  else activeQuestsCache["1005"].step_flags.part_b_obtained = true end
  game.stack:push(TextBox.new(game, wrapText(string.format("Obtained %s!", itemName))))
end

return Items
