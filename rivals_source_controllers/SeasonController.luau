local v_u_1 = game:GetService("ReplicatedStorage")
local v_u_2 = require(v_u_1.Modules.SeasonLibrary)
local v_u_3 = require(v_u_1.Modules.Utility)
local v_u_4 = {}
v_u_4.__index = v_u_4
function v_u_4._new()
    local v5 = v_u_4
    local v6 = setmetatable({}, v5)
    v6._last_update = -1
    v6._time_remaining = nil
    v6:_Init()
    return v6
end
function v_u_4.GetTimeRemaining(p7)
    if not p7._time_remaining then
        return nil
    end
    local v8 = p7._time_remaining - (tick() - p7._last_update)
    local v9 = math.ceil(v8)
    return math.max(0, v9)
end
function v_u_4.GetCountdownText(p10)
    local v11 = p10:GetTimeRemaining()
    if not v11 then
        return nil
    end
    local v12 = v11 <= 0 and "" or "in "
    local v13 = v11 <= 0 and "ANY SECOND NOW" or v_u_3:TimeFormat2((math.ceil(v11)))
    return string.format("Season %s ends %s<font color=\"rgb(255,50,50)\" weight=\"700\">%s</font>", v_u_2.CurrentSeason.Version, v12, v13)
end
function v_u_4._UpdateTimer(p14, p15)
    p14._last_update = tick()
    p14._time_remaining = p15
end
function v_u_4._Fetch(p16)
    p16:_UpdateTimer(v_u_1.Remotes.Misc.RequestSeasonTimer:InvokeServer())
end
function v_u_4._Init(p_u_17)
    v_u_1.Remotes.Misc.UpdateSeasonTimer.OnClientEvent:Connect(function(p18)
        p_u_17:_UpdateTimer(p18)
    end)
    task.defer(p_u_17._Fetch, p_u_17)
end
return v_u_4._new()
