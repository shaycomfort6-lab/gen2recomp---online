-- TUNER_CHIP pickup in Goldenrod Underground (quest 1006)
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local Items = {}

local function ball(data, mapId, index, x, y)
  local sprites = data and data.sprites or {}
  local sprite = "SPRITE_POKE_BALL"
  for _, id in ipairs({"SPRITE_POKE_BALL","SPRITE_POKEBALL"}) do
    if sprites[id] then sprite = id break end
  end
  local npc = NPC.new(data, mapId, {
    index = index, name = "CHIP", sprite = sprite,
    movement = "STAY", range = "NONE", x = x, y = y,
  })
  npc.isTunerChip = true
  npc.px, npc.py = x*16, y*16
  npc.cellX, npc.cellY = x, y
  npc.targetPx, npc.targetPy = x*16, y*16
  return npc
end

function Items.createChipNPC(data)
  return ball(data, "GOLDENROD_UNDERGROUND", 91041, 10, 10)
end
function Items.createChipFallbackNPC(data)
  return ball(data, "GOLDENROD_CITY", 91042, 12, 22)
end

function Items.interact(game, helpers)
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache

  local tid = getTrainerId(game.save)
  local q = (fetchPlayerQuests(game) or {})["1006"] or { state = 0 }
  if (q.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("A strange chip. RADIO TECH in GOLDENROD CITY might want this.")))
    -- still allow taking it / auto-start
    pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1006 }) end)
    activeQuestsCache["1006"] = { state = 1, step_flags = {} }
  end
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Empty.")))
    return
  end
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["TUNER_CHIP"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have the TUNER CHIP.")))
    return
  end
  pcall(function()
    questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1006, itemId = "TUNER_CHIP" })
  end)
  game.save.inventory["TUNER_CHIP"] = 1
  activeQuestsCache["1006"] = activeQuestsCache["1006"] or { state = 1, step_flags = {} }
  activeQuestsCache["1006"].state = 1
  activeQuestsCache["1006"].step_flags.find_chip = true
  game.stack:push(TextBox.new(game, wrapText("Obtained TUNER CHIP!")))
end

return Items
