-- Radio Tech (GOLDENROD_CITY) — quest 1006 turn-in
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Tech = { name = "RADIO TECH", mapId = "GOLDENROD_CITY", x = 20, y = 18, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_ROCKET","SPRITE_SUPER_NERD","SPRITE_SCIENTIST","SPRITE_YOUNGSTER"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_SUPER_NERD"
end

function Tech.createNPC(data)
  local npc = NPC.new(data, Tech.mapId, {
    index = 91040, name = Tech.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Tech.x, y = Tech.y,
  })
  npc.isRadioTech = true
  npc.facing = Tech.facing
  npc.px, npc.py = Tech.x*16, Tech.y*16
  npc.cellX, npc.cellY = Tech.x, Tech.y
  npc.targetPx, npc.targetPy = Tech.x*16, Tech.y*16
  return npc
end

function Tech.interact(game, npc, helpers)
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
  local q = (fetchPlayerQuests(game) or {})["1006"] or { state = 0 }
  local inv = (game.save and game.save.inventory) or {}

  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Radio waves are clean again. Nice work!"), unfreeze))
    return
  end

  if (inv["TUNER_CHIP"] or 0) > 0 then
    inv["TUNER_CHIP"] = nil
    pcall(function() questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1006 }) end)
    activeQuestsCache["1006"] = { state = 2, step_flags = { deliver_tech = true, completed = true } }
    if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 600) end
    pcall(function()
      local id = "SUPER_POTION"
      inv[id] = (inv[id] or 0) + 3
    end)
    game.stack:push(TextBox.new(game, wrapText("TUNER CHIP installed! (+3 SUPER POTION, +600 XP)"), unfreeze))
    return
  end

  pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1006 }) end)
  activeQuestsCache["1006"] = { state = 1, step_flags = { started = true } }
  game.stack:push(TextBox.new(game, wrapText(
    "Static is pouring from GOLDENROD UNDERGROUND.\\fFind the TUNER CHIP down there and bring it back!"
  ), unfreeze))
end

return Tech
