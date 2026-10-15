-- Quest 1001: Online Orientation (New Bark Town)
return {
  id = 1001,
  title = "WELCOME TO JOHTO",
  shortLabel = "G2-1. WELCOME",
  type = "solo",
  generation = 2,
  location = "NEW BARK TOWN",
  lore = "Guide Mira is waiting in New Bark Town for every trainer who connects online.\fSpeak with her to register your Johto online profile and learn the co-op signal system!",
  objectives = {
    { id = "talk_mira", label = "TALK TO GUIDE MIRA" },
    { id = "registered", label = "REGISTER ONLINE" }
  },
  reward = "ONLINE PROFILE + 250 XP"
}
