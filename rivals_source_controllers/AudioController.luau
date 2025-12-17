local v_u_1 = game:GetService("CollectionService")
local v2 = game:GetService("Players")
local v_u_3 = require(v2.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local v_u_4 = require(v2.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local v_u_5 = require(v2.LocalPlayer.PlayerScripts.Controllers.FighterController)
local v_u_6 = {}
v_u_6.__index = v_u_6
function v_u_6._new()
    local v7 = v_u_6
    local v8 = setmetatable({}, v7)
    v8._connections = {}
    v8._local_fighter = nil
    v8:_Init()
    return v8
end
function v_u_6._ObjectAdded(_, p9)
    if v_u_4.TrueCurrentSubject and v_u_4.TrueCurrentSubject.FighterInterface then
        if p9:IsDescendantOf(workspace) and p9.Parent:IsA("BasePart") then
            v_u_4.TrueCurrentSubject.FighterInterface.AudioVisualizers:Create(p9, p9.RollOffMinDistance, p9.RollOffMaxDistance)
        end
    else
        return
    end
end
function v_u_6._UpdateEnabled(p10)
    for _, v11 in pairs(p10._connections) do
        v11:Disconnect()
    end
    p10._connections = {}
end
function v_u_6._HookLocalFighter(p_u_12)
    p_u_12._local_fighter = v_u_5:WaitForLocalFighter()
    p_u_12._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
        p_u_12:_UpdateEnabled()
    end)
    p_u_12._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
        p_u_12:_UpdateEnabled()
    end)
    p_u_12:_UpdateEnabled()
end
function v_u_6._Init(p_u_13)
    v_u_3:GetDataChangedSignal("Settings Audio Visualizers"):Connect(function()
        p_u_13:_UpdateEnabled()
    end)
    p_u_13:_UpdateEnabled()
    task.defer(p_u_13._HookLocalFighter, p_u_13)
end
return v_u_6._new()
