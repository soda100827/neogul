local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/Library.lua'))()
local ThemeManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet('https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = 'Neogul Scripts - Rivals',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

-- CALLBACK NOTE:
-- Passing in callback functions via the initial element parameters (i.e. Callback = function(Value)...) works
-- HOWEVER, using Toggles/Options.INDEX:OnChanged(function(Value) ... ) is the RECOMMENDED way to do this.
-- I strongly recommend decoupling UI code from logic code. i.e. Create your UI elements FIRST, and THEN setup :OnChanged functions later.

-- You do not have to set your tabs & groups up this way, just a prefrence.
local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

-- Combat Tab
-- Combat Tab
local AimbotGroupbox = Tabs.Combat:AddLeftGroupbox('Aimbot')

AimbotGroupbox:AddToggle('AimbotEnabled', { Text = 'Enabled', Default = false }):AddKeyPicker('AimbotKey', { Default = 'MB2', Text = 'Aim Key', Mode = 'Hold' })
AimbotGroupbox:AddSlider('AimbotFOV', { Text = 'FOV Radius', Default = 150, Min = 10, Max = 800, Rounding = 0, Suffix = 'px' })
AimbotGroupbox:AddSlider('AimbotSmoothness', { Text = 'Smoothness', Default = 1, Min = 1, Max = 20, Rounding = 1 })
AimbotGroupbox:AddDropdown('AimbotTargetPart', { Values = { 'Head', 'Torso', 'Random' }, Default = 1, Multi = false, Text = 'Target Part' })
AimbotGroupbox:AddToggle('AimbotTeamCheck', { Text = 'Team Check', Default = true })
AimbotGroupbox:AddToggle('AimbotWallCheck', { Text = 'Wall Check', Default = true })

local CombatLeftGroupbox2 = Tabs.Combat:AddLeftGroupbox('Target Strafe')
CombatLeftGroupbox2:AddToggle('TargetStrafe', { Text = 'Enabled', Default = false }):AddKeyPicker('TargetStrafeKey', { Default = 'Z', Text = 'Target Strafe Key', Mode = 'Toggle' })
CombatLeftGroupbox2:AddSlider('TargetStrafeXOffset', { Text = 'X Offset', Default = 2, Min = 0, Max = 10, Rounding = 1, Suffix = 's' })
CombatLeftGroupbox2:AddSlider('TargetStrafeYOffset', { Text = 'Y Offset', Default = 1, Min = 0, Max = 10, Rounding = 1, Suffix = 's' })
CombatLeftGroupbox2:AddSlider('TargetStrafeSpinSpeed', { Text = 'Spin Speed', Default = 8, Min = 0, Max = 50, Rounding = 0, Suffix = 'rps' })

local CombatLeftGroupbox3 = Tabs.Combat:AddLeftGroupbox('Character')
CombatLeftGroupbox3:AddToggle('SlideBoost', { Text = 'Slide Boost', Default = false })
CombatLeftGroupbox3:AddToggle('Fly', { Text = 'Fly', Default = false }):AddKeyPicker('FlyKey', { Default = 'X', Text = 'Fly Key', Mode = 'Toggle' })
CombatLeftGroupbox3:AddToggle('Noclip', { Text = 'Noclip', Default = false }):AddKeyPicker('NoclipKey', { Default = 'N', Text = 'Noclip Key', Mode = 'Toggle' })
CombatLeftGroupbox3:AddSlider('SlideBoostMultiplier', { Text = 'Slide Boost Multiplier', Default = 1, Min = 1, Max = 10, Rounding = 1, Suffix = 'x' })
CombatLeftGroupbox3:AddSlider('FlySpeed', { Text = 'Fly Speed', Default = 500, Min = 100, Max = 1000, Rounding = 0, Suffix = 'x' })

local CombatLeftGroupbox4 = Tabs.Combat:AddLeftGroupbox('Miscellaneous')
CombatLeftGroupbox4:AddToggle('AntiFlashbang', { Text = 'Anti Flashbang', Default = false })
CombatLeftGroupbox4:AddToggle('SpoofDevice', { Text = 'Spoof Device', Default = false })
CombatLeftGroupbox4:AddDropdown('DeviceSelector', { Values = { 'MouseKeyboard', 'Controller', 'Mobile', 'VR' }, Default = 1, Multi = false, Text = 'Device' })

local function UpdateCombatDeviceSpoof()
    if not (Toggles.SpoofDevice and Options.DeviceSelector) then return end
    
    if Toggles.SpoofDevice.Value then
        local mapping = {
            ['MouseKeyboard'] = 'MouseKeyboard',
            ['Controller'] = 'Gamepad',
            ['Mobile'] = 'Touch',
            ['VR'] = 'VR'
        }
        local mode = mapping[Options.DeviceSelector.Value]
        if mode then
            game:GetService("ReplicatedStorage").Remotes.Replication.Fighter.SetControls:FireServer(mode)
        end
    end
end

Toggles.SpoofDevice:OnChanged(UpdateCombatDeviceSpoof)
Options.DeviceSelector:OnChanged(UpdateCombatDeviceSpoof)

task.spawn(function()
    local success, ControlsController = pcall(function()
        return require(game:GetService("Players").LocalPlayer.PlayerScripts.Controllers.ControlsController)
    end)
    if success and ControlsController then
        ControlsController.ControlsChanged:Connect(UpdateCombatDeviceSpoof)
    end
end)
CombatLeftGroupbox4:AddToggle('SoundSpammer', { Text = 'Sound Spammer', Default = false })
CombatLeftGroupbox4:AddDropdown('SoundSelector', { Values = { 'DoubleJump', 'Slide' }, Default = 1, Multi = false, Text = 'Sound' })

task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.SoundSpammer and Toggles.SoundSpammer.Value and Options.SoundSelector then
            local sound = Options.SoundSelector.Value
            if sound then
                game:GetService("ReplicatedStorage").Remotes.Replication.Fighter.PlayMechanicsSound:FireServer(unpack({sound}))
            end
        end
    end
end)

