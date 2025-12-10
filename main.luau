pcall(function()
    local replicatedFirst = game:GetService("ReplicatedFirst")
    local analytics = replicatedFirst:FindFirstChild("AnalyticsPipelineController")
    if analytics then analytics:Destroy() end
end)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Neogul Rivals",
    SubTitle = "by Neogul",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "sword" }),
    Movement = Window:AddTab({ Title = "Movement", Icon = "run" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "component" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

local Options = Fluent.Options
local Misc = Tabs.Misc


local UnlockAll = Misc:AddButton({
    Title = "Unlock All Cosmetics",
    Description = "Unlocks Skins, Wraps, Finishers (Client Sided)",
    Callback = function()
        -- [[ Unlock All Logic (Optimized) ]] --
        task.spawn(function()
            local Players = game:GetService("Players")
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            
            local player = Players.LocalPlayer
            local playerScripts = player:WaitForChild("PlayerScripts")
            local controllers = playerScripts:WaitForChild("Controllers")
            
            -- Attempt to load libraries safely
            local function safeRequire(modulePath)
                local success, result = pcall(require, modulePath)
                if success then return result end
                return nil
            end

            local EnumLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 5))
            if EnumLibrary and EnumLibrary.WaitForEnumBuilder then EnumLibrary:WaitForEnumBuilder() end
            
            local CosmeticLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 5))
            local DataController = safeRequire(controllers:WaitForChild("PlayerDataController", 5))

            if not CosmeticLibrary or not DataController then
                Fluent:Notify({Title = "Error", Content = "Failed to load Unlock All libraries.", Duration = 5})
                return
            end

            -- Hook Ownership Functions
            CosmeticLibrary.OwnsCosmeticNormally = function() return true end
            CosmeticLibrary.OwnsCosmeticUniversally = function() return true end
            CosmeticLibrary.OwnsCosmeticForWeapon = function() return true end
            
            local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
            CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
                if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
                return true
            end

            -- Hook DataController to fake inventory
            local originalGet = DataController.Get
            DataController.Get = function(self, key)
                local data = originalGet(self, key)
                if key == "CosmeticInventory" then
                    local proxy = {}
                    if data then for k, v in pairs(data) do proxy[k] = v end end
                    return setmetatable(proxy, {__index = function() return true end})
                end
                return data
            end
            
            Fluent:Notify({Title = "Success", Content = "All Cosmetics Unlocked!", Duration = 3})
        end)
    end
})

local AntiUnnamed = Misc:AddToggle("AntiUnnamed", {Title = "Anti Unnamed (God Mode)", Default = false })

-- Anti Unnamed Logic
task.spawn(function()
    local RunService = game:GetService("RunService")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local originalPos = nil
    
    RunService.Heartbeat:Connect(function()
        if Options.AntiUnnamed and Options.AntiUnnamed.Value then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                local root = char.HumanoidRootPart
                if not originalPos then originalPos = root.CFrame end
                
                local jitterX = math.random(-100, 100)
                local jitterZ = math.random(-100, 100)
                root.CFrame = CFrame.new(originalPos.X + jitterX, 900000, originalPos.Z + jitterZ)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            end
        else
            if originalPos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                 -- Restore position when disabled
                 LocalPlayer.Character.HumanoidRootPart.CFrame = originalPos
                 originalPos = nil
            end
        end
    end)
end)

local FullBright = Misc:AddToggle("FullBright", {Title = "Full Bright", Default = false })
FullBright:OnChanged(function()
    if Options.FullBright.Value then
        game:GetService("Lighting").Brightness = 2
        game:GetService("Lighting").ClockTime = 14
        game:GetService("Lighting").FogEnd = 100000
        game:GetService("Lighting").GlobalShadows = false
        game:GetService("Lighting").OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    else
        game:GetService("Lighting").Brightness = 1
        game:GetService("Lighting").GlobalShadows = true
    end
end)

-- // Attribute Manager //
-- Used to modify table values found in Garbage Collector and restore them if needed.
local AttributeCache = setmetatable({}, { __mode = "k" })

