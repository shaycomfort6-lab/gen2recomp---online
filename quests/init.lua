-- Quests: Gen1 Kanto + full Gen2 Johto→Kanto online storyline (1001–1016)

return function(loadModFile, mod)
  local function isGen2()
    local ok, G = pcall(require, "src.core.GameVersion")
    return ok and G and G.isGen2 and G.isGen2()
  end
  local Font = require("src.render.Font")
  local Menu = require("src.ui.Menu")
  local Game = require("src.core.Game")
  local Quests = { cache = {} }

  local gen1 = {
    loadModFile(mod, "quests/quest_1.lua"),
    loadModFile(mod, "quests/quest_2.lua"),
  }
  local gen2files = {
    "quest_gen2_welcome.lua", "quest_gen2_sprout.lua", "quest_gen2_cherry.lua",
    "quest_gen2_route29.lua", "quest_gen2_well.lua", "quest_gen2_underground.lua",
    "quest_gen2_burned.lua", "quest_gen2_rage.lua",
    "quest_gen2_olivine.lua", "quest_gen2_cianwood.lua", "quest_gen2_radio.lua",
    "quest_gen2_icepath.lua", "quest_gen2_den.lua", "quest_gen2_tohjo.lua",
    "quest_gen2_viridian.lua", "quest_gen2_indigo.lua",
    "quest_gen2_kanto_pewter.lua", "quest_gen2_kanto_cerulean.lua", "quest_gen2_kanto_vermilion.lua",
    "quest_gen2_kanto_celadon.lua", "quest_gen2_kanto_fuchsia.lua", "quest_gen2_kanto_saffron.lua",
    "quest_gen2_kanto_cinnabar.lua", "quest_gen2_kanto_blue.lua",
    "quest_gen2_league.lua", "quest_gen2_mtsilver.lua",
    "quest_gen2_park.lua",
  }
  local gen2 = {}
  for _, f in ipairs(gen2files) do
    local ok, q = pcall(loadModFile, mod, "quests/" .. f)
    if ok and q then gen2[#gen2 + 1] = q end
  end
  Quests.registry = isGen2() and gen2 or gen1

  function Quests.registerItems(game)
    game = game or Game
    if not game or not game.data or not game.data.items then return end
    local function ensure(id, name, full, desc)
      if not game.data.items[id] then
        game.data.items[id] = { name = name, fullName = full, desc = desc, questItem = true, keyItem = false, price = 0 }
      end
    end
    local items = {
      {"MAGNET_COIL","MAGNET COIL","Magnetized Coil","Gen1 quest."},
      {"CONDUIT_LENS","CONDUIT LENS","Conduit Lens","Gen1 quest."},
      {"SPROUT_BELL","SPROUT BELL","Sprout Bell","Sprout Tower."},
      {"SAGE_SCROLL","SAGE SCROLL","Sage Scroll","Sprout Tower."},
      {"ONLINE_PARCEL","ONLINE PARCEL","Online Parcel","Route 29 courier."},
      {"WELL_CHARM","WELL CHARM","Well Charm","Slowpoke Well."},
      {"WELL_BUCKET","WELL BUCKET","Well Bucket","Slowpoke Well."},
      {"TUNER_CHIP","TUNER CHIP","Tuner Chip","Goldenrod Underground."},
      {"ASH_SAMPLE","ASH SAMPLE","Ash Sample","Burned Tower."},
      {"RAGE_REPORT","RAGE REPORT","Rage Report","Lake of Rage."},
      {"LAMP_OIL","LAMP OIL","Lamp Oil","Olivine Lighthouse."},
      {"SECRET_MEDICINE","SECRET MEDICINE","Secret Medicine","Cianwood Pharmacy."},
      {"CARD_KEY","CARD KEY","Card Key","Radio Tower."},
      {"TX_CORE","TX CORE","Transmitter Core","Radio Tower."},
      {"ICE_BEACON","ICE BEACON","Ice Beacon","Ice Path."},
      {"DRAGON_TOKEN","DRAGON TOKEN","Dragon Token","Dragon's Den."},
      {"KANTO_PASS","KANTO PASS","Kanto Pass","Tohjo Crossing."},
      {"INDIGO_FILE","INDIGO FILE","Indigo File","Indigo expedition file."},
      {"NETWORK_TICKET","NETWORK TICKET","Network Ticket","Celadon network node."},
      {"PSY_CRYSTAL","PSY CRYSTAL","Psy Crystal","Saffron calibration."},
      {"VOLCANIC_ASH","VOLCANIC ASH","Volcanic Ash","Cinnabar sample."},
      {"VR_STAMP","VR STAMP","Victory Road Stamp","League path."},
      {"WILL_SEAL","WILL SEAL","Will's Seal","Elite Four."},
      {"KOGA_SEAL","KOGA SEAL","Koga's Seal","Elite Four (Gen2)."},
      {"BRUNO_SEAL","BRUNO SEAL","Bruno's Seal","Elite Four."},
      {"KAREN_SEAL","KAREN SEAL","Karen's Seal","Elite Four."},
      {"LANCE_SEAL","LANCE SEAL","Lance's Seal","Champion."},
      {"CHAMP_SEAL","CHAMP SEAL","Champ Seal","League complete."},
      {"SILVER_EMBLEM","SILVER EMBLEM","Silver Emblem","Mt. Silver summit."},
    }
    for _, row in ipairs(items) do ensure(row[1], row[2], row[3], row[4]) end
  end

  function Quests.findBugHeadButterfreeIndex(party)
    if not party then return nil end
    for idx, mon in ipairs(party) do
      if mon and mon.species == "BUTTERFREE" then
        local ot = mon.ot or mon.otName or mon.originalTrainer
        if ot == "BugHead" then return idx, mon end
      end
    end
  end

  function Quests.openDetailsScreen(game, qDef, questsData)
    game = game or Game
    local qStatus = questsData[tostring(qDef.id)] or questsData[qDef.id] or { state = 0, step_flags = {} }
    local flags = qStatus.step_flags or {}
    local inv = (game.save and game.save.inventory) or {}
    local stateMap = { [0] = "AVAILABLE", [1] = "IN PROGRESS", [2] = "COMPLETED" }
    local stateStr = stateMap[qStatus.state or 0] or "AVAILABLE"
    local id = tonumber(qDef.id) or 0
    local container = {
      update = function() end,
      draw = function()
        Font.draw("==================", 8, 8)
        Font.draw((qDef.shortLabel or qDef.title or "?"):sub(1, 18), 8, 18)
        Font.draw(stateStr, 8, 30)
        Font.draw("------------------", 8, 40)
        Font.draw((qDef.location or ""):sub(1, 18), 8, 50)
        local y = 66
        local function line(done, label)
          Font.draw(string.format("[%s] %s", done and "X" or " ", (label or ""):sub(1, 16)), 8, y)
          y = y + 11
        end
        local function has(k) return (inv[k] or 0) > 0 end
        if id == 1002 or id == 1005 or id == 1011 or id == 1 then
          for _, obj in ipairs(qDef.objectives or {}) do
            local done = qStatus.state == 2
            if obj.item then done = done or has(obj.item) or flags.part_a_obtained or flags.part_b_obtained end
            if obj.id == "turn_in" then done = qStatus.state == 2 end
            line(done, obj.label)
          end
        else
          for _, obj in ipairs(qDef.objectives or {}) do
            local done = qStatus.state == 2 or flags[obj.id] or (obj.item and has(obj.item))
            line(done, obj.label)
          end
        end
        Font.draw((qDef.reward or ""):sub(1, 18), 8, math.min(y, 114))
        Font.draw("A:BACK", 8, 128)
      end
    }
    game.stack:push(container)
  end

  function Quests.openLogScreen(game, fetchPlayerQuestsFn)
    game = game or Game
    local questsData = fetchPlayerQuestsFn and fetchPlayerQuestsFn(game) or Quests.cache
    local menuItems = {}
    local tagMap = { [0] = "[NEW]", [1] = "[ACTV]", [2] = "[DONE]" }
    for _, qDef in ipairs(Quests.registry) do
      local qStatus = questsData[tostring(qDef.id)] or questsData[qDef.id] or { state = 0 }
      local tag = tagMap[qStatus.state or 0] or "[NEW]"
      local labelStr = string.format("%s %s", qDef.shortLabel or (qDef.title or "?"):sub(1, 10), tag)
      if #labelStr > 16 then labelStr = labelStr:sub(1, 16) end
      table.insert(menuItems, {
        label = labelStr,
        onSelect = function() Quests.openDetailsScreen(game, qDef, questsData) end
      })
    end
    table.insert(menuItems, { label = "BACK", onSelect = function() end })
    game.stack:push(Menu.new(game, menuItems, { tx = 0, ty = 0, tw = 20, maxVisible = 8, startCloses = true }))
  end

  return Quests
end
