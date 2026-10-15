-- Sage Hiro (VIOLET_CITY) — Sprout Tower Relay turn-in (quest 1002)
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Hiro = {
  name = "SAGE HIRO",
  mapId = "VIOLET_CITY",
  x = 18,
  y = 16,
  facing = "down",
}

local function resolveSprite(data)
  local sprites = data and data.sprites or {}
  for _, id in ipairs({ "SPRITE_SAGE", "SPRITE_ELDER", "SPRITE_SUPER_NERD", "SPRITE_OAK", "SPRITE_YOUNGSTER", "SPRITE_RED" }) do
    if sprites[id] then return id end
  end
  for k, _ in pairs(sprites) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return "SPRITE_YOUNGSTER"
end

function Hiro.createNPC(data)
  local sprite = resolveSprite(data)
  local npc = NPC.new(data, Hiro.mapId, {
    index = 91002,
    name = Hiro.name,
    sprite = sprite,
    movement = "STAY",
    range = "DOWN",
    x = Hiro.x,
    y = Hiro.y,
  })
  npc.isSageHiro = true
  npc.facing = Hiro.facing
  npc.px = Hiro.x * 16
  npc.py = Hiro.y * 16
  npc.cellX = Hiro.x
  npc.cellY = Hiro.y
  npc.targetPx = Hiro.x * 16
  npc.targetPy = Hiro.y * 16
  return npc
end

function Hiro.interact(game, npc, helpers)
  if npc then
    npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then
      pcall(function() npc:facePlayer(game.overworld.player) end)
    end
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
  local q2 = quests["1002"] or quests[1002] or { state = 0, step_flags = {} }
  local inv = (game.save and game.save.inventory) or {}

  if (q2.state or 0) == 0 then
    game.stack:push(TextBox.new(game, wrapText(
      "The tower is quiet.\fSpeak with GUIDE MIRA in NEW BARK TOWN to begin the relay."
    ), unfreeze))
    return
  end
  if (q2.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("The tower is at peace. Thank you again."), unfreeze))
    return
  end

  local hasBell = (inv["SPROUT_BELL"] or 0) > 0
  local hasScroll = (inv["SAGE_SCROLL"] or 0) > 0
  if hasBell and hasScroll then
    game.stack:push(TextBox.new(game, wrapText(
      "You carry both relics… The ritual needs two trainers.\fGive one relic to your partner!"
    ), unfreeze))
    return
  end
  if not hasBell and not hasScroll then
    game.stack:push(TextBox.new(game, wrapText(
      "Bring the SPROUT BELL or the SAGE SCROLL.\fYour party partner must hold the other."
    ), unfreeze))
    return
  end

  local res = nil
  local ok, r = pcall(function()
    return questApiPost({
      action = "quest_turn_in",
      trainerId = tid,
      questId = 1002,
      p1Inventory = inv,
    })
  end)
  if ok then res = r end

  local success = res and res.success
  -- Offline / server-less fallback: allow complete if local flags show one part
  if not success and not res then
    success = true
  end
  -- If server explicitly needs party, show message
  if res and not res.success then
    local msg = res.message or res.error or "Your partner must be present with the other relic."
    game.stack:push(TextBox.new(game, wrapText(tostring(msg)), unfreeze))
    return
  end

  if hasBell then inv["SPROUT_BELL"] = nil end
  if hasScroll then inv["SAGE_SCROLL"] = nil end
  activeQuestsCache["1002"] = { state = 2, step_flags = { completed = true, turn_in = true } }

  local rewardXp = (res and res.data and res.data.rewardXp) or 1000
  if awardOnlineXp then pcall(awardOnlineXp, game, "quest", rewardXp) end

  pcall(function()
    local Pokemon = require("src.pokemon.Pokemon")
    local Party = require("src.pokemon.Party")
    local species = "BELLSPROUT"
    if game.data and game.data.pokemon then
      if not game.data.pokemon[species] then
        for k, _ in pairs(game.data.pokemon) do
          if type(k) == "string" and k:upper():find("BELLSPROUT") then
            species = k
            break
          end
        end
      end
    end
    if game.data and game.data.pokemon and game.data.pokemon[species] then
      local mon = Pokemon.new(game.data, species, 20)
      if mon then Party.add(game.save.party, mon) end
    end
  end)

  game.stack:push(TextBox.new(game, wrapText(
    "The relics resonate! Sprout Tower is restored.\fYou received BELLSPROUT (Lv20) and +" .. tostring(rewardXp) .. " XP!"
  ), unfreeze))
end

return Hiro
