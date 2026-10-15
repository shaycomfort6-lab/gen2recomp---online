-- Well Keeper (AZALEA_TOWN) — quest 1005 turn-in
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Keeper = { name = "WELL KEEPER", mapId = "AZALEA_TOWN", x = 18, y = 12, facing = "down" }

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({"SPRITE_FISHER","SPRITE_HIKER","SPRITE_GENTLEMAN","SPRITE_YOUNGSTER"}) do
    if s[id] then return id end
  end
  for k,_ in pairs(s) do if type(k)=="string" and k:match("^SPRITE_") then return k end end
  return "SPRITE_HIKER"
end

function Keeper.createNPC(data)
  local npc = NPC.new(data, Keeper.mapId, {
    index = 91022, name = Keeper.name, sprite = spr(data),
    movement = "STAY", range = "DOWN", x = Keeper.x, y = Keeper.y,
  })
  npc.isWellKeeper = true
  npc.facing = Keeper.facing
  npc.px, npc.py = Keeper.x*16, Keeper.y*16
  npc.cellX, npc.cellY = Keeper.x, Keeper.y
  npc.targetPx, npc.targetPy = Keeper.x*16, Keeper.y*16
  return npc
end

function Keeper.interact(game, npc, helpers)
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
  local q5 = (fetchPlayerQuests(game) or {})["1005"] or { state = 0 }
  local inv = (game.save and game.save.inventory) or {}

  if (q5.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText("Talk to KURT'S AIDE to start the well rescue."), unfreeze))
    return
  end
  if (q5.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The Slowpoke are calmer now. Thank you."), unfreeze))
    return
  end

  local hasA = (inv["WELL_CHARM"] or 0) > 0
  local hasB = (inv["WELL_BUCKET"] or 0) > 0
  if hasA and hasB then
    game.stack:push(TextBox.new(game, wrapText("You hold both pieces — split them with your partner!"), unfreeze))
    return
  end
  if not hasA and not hasB then
    game.stack:push(TextBox.new(game, wrapText("Bring WELL CHARM or WELL BUCKET. Your partner needs the other."), unfreeze))
    return
  end

  local res
  pcall(function()
    res = questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1005, p1Inventory = inv })
  end)
  if res and res.success == false then
    game.stack:push(TextBox.new(game, wrapText(tostring(res.message or res.error or "Need a party partner with the other relic.")), unfreeze))
    return
  end

  inv["WELL_CHARM"] = nil
  inv["WELL_BUCKET"] = nil
  activeQuestsCache["1005"] = { state = 2, step_flags = { completed = true } }
  local xp = (res and res.data and res.data.rewardXp) or 1000
  if awardOnlineXp then pcall(awardOnlineXp, game, "quest", xp) end
  pcall(function()
    local Pokemon = require("src.pokemon.Pokemon")
    local Party = require("src.pokemon.Party")
    local species = "SLOWPOKE"
    if game.data and game.data.pokemon and not game.data.pokemon[species] then
      for k,_ in pairs(game.data.pokemon) do
        if type(k)=="string" and k:upper():find("SLOWPOKE") then species = k break end
      end
    end
    if game.data and game.data.pokemon and game.data.pokemon[species] then
      local mon = Pokemon.new(game.data, species, 15)
      if mon then Party.add(game.save.party, mon) end
    end
  end)
  game.stack:push(TextBox.new(game, wrapText(
    "The well is cleared! You received SLOWPOKE (Lv15) and +" .. tostring(xp) .. " XP!"
  ), unfreeze))
end

return Keeper
