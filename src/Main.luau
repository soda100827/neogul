-- Main Entry Point
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

-- 1. Security Bypass / Cleanup
pcall(function()
    local replicatedFirst = game:GetService("ReplicatedFirst")
    for _, child in pairs(replicatedFirst:GetChildren()) do
        if child:IsA("LocalScript") then 
            child.Enabled = false 
            child:Destroy() 
        end
    end
    local analytics = replicatedFirst:FindFirstChild("AnalyticsPipelineController")
    if analytics then 
        analytics:Destroy() 
    end
end)

local player = Players.LocalPlayer
local playerScripts = player.PlayerScripts
local controllers = playerScripts.Controllers
local EnumLibrary = require(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
if EnumLibrary then 
    EnumLibrary:WaitForEnumBuilder() 
end

-- 2. Load Globals
-- Assuming this file is run from src/Main.luau, we need to locate Globals relative to it
-- or we assume the loader passes the path or we use relative paths if the executor supports it.
-- For standard 'loadfile' execution, we might need a helper to require files.

-- Configuration
local Repository = "https://raw.githubusercontent.com/soda100827/neogul/main/"

local function safeLoad(path)
    -- Remove 'rivals_neogul/src/' if it was added for local testing
    -- We assume the repo structure matches 'src/' or the path passed is relative to 'src'
    local success, result = pcall(function()
        return game:HttpGet(Repository .. "src/" .. path)
    end)

    if not success then
        return error("Failed to download " .. path .. ": " .. result)
    end
    
    local chunk, err = loadstring(result)
    if not chunk then
        return error("Failed to compile " .. path .. ": " .. (err or "Unknown error"))
    end
    
    return chunk()
end

local Globals = safeLoad("Globals.luau")
local Library = Globals.Library
local SaveManager = Globals.SaveManager
local ThemeManager = Globals.ThemeManager

-- 3. Load UI
safeLoad("UI/Interface.luau")(Globals)

-- 4. Load Modules
safeLoad("Modules/Combat.luau")(Globals)
safeLoad("Modules/Movement.luau")(Globals)
safeLoad("Modules/Misc.luau")(Globals)

-- 5. Finalize Library
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/rivals')

-- UI Settings Hook for "Remove Autoload"
local UISettingsTab = Globals.Tabs['UI Settings']
local oldAddRightGroupbox = UISettingsTab.AddRightGroupbox

UISettingsTab.AddRightGroupbox = function(self, name)
    local groupbox = oldAddRightGroupbox(self, name)
    if name == 'Configuration' then
        local oldAddButton = groupbox.AddButton
        groupbox.AddButton = function(self, text, func)
            local button = oldAddButton(self, text, func)
            if text == 'Set as autoload' then
                button:AddButton('Remove Autoload', function()
                    local autoloadPath = SaveManager.Folder .. '/settings/autoload.txt'
                    if isfile(autoloadPath) then
                        delfile(autoloadPath)
                        if SaveManager.AutoloadLabel then
                            SaveManager.AutoloadLabel:SetText('Current autoload config: none')
                        end
                        Library:Notify('Autoload removed. Reset to default.')
                    else
                        Library:Notify('No autoload config set.')
                    end
                end)
            end
            return button
        end
    end
    return groupbox
end

SaveManager:BuildConfigSection(UISettingsTab)
UISettingsTab.AddRightGroupbox = oldAddRightGroupbox
ThemeManager:ApplyToTab(UISettingsTab)
SaveManager:LoadAutoloadConfig()

Library:Notify('Neogul Scripts Loaded!')
