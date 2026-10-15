-- Quest 1003: Cherrygrove Signal (Solo bridge quest)
return {
  id = 1003,
  title = "CHERRYGROVE SIGNAL",
  shortLabel = "G2-3. CHERRY",
  type = "solo",
  generation = 2,
  location = "CHERRYGROVE CITY",
  lore = "Guide Mira needs a test signal delivered to Cherrygrove City.\fTalk to SIGNAL SCOUT at the Cherrygrove entrance to confirm the online network reaches Route 29!",
  objectives = {
    { id = "reach_cherry", label = "REACH CHERRYGROVE" },
    { id = "talk_scout", label = "TALK TO SIGNAL SCOUT" }
  },
  reward = "GREAT BALL x5 + 500 XP"
}
