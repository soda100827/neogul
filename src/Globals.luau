-- Global variables shared across modules
local Globals = {}

Globals.Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()
Globals.ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
Globals.SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

-- Handlers for Toggles and Options are usually accessed via Library.Toggles / Library.Options
-- But we can expose them if needed, though they are dynamically updated.

return Globals
