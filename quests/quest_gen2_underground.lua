-- Quest 1006: Goldenrod Underground Static
return {
  id = 1006,
  title = "UNDERGROUND STATIC",
  shortLabel = "G2-6. UNDER",
  type = "solo",
  generation = 2,
  location = "GOLDENROD UNDERGROUND",
  lore = "Radio interference is leaking from Goldenrod Underground.\fFind the TUNER CHIP in the underground tunnels and bring it to RADIO TECH in Goldenrod City!",
  objectives = {
    { id = "find_chip", label = "FIND TUNER CHIP" },
    { id = "deliver_tech", label = "GIVE TO RADIO TECH" }
  },
  reward = "SUPER POTION x3 + 600 XP"
}
