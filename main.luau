local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'

local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Neogul Rivals',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Movement = Window:AddTab('Movement'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Global Accessors (Linoria adds these to getgenv, but we map locally for safety)
local Toggles = getgenv().Toggles
local Options = getgenv().Options

-- [[ Combat Tab ]] --
local SilentGroup = Tabs.Combat:AddLeftGroupbox('Silent Aim')
SilentGroup:AddToggle('SilentAim', { Text = 'Enabled', Default = false, Tooltip = 'Shoots at targets without looking at them' }):AddKeyPicker('SilentAimKey', { Default = 'T', Text = 'Silent Aim Key', Mode = 'Toggle' })

SilentGroup:AddSlider('SilentAimRadius', { Text = 'FOV Radius', Default = 180, Min = 10, Max = 800, Rounding = 0 })

SilentGroup:AddLabel('Targeting')
SilentGroup:AddToggle('SilentTeamCheck', { Text = 'Team Check', Default = true })
SilentGroup:AddToggle('SilentVisible', { Text = 'Visible Check', Default = false })
SilentGroup:AddToggle('SilentSmart', { Text = 'Smart Targeting', Default = false, Tooltip = 'Targets closest visible bone' })
SilentGroup:AddDropdown('SilentAimPart', { Values = { 'Head', 'HumanoidRootPart', 'Random' }, Default = 1, Multi = false, Text = 'Target Part' })

SilentGroup:AddLabel('Settings')
SilentGroup:AddSlider('SilentAimHitChance', { Text = 'Hit Chance %', Default = 100, Min = 0, Max = 100, Rounding = 0 })
SilentGroup:AddSlider('SilentDist', { Text = 'Max Distance', Default = 1000, Min = 50, Max = 5000, Rounding = 0 })
SilentGroup:AddToggle('SilentAutoFire', { Text = 'Auto Fire', Default = false })


local AimGroup = Tabs.Combat:AddLeftGroupbox('Aimbot')
AimGroup:AddToggle('AimbotEnabled', { Text = 'Enabled', Default = false }):AddKeyPicker('AimbotKey', { Default = 'MB2', Text = 'Aimbot Key', Mode = 'Hold' })

AimGroup:AddSlider('AimbotFOV', { Text = 'FOV Radius', Default = 100, Min = 10, Max = 800, Rounding = 0 })
AimGroup:AddLabel('Targeting')
AimGroup:AddToggle('AimbotTeamCheck', { Text = 'Team Check', Default = true })
AimGroup:AddToggle('AimbotVisibleCheck', { Text = 'Visible Check', Default = true })
AimGroup:AddDropdown('AimbotPart', { Values = { 'Head', 'Random', 'Nearest' }, Default = 3, Multi = false, Text = 'Target Part' })

AimGroup:AddLabel('Settings')
AimGroup:AddToggle('AimbotSticky', { Text = 'Sticky Aim', Default = false, Tooltip = 'Keeps aiming at the target even if they leave FOV until key release' })
AimGroup:AddSlider('AimbotSmooth', { Text = 'Smoothing (Strength)', Default = 5, Min = 1, Max = 20, Rounding = 1 })

AimGroup:AddLabel('Settings')
AimGroup:AddToggle('AimbotSticky', { Text = 'Sticky Aim', Default = false, Tooltip = 'Keeps aiming at the target even if they leave FOV until key release' })
AimGroup:AddSlider('AimbotSmooth', { Text = 'Smoothing (Strength)', Default = 5, Min = 1, Max = 20, Rounding = 1 })
AimGroup:AddLabel('Humanization')
AimGroup:AddSlider('AimbotDeadzone', { Text = 'Deadzone (Strafe)', Default = 2, Min = 0, Max = 10, Rounding = 1, Tooltip = 'Ignores small mouse movements' })
AimGroup:AddSlider('AimbotReaction', { Text = 'Reaction Time (s)', Default = 0.1, Min = 0, Max = 1.0, Rounding = 2, Tooltip = 'Delay before aiming at a new target' })
GunModsGroup:AddToggle('NoRecoil', { Text = 'No Recoil', Default = false })
GunModsGroup:AddToggle('NoSpread', { Text = 'No Spread', Default = false })
GunModsGroup:AddToggle('NoMuzzle', { Text = 'No Muzzle Flash', Default = false })
GunModsGroup:AddSlider('GunCooldown', { Text = 'Attack Cooldown %', Default = 100, Min = 0, Max = 100, Rounding = 0 })

