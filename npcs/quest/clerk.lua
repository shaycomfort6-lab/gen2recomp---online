-- Mahogany Clerk (MAHOGANY_TOWN) — quest 1008 turn-in
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Clerk = { name = "MAHOGANY CLERK", mapId = "MAHOGANY_TOWN", x = 12, y = 10, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_CLERK","SPRITE_GENTLEMAN","SPRITE_YOUNGSTER","SPRITE_SUPER_NERD"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_YOUNGSTER"
end

function Clerk.createNPC(data)
  local npc = NPC.new(data, Clerk.mapId, {
    index = 91061, name = Clerk.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Clerk.x, y = Clerk.y,
  })
  npc.isMahoganyClerk = true
  npc.facing = Clerk.facing
  npc.px, npc.py = Clerk.x*16, Clerk.y*16
  npc.cellX, npc.cellY = Clerk.x, Clerk.y
  npc.targetPx, npc.targetPy = Clerk.x*16, Clerk.y*16
  return npc
end

function Clerk.interact(game, npc, helpers)
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
  local q = (fetchPlayerQuests(game) or {})["1008"] or { state = 0 }
  local inv = (game.save and game.save.inventory) or {}

  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Your report is on file. Stay alert near the lake."), unfreeze))
    return
  end
  if (inv["RAGE_REPORT"] or 0) > 0 then
    inv["RAGE_REPORT"] = nil
    pcall(function() questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1008 }) end)
    activeQuestsCache["1008"] = { state = 2, step_flags = { file_report = true, completed = true } }
    if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 800) end
    inv["HYPER_POTION"] = (inv["HYPER_POTION"] or 0) + 2
    game.stack:push(TextBox.new(game, wrapText(
      "Report filed. (+2 HYPER POTION, +800 XP)\\fYou've helped Johto Online from New Bark to the lake!"
    ), unfreeze))
    return
  end
  game.stack:push(TextBox.new(game, wrapText(
    "If you visit LAKE OF RAGE, speak to RAGE WATCHER and bring me a report."
  ), unfreeze))
end

return Clerk
