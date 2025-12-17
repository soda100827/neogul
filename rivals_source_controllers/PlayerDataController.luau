local v_u_1 = game:GetService("ReplicatedStorage")
local v2 = game:GetService("Players")
local v_u_3 = require(v_u_1:WaitForChild("Modules"):WaitForChild("EnumLibrary"))
local v_u_4 = require(v_u_1:WaitForChild("Modules"):WaitForChild("Signal"))
local v_u_5 = require(v2.LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"):WaitForChild("ClientReplicatedClasses"):WaitForChild("ClientPlayerData"))
local v6 = v_u_1:WaitForChild("Remotes"):WaitForChild("Data")
local v_u_7 = v6:WaitForChild("RequestPlayerData")
local v_u_8 = v6:WaitForChild("PlayerDataChanged")
local v_u_9 = v6:WaitForChild("PlayerDataAdded")
local v_u_10 = {}
v_u_10.__index = v_u_10
function v_u_10._new()
    local v11 = v_u_10
    local v12 = setmetatable({}, v11)
    v12.PlayerDataAdded = v_u_4.new()
    v12.StatisticsUpdated = v_u_4.new()
    v12.SettingsSliderChanged = v_u_4.new()
    v12.CurrentData = nil
    v12:_Init()
    return v12
end
function v_u_10.GetWeaponData(p13, ...)
    return p13.CurrentData:GetWeaponData(...)
end
function v_u_10.GetStatistic(p14, p15)
    local v16 = require(v_u_1.Modules.StatisticsLibrary).Info[p15]
    local v17 = v16 ~= nil
    assert(v17, p15)
    return p14:Get(p15) or v16.DefaultValue
end
function v_u_10.GetDirectoryStatistic(p18, p19, p20, p21)
    local v22 = require(v_u_1.Modules.StatisticsLibrary).Info[p21]
    local v23 = v22 ~= nil
    assert(v23, p21)
    local v24 = p18:Get(p19)
    return v24[p20] and v24[p20][p21] or v22.DefaultValue
end
function v_u_10.GetWeaponStatistic(p25, ...)
    return p25:GetDirectoryStatistic("WeaponStatistics", ...)
end
function v_u_10.GetMapStatistic(p26, ...)
    return p26:GetDirectoryStatistic("MapStatistics", ...)
end
function v_u_10.GetUnlockedWeapons(p27, p28)
    local v29 = {}
    for _, v30 in pairs(p27:Get("WeaponInventory")) do
        v29[v30.Name] = true
    end
    if not p28 then
        for v31 in pairs(p27:Get("FreeWeaponUnlockCheck")) do
            v29[v31] = true
        end
    end
    return v29
end
function v_u_10.OwnsAllWeapons(p32, p33, p34, p35)
    local v36 = require(v_u_1.Modules.ItemLibrary)
    local v37 = require(v_u_1.Modules.ShopLibrary)
    local v38 = 0
    local v39 = 0
    for _, v40 in pairs(v37:GetReleasedOwnableWeapons()) do
        if (not p33 or v36.Items[v40].Status == p33) and ((not p35 or v37:IsWeaponReleased(v40)) and (not p34 or v37.Weapons[v40].KeyPrice)) then
            v38 = v38 + 1
        end
    end
    for _, v41 in pairs(p32:Get("WeaponInventory")) do
        if not p33 or v36.Items[v41.Name].Status == p33 then
            local v42 = not p35 or v37:IsWeaponReleased(v41.Name)
            local v43 = (p34 and true or false) and v37.Weapons[v41.Name]
            if v43 then
                v43 = v37.Weapons[v41.Name].KeyPrice
            end
            if v42 and v43 then
                v39 = v39 + 1
            end
        end
    end
    return v38 <= v39
end
function v_u_10.GetNumTaksCompleted(p44, p45)
    local v46 = 0
    for _, v47 in pairs(p44:Get(p45 or "Tasks")) do
        if v47.Completed then
            v46 = v46 + 1
        end
    end
    return v46
end
function v_u_10.AreTasksCompleted(p48, p49)
    require(v_u_1.Modules.TaskLibrary)
    for _, v50 in pairs(p48:Get(p49 or "Tasks")) do
        if not v50.Completed then
            return false
        end
    end
    return true
end
function v_u_10.IsEmoteEquipped(p51, p52)
    for _, v53 in pairs(p51:Get("EquippedEmotes")) do
        if v53.Name == p52 then
            return true
        end
    end
end
function v_u_10.SilenceCosmeticNotification(p54, p55, p56)
    if p55 then
        local v57 = p54:Get("CosmeticNotifications")
        if p56 then
            local v58 = v57[p55]
            if typeof(v58) == "table" then
                v57[p55][p56] = nil
                p54.CurrentData:Replicate("CosmeticNotifications")
                v_u_1.Remotes.Data.SilenceCosmeticNotification:FireServer(p55, p56)
            end
        else
            v57[p55] = nil
            p54.CurrentData:Replicate("CosmeticNotifications")
            v_u_1.Remotes.Data.SilenceCosmeticNotification:FireServer(p55, nil)
        end
    else
        p54.CurrentData:SetReplicate("CosmeticNotifications", {})
        v_u_1.Remotes.Data.SilenceCosmeticNotification:FireServer(nil, nil)
        return
    end
end
function v_u_10.WaitUntilLoaded(p59)
    if not p59.CurrentData then
        p59.PlayerDataAdded:Wait()
    end
end
function v_u_10.Get(p60, ...)
    return p60.CurrentData:Get(...)
end
function v_u_10.Set(p61, ...)
    return p61.CurrentData:Set(...)
end
function v_u_10.GetDataChangedSignal(p62, ...)
    return p62.CurrentData:GetDataChangedSignal(...)
end
function v_u_10.HasGamepass(p63, ...)
    return p63.CurrentData:HasGamepass(...)
end
function v_u_10._PlayerDataChanged(p64, p65, ...)
    local v66 = p64.CurrentData
    if not v66 then
        return
    end
    v_u_3:WaitForEnumBuilder()
    local v67 = v_u_3:FromEnum(p65) or p65
    if v67 == "DataValueChanged" then
        v66:SetReplicate(...)
        return
    end
    if v67 == "BulkDataValueChanged" then
        for _, v68 in pairs((...)) do
            v66:SetReplicate(v68[1], v68[2])
        end
        return
    end
    if v67 == "StatisticsBatchUpdate" then
        local v69 = require(v_u_1.Modules.StatisticsLibrary)
        local v70 = ...
        for v71, v72 in pairs(v70[utf8.char(0)] or {}) do
            v66:Set(v66:FromEnum(v71), v72)
        end
        for v73, v74 in pairs(v69.STATISTICS_DIRECTORY_INFO) do
            local v75, _ = table.unpack(v74)
            local v76 = p64:Get(v75)
            for v77, v78 in pairs(v70[utf8.char(0 + v73)] or {}) do
                local v79 = v66:FromEnum(v77)
                v76[v79] = v76[v79] or {}
                for v80, v81 in pairs(v78) do
                    v76[v79][v66:FromEnum(v80)] = v81
                end
            end
        end
        p64.StatisticsUpdated:Fire()
        return
    end
    if v67 ~= "WeaponDataChanged" then
        v66:ReplicateFromServer(v67, ...)
        return
    end
    local v82 = v66:Get("WeaponInventory")
    local v83 = ...
    for v84, v85 in pairs(v82) do
        if v85.Name == v83.Name then
            v82[v84] = v83
            break
        end
    end
    v66:Replicate("WeaponInventory")
end
function v_u_10._CreatePlayerData(p86, p87)
    local v88 = typeof(p87) == "table"
    local v89 = "Argument 1 invalid, expected a table, got " .. tostring(p87)
    assert(v88, v89)
    local v90 = v_u_5.new(p87)
    p86.CurrentData = v90
    p86.PlayerDataAdded:Fire(v90)
end
function v_u_10._RequestPlayerData(p91)
    local v92 = v_u_7:InvokeServer()
    if v92 then
        p91:_CreatePlayerData(v92)
    end
end
function v_u_10._Init(p_u_93)
    v_u_8.OnClientEvent:Connect(function(...)
        p_u_93:_PlayerDataChanged(...)
    end)
    v_u_9.OnClientEvent:Connect(function(...)
        p_u_93:_CreatePlayerData(...)
    end)
    task.spawn(p_u_93._RequestPlayerData, p_u_93)
end
return v_u_10._new()
