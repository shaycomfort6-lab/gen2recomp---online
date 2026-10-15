-- ASH_SAMPLE in Burned Tower (quest 1007)
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
    index = index, name = "ASH", sprite = sprite,
    movement = "STAY", range = "NONE", x = x, y = y,
  })
  npc.isAshSample = true
  npc.px, npc.py = x*16, y*16
  npc.cellX, npc.cellY = x, y
  npc.targetPx, npc.targetPy = x*16, y*16
  return npc
end

function Items.createAshNPC(data)
  return ball(data, "BURNED_TOWER1_F", 91051, 8, 8)
end
function Items.createAshFallbackNPC(data)
  return ball(data, "ECRUTEAK_CITY", 91052, 10, 20)
end

function Items.interact(game, helpers)
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache
  local tid = getTrainerId(game.save)
  game.save.inventory = game.save.inventory or {}
  if (game.save.inventory["ASH_SAMPLE"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You already have an ASH SAMPLE.")))
    return
  end
  pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1007 }) end)
  pcall(function() questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1007, itemId = "ASH_SAMPLE" }) end)
  game.save.inventory["ASH_SAMPLE"] = 1
  activeQuestsCache["1007"] = activeQuestsCache["1007"] or { state = 1, step_flags = {} }
  activeQuestsCache["1007"].state = 1
  activeQuestsCache["1007"].step_flags.get_ash = true
  game.stack:push(TextBox.new(game, wrapText("Obtained ASH SAMPLE!")))
end

return Items