local function ApplyAttributes(attributes, isRestore)
    -- Iterate through the garbage collector ONCE
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" then
            for attr, val in pairs(attributes) do
                if rawget(t, attr) ~= nil then
                    if isRestore then
                         -- Restore the original value if it exists in cache
                        if AttributeCache[t] and AttributeCache[t][attr] ~= nil then
                            t[attr] = AttributeCache[t][attr]
                        end
                    else
                        -- Cache original value if not already cached
                        if not AttributeCache[t] then AttributeCache[t] = {} end
                        if AttributeCache[t][attr] == nil then
                            AttributeCache[t][attr] = t[attr]
                        end
                        -- Apply the new value
                        t[attr] = val
                    end
                end
            end
        end
    end
end

-- // Combat Features //

-- [[ Attribute Logic with Caching ]] --
local AttributeCache = setmetatable({}, { __mode = "k" })
local TargetTables = {} -- Cache for tables that contain our interested attributes

local InterestedAttributes = {
    "ShootCooldown", "ShootBurstCooldown", "QuickShotCooldown", "GlobalCooldown", "AirblastCooldown", "VortexCooldown",
    "ShootRecoil", "RecoilShake", "CameraShake", "ShootSpread", "AimSpreadMultiplier", "ShootAccuracy", "ShootSpreadConsistent",
    "MuzzleFlash", "FlashEnabled",
    "AttackCooldown", "HeavyAttackCooldown", "BladeCooldown",
    "DashCooldown", "DeflectCooldown", "SpinCooldown", "BuildCooldown",
    "HitboxSize", "Radius"
}

-- Initial Scan Function (Run once or rarely)
local function ScanForAttributes()
    table.clear(TargetTables)
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" then
            for _, attr in pairs(InterestedAttributes) do
                if rawget(t, attr) ~= nil then
                    -- Store original value if not cached
                    if not AttributeCache[t] then AttributeCache[t] = {} end
                    if AttributeCache[t][attr] == nil then
                        AttributeCache[t][attr] = t[attr]
                    end
                    
                    -- Add to target list
                    table.insert(TargetTables, t)
                    break -- Found at least one attribute, keep this table
                end
            end
        end
    end
    print("✅ Attributes Scanned & Cached: " .. #TargetTables .. " tables found.")
end

-- Run Scan immediately in background
task.spawn(ScanForAttributes)

local function ModAttribute(attribute, value)
    for _, t in pairs(TargetTables) do
        if rawget(t, attribute) ~= nil then
            t[attribute] = value
        end
    end
end

local function ModPercentage(attribute, percent)
    for _, t in pairs(TargetTables) do
        if rawget(t, attribute) ~= nil then
            -- Ensure we have the original cached
            if not AttributeCache[t] then AttributeCache[t] = {} end
            if AttributeCache[t][attribute] == nil then
                 AttributeCache[t][attribute] = t[attribute]
            end
            
            -- Apply
            if type(t[attribute]) == "number" then
                 t[attribute] = AttributeCache[t][attribute] * (percent / 100)
            end
        end
    end
end

-- // Combat Features //

-- [[ Gun Mods ]] --
local GunMods = Tabs.Combat:AddSection("Gun Mods")

local NoRecoil = Tabs.Combat:AddToggle("NoRecoil", {Title = "No Recoil", Default = false })
local NoSpread = Tabs.Combat:AddToggle("NoSpread", {Title = "No Spread", Default = false })
local NoMuzzle = Tabs.Combat:AddToggle("NoMuzzle", {Title = "No Muzzle Flash", Default = false })

local GunCooldown = Tabs.Combat:AddSlider("GunCooldown", {
    Title = "Attack Cooldown",
    Description = "Reduces gun delays (0% = Instant)",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        ModPercentage("ShootCooldown", Value)
        ModPercentage("ShootBurstCooldown", Value)
        ModPercentage("QuickShotCooldown", Value)
        ModPercentage("GlobalCooldown", Value)
    end
})

-- [[ Misc Combat ]] --
-- Removed from Combat Tab to separate Tab below

NoRecoil:OnChanged(function()
    local val = Options.NoRecoil.Value
    if val then
        ModAttribute("ShootRecoil", 0)
        ModAttribute("RecoilShake", 0)
        ModAttribute("CameraShake", false)
    else
        -- Restore via cache
        for t, attrs in pairs(AttributeCache) do
             if attrs["ShootRecoil"] ~= nil then t.ShootRecoil = attrs.ShootRecoil end
             if attrs["RecoilShake"] ~= nil then t.RecoilShake = attrs.RecoilShake end
             if attrs["CameraShake"] ~= nil then t.CameraShake = attrs.CameraShake end
        end
    end
end)

NoSpread:OnChanged(function()
    local val = Options.NoSpread.Value
    if val then
        ModAttribute("ShootSpread", 0)
        ModAttribute("AimSpreadMultiplier", 0)
        ModAttribute("ShootSpreadConsistent", true)
        ModAttribute("ShootAccuracy", 10000)
    else
        for t, attrs in pairs(AttributeCache) do
             if attrs["ShootSpread"] ~= nil then t.ShootSpread = attrs.ShootSpread end
             if attrs["AimSpreadMultiplier"] ~= nil then t.AimSpreadMultiplier = attrs.AimSpreadMultiplier end
             if attrs["ShootAccuracy"] ~= nil then t.ShootAccuracy = attrs.ShootAccuracy end
        end
    end
end)

NoMuzzle:OnChanged(function()
    local val = Options.NoMuzzle.Value
    if val then
        ModAttribute("MuzzleFlash", false)
        ModAttribute("FlashEnabled", false)
    else
        for t, attrs in pairs(AttributeCache) do
             if attrs["MuzzleFlash"] ~= nil then t.MuzzleFlash = attrs.MuzzleFlash end
             if attrs["FlashEnabled"] ~= nil then t.FlashEnabled = attrs.FlashEnabled end
        end
    end
end)

-- IsAiming Hook for No Spread (Continuous)
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    if Options.NoSpread and Options.NoSpread.Value then
        for _, v in pairs(getgc(true)) do
            if type(v) == "table" and rawget(v, "IsAiming") ~= nil then
                v.IsAiming = true
            end
        end
    end
end)


