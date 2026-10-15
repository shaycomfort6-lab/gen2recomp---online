-- Courier Ken (ROUTE29) — quest 1004 start / parcel give
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Ken = { name = "COURIER KEN", mapId = "ROUTE29", x = 20, y = 10, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_YOUNGSTER","SPRITE_BUG_CATCHER","SPRITE_RED"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_YOUNGSTER"
end

function Ken.createNPC(data)
  local npc = NPC.new(data, Ken.mapId, {
    index = 91020, name = Ken.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Ken.x, y = Ken.y,
  })
  npc.isCourierKen = true
  npc.facing = Ken.facing
  npc.px, npc.py = Ken.x*16, Ken.y*16
  npc.cellX, npc.cellY = Ken.x, Ken.y
  npc.targetPx, npc.targetPy = Ken.x*16, Ken.y*16
  return npc
end

function Ken.interact(game, npc, helpers)
  if npc then npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then pcall(function() npc:facePlayer(game.overworld.player) end) end
  end
  local unfreeze = function() if npc then npc.frozen = false end end
  local wrapText, getTrainerId, fetchPlayerQuests, questApiPost, activeQuestsCache =
    helpers.wrapText, helpers.getTrainerId, helpers.fetchPlayerQuests, helpers.questApiPost, helpers.activeQuestsCache

  local tid = getTrainerId(game.save)
  local q = (fetchPlayerQuests(game) or {})["1004"] or { state = 0, step_flags = {} }
  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory

  if (q.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Thanks for running that parcel to Azalea!"), unfreeze))
    return
  end
  if (inv["ONLINE_PARCEL"] or 0) > 0 then
    game.stack:push(TextBox.new(game, wrapText("You still have the ONLINE PARCEL. Take it to KURT'S AIDE in AZALEA TOWN!"), unfreeze))
    return
  end

  pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1004 }) end)
  activeQuestsCache["1004"] = { state = 1, step_flags = { take_parcel = true } }
  inv["ONLINE_PARCEL"] = 1
  pcall(function()
    questApiPost({ action = "quest_pickup", trainerId = tid, questId = 1004, itemId = "ONLINE_PARCEL" })
  end)
  game.stack:push(TextBox.new(game, wrapText(
    "Perfect timing! Take this ONLINE PARCEL west to AZALEA TOWN.\\fGive it to KURT'S AIDE near the well."
  ), unfreeze))
end

return Ken