-- Right Groupboxes (Exact Image)
local CombatRightGroupbox = Tabs.Combat:AddRightGroupbox('Gun Mods')
CombatRightGroupbox:AddToggle('NoRecoil', { Text = 'No Recoil', Default = false })
CombatRightGroupbox:AddToggle('NoSpread', { Text = 'No Spread', Default = false })
CombatRightGroupbox:AddToggle('NoMuzzleFlash', { Text = 'No Muzzle Flash', Default = false })
CombatRightGroupbox:AddSlider('AttackCooldown', { Text = 'Attack Cooldown', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })

local CombatRightGroupbox2 = Tabs.Combat:AddRightGroupbox('Melee')
CombatRightGroupbox2:AddToggle('MeleeAura', { Text = 'Melee Aura', Default = false })
CombatRightGroupbox2:AddToggle('TeleportAura', { Text = 'Teleport Aura', Default = false })
CombatRightGroupbox2:AddSlider('MeleeAttackCooldown', { Text = 'Attack Cooldown', Default = 100, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })

local CombatRightGroupbox3 = Tabs.Combat:AddRightGroupbox('Ragebot')
CombatRightGroupbox3:AddToggle('Ragebot', { Text = 'Ragebot', Default = false }):AddKeyPicker('RagebotKey', { Default = 'Z', Text = 'Ragebot Key', Mode = 'Toggle' })
CombatRightGroupbox3:AddToggle('SwapWeaponOnReload', { Text = 'Swap Weapon On Reload', Default = false })
CombatRightGroupbox3:AddToggle('TargetStrafeRage', { Text = 'Target Strafe', Default = false })
CombatRightGroupbox3:AddDropdown('RagebotWeapon', { Values = { 'Primary', 'Secondary', 'Melee' }, Default = 1, Multi = false, Text = 'Ragebot Weapon' })
CombatRightGroupbox3:AddSlider('ManipulationMax', { Text = 'Manipulation Max', Default = 90, Min = 0, Max = 100, Rounding = 0, Suffix = '%' })



-- Misc Tab
local MiscLeftGroupbox = Tabs.Misc:AddLeftGroupbox('Auto Load')
MiscLeftGroupbox:AddToggle('AutoLoad', { Text = 'Auto Load', Default = false })
MiscLeftGroupbox:AddToggle('SilentMode', { Text = 'Silent Mode', Default = false })

local MiscLeftGroupbox2 = Tabs.Misc:AddLeftGroupbox('Auto Select Loadout')
MiscLeftGroupbox2:AddToggle('AutoSelectLoadout', { Text = 'Enabled', Default = false })
MiscLeftGroupbox2:AddDropdown('Utility', { Values = { 'Grenade', 'Flashbang', 'Smoke' }, Default = 1, Multi = false, Text = 'Utility' })
MiscLeftGroupbox2:AddDropdown('Primary', { Values = { 'Assault Rifle', 'Sniper', 'Shotgun' }, Default = 1, Multi = false, Text = 'Primary' })
MiscLeftGroupbox2:AddDropdown('Melee', { Values = { 'Fists', 'Knife', 'Scythe' }, Default = 1, Multi = false, Text = 'Melee' })
MiscLeftGroupbox2:AddDropdown('Secondary', { Values = { 'Handgun', 'Revolver' }, Default = 1, Multi = false, Text = 'Secondary' })

