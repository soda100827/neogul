game:GetService("CollectionService")
local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("Players")
local v_u_3 = require(v_u_1.Modules.CONSTANTS)
local v_u_4 = require(v_u_1.Modules.Signal)
local v_u_5 = require(v_u_2.LocalPlayer.PlayerScripts.Controllers.FighterController)
local v_u_6 = require(v_u_2.LocalPlayer.PlayerScripts.Modules.ReplicatedController)
local v_u_7 = setmetatable({}, v_u_6)
v_u_7.__index = v_u_7
function v_u_7._new()
    local v8 = v_u_6.new("QueuePad")
    local v9 = v_u_7
    local v10 = setmetatable(v8, v9)
    v10.LocalPlayerActivity = v_u_4.new()
    v10._local_fighter = nil
    v10._update_loop_active = false
    v10:_Init()
    return v10
end
function v_u_7.GetQueuePad(p11, p12)
    for _, v13 in pairs(p11.Objects) do
        local v14 = v13:IsInQueue(p12)
        if v14 then
            return v13, v14
        end
    end
end
function v_u_7._CheckQueueStatus(p15)
    local v16 = p15._local_fighter:IsAlive()
    if v16 then
        v16 = p15._local_fighter.Player
    end
    local v17, v18 = p15:GetQueuePad(v_u_2.LocalPlayer)
    if v17 then
        if not (v16 and v17:IsWithin(v16, v18)) then
            v_u_1.Remotes.Misc.QueueLeave:InvokeServer()
            return
        end
    elseif v16 then
        for _, v19 in pairs(p15.Objects) do
            local v20 = v19:IsWithin(v16)
            if v20 then
                v_u_1.Remotes.Misc.QueueJoin:InvokeServer(v19:Get("ObjectID"), v20)
            end
        end
    end
end
function v_u_7._UpdateLoop(p21)
    if not p21._update_loop_active then
        p21._update_loop_active = true
        while true do
            wait(0.1)
            if p21._local_fighter:Get("IsInDuel") or p21._local_fighter:Get("IsInShootingRange") then
                break
            end
            if v_u_3.IS_STUDIO then
                p21:_CheckQueueStatus()
            else
                local v22, v23 = pcall(p21._CheckQueueStatus, p21)
                if not v22 then
                    warn("Failed to check queue status, error:", v23)
                end
            end
        end
        p21._update_loop_active = false
    end
end
function v_u_7._HookLocalFighter(p_u_24)
    p_u_24._local_fighter = v_u_5:WaitForLocalFighter()
    p_u_24._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
        p_u_24:_UpdateLoop()
    end)
    p_u_24._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
        p_u_24:_UpdateLoop()
    end)
    p_u_24:_UpdateLoop()
end
function v_u_7._Init(p_u_25)
    p_u_25.ObjectAdded:Connect(function(p26)
        p26.LocalPlayerActivity:Connect(function()
            p_u_25.LocalPlayerActivity:Fire()
        end)
    end)
    task.defer(p_u_25._HookLocalFighter, p_u_25)
end
return v_u_7._new()
