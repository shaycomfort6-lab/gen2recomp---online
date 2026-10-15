-- Quest 1012: ICE PATH BEACON
return {
  id = 1012,
  title = "ICE PATH BEACON",
  shortLabel = "G2-12. ICE",
  type = "solo",
  generation = 2,
  location = "ICE PATH & BLACKTHORN",
  lore = "A rescue beacon failed on the Ice Path.\fFind the ICE BEACON on Ice Path 1F and report to DEN GUARD in Blackthorn City.",
  objectives = {
    { id = "get_beacon", label = "GET ICE BEACON" },
    { id = "report_blackthorn", label = "REPORT DEN GUARD" },
  },
  reward = "MAX POTION x2 + 800 XP"
}
