-- Quest 1011: RADIO TOWER SIEGE
return {
  id = 1011,
  title = "RADIO TOWER SIEGE",
  shortLabel = "G2-11. RADIO",
  type = "coop",
  generation = 2,
  location = "GOLDENROD RADIO TOWER",
  lore = "Team Rocket has jammed the Radio Tower!\fTwo trainers must recover the CARD KEY and the TRANSMITTER CORE.\fTurn them in to DIRECTOR at Radio Tower 1F with a partner!",
  objectives = {
    { id = "part_a", label = "CARD KEY", item = "CARD_KEY" },
    { id = "part_b", label = "TRANSMITTER CORE", item = "TX_CORE" },
    { id = "turn_in", label = "RETURN W/ PARTNER" },
  },
  reward = "MAGNETON LV25 + 1,200 XP"
}
