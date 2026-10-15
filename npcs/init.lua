-- NPC manager: Gen1 + full Gen2 Johto→Kanto online questline

return function(loadModFile, mod)
  local function isGen2()
    local ok, G = pcall(require, "src.core.GameVersion")
    return ok and G and G.isGen2 and G.isGen2()
  end
  local Game = require("src.core.Game")
  local NPCs = {}

  NPCs.quest = {
    felix = loadModFile(mod, "npcs/quest/felix.lua"),
    bughead = loadModFile(mod, "npcs/quest/bughead.lua"),
    items = loadModFile(mod, "npcs/quest/quest_items.lua"),
    mira = loadModFile(mod, "npcs/quest/mira.lua"),
    hiro = loadModFile(mod, "npcs/quest/hiro.lua"),
    sprout = loadModFile(mod, "npcs/quest/sprout_items.lua"),
    scout = loadModFile(mod, "npcs/quest/scout.lua"),
    ken = loadModFile(mod, "npcs/quest/ken.lua"),
    aide = loadModFile(mod, "npcs/quest/aide.lua"),
    wellKeeper = loadModFile(mod, "npcs/quest/well_keeper.lua"),
    wellItems = loadModFile(mod, "npcs/quest/well_items.lua"),
    radioTech = loadModFile(mod, "npcs/quest/radio_tech.lua"),
    underItems = loadModFile(mod, "npcs/quest/under_items.lua"),
    monk = loadModFile(mod, "npcs/quest/monk.lua"),
    ashItem = loadModFile(mod, "npcs/quest/ash_item.lua"),
    watcher = loadModFile(mod, "npcs/quest/watcher.lua"),
    clerk = loadModFile(mod, "npcs/quest/clerk.lua"),
    jk = loadModFile(mod, "npcs/quest/johto_kanto.lua"),
    kls = loadModFile(mod, "npcs/quest/kanto_league_silver.lua"),
  }
  NPCs.trade = {
    haunter = loadModFile(mod, "npcs/trade/haunter_trader.lua"),
    gen2 = loadModFile(mod, "npcs/trade/gen2_trader.lua"),
  }
  NPCs.shop = loadModFile(mod, "npcs/shop/index.lua")
  NPCs.battle = loadModFile(mod, "npcs/battle/index.lua")

  local function safe(ow, flag, fn)
    for _, n in ipairs(ow.npcs) do if n[flag] then return end end
    local data = (ow.game and ow.game.data) or Game.data or require("src.core.Data")
    local ok, npc = pcall(fn, data)
    if ok and npc then
      table.insert(ow.npcs, npc)
      table.insert(ow.entities, npc)
    else
      print("[Gen2Online] spawn fail " .. tostring(flag) .. ": " .. tostring(npc))
    end
  end

  function NPCs.spawnForMap(ow)
    if not ow or not ow.map or not ow.npcs then return end
    local id = ow.map.id
    local Q = NPCs.quest

    if isGen2() then
      if id == "NEW_BARK_TOWN" and Q.mira then safe(ow, "isGuideMira", Q.mira.createNPC) end
      if id == "CHERRYGROVE_CITY" and Q.scout then safe(ow, "isSignalScout", Q.scout.createNPC) end
      if id == "VIOLET_CITY" then
        if Q.hiro then safe(ow, "isSageHiro", Q.hiro.createNPC) end
        if Q.sprout then
          safe(ow, "isSproutBell", Q.sprout.createBellFallbackNPC)
          safe(ow, "isSproutScroll", Q.sprout.createScrollFallbackNPC)
        end
      end
      if id == "SPROUT_TOWER1_F" and Q.sprout then safe(ow, "isSproutBell", Q.sprout.createBellNPC) end
      if id == "SPROUT_TOWER2_F" and Q.sprout then safe(ow, "isSproutScroll", Q.sprout.createScrollNPC) end
      if id == "SPROUT_TOWER3_F" and Q.sprout then safe(ow, "isSproutBell", Q.sprout.createBellTower3NPC) end
      if id == "ROUTE29" and Q.ken then safe(ow, "isCourierKen", Q.ken.createNPC) end
      if id == "AZALEA_TOWN" then
        if Q.aide then safe(ow, "isKurtAide", Q.aide.createNPC) end
        if Q.wellKeeper then safe(ow, "isWellKeeper", Q.wellKeeper.createNPC) end
        if Q.wellItems then
          safe(ow, "isWellCharm", Q.wellItems.createCharmFallbackNPC)
          safe(ow, "isWellBucket", Q.wellItems.createBucketFallbackNPC)
        end
      end
      if id == "SLOWPOKE_WELL_B1_F" and Q.wellItems then safe(ow, "isWellCharm", Q.wellItems.createCharmNPC) end
      if id == "SLOWPOKE_WELL_B2_F" and Q.wellItems then safe(ow, "isWellBucket", Q.wellItems.createBucketNPC) end
      if id == "GOLDENROD_CITY" then
        if Q.radioTech then safe(ow, "isRadioTech", Q.radioTech.createNPC) end
        if NPCs.trade.gen2 then safe(ow, "isGen2Trader", NPCs.trade.gen2.createNPC) end
        if Q.underItems then safe(ow, "isTunerChip", Q.underItems.createChipFallbackNPC) end
        if Q.jk then
          safe(ow, "isCardKey", Q.jk.createCardKeyFallback)
          safe(ow, "isTxCore", Q.jk.createTxCoreFallback)
        end
      end
      if id == "GOLDENROD_UNDERGROUND" and Q.underItems then safe(ow, "isTunerChip", Q.underItems.createChipNPC) end
      if id == "ECRUTEAK_CITY" then
        if Q.monk then safe(ow, "isTowerMonk", Q.monk.createNPC) end
        if Q.ashItem then safe(ow, "isAshSample", Q.ashItem.createAshFallbackNPC) end
      end
      if id == "BURNED_TOWER1_F" and Q.ashItem then safe(ow, "isAshSample", Q.ashItem.createAshNPC) end
      if id == "LAKE_OF_RAGE" and Q.watcher then safe(ow, "isRageWatcher", Q.watcher.createNPC) end
      if id == "MAHOGANY_TOWN" and Q.clerk then safe(ow, "isMahoganyClerk", Q.clerk.createNPC) end
      -- 1009–1016
      if Q.jk then
        local J = Q.jk
        if id == "OLIVINE_CITY" then
          safe(ow, "isSailorLight", J.createSailorLight)
          safe(ow, "isLampOil", J.createLampOilFallback)
        end
        if id == "OLIVINE_LIGHTHOUSE1_F" then safe(ow, "isLampOil", J.createLampOil) end
        if id == "CIANWOOD_CITY" then safe(ow, "isPharmacyAide", J.createPharmacyAide) end
        if id == "RADIO_TOWER1_F" then safe(ow, "isRadioDirector", J.createDirector) end
        if id == "RADIO_TOWER2_F" then safe(ow, "isCardKey", J.createCardKey) end
        if id == "RADIO_TOWER3_F" then safe(ow, "isTxCore", J.createTxCore) end
        if id == "BLACKTHORN_CITY" then
          safe(ow, "isDenGuard", J.createDenGuard)
          safe(ow, "isDragonElder", J.createElder)
          safe(ow, "isIceBeacon", J.createIceBeaconFallback)
          safe(ow, "isDragonToken", J.createDragonTokenFallback)
        end
        if id == "ICE_PATH1_F" then safe(ow, "isIceBeacon", J.createIceBeacon) end
        if id == "DRAGONS_DEN_B1_F" then safe(ow, "isDragonToken", J.createDragonToken) end
        if id == "TOHJO_FALLS" then safe(ow, "isFallsGuide", J.createFallsGuide) end
        if id == "ROUTE26" then safe(ow, "isGateRanger", J.createGateRanger) end
        if id == "VIRIDIAN_CITY" then safe(ow, "isCustomsClerk", J.createCustomsClerk) end
        if id == "INDIGO_PLATEAU_POKECENTER1_F" then safe(ow, "isIndigoClerk", J.createIndigoClerk) end
        -- Gen2 players must not get Gen1 Oak-aide online NPCs in Pallet
      end

      -- Gen2 Kanto + League + Mt. Silver
      if Q.kls then
        local K = Q.kls
        if id == "PEWTER_CITY" then safe(ow, "isPewterGuide", K.createPewterGuide) end
        if id == "CERULEAN_CITY" then safe(ow, "isCeruleanAide", K.createCeruleanAide) end
        if id == "VERMILION_CITY" then safe(ow, "isVermilionClerk", K.createVermilionClerk) end
        if id == "CELADON_CITY" then
          safe(ow, "isCeladonClerk", K.createCeladonClerk)
          safe(ow, "isNetworkTicket", K.createNetworkTicket)
        end
        if id == "FUCHSIA_CITY" then safe(ow, "isJanineAide", K.createJanineAide) end
        if id == "SAFFRON_CITY" then
          safe(ow, "isSaffronNode", K.createSaffronNode)
          safe(ow, "isPsyCrystal", K.createPsyCrystal)
        end
        if id == "CINNABAR_ISLAND" then
          safe(ow, "isCinnabarAide", K.createCinnabarAide)
          safe(ow, "isVolcanicAsh", K.createVolcanicAsh)
        end
        if id == "VIRIDIAN_CITY" then safe(ow, "isBlueFan", K.createBlueFan) end
        if id == "VICTORY_ROAD" then safe(ow, "isVRStamp", K.createVRStamp) end
        if id == "VICTORY_ROAD_GATE" then safe(ow, "isVRStamp", K.createVRStampGate) end
        if id == "WILLS_ROOM" then safe(ow, "isWillSeal", K.createWillSeal) end
        if id == "KOGAS_ROOM" then safe(ow, "isKogaSeal", K.createKogaSeal) end
        if id == "BRUNOS_ROOM" then safe(ow, "isBrunoSeal", K.createBrunoSeal) end
        if id == "KARENS_ROOM" then safe(ow, "isKarenSeal", K.createKarenSeal) end
        if id == "LANCES_ROOM" then safe(ow, "isLanceSeal", K.createLanceSeal) end
        if id == "INDIGO_PLATEAU_POKECENTER1_F" then
          safe(ow, "isLeagueClerk", K.createChampClerk)
          safe(ow, "isVRStamp", K.createVRStampFB)
          safe(ow, "isWillSeal", K.createWillSealFB)
          safe(ow, "isKogaSeal", K.createKogaSealFB)
          safe(ow, "isBrunoSeal", K.createBrunoSealFB)
          safe(ow, "isKarenSeal", K.createKarenSealFB)
          safe(ow, "isLanceSeal", K.createLanceSealFB)
        end
        if id == "SILVER_CAVE_ROOM3" then
          safe(ow, "isSilverEmblem", K.createSilverEmblem)
          safe(ow, "isSummitTrainer", K.createSummitTrainer)
        end
        if id == "SILVER_CAVE_ROOM1" then safe(ow, "isSilverEmblem", K.createSilverEmblemR1) end
        if id == "SILVER_CAVE_OUTSIDE" then
          safe(ow, "isSilverEmblem", K.createSilverEmblemOutside)
          safe(ow, "isSummitTrainer", K.createSummitTrainerOutside)
        end
        if id == "ROUTE28" then safe(ow, "isSummitTrainer", K.createSummitTrainerR28) end
        if id == "NATIONAL_PARK" then safe(ow, "isContestHost", K.createContestHost) end
        if id == "ROUTE35_NATIONAL_PARK_GATE" then safe(ow, "isContestHost", K.createContestHostGate) end
        if id == "ROUTE36_NATIONAL_PARK_GATE" then safe(ow, "isContestHost", K.createContestHostGate) end
      end
      return
    end

    if id == "PALLET_TOWN" and Q.felix then safe(ow, "isFixerFelix", Q.felix.createNPC) end
    if id == "VIRIDIAN_FOREST" and Q.bughead then safe(ow, "isBugHeadNpc", Q.bughead.createNPC) end
    if id == "POWER_PLANT" and Q.items then
      safe(ow, "isQuestCoil", Q.items.createCoilNPC)
      safe(ow, "isQuestLens", Q.items.createLensNPC)
    end
    if id == "PEWTER_CITY" and NPCs.trade.haunter then safe(ow, "isHaunterTrader", NPCs.trade.haunter.createNPC) end
  end

  function NPCs.talkTo(ow, npc, helpers)
    local Q = NPCs.quest
    local G = ow.game or Game
    if npc.isGuideMira and Q.mira then Q.mira.interact(G, npc, helpers) return true end
    if npc.isSageHiro and Q.hiro then Q.hiro.interact(G, npc, helpers) return true end
    if npc.isSignalScout and Q.scout then Q.scout.interact(G, npc, helpers) return true end
    if npc.isSproutBell and Q.sprout then Q.sprout.interact(G, "SPROUT_BELL", "SPROUT BELL", helpers) return true end
    if npc.isSproutScroll and Q.sprout then Q.sprout.interact(G, "SAGE_SCROLL", "SAGE SCROLL", helpers) return true end
    if npc.isCourierKen and Q.ken then Q.ken.interact(G, npc, helpers) return true end
    if npc.isKurtAide and Q.aide then Q.aide.interact(G, npc, helpers) return true end
    if npc.isWellKeeper and Q.wellKeeper then Q.wellKeeper.interact(G, npc, helpers) return true end
    if npc.isWellCharm and Q.wellItems then Q.wellItems.interact(G, "WELL_CHARM", "WELL CHARM", helpers) return true end
    if npc.isWellBucket and Q.wellItems then Q.wellItems.interact(G, "WELL_BUCKET", "WELL BUCKET", helpers) return true end
    if npc.isRadioTech and Q.radioTech then Q.radioTech.interact(G, npc, helpers) return true end
    if npc.isTunerChip and Q.underItems then Q.underItems.interact(G, helpers) return true end
    if npc.isTowerMonk and Q.monk then Q.monk.interact(G, npc, helpers) return true end
    if npc.isAshSample and Q.ashItem then Q.ashItem.interact(G, helpers) return true end
    if npc.isRageWatcher and Q.watcher then Q.watcher.interact(G, npc, helpers) return true end
    if npc.isMahoganyClerk and Q.clerk then Q.clerk.interact(G, npc, helpers) return true end
    if Q.jk then
      local J = Q.jk
      if npc.isSailorLight then J.interactSailorLight(G, npc, helpers) return true end
      if npc.isLampOil then J.interactLampOil(G, helpers) return true end
      if npc.isPharmacyAide then J.interactPharmacyAide(G, npc, helpers) return true end
      if npc.isRadioDirector then J.interactDirector(G, npc, helpers) return true end
      if npc.isCardKey then J.interactCardKey(G, helpers) return true end
      if npc.isTxCore then J.interactTxCore(G, helpers) return true end
      if npc.isDenGuard then J.interactDenGuard(G, npc, helpers) return true end
      if npc.isIceBeacon then J.interactIceBeacon(G, helpers) return true end
      if npc.isDragonElder then J.interactElder(G, npc, helpers) return true end
      if npc.isDragonToken then J.interactDragonToken(G, helpers) return true end
      if npc.isFallsGuide then J.interactFallsGuide(G, npc, helpers) return true end
      if npc.isGateRanger then J.interactGateRanger(G, npc, helpers) return true end
      if npc.isCustomsClerk then J.interactCustomsClerk(G, npc, helpers) return true end
      if npc.isIndigoClerk then J.interactIndigoClerk(G, npc, helpers) return true end
      if npc.isOakAide then J.interactOakAide(G, npc, helpers) return true end
    end

    if Q.kls then
      local K = Q.kls
      if npc.isPewterGuide then K.interactPewterGuide(G, npc, helpers) return true end
      if npc.isCeruleanAide then K.interactCeruleanAide(G, npc, helpers) return true end
      if npc.isVermilionClerk then K.interactVermilionClerk(G, npc, helpers) return true end
      if npc.isCeladonClerk then K.interactCeladonClerk(G, npc, helpers) return true end
      if npc.isNetworkTicket then K.interactNetworkTicket(G, helpers) return true end
      if npc.isJanineAide then K.interactJanineAide(G, npc, helpers) return true end
      if npc.isSaffronNode then K.interactSaffronNode(G, npc, helpers) return true end
      if npc.isPsyCrystal then K.interactPsyCrystal(G, helpers) return true end
      if npc.isCinnabarAide then K.interactCinnabarAide(G, npc, helpers) return true end
      if npc.isVolcanicAsh then K.interactVolcanicAsh(G, helpers) return true end
      if npc.isBlueFan then K.interactBlueFan(G, npc, helpers) return true end
      if npc.isVRStamp then K.interactSeal(G, helpers, "isVRStamp") return true end
      if npc.isWillSeal then K.interactSeal(G, helpers, "isWillSeal") return true end
      if npc.isKogaSeal then K.interactSeal(G, helpers, "isKogaSeal") return true end
      if npc.isBrunoSeal then K.interactSeal(G, helpers, "isBrunoSeal") return true end
      if npc.isKarenSeal then K.interactSeal(G, helpers, "isKarenSeal") return true end
      if npc.isLanceSeal then K.interactSeal(G, helpers, "isLanceSeal") return true end
      if npc.isLeagueClerk then K.interactLeagueClerk(G, npc, helpers) return true end
      if npc.isSilverEmblem then K.interactSilverEmblem(G, helpers) return true end
      if npc.isSummitTrainer then K.interactSummitTrainer(G, npc, helpers) return true end
      if npc.isContestHost then K.interactContestHost(G, npc, helpers) return true end
    end
    if npc.isFixerFelix and Q.felix then Q.felix.interact(G, npc, helpers) return true end
    if npc.isBugHeadNpc and Q.bughead then Q.bughead.interact(G, npc, helpers) return true end
    if npc.isQuestCoil and Q.items then Q.items.interact(G, "MAGNET_COIL", "MAGNETIZED COIL", helpers) return true end
    if npc.isQuestLens and Q.items then Q.items.interact(G, "CONDUIT_LENS", "CONDUIT LENS", helpers) return true end
    if npc.isGen2Trader and NPCs.trade.gen2 then NPCs.trade.gen2.interact(G, npc, helpers) return true end
    if npc.isHaunterTrader and NPCs.trade.haunter then NPCs.trade.haunter.interact(G, npc, helpers) return true end
    return false
  end

  return NPCs
end
