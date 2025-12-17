local v_u_1 = game:GetService("CollectionService")
local v_u_2 = game:GetService("ReplicatedStorage")
local v3 = game:GetService("Players")
local v_u_4 = require(v_u_2.Modules.CONSTANTS)
local v_u_5 = require(v_u_2.Modules.RotatingQueueLibrary)
local v_u_6 = require(v_u_2.Modules.Utility)
local v_u_7 = require(v_u_2.Modules.Signal)
local v_u_8 = require(v3.LocalPlayer.PlayerScripts.Controllers.MatchmakingController)
local v_u_9 = require(v3.LocalPlayer.PlayerScripts.Controllers.SpectateController)
local v_u_10 = require(v3.LocalPlayer.PlayerScripts.Controllers.FighterController)
local v_u_11 = require(v3.LocalPlayer.PlayerScripts.Controllers.DuelController)
local v_u_12 = require(v3.LocalPlayer.PlayerScripts.Modules.Functions.SendChat)
local v_u_13 = v3.LocalPlayer.PlayerScripts.Assets.RotatingQueueHolograms
local v_u_14 = {}
v_u_14.__index = v_u_14
function v_u_14._new()
    local v15 = v_u_14
    local v16 = setmetatable({}, v15)
    v16.DuelSet = v_u_7.new()
    v16.CurrentDuel = nil
    v16._has_joined_arcade_duel = false
    v16._hologram_loop_thread = nil
    v16._rotating_queue_hologram = nil
    v16:_Init()
    return v16
end
function v_u_14.Join(p17)
    p17._has_joined_arcade_duel = true
    v_u_2.Remotes.Arcade.Join:FireServer()
end
function v_u_14._UpdateHologram(p18, p19)
    if p18._rotating_queue_hologram then
        p18._rotating_queue_hologram:Destroy()
        p18._rotating_queue_hologram = nil
    end
    local v20 = v_u_1:GetTagged("LobbyRotatingQueueHologram")[1]
    if v20 then
        local v21 = v20:WaitForChild("Primary")
        local v22 = v20:WaitForChild("Particles")
        local v23 = v22:WaitForChild("Emit")
        local v_u_24 = v22:WaitForChild("Attachment")
        v20:WaitForChild("Prompt"):WaitForChild("ProximityPrompt").ObjectText = "Limited Time"
        p18._rotating_queue_hologram = (v_u_13:FindFirstChild(v_u_5:GetCurrent().Name) or v_u_13.Default):Clone()
        p18._rotating_queue_hologram:PivotTo(v21.CFrame)
        p18._rotating_queue_hologram.Name = "_hologram"
        p18._rotating_queue_hologram.Parent = v20
        if p19 then
            v_u_12({
                ["Text"] = "[SERVER] New gamemodes are here! Open the PLAY page now! \240\159\142\137",
                ["Color"] = Color3.fromRGB(100, 255, 50)
            })
            v_u_6:PlayParticles(v23)
            v_u_6:CreateSound("rbxassetid://120776960987657", 0.75, 1, v22, true, 15)
            v_u_6:CreateSound("rbxassetid://75616400922980", 1, 1, v22, true, 15)
            for _, v25 in pairs(v_u_24:GetChildren()) do
                v25.Enabled = true
            end
            task.delay(10, function()
                for _, v26 in pairs(v_u_24:GetChildren()) do
                    v26.Enabled = false
                end
            end)
        end
    end
end
function v_u_14._UpdateHologramLoop(p_u_27)
    local v28 = p_u_27._local_fighter and not p_u_27._local_fighter:Get("IsInDuel")
    if v28 then
        v28 = not p_u_27._local_fighter:Get("IsInShootingRange")
    end
    if v28 then
        if not p_u_27._hologram_loop_thread then
            p_u_27._hologram_loop_thread = task.spawn(function()
                p_u_27:_UpdateHologram()
                while true do
                    wait(v_u_5:GetTimeUntilNext() + 1)
                    p_u_27:_UpdateHologram(true)
                end
            end)
        end
    elseif p_u_27._hologram_loop_thread then
        task.cancel(p_u_27._hologram_loop_thread)
        p_u_27._hologram_loop_thread = nil
        return
    end
end
function v_u_14._HookLocalFighter(p_u_29)
    p_u_29._local_fighter = v_u_10:WaitForLocalFighter()
    p_u_29._local_fighter:GetDataChangedSignal("IsInDuel"):Connect(function()
        p_u_29:_UpdateHologramLoop()
    end)
    p_u_29._local_fighter:GetDataChangedSignal("IsInShootingRange"):Connect(function()
        p_u_29:_UpdateHologramLoop()
    end)
    p_u_29:_UpdateHologramLoop()
end
function v_u_14._DuelRemoved(p30, p31)
    if p30.CurrentDuel == p31 then
        p30.CurrentDuel = nil
        p30.DuelSet:Fire(p31)
    end
end
function v_u_14._DuelAdded(p_u_32, p_u_33)
    p_u_33:GetDataChangedSignal("IsCurrentArcadeDuel"):Connect(function()
        if p_u_33:Get("IsCurrentArcadeDuel") then
            p_u_32.CurrentDuel = p_u_33
            p_u_32.DuelSet:Fire(p_u_33)
        end
    end)
    if p_u_33:Get("IsCurrentArcadeDuel") then
        p_u_32.CurrentDuel = p_u_33
        p_u_32.DuelSet:Fire(p_u_33)
    end
end
function v_u_14._PromptAdded(_, p34)
    p34.Triggered:Connect(function()
        if v_u_4.IS_ARCADE_SERVER then
            v_u_2.Remotes.Matchmaking.BackToHub:FireServer()
        else
            v_u_8:ToArcadeServer()
        end
    end)
    p34.ActionText = v_u_4.IS_ARCADE_SERVER and "Leave" or "Teleport"
end
function v_u_14._Init(p_u_35)
    p_u_35.DuelSet:Connect(function(p36)
        if v_u_10.LocalFighter and not (v_u_10.LocalFighter:Get("IsInDuel") or v_u_10.LocalFighter:Get("IsInShootingRange")) then
            if v_u_4.IS_ARCADE_SERVER and (not p_u_35._has_joined_arcade_duel and #p36.Duelers >= 3) then
                v_u_9:SpectateDuelRequest(p36)
            else
                p_u_35:Join()
            end
        else
            return
        end
    end)
    v_u_11.ObjectAdded:Connect(function(p37)
        p_u_35:_DuelAdded(p37)
    end)
    v_u_11.ObjectRemoved:Connect(function(p38)
        p_u_35:_DuelRemoved(p38)
    end)
    v_u_1:GetInstanceAddedSignal("LobbyRotatingQueueHologram"):Connect(function(p39)
        p_u_35:_UpdateHologram(p39)
    end)
    v_u_1:GetInstanceAddedSignal("LobbyArcadePrompt"):Connect(function(p40)
        p_u_35:_PromptAdded(p40)
    end)
    for _, v41 in pairs(v_u_1:GetTagged("LobbyArcadePrompt")) do
        task.defer(p_u_35._PromptAdded, p_u_35, v41)
    end
    for _, v42 in pairs(v_u_11.Objects) do
        task.defer(p_u_35._DuelAdded, p_u_35, v42)
    end
    task.defer(p_u_35._HookLocalFighter, p_u_35)
end
return v_u_14._new()
