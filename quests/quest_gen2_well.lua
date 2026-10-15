-- Quest 1005: Slowpoke Well Rescue (co-op)
return {
  id = 1005,
  title = "SLOWPOKE WELL RESCUE",
  shortLabel = "G2-5. WELL",
  type = "coop",
  generation = 2,
  location = "AZALEA & SLOWPOKE WELL",
  lore = "Team Rocket leftovers still haunt Slowpoke Well!\fTwo trainers must recover the WELL CHARM and WELL BUCKET from the well floors.\fYou cannot carry both — return to WELL KEEPER in Azalea Town with a partner!",
  objectives = {
    { id = "part_a", label = "WELL CHARM", item = "WELL_CHARM" },
    { id = "part_b", label = "WELL BUCKET", item = "WELL_BUCKET" },
    { id = "turn_in", label = "RETURN W/ PARTNER" }
  },
  reward = "SLOWPOKE LV15 + 1,000 XP"
}
