-- Tower Monk (ECRUTEAK_CITY) — quest 1007
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Monk = { name = "TOWER MONK", mapId = "ECRUTEAK_CITY", x = 16, y = 14, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_SAGE","SPRITE_ELDER","SPRITE_SUPER_NERD","SPRITE_YOUNGSTER"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_SAGE"
end

function Monk.createNPC(data)
  local npc = NPC.new(data, Monk.mapId, {
    index = 91050, name = Monk.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Monk.x, y = Monk.y,
  })
  npc.isTowerMonk = true
  npc.facing = Monk.facing
  npc.px, npc.py = Monk.x*16, Monk.y*16
  npc.cellX, npc.cellY = Monk.x, Monk.y
  npc.targetPx, npc.targetPy = Monk.x*16, Monk.y*16
  return npc
end

function Monk.interact(game, npc, helpers)
  if npc then npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then pcall(function() npc:facePlayer(game.overworld.player) end) end
  end
  local unfreeze = function() if npc then npc.frozen = false end end
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache
  local awardOnlineXp = helpers.awardOnlineXp

  local tid = getTrainerId(game.save)
  local q = (fetchPlayerQuests(game) or {})["1007"] or { state = 0 }
  local inv = (game.save and game.save.inventory) or {}

  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("May the legends of Ecruteak watch over you."), unfreeze))
    return
  end
  if (inv["ASH_SAMPLE"] or 0) > 0 then
    inv["ASH_SAMPLE"] = nil
    pcall(function() questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1007 }) end)
    activeQuestsCache["1007"] = { state = 2, step_flags = { show_monk = true, completed = true } }
    if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 700) end
    inv["ESCAPE_ROPE"] = (inv["ESCAPE_ROPE"] or 0) + 3
    game.stack:push(TextBox.new(game, wrapText("The ash still holds heat… (+3 ESCAPE ROPE, +700 XP)"), unfreeze))
    return
  end
  pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1007 }) end)
  activeQuestsCache["1007"] = { state = 1, step_flags = { started = true } }
  game.stack:push(TextBox.new(game, wrapText(
    "Enter BURNED TOWER and bring me an ASH SAMPLE from the first floor."
  ), unfreeze))
end

return Monk
