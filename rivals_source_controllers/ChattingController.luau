game:GetService("ReplicatedStorage")
local v_u_1 = game:GetService("TextChatService")
local v_u_2 = game:GetService("Players")
local v_u_3 = require(v_u_2.LocalPlayer.PlayerScripts.Controllers.DuelController)
local v_u_4 = {
    {
        ["Result"] = "GG \226\157\164\239\184\143",
        ["Words"] = { "ggez" },
        ["Messages"] = {}
    },
    {
        ["Result"] = "you played well",
        ["Words"] = {
            "ur bad",
            "ur so bad",
            "you are so bad",
            "you are bad",
            "horrible"
        },
        ["Messages"] = {}
    },
    {
        ["Result"] = "W update \226\157\164\239\184\143",
        ["Words"] = { "l update" },
        ["Messages"] = {}
    },
    {
        ["Result"] = "well played \240\159\145\141",
        ["Words"] = { "gg ez" },
        ["Messages"] = { "ez" }
    },
    {
        ["Result"] = "nice loadout",
        ["Words"] = { "p2w", "pay to win", "pay 2 win" },
        ["Messages"] = {}
    }
}
local v_u_5 = {}
v_u_5.__index = v_u_5
function v_u_5._new()
    local v6 = v_u_5
    local v7 = setmetatable({}, v6)
    v7:_Init()
    return v7
end
function v_u_5._DuelInterfaceBubble(_, p8, p9)
    if p8 then
        local v10 = {}
        for _, v11 in pairs(v_u_3.Objects) do
            if v11:GetDueler(p8) then
                table.insert(v10, v11)
            end
        end
        if #v10 ~= 0 then
            for _, v12 in pairs(v10) do
                v12.DuelInterface.Scores:DisplayBubbleChat(p8, p9)
            end
        end
    else
        return
    end
end
function v_u_5._OnIncomingMessage(_, p13)
    if not p13.TextSource then
        return
    end
    local v14 = p13.Text
    local v15 = false
    for _, v16 in pairs(v_u_4) do
        if table.find(v16.Messages, string.lower(v14)) then
            v14 = v16.Result
            v15 = true
            break
        end
    end
    if v15 then
        ::l9::
        if v14 ~= p13.Text then
            local v17 = Instance.new("TextChatMessageProperties")
            v17.Text = v14
            return v17
        end
        return
    else
        while true do
            local v18 = false
            for _, v19 in pairs(v_u_4) do
                for _, v20 in pairs(v19.Words) do
                    local v21 = string.find(string.lower(v14), v20)
                    if v21 then
                        local v22 = v21 - 1
                        local v23 = string.sub(v14, 1, v22)
                        local v24 = v19.Result
                        local v25 = v21 + #v20
                        v14 = v23 .. v24 .. string.sub(v14, v25)
                        v18 = true
                    end
                end
            end
            if not v18 then
                goto l9
            end
        end
    end
end
function v_u_5._Init(p_u_26)
    function v_u_1.OnIncomingMessage(p27)
        local v28 = p_u_26:_OnIncomingMessage(p27)
        if p27.Status == Enum.TextChatMessageStatus.Success then
            local v29 = p27.TextSource and p27.TextSource.UserId
            if v29 then
                v29 = v_u_2:GetPlayerByUserId(p27.TextSource.UserId)
            end
            local v30 = v28 and v28.Text or p27.Text
            task.defer(p_u_26._DuelInterfaceBubble, p_u_26, v29, v30)
        end
        return v28
    end
end
return v_u_5._new()
