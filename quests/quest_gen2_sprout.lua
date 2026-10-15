-- Quest 1002: Sprout Tower Relay (Co-op, Violet / Sprout Tower)
return {
  id = 1002,
  title = "SPROUT TOWER RELAY",
  shortLabel = "G2-2. SPROUT",
  type = "coop",
  generation = 2,
  location = "VIOLET CITY & SPROUT TOWER",
  lore = "The sages of Sprout Tower need two trainers working together.\fOne recovers the SPROUT BELL from the lower hall; the other recovers the SAGE SCROLL from the upper landing.\fYou cannot carry both — meet Guide Mira's contact SAGE HIRO in Violet City with your partner!",
  objectives = {
    { id = "part_a", label = "SPROUT BELL", item = "SPROUT_BELL" },
    { id = "part_b", label = "SAGE SCROLL", item = "SAGE_SCROLL" },
    { id = "turn_in", label = "RETURN W/ PARTNER" }
  },
  reward = "BELLSPROUT LV20 + 1,000 XP"
}
