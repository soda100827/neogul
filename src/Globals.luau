-- Global variables shared across modules
local Globals = {}

Globals.Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()
Globals.ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
Globals.SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

-- Fix for LinoriaLib versions that use global Toggles/Options but don't attach to Library
local Toggles = getgenv and getgenv().Toggles or Toggles or {}
local Options = getgenv and getgenv().Options or Options or {}

Globals.Library.Toggles = Globals.Library.Toggles or Toggles
Globals.Library.Options = Globals.Library.Options or Options

-- Also expose via Globals just in case
Globals.Toggles = Globals.Library.Toggles
Globals.Options = Globals.Library.Options

return Globals