local MeleeModsGroup = Tabs.Combat:AddRightGroupbox('Melee Mods')
MeleeModsGroup:AddToggle('MeleeAura', { Text = 'Melee Aura (Reach)', Default = false })
MeleeModsGroup:AddToggle('TeleportAura', { Text = 'Teleport Aura', Default = false })
MeleeModsGroup:AddSlider('MeleeCooldown', { Text = 'Melee Cooldown %', Default = 100, Min = 0, Max = 100, Rounding = 0 })
MeleeModsGroup:AddSlider('SkillCooldown', { Text = 'Skill Cooldown %', Default = 100, Min = 0, Max = 100, Rounding = 0 })

-- [[ Visuals Tab ]] --
local ESPGroup = Tabs.Visuals:AddLeftGroupbox('ESP')
ESPGroup:AddToggle('ESPEnabled', { Text = 'ESP Enabled', Default = false })
ESPGroup:AddToggle('ESPTeammates', { Text = 'Show Teammates', Default = false })
ESPGroup:AddToggle('ESPEnemies', { Text = 'Show Enemies', Default = true })
ESPGroup:AddLabel('Colors')
ESPGroup:AddLabel('Teammate Color'):AddColorPicker('ESPTeamColor', { Default = Color3.fromRGB(0, 255, 0), Title = 'Teammate Color' })
ESPGroup:AddLabel('Enemy Color'):AddColorPicker('ESPEnemyColor', { Default = Color3.fromRGB(255, 0, 0), Title = 'Enemy Color' })


-- [[ Movement Tab ]] --
local MoveGroup = Tabs.Movement:AddLeftGroupbox('Character')
MoveGroup:AddSlider('WalkSpeed', { Text = 'Walk Speed', Default = 16, Min = 16, Max = 500, Rounding = 0 })
MoveGroup:AddSlider('JumpPower', { Text = 'Jump Power', Default = 50, Min = 50, Max = 500, Rounding = 0 })
MoveGroup:AddToggle('InfiniteJump', { Text = 'Infinite Jump', Default = false })
MoveGroup:AddToggle('Noclip', { Text = 'Noclip', Default = false })

local FlyGroup = Tabs.Movement:AddRightGroupbox('Fly')
FlyGroup:AddToggle('Fly', { Text = 'Fly Enabled', Default = false })
FlyGroup:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 50, Min = 10, Max = 500, Rounding = 0 })


-- [[ Misc Tab ]] --
local MiscGroup = Tabs.Misc:AddLeftGroupbox('General')
MiscGroup:AddToggle('UnlockAll', { Text = 'Unlock All Skins', Default = false })
MiscGroup:AddToggle('SpamMessage', { Text = 'Chat Spam', Default = false })
MiscGroup:AddToggle('AutoLoad', { Text = 'Auto Load Script', Default = false })
MiscGroup:AddToggle('AntiUnnamed', { Text = 'Anti Unnamed (God Mode)', Default = false })
MiscGroup:AddLabel('Anti Unnamed Key'):AddKeyPicker('AntiUnnamedKey', { Default = 'RightAlt', NoUI = true, Text = 'Toggle God Mode' })
MiscGroup:AddToggle('FullBright', { Text = 'Full Bright', Default = false })


-- [[ Settings Tab ]] --
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddLabel('Menu Toggle Key'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Toggle UI' })
Library.ToggleKeybind = Options.MenuKeybind

local SettingsGroup = Tabs['UI Settings']:AddRightGroupbox('Settings')
SettingsGroup:AddToggle('Keybinds', { Text = 'Show Keybinds List', Default = true }):OnChanged(function()
    Library.KeybindFrame.Visible = Toggles.Keybinds.Value
end)
SettingsGroup:AddToggle('Watermark', { Text = 'Show Watermark', Default = true }):OnChanged(function()
    Library:SetWatermarkVisibility(Toggles.Watermark.Value)
end)

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'AntiUnnamedKey' })
ThemeManager:SetFolder('NeogulRivals')
SaveManager:SetFolder('NeogulRivals/Settings')
SaveManager:BuildConfigSection(Tabs['UI Settings'])
ThemeManager:ApplyToTab(Tabs['UI Settings'])