local MiscLeftGroupbox3 = Tabs.Misc:AddLeftGroupbox('Kill Say')
MiscLeftGroupbox3:AddToggle('KillSay', { Text = 'Enabled', Default = false })
MiscLeftGroupbox3:AddDropdown('KillSayLanguage', { Values = { 'English', 'Korean' }, Default = 1, Multi = false, Text = 'Language' })
MiscLeftGroupbox3:AddDropdown('KillSayType', { Values = { 'Roast', 'Toxic', 'HvH', 'Custom' }, Default = 1, Multi = false, Text = 'Type' })

-- Custom Chat Management Logic
local CustomKillSayMessages = {}
local KillSayDropdown = MiscLeftGroupbox3:AddDropdown('KillSayCustomList', { Values = {}, Default = 0, Multi = false, Text = 'Custom Message List', AllowNull = true })
MiscLeftGroupbox3:AddInput('KillSayAddCustom', { Default = '', Text = 'Add Custom Chat', Placeholder = 'Type message and press Enter', Finished = true, Callback = function(Value) 
    if Value and Value ~= '' then
        table.insert(CustomKillSayMessages, Value)
        KillSayDropdown:SetValues(CustomKillSayMessages)
        KillSayDropdown:SetValue(Value)
        Library:Notify('Added custom Kill Say message.')
    end
end })
MiscLeftGroupbox3:AddButton('Remove Selected', function()
    local selected = Options.KillSayCustomList.Value
    if selected then
        local idx = table.find(CustomKillSayMessages, selected)
        if idx then
            table.remove(CustomKillSayMessages, idx)
            KillSayDropdown:SetValues(CustomKillSayMessages)
            KillSayDropdown:SetValue(nil)
            Library:Notify('Removed custom message.')
        end
    end
end)


local MiscRightGroupbox = Tabs.Misc:AddRightGroupbox('Auto Queue')
MiscRightGroupbox:AddToggle('AutoQueue', { Text = 'Enabled', Default = false })
MiscRightGroupbox:AddDropdown('AutoQueueMode', { Values = { '1v1', '2v2', 'Deathmatch' }, Default = 1, Multi = false, Text = 'Mode' })

local MiscRightGroupbox2 = Tabs.Misc:AddRightGroupbox('Chat Spammer')
MiscRightGroupbox2:AddToggle('ChatSpammer', { Text = 'Enabled', Default = false })
MiscRightGroupbox2:AddDropdown('ChatSpammerLanguage', { Values = { 'English', 'Korean' }, Default = 1, Multi = false, Text = 'Language' })
MiscRightGroupbox2:AddDropdown('ChatSpammerType', { Values = { 'Roast', 'Toxic', 'HvH', 'Custom' }, Default = 1, Multi = false, Text = 'Type' })

-- Custom Chat Spammer Management Logic
local CustomSpammerMessages = {}
local ChatSpammerDropdown = MiscRightGroupbox2:AddDropdown('ChatSpammerCustomList', { Values = {}, Default = 0, Multi = false, Text = 'Custom Message List', AllowNull = true })
MiscRightGroupbox2:AddInput('ChatSpammerAddCustom', { Default = '', Text = 'Add Custom Chat', Placeholder = 'Type message and press Enter', Finished = true, Callback = function(Value) 
    if Value and Value ~= '' then
        table.insert(CustomSpammerMessages, Value)
        ChatSpammerDropdown:SetValues(CustomSpammerMessages)
        ChatSpammerDropdown:SetValue(Value)
        Library:Notify('Added custom Spammer message.')
    end
end })
MiscRightGroupbox2:AddButton('Remove Selected', function()
    local selected = Options.ChatSpammerCustomList.Value
    if selected then
        local idx = table.find(CustomSpammerMessages, selected)
        if idx then
            table.remove(CustomSpammerMessages, idx)
            ChatSpammerDropdown:SetValues(CustomSpammerMessages)
            ChatSpammerDropdown:SetValue(nil)
            Library:Notify('Removed custom message.')
        end
    end
end)

MiscRightGroupbox2:AddSlider('ChatSpammerDelay', { Text = 'Delay', Default = 3, Min = 1, Max = 60, Rounding = 1, Suffix = 's' })

