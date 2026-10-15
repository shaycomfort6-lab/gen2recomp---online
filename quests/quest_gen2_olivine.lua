-- Quest 1009: OLIVINE LIGHTHOUSE
return {
  id = 1009,
  title = "OLIVINE LIGHTHOUSE",
  shortLabel = "G2-9. OLIVINE",
  type = "solo",
  generation = 2,
  location = "OLIVINE CITY & LIGHTHOUSE",
  lore = "The Olivine lighthouse lamp is fading.\fTalk to SAILOR LIGHT in Olivine City, recover LAMP OIL from the lighthouse, and return it!",
  objectives = {
    { id = "get_oil", label = "GET LAMP OIL" },
    { id = "deliver_oil", label = "RETURN TO SAILOR" },
  },
  reward = "SUPER REPEL x3 + 700 XP"
}
