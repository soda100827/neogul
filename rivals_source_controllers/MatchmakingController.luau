local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("Players")
local v_u_3 = require(v_u_1.Modules.CONSTANTS)
local v_u_4 = require(v_u_1.Modules.ReplicatedClass)
require(v_u_1.Modules.Utility)
local v_u_5 = require(v_u_1.Modules.Signal)
local v_u_6 = require(v_u_2.LocalPlayer.PlayerScripts.Controllers.PlayerDataController)
local v_u_7 = {
    "ServerRegion",
    "MatchmadeStatus",
    "MatchmadeExpectedPlayers",
    "MatchmadeConnectedPlayers",
    "MatchmadeGameOver",
    "MatchmadeCountdown",
    "MatchmadeRematchAvailable",
    "MatchmadeRematchCount",
    "MatchmadeRematchGoal",
    "MatchmadeRematchSuccess"
}
local v_u_8 = setmetatable({}, v_u_4)
v_u_8.__index = v_u_8
function v_u_8._new()
    local v9 = v_u_4.new()
    local v10 = v_u_8
    local v11 = setmetatable(v9, v10)
    v11.PartyChanged = v_u_5.new()
    v11.FriendsFetched = v_u_5.new()
    v11.MatchmadeDuelEnded = v_u_5.new()
    v11.RematchDetailsChanged = v_u_5.new()
    v11.CurrentParty = nil
    v11.Friends = {}
    v11._is_friends_with = {}
    v11:_Init()
    return v11
end
function v_u_8.IsMatchmadeDuelOver(p12)
    local v13 = v_u_3.IS_MATCHMAKING_SERVER
    if v13 then
        v13 = p12:Get("MatchmadeGameOver")
    end
    return v13
end
function v_u_8.IsPartyLeader(p14)
    return not p14.CurrentParty or p14.CurrentParty[1] == v_u_2.LocalPlayer
end
function v_u_8.IsInParty(p15, p16)
    local v17 = p15.CurrentParty
    if v17 then
        v17 = table.find(p15.CurrentParty, p16)
    end
    return v17
end
function v_u_8.IsFriendsWith(p18, p19)
    local v20 = p18._is_friends_with[tostring(p19)]
    if v20 then
        return v20
    end
    local v21, v22 = pcall(v_u_2.LocalPlayer.IsFriendsWith, v_u_2.LocalPlayer, p19)
    if v21 then
        return v22
    end
    warn("Failed to check IsFriendsWith, error:", v22)
    return false
end
function v_u_8.IsRematchAvailable(p23)
    local v24 = not p23:Get("MatchmadeRematchSuccess") and (p23:Get("MatchmadeRematchCount") and p23:Get("MatchmadeRematchGoal"))
    if v24 then
        v24 = p23:Get("MatchmadeRematchAvailable")
    end
    return v24
end
function v_u_8.QueueInto(_, p25)
    return v_u_1.Remotes.Matchmaking.JoinQueue:InvokeServer(p25)
end
function v_u_8.ToArcadeServer(_)
    return v_u_1.Remotes.Arcade.TeleportToArcadeServer:InvokeServer()
end
function v_u_8._OnboardingQueue(p26)
    if not v_u_3.IS_STUDIO and (not v_u_3.IS_PRIVATE_HUB_SERVER and v_u_6:GetStatistic("StatisticDuelsPlayed") <= 0) then
        p26:QueueInto(v_u_3.BEGINNER_QUEUE_NAME)
    end
end
function v_u_8._FetchFriends(p27)
    while true do
        local v28, v29 = pcall(v_u_2.LocalPlayer.GetFriendsOnline, v_u_2.LocalPlayer, 50)
        if v28 then
            break
        end
        warn("Failed to fetch friends, error:", v29)
        wait(1)
    end
    p27.Friends = v29
    for _, v30 in pairs(p27.Friends) do
        local v31 = p27._is_friends_with
        local v32 = v30.VisitorId
        v31[tostring(v32)] = true
    end
    p27.FriendsFetched:Fire()
end
function v_u_8._FetchParty(_)
    v_u_1.Remotes.Matchmaking.RequestOneTimePartyReplication:FireServer()
end
function v_u_8._Setup(p_u_33)
    for _, v_u_34 in pairs(v_u_7) do
        local v_u_35 = string.find(v_u_34, "Rematch")
        workspace:GetAttributeChangedSignal(v_u_34):Connect(function()
            p_u_33:SetReplicate(v_u_34, workspace:GetAttribute(v_u_34))
            if v_u_35 then
                p_u_33.RematchDetailsChanged:Fire()
            end
        end)
        p_u_33:SetReplicate(v_u_34, workspace:GetAttribute(v_u_34))
    end
end
function v_u_8._Init(p_u_36)
    v_u_1.Remotes.Matchmaking.UpdateParty.OnClientEvent:Connect(function(p37)
        p_u_36.CurrentParty = p37
        p_u_36.PartyChanged:Fire()
    end)
    p_u_36:GetDataChangedSignal("MatchmadeGameOver"):Connect(function()
        p_u_36.MatchmadeDuelEnded:Fire()
    end)
    p_u_36:_Setup()
    task.defer(p_u_36._FetchParty, p_u_36)
    task.defer(p_u_36._FetchFriends, p_u_36)
    task.defer(p_u_36._OnboardingQueue, p_u_36)
end
return v_u_8._new()
