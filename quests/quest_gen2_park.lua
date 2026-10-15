-- Quest 1027: National Park Bug Contest (online side event)
return {
  id = 1027,
  title = "BUG CONTEST ONLINE",
  shortLabel = "G2-27. PARK",
  type = "solo",
  generation = 2,
  location = "NATIONAL PARK",
  lore = "National Park hosts an online Bug Contest checkpoint.\\fTalk to the CONTEST HOST inside the park to register and claim a participant prize.",
  objectives = {
    { id = "enter_park", label = "ENTER NATIONAL PARK" },
    { id = "talk_host", label = "TALK CONTEST HOST" }
  },
  reward = "NET BALL x5 + 600 XP"
}
