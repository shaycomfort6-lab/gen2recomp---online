-- Quest 1004: Route 29 Courier
return {
  id = 1004,
  title = "ROUTE 29 COURIER",
  shortLabel = "G2-4. ROUTE29",
  type = "solo",
  generation = 2,
  location = "ROUTE 29 & AZALEA",
  lore = "Guide Mira's network needs a test parcel carried along Route 29 to Azalea Town.\fSpeak to COURIER KEN on Route 29, then deliver the ONLINE PARCEL to KURT'S AIDE in Azalea Town!",
  objectives = {
    { id = "take_parcel", label = "TAKE PARCEL (ROUTE 29)" },
    { id = "deliver_azalea", label = "DELIVER IN AZALEA" }
  },
  reward = "POTION x5 + 400 XP"
}
