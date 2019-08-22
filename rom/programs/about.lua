-- Prints information about CraftOS
term.setTextColor(colors.yellow)
print(os.version() .. " on " .. string.gsub(os.about(), "\n.+$", ""))
term.setTextColor(colors.white)