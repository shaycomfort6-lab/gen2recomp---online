-- Guide Mira (NEW_BARK_TOWN) — Johto online orientation + Sprout Tower hub
-- Compatible with Gen2Recomp map id NEW_BARK_TOWN and Gen1Online quest API.

local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local ChoiceBox = require("src.ui.ChoiceBox")

local Mira = {
  name = "GUIDE MIRA",
  mapId = "NEW_BARK_TOWN",
  sprite = "SPRITE_LASS",
  x = 12,
  y = 8,
  facing = "down",
}

local function resolveSprite(data, preferred)
  local sprites = data and data.sprites
  if not sprites then return preferred end
  for _, id in ipairs({ preferred, "SPRITE_LASS", "SPRITE_COOLTRAINER_F", "SPRITE_GIRL", "SPRITE_RED" }) do
    if sprites[id] then return id end
  end
  for k, _ in pairs(sprites) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return preferred
end

function Mira.createNPC(data)
  local sprite = resolveSprite(data, Mira.sprite)
  local npc = NPC.new(data, Mira.mapId, {
    index = 91001,
    name = Mira.name,
    sprite = sprite,
    movement = "STAY",
    range = "DOWN",
    x = Mira.x,
    y = Mira.y,
  })
  npc.isGuideMira = true
  npc.facing = Mira.facing
  npc.px = Mira.x * 16
  npc.py = Mira.y * 16
  npc.cellX = Mira.x
  npc.cellY = Mira.y
  npc.targetPx = Mira.x * 16
  npc.targetPy = Mira.y * 16
  return npc
end

function Mira.interact(game, npc, helpers)
  if npc then
    npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then
      pcall(function() npc:facePlayer(game.overworld.player) end)
    end
  end
  local unfreeze = function()
    if npc then npc.frozen = false end
  end

  local wrapText = helpers.wrapText
  local getTrainerId = helpers.getTrainerId
  local fetchPlayerQuests = helpers.fetchPlayerQuests
  local questApiPost = helpers.questApiPost
  local activeQuestsCache = helpers.activeQuestsCache
  local awardOnlineXp = helpers.awardOnlineXp

  local tid = getTrainerId(game.save)
  local quests = fetchPlayerQuests(game) or {}
  local q1 = quests["1001"] or quests[1001] or { state = 0, step_flags = {} }
  local q2 = quests["1002"] or quests[1002] or { state = 0, step_flags = {} }

  local function cache(qid, state, flags)
    activeQuestsCache[tostring(qid)] = activeQuestsCache[tostring(qid)] or { state = 0, step_flags = {} }
    if state ~= nil then activeQuestsCache[tostring(qid)].state = state end
    if flags then
      activeQuestsCache[tostring(qid)].step_flags = activeQuestsCache[tostring(qid)].step_flags or {}
      for k, v in pairs(flags) do activeQuestsCache[tostring(qid)].step_flags[k] = v end
    end
  end

  -- Quest 1001: Welcome
  if (q1.state or 0) ~= 2 then
    local intro = "Hi! I'm MIRA, your Johto online guide.\f"
      .. "Gold & Silver trainers start here in NEW BARK TOWN.\f"
      .. "I'll register your online profile now!"
    game.stack:push(TextBox.new(game, wrapText(intro), function()
      pcall(function()
        questApiPost({ action = "quest_accept", trainerId = tid, questId = 1001 })
      end)
      cache(1001, 1, { talk_mira = true, started = true })
      pcall(function()
        questApiPost({ action = "quest_turn_in", trainerId = tid, questId = 1001 })
      end)
      cache(1001, 2, { registered = true, completed = true })
      if awardOnlineXp then pcall(awardOnlineXp, game, "quest", 250) end
      game.stack:push(TextBox.new(game, wrapText(
        "Profile registered! (+250 XP)\fTalk to me again when you want the SPROUT TOWER co-op quest."
      ), unfreeze))
    end))
    return
  end

  -- Quest 1002 offer / status
  if (q2.state or 0) == 0 then
    local msg = "The sages need two trainers for the SPROUT TOWER RELAY.\fOne takes the SPROUT BELL, the other the SAGE SCROLL.\fStart the quest?"
    game.stack:push(TextBox.new(game, wrapText(msg), function()
      game.stack:push(ChoiceBox.new(game, function(yes)
        if yes then
          pcall(function()
            questApiPost({ action = "quest_accept", trainerId = tid, questId = 1002 })
          end)
          cache(1002, 1, { started = true, part_a_obtained = false, part_b_obtained = false })
          game.stack:push(TextBox.new(game, wrapText(
            "Search SPROUT TOWER (or the pedestals in VIOLET CITY).\fYou cannot carry both relics. Turn them in to SAGE HIRO in VIOLET CITY with your partner!"
          ), unfreeze))
        else
          game.stack:push(TextBox.new(game, wrapText("Come back when you have a partner ready."), unfreeze))
        end
      end))
    end))
    return
  end

  if (q2.state or 0) == 1 then
    game.stack:push(TextBox.new(game, wrapText(
      "SPROUT TOWER RELAY is active.\fBell + Scroll → SAGE HIRO in VIOLET CITY (with a party partner)!"
    ), unfreeze))
    return
  end

  game.stack:push(TextBox.new(game, wrapText(
    "Johto Online board:\f"
    .. "• Route 29 parcel → Azalea\f"
    .. "• Slowpoke Well co-op\f"
    .. "• Goldenrod Underground chip\f"
    .. "• Burned Tower ash\f"
    .. "• Lake of Rage report\f"
    .. "Check START → QUEST for progress!"
  ), unfreeze))
end

return Mira