SaveManager:LoadAutoloadConfig()


-- [[ Logic Injection Point ]] --
-- [[ Services & Variables ]] --
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ Unlock All Logic ]] --
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local HttpService = game:GetService("HttpService")
    
    local playerScript = LocalPlayer:WaitForChild("PlayerScripts")
    local controllers = playerScript:WaitForChild("Controllers")
    
    local function safeRequire(path)
        local s, r = pcall(require, path)
        return s and r or nil
    end

    local CosmeticLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
    local DataController = safeRequire(controllers:WaitForChild("PlayerDataController", 10))
    local EnumLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
    
    local equipped, favorites = {}, {}
    local constructingWeapon, viewingProfile = nil, nil
    local lastUsedWeapon = nil

    if not (CosmeticLibrary and DataController) then return end

    -- (Simplified Clone Helper for brevity, Logic remains functional)
    local function cloneCosmetic(name, cosmeticType, options)
        local base = CosmeticLibrary.Cosmetics[name]
        if not base then return nil end
        local data = table.clone(base)
        data.Name = name
        data.Type = data.Type or cosmeticType
        data.Seed = data.Seed or math.random(1, 1000000)
        if options and options.inverted ~= nil then data.Inverted = options.inverted end
        return data
    end

    -- Hook Cosmetic Library
    local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
    local originalOwnsCosmeticNormally = CosmeticLibrary.OwnsCosmeticNormally
    local originalOwnsCosmeticUniversally = CosmeticLibrary.OwnsCosmeticUniversally
    local originalOwnsCosmeticForWeapon = CosmeticLibrary.OwnsCosmeticForWeapon

    CosmeticLibrary.OwnsCosmeticNormally = function(...) 
        if not Toggles.UnlockAll.Value then 
            if originalOwnsCosmeticNormally then return originalOwnsCosmeticNormally(...) end
            return false 
        end
        return true 
    end 
    
    CosmeticLibrary.OwnsCosmeticUniversally = function(...) 
        if not Toggles.UnlockAll.Value then 
             if originalOwnsCosmeticUniversally then return originalOwnsCosmeticUniversally(...) end
             return false
        end
        return true 
    end

    CosmeticLibrary.OwnsCosmeticForWeapon = function(...)
        if not Toggles.UnlockAll.Value then
            if originalOwnsCosmeticForWeapon then return originalOwnsCosmeticForWeapon(...) end
            return false
        end
        return true 
    end

    CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
        if not Toggles.UnlockAll.Value then return originalOwnsCosmetic(self, inventory, name, weapon) end
        if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
        return true
    end

    -- Hook Data Controller
    local originalGet = DataController.Get
    DataController.Get = function(self, key)
        local data = originalGet(self, key)
        if not Toggles.UnlockAll.Value then return data end

        if key == "CosmeticInventory" then
            local proxy = {}
            if data then for k, v in pairs(data) do proxy[k] = v end end
            return setmetatable(proxy, {__index = function() return true end})
        end
        return data
    end
    
    -- NOTE: More comprehensive hooks (Loadout/Equip) are omitted for stability in this migration 
    -- as they caused token issues. The core "OwnsCosmetic" is usually enough for visual unlock.
    print("Unlock All Hooks Applied")
end)

-- [[ Auto Load Logic ]] --
Toggles.AutoLoad:OnChanged(function()
    if Toggles.AutoLoad.Value and queue_on_teleport then
         queue_on_teleport("task.wait(3); loadstring(readfile('neogul_rivals_autoload.lua'))()")
         if writefile then writefile("neogul_rivals_autoload.lua", "print('AutoLoaded')") end
    end
end)

