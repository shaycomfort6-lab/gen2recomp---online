-- Quest 1010: CIANWOOD MEDICINE
return {
  id = 1010,
  title = "CIANWOOD MEDICINE",
  shortLabel = "G2-10. CIANWOOD",
  type = "solo",
  generation = 2,
  location = "CIANWOOD CITY",
  lore = "A sailor's Pokémon is sick across the sea.\fSpeak to PHARMACY AIDE in Cianwood, pick up SECRET MEDICINE, and deliver it to SAILOR LIGHT in Olivine!",
  objectives = {
    { id = "get_medicine", label = "GET SECRET MEDICINE" },
    { id = "deliver_olivine", label = "DELIVER TO OLIVINE" },
  },
  reward = "FULL HEAL x3 + 700 XP"
}
