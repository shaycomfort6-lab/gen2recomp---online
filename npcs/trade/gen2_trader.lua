-- Goldenrod online trade fan (Gen2) — wants a Bellsprout, offers Onix (or fallback)
local NPC = require("src.world.NPC")
local TextBox = require("src.render.TextBox")
local ChoiceBox = require("src.ui.ChoiceBox")

local T = {
  name = "TRADE FAN",
  mapId = "GOLDENROD_CITY",
  x = 16,
  y = 20,
}

local function spr(data)
  local s = data and data.sprites or {}
  for _, id in ipairs({ "SPRITE_YOUNGSTER", "SPRITE_BUG_CATCHER", "SPRITE_SUPER_NERD", "SPRITE_RED" }) do
    if s[id] then return id end
  end
  for k, _ in pairs(s) do
    if type(k) == "string" and k:match("^SPRITE_") then return k end
  end
  return "SPRITE_YOUNGSTER"
end

local function resolveSpecies(data, preferred)
  if not (data and data.pokemon) then return preferred end
  if data.pokemon[preferred] then return preferred end
  local up = preferred:upper()
  for k, _ in pairs(data.pokemon) do
    if type(k) == "string" and k:upper() == up then return k end
  end
  for k, _ in pairs(data.pokemon) do
    if type(k) == "string" and k:upper():find(up) then return k end
  end
  return preferred
end

function T.createNPC(data)
  local npc = NPC.new(data, T.mapId, {
    index = 91200,
    name = T.name,
    sprite = spr(data),
    movement = "STAY",
    range = "DOWN",
    x = T.x,
    y = T.y,
  })
  npc.isGen2Trader = true
  npc.facing = "down"
  npc.px, npc.py = T.x * 16, T.y * 16
  npc.cellX, npc.cellY = T.x, T.y
  npc.targetPx, npc.targetPy = T.x * 16, T.y * 16
  return npc
end

function T.interact(game, npc, helpers)
  if npc then
    npc.frozen = true
    if game.overworld and game.overworld.player and npc.facePlayer then
      pcall(function() npc:facePlayer(game.overworld.player) end)
    end
  end
  local unfreeze = function() if npc then npc.frozen = false end end
  local wrapText = helpers.wrapText or function(s) return s end

  local want = resolveSpecies(game.data, "BELLSPROUT")
  local give = resolveSpecies(game.data, "ONIX")

  game.stack:push(TextBox.new(game, wrapText(
    "I'm looking for a " .. want .. "!\\fI'll trade my " .. give .. " for one. Deal?"
  ), function()
    game.stack:push(ChoiceBox.new(game, function(yes)
      if not yes then
        game.stack:push(TextBox.new(game, wrapText("Aw, come back if you change your mind."), unfreeze))
        return
      end
      local party = game.save and game.save.party or {}
      local idx = nil
      for i, mon in ipairs(party) do
        if mon and mon.species == want then idx = i break end
      end
      if not idx then
        game.stack:push(TextBox.new(game, wrapText("You don't have a " .. want .. " in your party…"), unfreeze))
        return
      end
      if #party >= 6 then
        -- replace in place
      end
      local ok, err = pcall(function()
        local Pokemon = require("src.pokemon.Pokemon")
        local Party = require("src.pokemon.Party")
        local level = (party[idx].level or 15)
        table.remove(party, idx)
        local mon = Pokemon.new(game.data, give, math.max(5, math.min(level, 30)))
        if mon then
          mon.ot = mon.ot or "TRADEFAN"
          Party.add(party, mon)
        end
      end)
      if ok then
        game.stack:push(TextBox.new(game, wrapText(
          "Yes! " .. want .. " for " .. give .. "!\\fThanks for trading online-style!"
        ), unfreeze))
      else
        game.stack:push(TextBox.new(game, wrapText("Trade failed: " .. tostring(err)), unfreeze))
      end
    end))
  end))
end

return T
