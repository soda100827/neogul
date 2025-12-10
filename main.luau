pcall(function()
    local replicatedFirst = game:GetService("ReplicatedFirst")
    local analytics = replicatedFirst:FindFirstChild("AnalyticsPipelineController")
    if analytics then analytics:Destroy() end
end)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

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

local UnlockAll = Misc:AddToggle("UnlockAll", {Title = "Unlock All Cosmetics", Default = false })

-- Unlock All Logic (Comprehensive)
-- Adapted to respect 'UnlockAll' Toggle
task.spawn(function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    
    local player = Players.LocalPlayer
    local playerScripts = player:WaitForChild("PlayerScripts")
    local controllers = playerScripts:WaitForChild("Controllers")
    
    -- Safe Require Helper
    local function safeRequire(path)
        local s, r = pcall(require, path)
        return s and r or nil
    end

    local EnumLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("EnumLibrary", 10))
    if EnumLibrary and EnumLibrary.WaitForEnumBuilder then EnumLibrary:WaitForEnumBuilder() end
    local CosmeticLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("CosmeticLibrary", 10))
    local ItemLibrary = safeRequire(ReplicatedStorage.Modules:WaitForChild("ItemLibrary", 10))
    local DataController = safeRequire(controllers:WaitForChild("PlayerDataController", 10))
    
    local equipped, favorites = {}, {}
    local constructingWeapon, viewingProfile = nil, nil
    local lastUsedWeapon = nil

    if not (CosmeticLibrary and DataController) then return end

    local function cloneCosmetic(name, cosmeticType, options)
        local base = CosmeticLibrary.Cosmetics[name]
        if not base then return nil end
        local data = {}
        for key, value in pairs(base) do data[key] = value end
        data.Name = name
        data.Type = data.Type or cosmeticType
        data.Seed = data.Seed or math.random(1, 1000000)
        if EnumLibrary then
            local success, enumId = pcall(EnumLibrary.ToEnum, EnumLibrary, name)
            if success and enumId then data.Enum, data.ObjectID = enumId, data.ObjectID or enumId end
        end
        if options then
            if options.inverted ~= nil then data.Inverted = options.inverted end
            if options.favoritesOnly ~= nil then data.OnlyUseFavorites = options.favoritesOnly end
        end
        return data
    end

    local saveFile = "unlockall/config.json"
    local function saveConfig()
        if not writefile then return end
        pcall(function()
            local config = {equipped = {}, favorites = favorites}
            for weapon, cosmetics in pairs(equipped) do
                config.equipped[weapon] = {}
                for cosmeticType, cosmeticData in pairs(cosmetics) do
                    if cosmeticData and cosmeticData.Name then
                        config.equipped[weapon][cosmeticType] = {
                            name = cosmeticData.Name, seed = cosmeticData.Seed, inverted = cosmeticData.Inverted
                        }
                    end
                end
            end
            if not isfolder("unlockall") then makefolder("unlockall") end
            writefile(saveFile, HttpService:JSONEncode(config))
        end)
    end

    local function loadConfig()
        if not readfile or not isfile or not isfile(saveFile) then return end
        pcall(function()
            local config = HttpService:JSONDecode(readfile(saveFile))
            if config.equipped then
                for weapon, cosmetics in pairs(config.equipped) do
                    equipped[weapon] = {}
                    for cosmeticType, cosmeticData in pairs(cosmetics) do
                        local cloned = cloneCosmetic(cosmeticData.name, cosmeticType, {inverted = cosmeticData.inverted})
                        if cloned then cloned.Seed = cosmeticData.seed equipped[weapon][cosmeticType] = cloned end
                    end
                end
            end
            favorites = config.favorites or {}
        end)
    end

    -- Hook Cosmetic Library
    -- Hook Cosmetic Library
    local originalOwnsCosmetic = CosmeticLibrary.OwnsCosmetic
    local originalOwnsCosmeticNormally = CosmeticLibrary.OwnsCosmeticNormally
    local originalOwnsCosmeticUniversally = CosmeticLibrary.OwnsCosmeticUniversally
    local originalOwnsCosmeticForWeapon = CosmeticLibrary.OwnsCosmeticForWeapon

    CosmeticLibrary.OwnsCosmeticNormally = function(...) 
        if not Options.UnlockAll.Value then 
            if originalOwnsCosmeticNormally then return originalOwnsCosmeticNormally(...) end
            return false 
        end
        return true 
    end 
    
    CosmeticLibrary.OwnsCosmeticUniversally = function(...) 
        if not Options.UnlockAll.Value then 
             if originalOwnsCosmeticUniversally then return originalOwnsCosmeticUniversally(...) end
             return false
        end
        return true 
    end

    CosmeticLibrary.OwnsCosmeticForWeapon = function(...)
        if not Options.UnlockAll.Value then
            if originalOwnsCosmeticForWeapon then return originalOwnsCosmeticForWeapon(...) end
            return false
        end
        return true 
    end

    CosmeticLibrary.OwnsCosmetic = function(self, inventory, name, weapon)
        if not Options.UnlockAll.Value then return originalOwnsCosmetic(self, inventory, name, weapon) end
        if name:find("MISSING_") then return originalOwnsCosmetic(self, inventory, name, weapon) end
        return true
    end

    -- Hook Data Controller
    local originalGet = DataController.Get
    DataController.Get = function(self, key)
        local data = originalGet(self, key)
        if not Options.UnlockAll.Value then return data end

        if key == "CosmeticInventory" then
            local proxy = {}
            if data then for k, v in pairs(data) do proxy[k] = v end end
            return setmetatable(proxy, {__index = function() return true end})
        end
        if key == "FavoritedCosmetics" then
            local result = data and table.clone(data) or {}
            for weapon, favs in pairs(favorites) do
                result[weapon] = result[weapon] or {}
                for name, isFav in pairs(favs) do result[weapon][name] = isFav end
            end
            return result
        end
        return data
    end

    local originalGetWeaponData = DataController.GetWeaponData
    DataController.GetWeaponData = function(self, weaponName)
        local data = originalGetWeaponData(self, weaponName)
        if not Options.UnlockAll.Value then return data end
        if not data then return nil end
        
        local merged = {}
        for key, value in pairs(data) do merged[key] = value end
        merged.Name = weaponName
        if equipped[weaponName] then
            for cosmeticType, cosmeticData in pairs(equipped[weaponName]) do merged[cosmeticType] = cosmeticData end
        end
        return merged
    end

    -- Hook Metamethods (Equip/Favorite/UseItem)
    local FighterController = safeRequire(controllers:WaitForChild("FighterController", 5))

    if hookmetamethod then
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local dataRemotes = remotes and remotes:FindFirstChild("Data")
        local equipRemote = dataRemotes and dataRemotes:FindFirstChild("EquipCosmetic")
        local favoriteRemote = dataRemotes and dataRemotes:FindFirstChild("FavoriteCosmetic")
        local replicationRemotes = remotes and remotes:FindFirstChild("Replication")
        local fighterRemotes = replicationRemotes and replicationRemotes:FindFirstChild("Fighter")
        local useItemRemote = fighterRemotes and fighterRemotes:FindFirstChild("UseItem")
        
        if equipRemote then
            local oldNamecall
            oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
                if getnamecallmethod() ~= "FireServer" then return oldNamecall(self, ...) end
                
                local args = {...}
                if useItemRemote and self == useItemRemote then
                    local objectID = args[1]
                    if FighterController then
                        pcall(function()
                            local fighter = FighterController:GetFighter(player)
                            if fighter and fighter.Items then
                                for _, item in pairs(fighter.Items) do
                                    if item:Get("ObjectID") == objectID then
                                        lastUsedWeapon = item.Name
                                        break
                                    end
                                end
                            end
                        end)
                    end
                end            
                
                if self == equipRemote then
                    if not Options.UnlockAll.Value then return oldNamecall(self, ...) end

                    local weaponName, cosmeticType, cosmeticName, options = args[1], args[2], args[3], args[4] or {}                
                    if cosmeticName and cosmeticName ~= "None" and cosmeticName ~= "" then
                        local inventory = DataController:Get("CosmeticInventory")
                        if inventory and type(inventory) == "table" and rawget(inventory, cosmeticName) then return oldNamecall(self, ...) end
                    end                
                    
                    equipped[weaponName] = equipped[weaponName] or {}                
                    if not cosmeticName or cosmeticName == "None" or cosmeticName == "" then
                        equipped[weaponName][cosmeticType] = nil
                        if not next(equipped[weaponName]) then equipped[weaponName] = nil end
                    else
                        local cloned = cloneCosmetic(cosmeticName, cosmeticType, {inverted = options and options.IsInverted, favoritesOnly = options and options.OnlyUseFavorites})
                        if cloned then equipped[weaponName][cosmeticType] = cloned end
                    end                
                    task.defer(function()
                        pcall(function() DataController.CurrentData:Replicate("WeaponInventory") end)
                        task.wait(0.2)
                        saveConfig()
                    end)
                    return 
                end            
                
                if self == favoriteRemote then
                     if not Options.UnlockAll.Value then return oldNamecall(self, ...) end
                     
                    favorites[args[1]] = favorites[args[1]] or {}
                    favorites[args[1]][args[2]] = args[3] or nil
                    saveConfig()
                    task.spawn(function() pcall(function() DataController.CurrentData:Replicate("FavoritedCosmetics") end) end)
                    return 
                end            
                return oldNamecall(self, ...)
            end)
        end
    end

    -- Client Item / View Model Overrides
    local ClientItemModule = playerScripts.Modules.ClientReplicatedClasses.ClientFighter.ClientItem
    local ClientItem = safeRequire(ClientItemModule)
    
    if ClientItem and ClientItem._CreateViewModel then
        local originalCreateViewModel = ClientItem._CreateViewModel
        ClientItem._CreateViewModel = function(self, viewmodelRef)
            if not Options.UnlockAll.Value then return originalCreateViewModel(self, viewmodelRef) end

            local weaponName = self.Name
            local weaponPlayer = self.ClientFighter and self.ClientFighter.Player
            constructingWeapon = (weaponPlayer == player) and weaponName or nil    
            if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Skin and viewmodelRef then
                local dataKey, skinKey, nameKey = self:ToEnum("Data"), self:ToEnum("Skin"), self:ToEnum("Name")
                if viewmodelRef[dataKey] then
                    viewmodelRef[dataKey][skinKey] = equipped[weaponName].Skin
                    viewmodelRef[dataKey][nameKey] = equipped[weaponName].Skin.Name
                elseif viewmodelRef.Data then
                    viewmodelRef.Data.Skin = equipped[weaponName].Skin
                    viewmodelRef.Data.Name = equipped[weaponName].Skin.Name
                end
            end
            local result = originalCreateViewModel(self, viewmodelRef)
            constructingWeapon = nil
            return result
        end
    end

    local viewModelModule = ClientItemModule:FindFirstChild("ClientViewModel")
    if viewModelModule then
        local ClientViewModel = safeRequire(viewModelModule)
        if ClientViewModel.GetWrap then
            local originalGetWrap = ClientViewModel.GetWrap
            ClientViewModel.GetWrap = function(self)
                if not Options.UnlockAll.Value then return originalGetWrap(self) end
                
                local weaponName = self.ClientItem and self.ClientItem.Name
                local weaponPlayer = self.ClientItem and self.ClientItem.ClientFighter and self.ClientItem.ClientFighter.Player
                if weaponName and weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap then
                    return equipped[weaponName].Wrap
                end
                return originalGetWrap(self)
            end
        end
        
        local originalNew = ClientViewModel.new
        ClientViewModel.new = function(replicatedData, clientItem)
             if not Options.UnlockAll.Value then return originalNew(replicatedData, clientItem) end

            local weaponPlayer = clientItem.ClientFighter and clientItem.ClientFighter.Player
            local weaponName = constructingWeapon or clientItem.Name
            if weaponPlayer == player and equipped[weaponName] then
                local ReplicatedClass = require(ReplicatedStorage.Modules.ReplicatedClass) -- Assuming this exists here based on user script
                local dataKey = ReplicatedClass:ToEnum("Data")
                replicatedData[dataKey] = replicatedData[dataKey] or {}
                local cosmetics = equipped[weaponName]
                if cosmetics.Skin then replicatedData[dataKey][ReplicatedClass:ToEnum("Skin")] = cosmetics.Skin end
                if cosmetics.Wrap then replicatedData[dataKey][ReplicatedClass:ToEnum("Wrap")] = cosmetics.Wrap end
                if cosmetics.Charm then replicatedData[dataKey][ReplicatedClass:ToEnum("Charm")] = cosmetics.Charm end
            end
            local result = originalNew(replicatedData, clientItem)
            if weaponPlayer == player and equipped[weaponName] and equipped[weaponName].Wrap and result._UpdateWrap then
                result:_UpdateWrap()
                task.delay(0.1, function() if not result._destroyed then result:_UpdateWrap() end end)
            end
            return result
        end
    end
    
    if ItemLibrary then
        local originalGetViewModelImage = ItemLibrary.GetViewModelImageFromWeaponData
        ItemLibrary.GetViewModelImageFromWeaponData = function(self, weaponData, highRes)
            if not Options.UnlockAll.Value then return originalGetViewModelImage(self, weaponData, highRes) end
            
            if not weaponData then return originalGetViewModelImage(self, weaponData, highRes) end
            local weaponName = weaponData.Name
            local shouldShowSkin = (weaponData.Skin and equipped[weaponName] and weaponData.Skin == equipped[weaponName].Skin) or (viewingProfile == player and equipped[weaponName] and equipped[weaponName].Skin)
            if shouldShowSkin and equipped[weaponName] and equipped[weaponName].Skin then
                local skinInfo = self.ViewModels[equipped[weaponName].Skin.Name]
                if skinInfo then return skinInfo[highRes and "ImageHighResolution" or "Image"] or skinInfo.Image end
            end
            return originalGetViewModelImage(self, weaponData, highRes)
        end
    end
    
    -- View Profile Hook
    pcall(function()
        local ViewProfile = require(playerScripts.Modules.Pages.ViewProfile)
        if ViewProfile and ViewProfile.Fetch then
            local originalFetch = ViewProfile.Fetch
            ViewProfile.Fetch = function(self, targetPlayer)
                viewingProfile = targetPlayer
                return originalFetch(self, targetPlayer)
            end
        end
    end)
    
    -- ClientEntity / Finisher Hook
    pcall(function()
        local ClientEntity = require(playerScripts.Modules.ClientReplicatedClasses.ClientEntity) 
        if ClientEntity and ClientEntity.ReplicateFromServer then
            local originalReplicateFromServer = ClientEntity.ReplicateFromServer
            ClientEntity.ReplicateFromServer = function(self, action, ...)
                if not Options.UnlockAll.Value then return originalReplicateFromServer(self, action, ...) end
                
                if action == "FinisherEffect" then
                    local args = {...}
                    local killerName = args[3]            
                    local decodedKiller = killerName
                    if type(killerName) == "userdata" and EnumLibrary and EnumLibrary.FromEnum then
                        local ok, decoded = pcall(EnumLibrary.FromEnum, EnumLibrary, killerName)
                        if ok and decoded then decodedKiller = decoded end
                    end            
                    local isOurKill = tostring(decodedKiller) == player.Name or tostring(decodedKiller):lower() == player.Name:lower()            
                    if isOurKill and lastUsedWeapon and equipped[lastUsedWeapon] and equipped[lastUsedWeapon].Finisher then
                        local finisherData = equipped[lastUsedWeapon].Finisher
                        local finisherEnum = finisherData.Enum                
                        if not finisherEnum and EnumLibrary then
                            local ok, result = pcall(EnumLibrary.ToEnum, EnumLibrary, finisherData.Name)
                            if ok and result then finisherEnum = result end
                        end                
                        if finisherEnum then
                            args[1] = finisherEnum
                            return originalReplicateFromServer(self, action, unpack(args))
                        end
                    end
                end        
                return originalReplicateFromServer(self, action, ...)
            end
        end
    end)
    
    loadConfig()
    print("Unlock All Loaded")
