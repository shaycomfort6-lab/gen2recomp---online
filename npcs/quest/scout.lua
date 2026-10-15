-- Signal Scout (CHERRYGROVE_CITY) — quest 1003
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")

local Scout = {
  name = "SIGNAL SCOUT",
  mapId = "CHERRYGROVE_CITY",
  x = 18,
  y = 8,
  facing = "down",
}

local function resolveSprite(data)
  local sprites = data and data.sprites or {}
  for _, id in ipairs({ "SPRITE_YOUNGSTER", "SPRITE_BUG_CATCHER", "SPRITE_RED" }) do
    if sprites[id] then return id end
  end
  for k, _ in pairs(sprites) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return "SPRITE_YOUNGSTER"
end

function Scout.createNPC(data)
  local npc = NPC.new(data, Scout.mapId, {
    index = 91003,
    name = Scout.name,
    sprite = resolveSprite(data),
    movement = "STAY",
    range = "DOWN",
    x = Scout.x,
    y = Scout.y,
  })
  npc.isSignalScout = true
  npc.facing = Scout.facing
  npc.px = Scout.x * 16
  npc.py = Scout.y * 16
  npc.cellX = Scout.x
  npc.cellY = Scout.y
  npc.targetPx = Scout.x * 16
  npc.targetPy = Scout.y * 16
  return npc
end

function Scout.interact(game, npc, helpers)
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
  local q3 = quests["1003"] or quests[1003] or { state = 0, step_flags = {} }

  if (q3.state or 0) == 2 then
    game.stack:push(TextBox.new(game, wrapText("Signal is strong all the way from New Bark. Nice work!"), unfreeze))
    return
  end

  pcall(function()
    questApiPost({ action = "quest_accept", trainerId = tid, questId = 1003 })
  end)
  activeQuestsCache["1003"] = { state = 1, step_flags = { reach_cherry = true, started = true } }

  local res = nil
  pcall(function()
    res = questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1003 })
  end)
  activeQuestsCache["1003"] = { state = 2, step_flags = { reach_cherry = true, talk_scout = true, completed = true } }

  if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 500) end

  pcall(function()
    game.save.inventory = game.save.inventory or {}
    local id = "GREAT_BALL"
    if game.data and game.data.items then
      if not game.data.items[id] then
        for k, _ in pairs(game.data.items) do
          if type(k) == "string" and k:upper():find("GREAT") and k:upper():find("BALL") then
            id = k
            break
          end
        end
      end
    end
    game.save.inventory[id] = (game.save.inventory[id] or 0) + 5
  end)

  game.stack:push(TextBox.new(game, wrapText(
    "Signal received from NEW BARK TOWN!\fNetwork link confirmed. Take these GREAT BALLS — and +500 XP!"
  ), unfreeze))
end

return Scout