-- [[ Melee Mods ]] --
local MeleeMods = Tabs.Combat:AddSection("Melee")

local MeleeAura = Tabs.Combat:AddToggle("MeleeAura", {Title = "Melee Aura (Reach)", Default = false })
local TeleportAura = Tabs.Combat:AddToggle("TeleportAura", {Title = "Teleport Aura (Behind Enemy)", Default = false })

local MeleeCooldown = Tabs.Combat:AddSlider("MeleeCooldown", {
    Title = "Attack Cooldown",
    Description = "Reduces melee/skill delays",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        ModPercentage("AttackCooldown", Value)
        ModPercentage("HeavyAttackCooldown", Value)
        ModPercentage("BladeCooldown", Value)
    end
})

-- [[ Skill Mods ]] --
local SkillMods = Tabs.Combat:AddSection("Skills")

local SkillCooldown = Tabs.Combat:AddSlider("SkillCooldown", {
    Title = "Skill Cooldown",
    Description = "Reduces special ability delays (Dash, Spin, etc.)",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 1,
    Callback = function(Value)
        ModPercentage("DashCooldown", Value)
        ModPercentage("DeflectCooldown", Value)
        ModPercentage("SpinCooldown", Value)
        ModPercentage("BuildCooldown", Value)
        ModPercentage("AirblastCooldown", Value)
        ModPercentage("VortexCooldown", Value)
    end
})

-- Melee/TP Aura Logic
RunService.Heartbeat:Connect(function()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    if not LocalPlayer.Character then return end
    
    if Options.MeleeAura.Value then
        -- Expand Hitboxes / Reach
        ModAttribute("HitboxSize", 20)
        ModAttribute("Radius", 20)
    else
         -- Reset Reach logic handled poorly here without cache restore on loop
         -- But sliders/toggles usually handle one-off. 
         -- For loop logic, we just rely on ModAttribute caching original first time.
    end

    if Options.TeleportAura.Value then
        local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            -- Find closest enemy
            local closest, dist = nil, 100 -- Max dist
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    -- Check team check? Assuming FFA or check TeamColor
                    if p.Team ~= LocalPlayer.Team or p.Team == nil then 
                        local d = (root.Position - p.Character.HumanoidRootPart.Position).Magnitude
                        if d < dist then
                            closest = p.Character.HumanoidRootPart
                            dist = d
                        end
                    end
                end
            end
            
            if closest then
                -- TP Behind
                root.CFrame = closest.CFrame * CFrame.new(0,0,3) -- 3 studs behind
                 -- Face them
                root.CFrame = CFrame.new(root.Position, closest.Position)
            end
        end
    end
end)

-- // Movement Features //

local WalkSpeed = Tabs.Movement:AddSlider("WalkSpeed", {
    Title = "WalkSpeed",
    Description = "Adjusts movement speed",
    Default = 16,
    Min = 16,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value) end
})