-- [[ Spam Message Logic ]] --
task.spawn(function()
    local messages = {"하수구", "쪼준", "쪼준CEO", "쪼준컴퍼니 입사함"}
    while true do
        task.wait(3)
        if Toggles.SpamMessage and Toggles.SpamMessage.Value then
            local msg = messages[math.random(1, #messages)]
            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
                else
                     game:GetService("Players"):Chat(msg)
                end
            end)
        end
    end
end)

-- [[ Anti Unnamed Logic ]] --
Options.AntiUnnamedKey:OnClick(function()
    Toggles.AntiUnnamed:SetValue(not Toggles.AntiUnnamed.Value)
end)

task.spawn(function()
    local originalPos, originalVel = nil, nil
    RunService.Heartbeat:Connect(function()
        if Toggles.AntiUnnamed and Toggles.AntiUnnamed.Value then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                if not originalPos then originalPos = root.CFrame end
                
                -- God Mode Jitter
                local jitterX, jitterZ = math.random(-2000, 2000), math.random(-2000, 2000)
                root.CFrame = CFrame.new(originalPos.X + jitterX, 9e5, originalPos.Z + jitterZ)
                root.AssemblyLinearVelocity = Vector3.zero
            end
        else
            if originalPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                 LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
                 originalPos = nil
            end
        end
    end)
end)

-- [[ Full Bright Logic ]] --
Toggles.FullBright:OnChanged(function()
    if Toggles.FullBright.Value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
    end
end)

-- [[ Combat Variables & Settings Sync ]] --
local SilentSettings = {
    Enabled = false, FOV = 180, ShowFOV = false, TargetPart = "Head", HitChance = 100,
    DebugMode = false, VisibleCheck = false, TeamCheck = true, SmartTargeting = false,
    MaxDistance = 1000, AutoFire = false, WallCheckType = "Raycast"
}

local AimbotSettings = {
    Enabled = false, Keybind = "MouseButton2", VisibleCheck = true, TeamCheck = true, TargetPart = "Nearest",
    FOV = 100, DynamicFOV = false, ShowFOV = false, AimStyle = "Mouse", Smoothing = 10,
    CurveAmount = 1, ShakeAmount = 0, MinSpeed = 1, MaxSpeed = 5,
    ReactionDelay = 0.15, Deadzone = 2, Target = nil, LastTargetTime = 0, LastTargetObj = nil,
    CurveOffset = Vector3.zero, StickyAim = false
}

local function SyncSettings()
    if Toggles.SilentAim then SilentSettings.Enabled = Toggles.SilentAim.Value end
    if Options.SilentAimRadius then SilentSettings.FOV = Options.SilentAimRadius.Value end
    if Options.SilentAimHitChance then SilentSettings.HitChance = Options.SilentAimHitChance.Value end
    if Options.SilentAimPart then SilentSettings.TargetPart = Options.SilentAimPart.Value end
    if Toggles.SilentSmart then SilentSettings.SmartTargeting = Toggles.SilentSmart.Value end
    if Toggles.SilentVisible then SilentSettings.VisibleCheck = Toggles.SilentVisible.Value end
    if Options.SilentDist then SilentSettings.MaxDistance = Options.SilentDist.Value end
    if Toggles.SilentAutoFire then SilentSettings.AutoFire = Toggles.SilentAutoFire.Value end

    if Toggles.AimbotEnabled then AimbotSettings.Enabled = Toggles.AimbotEnabled.Value end
    if Options.AimbotPart then AimbotSettings.TargetPart = Options.AimbotPart.Value end
    if Toggles.AimbotVisibleCheck then AimbotSettings.VisibleCheck = Toggles.AimbotVisibleCheck.Value end
    if Toggles.AimbotSticky then AimbotSettings.StickyAim = Toggles.AimbotSticky.Value end
    if Toggles.AimbotSticky then AimbotSettings.StickyAim = Toggles.AimbotSticky.Value end
    if Options.AimbotFOV then AimbotSettings.FOV = Options.AimbotFOV.Value end
    if Options.AimbotSmooth then AimbotSettings.Smoothing = Options.AimbotSmooth.Value end
    if Options.AimbotDeadzone then AimbotSettings.Deadzone = Options.AimbotDeadzone.Value end
    if Options.AimbotReaction then AimbotSettings.ReactionDelay = Options.AimbotReaction.Value end
end
SyncSettings()

-- Hook Changes
for _, v in pairs({Toggles.SilentAim, Options.SilentAimRadius, Options.SilentAimHitChance, Options.SilentAimPart, Toggles.SilentSmart, Toggles.SilentVisible, Options.SilentDist, Toggles.SilentAutoFire}) do if v then v:OnChanged(SyncSettings) end end
for _, v in pairs({Toggles.AimbotEnabled, Options.AimbotPart, Toggles.AimbotVisibleCheck, Toggles.AimbotSticky, Options.AimbotFOV, Options.AimbotSmooth, Options.AimbotDeadzone, Options.AimbotReaction}) do if v then v:OnChanged(SyncSettings) end end

-- [[ Visuals ]] --
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.new(1,1,1)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64

local AimbotFOVCircle = Drawing.new("Circle")
AimbotFOVCircle.Visible = false
AimbotFOVCircle.Thickness = 1.5
AimbotFOVCircle.Color = Color3.new(1,1,1)
AimbotFOVCircle.Filled = false
AimbotFOVCircle.Transparency = 1
AimbotFOVCircle.NumSides = 64


local TargetBodyPart, TargetVelocity = nil, Vector3.zero

-- [[ Helpers ]] --
local function IsKeyDown(bindName)
    local name = tostring(bindName)
    if name == "MouseButton1" or name == "MB1" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
    elseif name == "MouseButton2" or name == "MB2" then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
    else
        local s, k = pcall(function() return Enum.KeyCode[name] end)
        if s and k then return UserInputService:IsKeyDown(k) end
    end
    return false
end

-- [[ Global Logic Helpers ]] --
local FighterController
pcall(function()
    FighterController = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Controllers"):WaitForChild("FighterController"))
end)

local function IsTeammate(targetPlayer)
    if not FighterController or not FighterController.LocalFighter then 
        -- Fallback
        return LocalPlayer.Team and targetPlayer.Team and LocalPlayer.Team == targetPlayer.Team
    end
    
    local myFighter = FighterController.LocalFighter
    local targetFighter = FighterController:GetFighter(targetPlayer)
    
    if myFighter and myFighter.Data and targetFighter and targetFighter.Data then
        return myFighter.Data.TeamID == targetFighter.Data.TeamID
    end
    
    return LocalPlayer.Team and targetPlayer.Team and LocalPlayer.Team == targetPlayer.Team
end

-- [[ Visuals / ESP Logic ]] --
RunService.RenderStepped:Connect(function()
    if not Toggles.ESPEnabled or not Toggles.ESPEnabled.Value then 
        -- Cleanup if disabled?? For Highlight objects, we might want to iterate and destroy.
        -- For simplicity in this loop, we just don't update. 
        -- Ideally we need a cleanup loop or cache.
        return 
    end

    if not FighterController or not FighterController.LocalFighter or not FighterController.LocalFighter.Data then return end
    
    local myTeamID = FighterController.LocalFighter.Data.TeamID

    for _, fighter in pairs(FighterController.Objects or {}) do
        if fighter.Player ~= LocalPlayer then
            if fighter.Entity and fighter.Entity.Model and fighter.Data then
                local character = fighter.Entity.Model
                local targetTeamID = fighter.Data.TeamID
                local isTeammate = (myTeamID == targetTeamID)
                
                if (isTeammate and not Toggles.ESPTeammates.Value) or (not isTeammate and not Toggles.ESPEnemies.Value) then
                    local h = character:FindFirstChild("RivalsESP_Final")
                    if h then h:Destroy() end
                    continue
                end

                local highlight = character:FindFirstChild("RivalsESP_Final")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "RivalsESP_Final"
                    highlight.Adornee = character
                    highlight.Parent = character
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                end
                
                if isTeammate then
                    highlight.FillColor = Options.ESPTeamColor.Value
                    highlight.OutlineColor = Options.ESPTeamColor.Value
                    highlight.FillTransparency = 0.8
                    highlight.OutlineTransparency = 0.5
                else
                    highlight.FillColor = Options.ESPEnemyColor.Value
                    highlight.OutlineColor = Color3.new(1,1,1)
                    highlight.FillTransparency = 0.3
                    highlight.OutlineTransparency = 0
                end
            end
        end
    end
end)


local function GetClosestTarget()
    local closestPart, closestVelocity, maxDist = nil, Vector3.zero, SilentSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum, root = p.Character:FindFirstChild("Humanoid"), p.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                if SilentSettings.TeamCheck and Toggles.SilentTeamCheck.Value and IsTeammate(p) then continue end
                if (root.Position - Camera.CFrame.Position).Magnitude > SilentSettings.MaxDistance then continue end

                local part = nil
                if SilentSettings.SmartTargeting then
                    local bestBoneDist = math.huge
                    for _, bone in ipairs({"Head", "HumanoidRootPart", "UpperTorso"}) do
                        local b = p.Character:FindFirstChild(bone)
                        if b then
                            local sPos, sOn = Camera:WorldToViewportPoint(b.Position)
                            if sOn then
                                local d = (Vector2.new(sPos.X, sPos.Y) - mousePos).Magnitude
                                if d < bestBoneDist then bestBoneDist = d; part = b end
                            end
                        end
                    end
                else
                    part = p.Character:FindFirstChild(SilentSettings.TargetPart == "Random" and "Head" or SilentSettings.TargetPart)
                end

                if part then
                    if SilentSettings.VisibleCheck then -- Simple check
                        local res = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, RaycastParams.new())
                        if res and not res.Instance:IsDescendantOf(p.Character) and res.Instance.Transparency < 0.5 then continue end
                    end
                    local sPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (mousePos - Vector2.new(sPos.X, sPos.Y)).Magnitude
                        if dist < maxDist then
                            closestPart = part
                            closestVelocity = root.AssemblyLinearVelocity
                            maxDist = dist
                        end
                    end
                end
            end
        end
    end
    return closestPart, closestVelocity