local MessageTemplates = {
    English = {
        Roast = {
            'Are you playing with your monitor off?',
            'Is that a bot or a player?',
            'I think the tutorial boss was harder than you.',
            'Your aim is allergic to players.',
            'You missed... again.',
            'Are you using a trackpad?',
            'Refund your internet, it\'s wasted on you.',
            'My cat could aim better.',
            'Nice strategy, dying repeatedly.',
            'Just leave, save your KD.',
            'I\'d say uninstall, but you probably missed the button.'
        },
        Toxic = {
            'EZ',
            'Skill issue',
            'Gap',
            'Trash',
            'Tutorial complete?',
            'You\'re awful',
            'Bot movement',
            'Cry about it',
            'Mad because bad',
            'Imagine being this bad',
            'Get rolled'
        },
        HvH = {
            'Nice free paste.',
            'Did you get that script from a cereal box?',
            'My config costs more than your PC.',
            'Update your cheat, it\'s outdated.',
            'Refund your subscription.',
            'Are you even trying?',
            'Config issue or brain issue?',
            'Nice silent aim, does it hit anything?',
        }
    },
    Korean = {
        Roast = {
            '모니터 끄고 게임하시나요?',
            '봇인줄 알았네 ㅋㅋ',
            '튜토리얼 보스가 더 잘할듯',
            '에임이 사람을 피해가네요',
            '와 그걸 못 맞추네',
            '트랙패드로 게임함?',
            '인터넷 요금이 아깝다',
            '우리집 고양이가 더 잘 쏠듯',
            '계속 죽는 게 전략인가요?',
            '그냥 나가시는 게 킬뎃 보호에 좋을듯',
            '게임 삭제하라고 하고 싶은데 삭제 버튼도 못 누를듯'
        },
        Toxic = {
            '허접',
            '실력 차이',
            '수준 ㄷㄷ',
            '쓰레기',
            '튜토리얼은 깸?',
            '개못하네',
            '너무 못해',
            '봇 무빙',
            '울지마',
            '화났쥬?',
            '이렇게 못하기도 힘들겠다',
            '털렸죠?'
        },
        HvH = {
            '어디서 주워온 무료 핵 씀?',
            '니 핵은 그게 한계냐?',
            '내 설정이 니 컴퓨터보다 비쌀듯',
            '핵 업데이트 좀 해라 구닥다리네',
            '그거 돈 주고 산 거임? 환불해라',
            '진심으로 하는 거임?',
            '설정 문제냐 지능 문제냐?',
            '사일런트 에임 킨 거 맞음? 하나도 안 맞네',
            '짭 스크립트 수준 ㅋㅋ'
        }
    }
}