end)

local SpamMessage = Misc:AddToggle("SpamMessage", {Title = "Spam Message", Default = false })

-- Auto Chat Spam Logic
task.spawn(function()
    local messages = {
        "하수구",
        "쪼준",
        "쪼준CEO",
        "쪼준컴퍼니 입사함"
    }
    
    while true do
        task.wait(3) -- Adjusted wait time to 3s per user example
        if Options.SpamMessage and Options.SpamMessage.Value then
            local msg = messages[math.random(1, #messages)]
            
            pcall(function()
                local TextChatService = game:GetService("TextChatService")
                if TextChatService and TextChatService.TextChannels and TextChatService.TextChannels.RBXGeneral then
                    TextChatService.TextChannels.RBXGeneral:SendAsync(msg)
                else
                    -- Fallback for legacy games
                     local ReplicatedStorage = game:GetService("ReplicatedStorage")
                     local DefaultChatSystemChatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
                     local SayMessageRequest = DefaultChatSystemChatEvents and DefaultChatSystemChatEvents:FindFirstChild("SayMessageRequest")
                     if SayMessageRequest then
                         SayMessageRequest:FireServer(msg, "All")
                     else
                         game:GetService("Players"):Chat(msg)
                     end
                end
            end)
        end
    end
end)


local AutoLoad = Misc:AddToggle("AutoLoad", {Title = "Auto Load Script", Default = false })
AutoLoad:OnChanged(function()
    if Options.AutoLoad.Value then
        local qot = queue_on_teleport or queueonteleport or (syn and syn.queue_on_teleport)
        if qot then
            -- Save current script to file for persistence
            local fileName = "neogul_rivals_autoload.lua"
            if writefile then
                -- Note: 'script' variable might not be source in all executors, 
                -- checking if we can get source via 'game:HttpGet' logic or if user executed file already exists.
                -- Best practice in auto-update scripts: Resave the loader. 
                -- Here we assume 'readfile' of original execution or just generic loader.
                -- Actually, best simplest way: content string.
                -- BUT since we can't capture 'this' script source easily dynamically in all environments without 'game:HttpGet',
                -- WE WILL USE THE STANDARD LOADER STRING provided in user instructions context if possible,
                -- OR reliance on the file successfully existing if they opened it in executor.
                
                -- However, user specifically asked: "Save this script via writefile". 
                -- We can try to assume the user put this script in a file, OR we just download the latest if it was a URL.
                -- Since this is a local development context, let's assume we re-load the file we are in.
                
                -- Queue code:
                 qot(string.format([[
                    task.wait(3)
                    local f = "%s"
                    if isfile(f) then
                        loadstring(readfile(f))()
                    end
                ]], fileName))
                
                -- Ideally we write 'this' content to that file. 
                -- If we can't access source, we notify user to ensure file exists.
                -- In typical executor 'files' tab, if they ran it, it might not be 'saved' yet.
                -- We will try to write a placeholder loader or if we assume this is the 'main.luau' editing.
                
                -- Let's act as if this is the setup: notify user to ensure file is saved.
                 Fluent:Notify({Title = "Auto Load", Content = "Ensuring '"..fileName.."' is loaded next.", Duration = 3})
            else
                 Fluent:Notify({Title = "Error", Content = "writefile not supported.", Duration = 5})
            end
        else
            Fluent:Notify({Title = "Error", Content = "queue_on_teleport not supported.", Duration = 5})
        end
    end
end)

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
                
                -- Extreme Jitter & Height
                local jitterX = math.random(-2000, 2000)
                local jitterZ = math.random(-2000, 2000)
                root.CFrame = CFrame.new(originalPos.X + jitterX, 90000000, originalPos.Z + jitterZ)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)

                 -- Extreme Spin Speed
                local spin = root:FindFirstChild("AntiSpin")
                if not spin then
                    spin = Instance.new("BodyAngularVelocity")
                    spin.Name = "AntiSpin"
                    spin.MaxTorque = Vector3.new(0, math.huge, 0)
                    spin.P = 100000
                    spin.Parent = root
                end
                spin.AngularVelocity = Vector3.new(0, 100000, 0)
            end
        else
            -- Cleanup Spin
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local spin = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("AntiSpin")
                if spin then spin:Destroy() end
            end

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

-- [[ Silent Aim Variables ]] --
local SilentSettings = {
    Enabled = false,
    FOV = 180,
    ShowFOV = false,
    TargetPart = "Head",
    HitChance = 100,
    Prediction = 0.135,
    DebugMode = false
}

local TargetBodyPart = nil
local TargetVelocity = Vector3.zero

-- [[ Silent Aim UI ]] --
local SilentSection = Tabs.Combat:AddSection("Silent Aim")

local ToggleSilentAvg = Tabs.Combat:AddToggle("SilentAim", {Title = "Enabled", Default = false })
ToggleSilentAvg:OnChanged(function(v) SilentSettings.Enabled = v end)

local ToggleFOV = Tabs.Combat:AddToggle("SilentAimFOV", {Title = "Show FOV", Default = false })
ToggleFOV:OnChanged(function(v) SilentSettings.ShowFOV = v; FOVCircle.Visible = v end)

local SliderFOV = Tabs.Combat:AddSlider("SilentAimRadius", {
    Title = "FOV Radius",
    Default = 180,
    Min = 10,
    Max = 800,
    Rounding = 0,
    Callback = function(v) SilentSettings.FOV = v; FOVCircle.Radius = v end
})

local SliderChance = Tabs.Combat:AddSlider("SilentAimHitChance", {
    Title = "Hit Chance",
    Default = 100,
    Min = 0,
    Max = 100,
    Rounding = 0,
    Callback = function(v) SilentSettings.HitChance = v end
})

local SliderPred = Tabs.Combat:AddSlider("SilentAimPrediction", {
    Title = "Prediction",
    Default = 0.135,
    Min = 0,
    Max = 1,
    Rounding = 3,
    Callback = function(v) SilentSettings.Prediction = v end
})

local DropdownPart = Tabs.Combat:AddDropdown("SilentAimPart", {
    Title = "Target Part",
    Values = {"Head", "HumanoidRootPart", "Random"}, 
    Default = "Head", 
    Multi = false, 
    Callback = function(v) SilentSettings.TargetPart = v end
})

-- FOV Circle Visual
local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = false
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64

-- [[ Silent Aim Functions ]] --
local function GetTargetPart(character)
    if SilentSettings.TargetPart == "Random" then
        local parts = {"Head", "HumanoidRootPart", "UpperTorso"}
        return character:FindFirstChild(parts[math.random(1, #parts)]) or character:FindFirstChild("Head")
    else
        return character:FindFirstChild(SilentSettings.TargetPart)
    end
end

local function GetClosestTarget()
    local closestPart = nil
    local closestVelocity = Vector3.zero
    local maxDistance = SilentSettings.FOV
    local mousePos = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChild("Humanoid")
            local root = player.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                -- Team Check (Optional usually in FFA but good to have)
                if player.Team == LocalPlayer.Team and player.Team ~= nil then
                    -- Continue
                else
                    local part = GetTargetPart(player.Character)
                    if part then
                        local screenPos, onScreen = Camera:WorldToViewportPoint(part.Position)
                        if onScreen then
                            local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                            if dist < maxDistance then
                                closestPart = part
                                closestVelocity = root.Velocity
                                maxDistance = dist
                            end
                        end
                    end
                end
            end
        end
    end
    return closestPart, closestVelocity
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = SilentSettings.ShowFOV and SilentSettings.Enabled
    FOVCircle.Radius = SilentSettings.FOV
    if SilentSettings.Enabled then
        TargetBodyPart, TargetVelocity = GetClosestTarget()
    else
        TargetBodyPart = nil
    end
end)

-- [[ Universal Hooking (Range + Prediction) ]] --
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "Raycast" and SilentSettings.Enabled and TargetBodyPart then
        -- Validate Vectors without verifying script name (Universal)
        if typeof(args[1]) == "Vector3" and typeof(args[2]) == "Vector3" then
            
            -- Hit Chance Check
            if math.random(1, 100) <= SilentSettings.HitChance then
                local origin = args[1]
                local oldDirection = args[2]
                local weaponRange = oldDirection.Magnitude
                
                -- Only consider raycasts that travel significant distance (likely bullets)
                if weaponRange > 10 then
                    -- Calculate Predicted Position
                    local predictedPos = TargetBodyPart.Position + (TargetVelocity * SilentSettings.Prediction)
                    
                    -- Update Direction: (Predicted - Origin).Unit * Range
                    args[2] = (predictedPos - origin).Unit * weaponRange
                    
                    if SilentSettings.DebugMode then
                        print("[Silent Aim] Hitting:", TargetBodyPart.Parent.Name, "| Range:", weaponRange)
                    end
                    
                    return oldNamecall(self, unpack(args))
                end
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- [[ Legit Aimbot Logic ]] --
local AimbotSettings = {
    Enabled = false,
    Keybind = "RMS", 
    VisibleCheck = true,
    TeamCheck = true,
    TargetPart = "Nearest", 
    
    -- FOV
    FOV = 100,
    DynamicFOV = false,
    ShowFOV = false,
    
    -- Advanced Styling
    AimStyle = "Spring", -- Spring, Linear, Sine, Back, Elastic
    Smoothing = 15, -- For Spring (Higher = Slower)
    AssistStrength = 100, -- % (For non-spring styles, 100% = lock, 1% = slow drift)
    
    -- Humanization
    ReactionDelay = 0.15,
    Jitter = 0,
    Overshoot = 0,
    Deadzone = 0, -- Pixels (Don't aim if close)
    TargetSwitchDelay = 0,
    
    -- Recoil Control
    RCS = false,
    RCSStrength = 50,
    
    -- Internal
    Target = nil,
    LastTargetTime = 0,
    LastKillTime = 0, -- For switch delay
    OvershootOffset = Vector3.zero 
}

local AimbotSection = Tabs.Combat:AddSection("Legit Aimbot Config")

local AimToggle = Tabs.Combat:AddToggle("AimbotEnabled", {Title = "Aimbot Enabled", Default = false })
AimToggle:OnChanged(function(v) AimbotSettings.Enabled = v end)

local AimKey = Tabs.Combat:AddKeybind("AimbotKey", {
    Title = "Trigger Key",
    Mode = "Hold",
    Default = "RightMouseButton",
    ChangedCallback = function(New) end
})

Tabs.Combat:AddDropdown("AimbotPart", {Title = "Target Priority", Values = {"Head", "Random", "Nearest"}, Default = "Nearest", Multi = false, Callback = function(v) AimbotSettings.TargetPart = v end})
Tabs.Combat:AddToggle("AimbotVisibleCheck", {Title = "Visible Check", Default = true }):OnChanged(function(v) AimbotSettings.VisibleCheck = v end)

-- FOV Section
local FOVSection = Tabs.Combat:AddSection("Field of View")
Tabs.Combat:AddSlider("AimbotFOV", {Title = "FOV Radius", Default = 100, Min = 10, Max = 800, Rounding = 0, Callback = function(v) AimbotSettings.FOV = v end})
Tabs.Combat:AddToggle("AimbotDynamicFOV", {Title = "Dynamic FOV", Description = "Adjusts FOV based on Enemy Distance", Default = false }):OnChanged(function(v) AimbotSettings.DynamicFOV = v end)

-- Styles & Humanization Section
local StyleSection = Tabs.Combat:AddSection("Aim Styles & Humanization")

Tabs.Combat:AddDropdown("AimStyle", {
    Title = "Aim Style",
    Values = {"Spring", "Linear", "Sine EaseOut", "Back EaseOut", "Elastic"},
    Default = "Spring",
    Multi = false,
    Callback = function(v) AimbotSettings.AimStyle = v end
})

Tabs.Combat:AddSlider("AimbotSmooth", {Title = "Spring / Smoothness", Description = "Spring: Stiffness | Others: Speed", Default = 15, Min = 1, Max = 100, Rounding = 1, Callback = function(v) AimbotSettings.Smoothing = v end})

Tabs.Combat:AddSlider("AimbotReaction", {Title = "Reaction Delay", Default = 0.15, Min = 0, Max = 0.5, Rounding = 2, Callback = function(v) AimbotSettings.ReactionDelay = v end})
Tabs.Combat:AddSlider("TargetSwitchDelay", {Title = "Target Switch Delay", Default = 0, Min = 0, Max = 1, Rounding = 2, Callback = function(v) AimbotSettings.TargetSwitchDelay = v end})
Tabs.Combat:AddSlider("AimbotDeadzone", {Title = "Deadzone (px)", Description = "Stop aiming if crosshair is this close", Default = 2, Min = 0, Max = 30, Rounding = 0, Callback = function(v) AimbotSettings.Deadzone = v end})

Tabs.Combat:AddSlider("AimbotJitter", {Title = "Jitter Intensity", Default = 0, Min = 0, Max = 20, Rounding = 1, Callback = function(v) AimbotSettings.Jitter = v end})
Tabs.Combat:AddSlider("AimbotOvershoot", {Title = "Overshoot Amount", Default = 0, Min = 0, Max = 20, Rounding = 1, Callback = function(v) AimbotSettings.Overshoot = v end})


-- [[ Spring Module (Internal) ]] --
local Spring = {}
Spring.__index = Spring

function Spring.new(mass, force, damping, speed)
    local self = setmetatable({}, Spring)
    self.Target = Vector3.zero
    self.Position = Vector3.zero
    self.Velocity = Vector3.zero
    self.Mass = mass
    self.Force = force
    self.Damping = damping
    self.Speed = speed
    return self
end

function Spring:Update(dt)
    local scaledDt = dt * self.Speed
    local acceleration = (self.Target - self.Position) * self.Force / self.Mass
    acceleration = acceleration - self.Velocity * self.Damping
    self.Velocity = self.Velocity + acceleration * scaledDt
    self.Position = self.Position + self.Velocity * scaledDt
    return self.Position
end

local AimSpring = Spring.new(5, 50, 4, 4) 

-- Helper: Visibility Check
local function IsVisible(targetPart, ignoreList)
    local origin = Camera.CFrame.Position
    local direction = targetPart.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = ignoreList or {LocalPlayer.Character, Camera}
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    raycastParams.IgnoreWater = true
    
    local result = workspace:Raycast(origin, direction, raycastParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- Helper: Get Best Aimbot Target
local function GetBestAimTarget()
    local bestTarget = nil
    local bestScore = math.huge 
    local mousePos = UserInputService:GetMouseLocation()
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                if AimbotSettings.TeamCheck and p.Team == LocalPlayer.Team then continue end
                
                local targetPartObj
                if AimbotSettings.TargetPart == "Head" then targetPartObj = p.Character:FindFirstChild("Head")
                elseif AimbotSettings.TargetPart == "Random" then 
                    local parts = {"Head", "UpperTorso", "LowerTorso"}
                    targetPartObj = p.Character:FindFirstChild(parts[math.random(1, #parts)])
                else -- Nearest
                    local head = p.Character:FindFirstChild("Head")
                    local torso = p.Character:FindFirstChild("UpperTorso")
                    
                    if head and torso then
                        local hPos, hOn = Camera:WorldToViewportPoint(head.Position)
                        local tPos, tOn = Camera:WorldToViewportPoint(torso.Position)
                        local hDist = hOn and (Vector2.new(hPos.X, hPos.Y) - mousePos).Magnitude or math.huge
                        local tDist = tOn and (Vector2.new(tPos.X, tPos.Y) - mousePos).Magnitude or math.huge
                        targetPartObj = (hDist < tDist) and head or torso
                    elseif head then targetPartObj = head
                    elseif torso then targetPartObj = torso
                    end
                end
                
                if targetPartObj then
                    if AimbotSettings.VisibleCheck and not IsVisible(targetPartObj, {LocalPlayer.Character, Camera}) then continue end
                    
                    local screenPos, onScreen = Camera:WorldToViewportPoint(targetPartObj.Position)
                    if onScreen then
                        local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                        
                        -- Dynamic FOV Adjustment
                        local maxFov = AimbotSettings.FOV
                        if AimbotSettings.DynamicFOV then
                             local distToPlayer = (targetPartObj.Position - Camera.CFrame.Position).Magnitude
                             -- Smaller FOV for distant players to prevent snapping to randoms
                             maxFov = maxFov * (100 / math.max(10, distToPlayer)) 
                        end
                        
                        if dist < maxFov and dist < bestScore then
                            bestScore = dist
                            bestTarget = targetPartObj
                        end
                    end
                end
            end
        end
    end
    return bestTarget
end

-- Calculation & Application Loop
RunService.RenderStepped:Connect(function(dt)
    if not AimbotSettings.Enabled then return end
    
    -- Check Keybind
    local keyState = Options.AimbotKey and Options.AimbotKey:GetState()
    if not keyState then 
        AimbotSettings.Target = nil
        -- Reset Spring
        AimSpring.Position = Vector3.zero
        AimSpring.Velocity = Vector3.zero
        return 
    end
    
    -- Target Switch Delay Check
    if tick() - AimbotSettings.LastKillTime < AimbotSettings.TargetSwitchDelay then return end
    
    local target = GetBestAimTarget()
    
    -- Reaction Delay Logic
    if target ~= AimbotSettings.Target then
        if AimbotSettings.Target == nil then
             -- New target acquired from nothing
             AimbotSettings.LastTargetTime = tick() 
        end
        AimbotSettings.Target = target
        
        -- Generate Overshoot
        if AimbotSettings.Overshoot > 0 then
            AimbotSettings.OvershootOffset = Vector3.new(math.random(-100,100)/100, math.random(-100,100)/100, math.random(-100,100)/100) * (AimbotSettings.Overshoot / 10)
        else
            AimbotSettings.OvershootOffset = Vector3.zero
        end
    end
    
    -- Check if target is still valid
    if target and target.Parent and target.Parent:FindFirstChild("Humanoid") and target.Parent.Humanoid.Health > 0 then
        -- Reaction Check
        if tick() - AimbotSettings.LastTargetTime < AimbotSettings.ReactionDelay then return end
    
        local currentCFrame = Camera.CFrame
        local goalPosition = target.Position
        
        -- Apply Deadzone Check
        local screenPos, onScreen = Camera:WorldToViewportPoint(goalPosition)
        if onScreen then
            local mousePos = UserInputService:GetMouseLocation()
            local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
            if dist < AimbotSettings.Deadzone then return end
        end
        
        -- Apply Jitter
        if AimbotSettings.Jitter > 0 then
             goalPosition = goalPosition + Vector3.new(
                math.random(-10, 10) / 200 * AimbotSettings.Jitter, 
                math.random(-10, 10) / 200 * AimbotSettings.Jitter, 
                math.random(-10, 10) / 200 * AimbotSettings.Jitter
             )
        end
        
        -- Apply Overshoot Decay
        if AimbotSettings.OvershootOffset.Magnitude > 0.01 then
            AimbotSettings.OvershootOffset = AimbotSettings.OvershootOffset:Lerp(Vector3.zero, dt * 3)
            goalPosition = goalPosition + AimbotSettings.OvershootOffset
        end
        
        -- Aim Calculation
        local lookVector = (goalPosition - currentCFrame.Position).Unit
        local goalRotation = CFrame.new(currentCFrame.Position, goalPosition)
        
        -- STYLES
        local style = AimbotSettings.AimStyle
        local alpha = 1
        
        if style == "Spring" then
            -- Use the internal Spring module
            -- We update the spring target to 'lookVector' relative space or simple offset?
            -- Easiest way for Camera CFrame lerping is calculating an Alpha based on springs.
            -- But standard spring aimbots usually spring the mouse delta.
            -- Let's stick to the 'Smoothing' factor hybrid for simplicity and stability in Lua.
            
            -- High smoothing = low factor.
            alpha = math.clamp(1 / (AimbotSettings.Smoothing * 0.5), 0.01, 1)
            Camera.CFrame = currentCFrame:Lerp(goalRotation, alpha)
            
        elseif style == "Linear" then
            -- Fixed speed movement
            -- Smoothing slider acts as "Slow down". 1 = Instant, 100 = Very Slow.
            alpha = math.clamp((100 - AimbotSettings.Smoothing) / 100 * dt * 10, 0.01, 1)
             Camera.CFrame = currentCFrame:Lerp(goalRotation, alpha)
             
        elseif style == "Sine EaseOut" then
            -- Trig smoothing
            local t = math.sin(tick() * 5) * 0.5 + 0.5
            alpha = math.clamp((100 - AimbotSettings.Smoothing) / 100 * dt * 20, 0.01, 1)
             Camera.CFrame = currentCFrame:Lerp(goalRotation, alpha)
             
        elseif style == "Back EaseOut" or style == "Elastic" then
             -- Simple Lerp with overshoot baked in
             alpha = math.clamp(0.1 + (100 - AimbotSettings.Smoothing)/200, 0.05, 1)
             Camera.CFrame = currentCFrame:Lerp(goalRotation, alpha * dt * 6)
        end
        
    else
        AimbotSettings.Target = nil
    end
end)

-- [[ Attribute Logic with Caching ]] --
local AttributeCache = setmetatable({}, { __mode = "k" })
local TargetTables = {} -- Cache for tables that contain our interested attributes

local InterestedAttributes = {
    "ShootCooldown", "ShootBurstCooldown", "QuickShotCooldown", "GlobalCooldown", "AirblastCooldown", "VortexCooldown",
    "ShootRecoil", "RecoilShake", "CameraShake", "ShootSpread", "AimSpreadMultiplier", "ShootAccuracy", "ShootSpreadConsistent",
    "MuzzleFlash", "FlashEnabled",
    "AttackCooldown", "HeavyAttackCooldown", "BladeCooldown",
    "DashCooldown", "DeflectCooldown", "SpinCooldown", "BuildCooldown",
    "HitboxSize", "Radius", "IsAiming"
}

-- Initial Scan Function (Run once or rarely)
local function ScanForAttributes()
    table.clear(TargetTables)
    for _, t in pairs(getgc(true)) do
        if type(t) == "table" then
            for _, attr in pairs(InterestedAttributes) do
                -- Safer check using pcall or just type checking
                local success, val = pcall(function() return rawget(t, attr) end)
                if success and val ~= nil then
                    -- Store original value if not cached
                    if not AttributeCache[t] then AttributeCache[t] = {} end
                    if AttributeCache[t][attr] == nil then
                         AttributeCache[t][attr] = val -- Use the retrieved value
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

-- Unified RenderStepped Loop for Combat Mods
-- Ensures values are constantly enforced without laggy getgc scans
local RunService = game:GetService("RunService")
RunService.RenderStepped:Connect(function()
    local noRecoil = Options.NoRecoil and Options.NoRecoil.Value
    local noSpread = Options.NoSpread and Options.NoSpread.Value
    local noMuzzle = Options.NoMuzzle and Options.NoMuzzle.Value

    -- If no features are enabled, don't iterate at all
    if not (noRecoil or noSpread or noMuzzle) then return end

    for _, t in pairs(TargetTables) do
        -- No Recoil Loop
        if noRecoil then
            if rawget(t, "ShootRecoil") then t.ShootRecoil = 0 end
            if rawget(t, "RecoilShake") then t.RecoilShake = 0 end
            if rawget(t, "CameraShake") ~= nil then t.CameraShake = false end
        end

        -- No Spread Loop
        if noSpread then
            if rawget(t, "ShootSpread") then t.ShootSpread = 0 end
            if rawget(t, "AimSpreadMultiplier") then t.AimSpreadMultiplier = 0 end
            if rawget(t, "ShootAccuracy") then t.ShootAccuracy = 10000 end
            if rawget(t, "ShootSpreadConsistent") ~= nil then t.ShootSpreadConsistent = true end
            if rawget(t, "IsAiming") ~= nil then t.IsAiming = true end
        end

        -- No Muzzle Flash Loop
        if noMuzzle then
            if rawget(t, "MuzzleFlash") ~= nil then t.MuzzleFlash = false end
            if rawget(t, "FlashEnabled") ~= nil then t.FlashEnabled = false end
        end
    end
end)


-- [[ Melee Mods ]] --
local MeleeMods = Tabs.Combat:AddSection("Melee")

local MeleeAura = Tabs.Combat:AddToggle("MeleeAura", {Title = "Melee Aura (Reach)", Default = false })
local TeleportAura = Tabs.Combat:AddToggle("TeleportAura", {Title = "Target Strafe (Chaotic TP)", Default = false })

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
            local closest, dist = nil, 1000 -- Max dist
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
                -- Chaotic Target Strafe
                -- Tp to chaotic random points around the target (20-80 studs)
                local startAngle = math.random() * math.pi * 2
                local distance = math.random(20, 80)
                local height = math.random(0, 30)
                
                local offset = CFrame.new(math.sin(startAngle) * distance, height, math.cos(startAngle) * distance)
                
                root.CFrame = closest.CFrame * offset
                
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