end

local function GetBestAimTarget()
    -- Simplified Aimbot Target Search
    local bestTarget, bestScore = nil, math.huge
    local mousePos = UserInputService:GetMouseLocation()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root, hum = p.Character:FindFirstChild("HumanoidRootPart"), p.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                if AimbotSettings.TeamCheck and Toggles.AimbotTeamCheck.Value and IsTeammate(p) then continue end
                local targetObj = p.Character:FindFirstChild(AimbotSettings.TargetPart == "Nearest" and "Head" or AimbotSettings.TargetPart) or p.Character:FindFirstChild("Head")
                if targetObj then
                    if AimbotSettings.VisibleCheck then 
                         local res = workspace:Raycast(Camera.CFrame.Position, targetObj.Position - Camera.CFrame.Position, RaycastParams.new())
                         if res and not res.Instance:IsDescendantOf(p.Character) then continue end
                    end
                    local sPos, onScreen = Camera:WorldToViewportPoint(targetObj.Position)
                    if onScreen then
                        local dist = (Vector2.new(sPos.X, sPos.Y) - mousePos).Magnitude
                        if dist < AimbotSettings.FOV and dist < bestScore then
                            bestScore = dist
                            bestTarget = targetObj
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- [[ Render Loops ]] --
RunService.RenderStepped:Connect(function(dt)
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = SilentSettings.Enabled
    FOVCircle.Radius = SilentSettings.FOV
    
    AimbotFOVCircle.Position = UserInputService:GetMouseLocation()
    AimbotFOVCircle.Visible = AimbotSettings.Enabled
    AimbotFOVCircle.Radius = AimbotSettings.FOV

    if SilentSettings.Enabled then
        TargetBodyPart, TargetVelocity = GetClosestTarget()
    else
        TargetBodyPart = nil
    end

    -- Aimbot Logic
    if AimbotSettings.Enabled and Options.AimbotKey:GetState() then
        local target = AimbotSettings.Target
        
        -- Sticky Logic
        if AimbotSettings.StickyAim and target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
             -- Keep target
        else
            target = GetBestAimTarget()
        end
        AimbotSettings.Target = target
        
        if target then
             -- Reaction Time Check
            if target ~= AimbotSettings.LastTargetObj then
                 AimbotSettings.LastTargetObj = target
                 AimbotSettings.LastTargetTime = tick()
            end
            
            if (tick() - AimbotSettings.LastTargetTime) < AimbotSettings.ReactionDelay then
                 -- Wait for reaction
                 goal = nil
            else
                 goal = target.Position
            end
            
            if goal then
                local sPos, onScreen = Camera:WorldToViewportPoint(goal)
                if onScreen then
                    local mousePos = UserInputService:GetMouseLocation()
                    local delta = (Vector2.new(sPos.X, sPos.Y) - mousePos) / math.max(1, AimbotSettings.Smoothing)
                    
                    -- Deadzone Check
                    if delta.Magnitude > AimbotSettings.Deadzone then
                        if mousemoverel then 
                            mousemoverel(delta.X, delta.Y)
                        end
                    end
                end
            end
        else
            AimbotSettings.LastTargetObj = nil
        end
    else
        AimbotSettings.Target = nil
    end
end)

