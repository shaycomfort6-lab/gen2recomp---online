-- Rage Watcher (LAKE_OF_RAGE) — quest 1008 start
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Watcher = { name = "RAGE WATCHER", mapId = "LAKE_OF_RAGE", x = 18, y = 16, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_FISHER","SPRITE_HIKER","SPRITE_YOUNGSTER"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_FISHER"
end

function Watcher.createNPC(data)
  local npc = NPC.new(data, Watcher.mapId, {
    index = 91060, name = Watcher.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Watcher.x, y = Watcher.y,
  })
  npc.isRageWatcher = true
  npc.facing = Watcher.facing
  npc.px, npc.py = Watcher.x*16, Watcher.y*16
  npc.cellX, npc.cellY = Watcher.x, Watcher.y
  npc.targetPx, npc.targetPy = Watcher.x*16, Watcher.y*16
  return npc
end

function Watcher.interact(game, npc, helpers)
  if npc then npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then pcall(function() npc:facePlayer(game.overworld.player) end) end
  end
  local unfreeze = function() if npc then npc.frozen = false end end
  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache

  local tid = getTrainerId(game.save)
  local q = (fetchPlayerQuests(game) or {})["1008"] or { state = 0 }
  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The lake is quiet… for now."), unfreeze))
    return
  end
  game.save.inventory = game.save.inventory or {}
  pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1008 }) end)
  activeQuestsCache["1008"] = { state = 1, step_flags = { visit_lake = true } }
  game.save.inventory["RAGE_REPORT"] = 1
  pcall(function()
    questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1008, itemId = "RAGE_REPORT" })
  end)
  game.stack:push(TextBox.new(game, wrapText(
    "I saw a red Gyarados leap from the water!\\fTake this RAGE REPORT to MAHOGANY CLERK in Mahogany Town!"
  ), unfreeze))
end

return Watcher
