-- Kurt's Aide (AZALEA_TOWN) — quest 1004 deliver + 1005 hub
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local ChoiceBox = require("src.ui.ChoiceBox")

local Aide = { name = "KURT'S AIDE", mapId = "AZALEA_TOWN", x = 15, y = 10, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_SCIENTIST","SPRITE_SUPER_NERD","SPRITE_GENTLEMAN","SPRITE_OAK","SPRITE_YOUNGSTER"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_YOUNGSTER"
end

function Aide.createNPC(data)
  local npc = NPC.new(data, Aide.mapId, {
    index = 91021, name = Aide.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Aide.x, y = Aide.y,
  })
  npc.isKurtAide = true
  npc.facing = Aide.facing
  npc.px, npc.py = Aide.x*16, Aide.y*16
  npc.cellX, npc.cellY = Aide.x, Aide.y
  npc.targetPx, npc.targetPy = Aide.x*16, Aide.y*16
  return npc
end

function Aide.interact(game, npc, helpers)
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
  local quests = fetchPlayerQuests(game) or {}
  local q4 = quests["1004"] or { state = 0, step_flags = {} }
  local q5 = quests["1005"] or { state = 0, step_flags = {} }
  game.save.inventory = game.save.inventory or {}
  local inv = game.save.inventory

  -- Complete 1004 if parcel held
  if (q4.state or 0) ~= 2 and (inv["ONLINE_PARCEL"] or 0) > 0 then
    inv["ONLINE_PARCEL"] = nil
    pcall(function() questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1004 }) end)
    activeQuestsCache["1004"] = { state = 2, step_flags = { deliver_azalea = true, completed = true } }
    if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 400) end
    pcall(function()
      local id = "POTION"
      if game.data and game.data.items then
        for k,_ in pairs(game.data.items) do
          if type(k)=="string" and k:upper()=="POTION" then id = k break end
        end
      end
      inv[id] = (inv[id] or 0) + 5
    end)
    game.stack:push(TextBox.new(game, wrapText(
      "Parcel received! Kurt will be glad.\\f(+5 POTION, +400 XP)\\fIf you have a partner, ask me about SLOWPOKE WELL."
    ), unfreeze))
    return
  end

  -- Offer 1005
  if (q5.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText(
      "Slowpoke Well still has Rocket trash in it.\\fTwo trainers must fetch the WELL CHARM and WELL BUCKET. Start that rescue?"
    ), function()
      game.stack:push(ChoiceBox.new(game, function(yes)
        if yes then
          pcall(function() questApiPost({ action = "quest_accept", trainerId = tid, questId = 1005 }) end)
          activeQuestsCache["1005"] = { state = 1, step_flags = { part_a_obtained = false, part_b_obtained = false } }
          game.stack:push(TextBox.new(game, wrapText(
            "Enter SLOWPOKE WELL. One takes the CHARM, one the BUCKET.\\fReturn here to WELL KEEPER with your partner!"
          ), unfreeze))
        else
          game.stack:push(TextBox.new(game, wrapText("Stay safe on the roads."), unfreeze))
        end
      end))
    end))
    return
  end

  if (q5.state or 0) == 1 then
    game.stack:push(TextBox.new(game, wrapText(
      "WELL RESCUE is active. Split the relics in the well, then talk to WELL KEEPER here in Azalea."
    ), unfreeze))
    return
  end

  game.stack:push(TextBox.new(game, wrapText("Azalea appreciates online trainers who help the well."), unfreeze))
end

return Aide