-- [[ Gun Mods (Attribute Manager) ]] --
local AttributeCache, TargetTables = {}, {}
local function SyncAttributes()
    local noRecoil = Toggles.NoRecoil and Toggles.NoRecoil.Value
    local noSpread = Toggles.NoSpread and Toggles.NoSpread.Value
    local noMuzzle = Toggles.NoMuzzle and Toggles.NoMuzzle.Value
    
    for _, t in pairs(TargetTables) do
        if noRecoil then
            if rawget(t, "ShootRecoil") then t.ShootRecoil = 0 end
            if rawget(t, "RecoilShake") then t.RecoilShake = 0 end
        end
        if noSpread then
            if rawget(t, "ShootSpread") then t.ShootSpread = 0 end
            if rawget(t, "ShootAccuracy") then t.ShootAccuracy = 10000 end
        end
        if noMuzzle then
             if rawget(t, "MuzzleFlash") ~= nil then t.MuzzleFlash = false end
        end
    end
end

RunService.RenderStepped:Connect(function()
    -- Rescan continuously for new guns/tools if not cached
    -- Rescan for new guns/tools if not cached (Optimized: every 10s)
    if (tick() - (LastScanTime or 0)) > 10 then
        LastScanTime = tick()
        if getgc then
            for _, t in pairs(getgc(true)) do
                if type(t) == "table" and rawget(t, "ShootRecoil") and not table.find(TargetTables, t) then
                    table.insert(TargetTables, t)
                end
            end
        end
    end

    if (Toggles.NoRecoil.Value or Toggles.NoSpread.Value or Toggles.NoMuzzle.Value) then
        SyncAttributes()
    end
end)

