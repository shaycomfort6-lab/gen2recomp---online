-- Quest 1020: CELADON LINK
return {
  id = 1020,
  title = "CELADON LINK",
  shortLabel = "G2-20. CELADON",
  type = "solo",
  generation = 2,
  location = "CELADON CITY",
  lore = "Dept. Store network node is offline.\fPick up a NETWORK TICKET from Celadon and file it with the CLERK.",
  objectives = {
    { id = "get_ticket", label = "GET NETWORK TICKET" },
    { id = "file_ticket", label = "FILE WITH CLERK" },
  },
  reward = "PRISM SCALE x1 + 600 XP"
}