task.spawn(function()
    while true do
        task.wait(Options.ChatSpammerDelay.Value)
        if Toggles.ChatSpammer and Toggles.ChatSpammer.Value then
            local lang = Options.ChatSpammerLanguage.Value
            local msgType = Options.ChatSpammerType.Value
            local msgList = {}
            
            if msgType == 'Custom' then
                msgList = CustomSpammerMessages
            elseif MessageTemplates[lang] and MessageTemplates[lang][msgType] then
                msgList = MessageTemplates[lang][msgType]
            else
                 msgList = {'Default message'}
            end

            if #msgList > 0 then
                local TextChat = msgList[math.random(1, #msgList)]
                pcall(function()
                     game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(TextChat)
                end)
            end
        end
    end
end)

-- Rivals: EliminationFeed Logic Hook
task.spawn(function()
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer

    local function GetEliminationFeedModule()
        local scripts = LocalPlayer:FindFirstChild("PlayerScripts")
        if scripts then
            for _, v in pairs(scripts:GetDescendants()) do
                if v:IsA("ModuleScript") and v.Name == "EliminationFeed" then
                    return v
                end
            end
        end
        for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
            if v:IsA("ModuleScript") and v.Name == "EliminationFeed" then
                return v
            end
        end
        return nil
    end

    local moduleScript = GetEliminationFeedModule()
    if moduleScript then
        local success, FeedModule = pcall(require, moduleScript)
        if success and FeedModule and FeedModule.Play then
            local OldPlay = FeedModule.Play
            
            FeedModule.Play = function(self, victim, eliminator, assistant, weaponName, isCrit, isBlind, isNoscope)
                if eliminator == LocalPlayer then
                    if Toggles.KillSay and Toggles.KillSay.Value then
                        local lang = Options.KillSayLanguage.Value
                        local msgType = Options.KillSayType.Value
                        local msgList = {}
                        
                        if msgType == 'Custom' then
                            msgList = CustomKillSayMessages
                        elseif MessageTemplates[lang] and MessageTemplates[lang][msgType] then
                            msgList = MessageTemplates[lang][msgType]
                        end

                        if #msgList > 0 then
                            local TextChat = msgList[math.random(1, #msgList)]
                            -- Send to chat using TextChatService
                            pcall(function()
                                game:GetService("TextChatService").TextChannels.RBXGeneral:SendAsync(TextChat)
                            end)
                        end
                    end
                end
                return OldPlay(self, victim, eliminator, assistant, weaponName, isCrit, isBlind, isNoscope)
            end
        end
    end
end)

local MiscRightGroupbox3 = Tabs.Misc:AddRightGroupbox('World')


Library.KeybindFrame.Visible = true;

--------------------------------------------------------------------------------
-- Slide Boost Implementation
--------------------------------------------------------------------------------
task.spawn(function()
    local MechanicsController = require(game:GetService("Players").LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
    
    while not MechanicsController.LocalFighter do
        task.wait()
    end
    
    local LocalFighter = MechanicsController.LocalFighter
    local oldGet = LocalFighter.Get
    
    LocalFighter.Get = function(self, key, ...)
        if key == "SlidingSpeedMax" and Toggles.SlideBoost and Toggles.SlideBoost.Value and Options.SlideBoostMultiplier then
            local multiplier = Options.SlideBoostMultiplier.Value
            local val = oldGet(self, key, ...)
            return (val or 3) * multiplier
        end
        return oldGet(self, key, ...)
    end
end)

--------------------------------------------------------------------------------
-- Noclip Implementation
--------------------------------------------------------------------------------
game:GetService('RunService').Stepped:Connect(function()
    if Toggles.Noclip and Toggles.Noclip.Value and Options.NoclipKey and Options.NoclipKey:GetState() then
        for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide == true then
                v.CanCollide = false
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- Aimbot Implementation (Cursor Based)
--------------------------------------------------------------------------------


-- FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.Radius = 150
FOVCircle.Position = Vector2.new(0, 0)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()
local UserInputService = game:GetService("UserInputService") -- Add for mouse pos if needed

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do 
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local targetPartName = Options.AimbotTargetPart.Value
            
            if targetPartName == 'Random' then
                targetPartName = (math.random() > 0.5) and 'Head' or 'HumanoidRootPart'
            elseif targetPartName == 'Torso' then
                targetPartName = 'HumanoidRootPart' -- R15
            end
            
            local targetPart = character and character:FindFirstChild(targetPartName)

            if character and humanoid and humanoid.Health > 0 and targetPart then
                -- Team Check
                if Toggles.AimbotTeamCheck.Value and player.Team == LocalPlayer.Team then
                    continue
                end

                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                local mouseLocation = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                if onScreen and distance < Options.AimbotFOV.Value then
                    -- Wall Check
                    if Toggles.AimbotWallCheck.Value then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, rayParams)
                        
                        if rayResult then
                            continue -- Hit a wall
                        end
                    end

                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = targetPart
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    local mouseLocation = UserInputService:GetMouseLocation()
    FOVCircle.Visible = Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value
    FOVCircle.Radius = Options.AimbotFOV.Value
    FOVCircle.Position = mouseLocation
    
    if Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value and Options.AimbotKey:GetState() then
        local target = GetClosestPlayerToCursor()
        if target then
            -- Calculate screen position
            local screenPoint, onScreen = Camera:WorldToViewportPoint(target.Position)
            
            if onScreen then
                local mouseLocation = UserInputService:GetMouseLocation()
                local relativeX = (screenPoint.X - mouseLocation.X)
                local relativeY = (screenPoint.Y - mouseLocation.Y)
                
                -- Smoothness
                local smoothValue = Options.AimbotSmoothness.Value
                
                -- Move Mouse
                mousemoverel(relativeX / smoothValue, relativeY / smoothValue)
            end
        end
    end
end)



local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')

MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddToggle('KeybindMenu', { Text = 'Keybind Menu', Default = true }):OnChanged(function()
    Library.KeybindFrame.Visible = Toggles.KeybindMenu.Value
end)

MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })

Library.ToggleKeybind = Options.MenuKeybind 

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)

SaveManager:IgnoreThemeSettings()

ThemeManager:SetFolder('MyScriptHub')
SaveManager:SetFolder('MyScriptHub/specific-game')

local oldAddRightGroupbox = Tabs['UI Settings'].AddRightGroupbox
Tabs['UI Settings'].AddRightGroupbox = function(self, name)
    local groupbox = oldAddRightGroupbox(self, name)
    if name == 'Configuration' then
        -- Hook AddButton on this specific groupbox
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

SaveManager:BuildConfigSection(Tabs['UI Settings'])
Tabs['UI Settings'].AddRightGroupbox = oldAddRightGroupbox
ThemeManager:ApplyToTab(Tabs['UI Settings'])
SaveManager:LoadAutoloadConfig()