local JumpPower = Tabs.Movement:AddSlider("JumpPower", {
    Title = "JumpPower",
    Description = "Adjusts jump height",
    Default = 50,
    Min = 50,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value) end
})

local InfiniteJump = Tabs.Movement:AddToggle("InfiniteJump", {Title = "Infinite Jump", Default = false })
local Noclip = Tabs.Movement:AddToggle("Noclip", {Title = "Noclip (Walk Through Walls)", Default = false })
local Fly = Tabs.Movement:AddToggle("Fly", {Title = "Fly", Default = false })
local FlySpeed = Tabs.Movement:AddSlider("FlySpeed", {
    Title = "Fly Speed",
    Description = "Speed while flying",
    Default = 50,
    Min = 10,
    Max = 1000,
    Rounding = 1,
    Callback = function(Value) end
})

-- // Movement Logic //
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local function GetRoot()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
end

-- Fly Logic variables
local flying = false
local flyBodyGyro, flyBodyVelocity

-- CFrame Speed (Bypass)
RunService.Heartbeat:Connect(function(deltaTime)
    if not LocalPlayer.Character then return end
    
    local speedVal = tonumber(Options.WalkSpeed.Value) or 16
    if speedVal > 16 then
        local hum = GetHumanoid()
        local root = GetRoot()
        if hum and root and hum.MoveDirection.Magnitude > 0 then
            local extraSpeed = speedVal - 16
            root.CFrame = root.CFrame + (hum.MoveDirection * (extraSpeed * deltaTime))
        end
    end
end)

-- Velocity Jump (Bypass) & Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if not LocalPlayer.Character then return end
    
    local jpVal = tonumber(Options.JumpPower.Value) or 50
    local infJump = Options.InfiniteJump.Value
    local hum = GetHumanoid()
    local root = GetRoot()
    
    if hum and root then
        local isGrounded = hum.FloorMaterial ~= Enum.Material.Air
        if jpVal > 50 then
            if isGrounded or infJump then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, jpVal, root.AssemblyLinearVelocity.Z)
            end
        elseif infJump then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Noclip & Fly Handling
RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    -- Noclip
    if Options.Noclip.Value then
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BasePart") and v.CanCollide then
                v.CanCollide = false
            end
        end
    end
    
    -- Fly
    if Options.Fly.Value then
        local root = GetRoot()
        local hum = GetHumanoid()
        
        if root and hum then
            if not flying then
                flying = true
                
                flyBodyGyro = Instance.new("BodyGyro")
                flyBodyGyro.P = 9e4
                flyBodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
                flyBodyGyro.cframe = root.CFrame
                flyBodyGyro.Parent = root
                
                flyBodyVelocity = Instance.new("BodyVelocity")
                flyBodyVelocity.velocity = Vector3.new(0, 0.1, 0)
                flyBodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
                flyBodyVelocity.Parent = root
                
                hum.PlatformStand = true
            end
            
            local flySpd = tonumber(Options.FlySpeed.Value) or 50
            flyBodyGyro.cframe = Camera.CFrame
            
            local vel = Vector3.new(0,0,0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                vel = vel + Camera.CFrame.LookVector * flySpd
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                vel = vel - Camera.CFrame.LookVector * flySpd
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                vel = vel + Camera.CFrame.RightVector * flySpd
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                vel = vel - Camera.CFrame.RightVector * flySpd
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                vel = vel + Vector3.new(0, flySpd/1.5, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                vel = vel - Vector3.new(0, flySpd/1.5, 0)
            end
            
            flyBodyVelocity.velocity = vel
        else
            -- Cleanup if char missing parts
            if flying then
                flying = false
                if flyBodyGyro then flyBodyGyro:Destroy() end
                if flyBodyVelocity then flyBodyVelocity:Destroy() end
                if hum then hum.PlatformStand = false end
            end
        end
    else
        -- Cleanup if fly disabled
        if flying then
            flying = false
            if flyBodyGyro then flyBodyGyro:Destroy() end
            if flyBodyVelocity then flyBodyVelocity:Destroy() end
            local hum = GetHumanoid()
            if hum then hum.PlatformStand = false end
        end
    end
end)

-- // Managers Setup //
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Neogul Rivals",
    Content = "Script Loaded Successfully!",
    Duration = 5
})

-- // Cleanup //
SaveManager:LoadAutoloadConfig()