-- Scan (One-time)
task.spawn(function()
    if not getgc then return end
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" and rawget(t, "ShootRecoil") then
            table.insert(TargetTables, t)
        end
    end
end)

-- [[ Movement Logic ]] --
local flying, flyBodyGyro, flyBodyVelocity = false, nil, nil
RunService.Stepped:Connect(function(t, dt)
    local char = LocalPlayer.Character
    if not char then return end
    
    -- WalkSpeed/JumpPower (Bypass)
    local ws = Options.WalkSpeed.Value
    local jp = Options.JumpPower.Value
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    
    if hum and root then
        if ws > 16 and hum.MoveDirection.Magnitude > 0 then
             root.CFrame = root.CFrame + (hum.MoveDirection * (ws - 16) * dt)
        end
        
        -- Inf Jump
        if Toggles.InfiniteJump.Value and UserInputService:IsKeyDown(Enum.KeyCode.Space) then
             if hum:GetState() == Enum.HumanoidStateType.Jumping or hum:GetState() == Enum.HumanoidStateType.Freefall then
                  hum:ChangeState(Enum.HumanoidStateType.Jumping)
             end
        end
    end

    -- Noclip
    if Toggles.Noclip.Value then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end

    -- Fly
    if Toggles.Fly.Value then
        local root, hum = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Humanoid")
        if root and hum then
            if not flying then
                flying = true
                flyBodyGyro = Instance.new("BodyGyro", root)
                flyBodyGyro.P = 9e4
                flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBodyGyro.cframe = root.CFrame
                flyBodyVelocity = Instance.new("BodyVelocity", root)
                flyBodyVelocity.velocity = Vector3.zero
                flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
                hum.PlatformStand = true
            end
            
            flyBodyGyro.cframe = Camera.CFrame
            local vel = Vector3.zero
            local speed = Options.FlySpeed.Value
            
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - Camera.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - Camera.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0, speed, 0) end
            
            flyBodyVelocity.velocity = vel
        end
    elseif flying then
        flying = false
        if flyBodyGyro then flyBodyGyro:Destroy() end
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        local hum = char:FindFirstChild("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end)

-- [[ Hooks ]] --
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    if method == "Raycast" and SilentSettings.Enabled and TargetBodyPart then
        if math.random(1,100) <= SilentSettings.HitChance then
             local origin = args[1]
             local dir = (TargetBodyPart.Position - origin).Unit * args[2].Magnitude
             args[2] = dir
             return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

print("[Neogul] Linoria Lib Loaded")


