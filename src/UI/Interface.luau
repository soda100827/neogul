return function(Globals)
local Library = Globals.Library

local Window = Library:CreateWindow({
    Title = 'Neogul Scripts - Rivals',
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})

local Tabs = {
    Combat = Window:AddTab('Combat'),
    Visuals = Window:AddTab('Visuals'),
    Misc = Window:AddTab('Misc'),
    ['UI Settings'] = Window:AddTab('UI Settings'),
}

Globals.Tabs = Tabs -- Expose tabs to other modules if needed

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
CombatLeftGroupbox4:AddToggle('SoundSpammer', { Text = 'Sound Spammer', Default = false })
CombatLeftGroupbox4:AddDropdown('SoundSelector', { Values = { 'DoubleJump', 'Slide' }, Default = 1, Multi = false, Text = 'Sound' })

-- Right Groupboxes
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
-- Custom Kill Say Logic needs to stay with UI or be in Misc Module?
-- The Logic for ADDING to the dropdown can stay here as it is UI interaction.
-- But the 'CustomKillSayMessages' table should be accessible.
Globals.CustomKillSayMessages = {}
local KillSayDropdown = MiscLeftGroupbox3:AddDropdown('KillSayCustomList', { Values = {}, Default = 0, Multi = false, Text = 'Custom Message List', AllowNull = true })
MiscLeftGroupbox3:AddInput('KillSayAddCustom', { Default = '', Text = 'Add Custom Chat', Placeholder = 'Type message and press Enter', Finished = true, Callback = function(Value) 
    if Value and Value ~= '' then
        table.insert(Globals.CustomKillSayMessages, Value)
        KillSayDropdown:SetValues(Globals.CustomKillSayMessages)
        KillSayDropdown:SetValue(Value)
        Library:Notify('Added custom Kill Say message.')
    end
end })
MiscLeftGroupbox3:AddButton('Remove Selected', function()
    local selected = Library.Options.KillSayCustomList.Value
    if selected then
        local idx = table.find(Globals.CustomKillSayMessages, selected)
        if idx then
            table.remove(Globals.CustomKillSayMessages, idx)
            KillSayDropdown:SetValues(Globals.CustomKillSayMessages)
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
MiscRightGroupbox2:AddSlider('ChatSpammerDelay', { Text = 'Delay', Default = 3, Min = 1, Max = 60, Rounding = 1, Suffix = 's' })

Globals.CustomSpammerMessages = {}
local ChatSpammerDropdown = MiscRightGroupbox2:AddDropdown('ChatSpammerCustomList', { Values = {}, Default = 0, Multi = false, Text = 'Custom Message List', AllowNull = true })
MiscRightGroupbox2:AddInput('ChatSpammerAddCustom', { Default = '', Text = 'Add Custom Chat', Placeholder = 'Type message and press Enter', Finished = true, Callback = function(Value) 
    if Value and Value ~= '' then
        table.insert(Globals.CustomSpammerMessages, Value)
        ChatSpammerDropdown:SetValues(Globals.CustomSpammerMessages)
        ChatSpammerDropdown:SetValue(Value)
        Library:Notify('Added custom Spammer message.')
    end
end })
MiscRightGroupbox2:AddButton('Remove Selected', function()
    local selected = Library.Options.ChatSpammerCustomList.Value
    if selected then
        local idx = table.find(Globals.CustomSpammerMessages, selected)
        if idx then
            table.remove(Globals.CustomSpammerMessages, idx)
            ChatSpammerDropdown:SetValues(Globals.CustomSpammerMessages)
            ChatSpammerDropdown:SetValue(nil)
            Library:Notify('Removed custom message.')
        end
    end
end)

local MiscRightGroupbox3 = Tabs.Misc:AddRightGroupbox('World')


-- Settings Tab
local MenuGroup = Tabs['UI Settings']:AddLeftGroupbox('Menu')
MenuGroup:AddButton('Unload', function() Library:Unload() end)
MenuGroup:AddToggle('KeybindMenu', { Text = 'Keybind Menu', Default = true }):OnChanged(function()
    Library.KeybindFrame.Visible = Library.Toggles.KeybindMenu.Value
end)
MenuGroup:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu keybind' })
Library.ToggleKeybind = Library.Options.MenuKeybind 

return Window
end
