local v_u_1 = game:GetService("ReplicatedStorage")
game:GetService("StarterGui")
local v_u_2 = game:GetService("RunService")
local v_u_3 = game:GetService("Players")
local v_u_4 = require(v_u_1.Modules.CONSTANTS)
local v_u_5 = require(v_u_1.Modules.InputLibrary)
local v_u_6 = require(v_u_1.Modules.Signal)
local v_u_7 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local v_u_8 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers.FighterController)
local v_u_9 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers.CameraController)
local v_u_10 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers.DuelController)
local v_u_11 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface.Teleporting)
local v_u_12 = {}
v_u_12.__index = v_u_12
function v_u_12._new()
    local v13 = v_u_12
    local v14 = setmetatable({}, v13)
    v14.SubjectChanged = v_u_6.new()
    v14.SubjectAdded = v_u_6.new()
    v14.SubjectRemoved = v_u_6.new()
    v14.DuelSubjectChanged = v_u_6.new()
    v14.DuelSubjectEnvironmentIDChanged = v_u_6.new()
    v14.DuelSubjectStatusChanged = v_u_6.new()
    v14.SubjectEmoteStatusChanged = v_u_6.new()
    v14.Subjects = {}
    v14.CurrentSubject = nil
    v14.TrueCurrentSubject = nil
    v14.CurrentDuelSubject = nil
    v14._duel_connections = {}
    v14._true_subject_connections = {}
    v14._last_spectating_user_id = nil
    v14._spectate_duel_request_queue = {}
    v14._spectate_duel_request_queue_active = false
    v14:_Init()
    return v14
end
function v_u_12.IsRendered(p15, p16)
    local v17 = not v_u_4.IS_ARCADE_SERVER and (v_u_3.LocalPlayer:GetAttribute("EnvironmentID") ~= p16 and p15.CurrentDuelSubject)
    if v17 then
        v17 = p15.CurrentDuelSubject:Get("EnvironmentID") == p16
    end
    return v17
end
function v_u_12.IsSubjectEmoting(p18)
    local v19 = p18.TrueCurrentSubject and p18.TrueCurrentSubject.Entity
    if v19 then
        v19 = p18.TrueCurrentSubject.Entity:IsEmoting()
    end
    return v19
end
function v_u_12.GetLocalSubject(p20)
    for v21, v22 in pairs(p20.Subjects) do
        if v22.IsLocalPlayer then
            return v22, v21
        end
    end
end
function v_u_12.SetCurrentSubject(p23, p24, p25)
    if p24 ~= p23.CurrentSubject and table.find(p23.Subjects, p24) then
        p23.CurrentSubject = p24
        p23:_UpdateTrueSubject(p25)
    end
end
function v_u_12.Increment(p26, p27)
    local v28 = p27 == 1 and true or p27 == -1
    local v29 = "Argument 1 invalid, expected 1 or -1, got " .. tostring(p27)
    assert(v28, v29)
    if p26.CurrentSubject and #p26.Subjects >= 2 then
        local v30 = table.find(p26.Subjects, p26.CurrentSubject)
        local v31 = p27 == 1 and v30 == #p26.Subjects and 1 or (p27 == -1 and v30 == 1 and #p26.Subjects or v30 + p27)
        p26:SetCurrentSubject(p26.Subjects[v31], true)
    end
end
function v_u_12.IncrementUntilNewSubject(p32, p33)
    local v34 = p32.TrueCurrentSubject
    for _ = 1, #p32.Subjects do
        p32:Increment(p33)
        if p32.TrueCurrentSubject ~= v34 then
            break
        end
    end
end
function v_u_12.Next(p35)
    if p35.CurrentDuelSubject and not (p35.TrueCurrentSubject and p35.TrueCurrentSubject.IsLocalPlayer) then
        p35:IncrementUntilNewSubject(1)
    end
end
function v_u_12.Last(p36)
    if p36.CurrentDuelSubject and not (p36.TrueCurrentSubject and p36.TrueCurrentSubject.IsLocalPlayer) then
        p36:IncrementUntilNewSubject(-1)
    end
end
function v_u_12.Exit(p37)
    if p37.CurrentDuelSubject and not p37.CurrentDuelSubject.LocalDueler then
        p37:SpectateDuelRequest(nil)
    end
end
function v_u_12.AddSubject(p38, p39, p40)
    if not table.find(p38.Subjects, p39) then
        local v41 = p38.Subjects
        table.insert(v41, p39)
        p38.SubjectAdded:Fire(p39)
        if not p40 then
            p38:SetCurrentSubject(p39)
        end
    end
end
function v_u_12.RemoveSubject(p42, p43, _)
    if p43.IsLocalPlayer then
        return
    else
        local v44 = table.find(p42.Subjects, p43)
        if v44 then
            if p43 == p42.CurrentSubject then
                p42:Increment(-1)
            end
            table.remove(p42.Subjects, v44)
            p42.SubjectRemoved:Fire(p43)
            if p43 == p42.CurrentSubject then
                p42:SetCurrentSubject(nil)
            end
            p42:_UpdateTrueSubject()
        end
    end
end
function v_u_12.ClearSubjects(p45)
    for v46 = #p45.Subjects, 1, -1 do
        p45:RemoveSubject(p45.Subjects[v46])
    end
    p45:_UpdateTrueSubject()
end
function v_u_12.SpectateDuelRequest(p_u_47, p48)
    local v49 = v_u_10:GetDuel(v_u_3.LocalPlayer) or p48
    local v50 = p_u_47._spectate_duel_request_queue
    table.insert(v50, { v49 })
    task.spawn(function()
        if not p_u_47._spectate_duel_request_queue_active then
            p_u_47._spectate_duel_request_queue_active = true
            while #p_u_47._spectate_duel_request_queue > 0 do
                local v51 = table.remove(p_u_47._spectate_duel_request_queue, 1)
                local v52 = p_u_47.CurrentDuelSubject and p_u_47.CurrentDuelSubject:Get("ObjectID") or nil
                local v53 = v51[1] and v51[1]:Get("ObjectID") or nil
                if v53 ~= v52 then
                    v_u_1.Remotes.Replication.Fighter.SpectateDuel:FireServer(v53)
                    wait(1)
                end
            end
            p_u_47._spectate_duel_request_queue = {}
            p_u_47._spectate_duel_request_queue_active = false
        end
    end)
end
function v_u_12.SpectateDuel(p_u_54, p_u_55)
    local v56 = v_u_10:GetDuel(v_u_3.LocalPlayer)
    if v56 and p_u_55 ~= v56 then
        return
    else
        for _, v57 in pairs(p_u_54._duel_connections) do
            v57:Disconnect()
        end
        p_u_54._duel_connections = {}
        p_u_54:ClearSubjects()
        if p_u_54.CurrentDuelSubject and p_u_54.CurrentDuelSubject ~= p_u_55 then
            p_u_54.CurrentDuelSubject:SetReplicate("IsSpectating", false)
            for _, v58 in pairs(p_u_54.CurrentDuelSubject.Duelers) do
                if v58.ClientFighter then
                    v58.ClientFighter:ClearInterface()
                    v58.ClientFighter:ClearSounds(true)
                end
            end
        end
        p_u_54.CurrentDuelSubject = p_u_55
        p_u_54.DuelSubjectChanged:Fire()
        p_u_54:_UpdateTrueSubject()
        if p_u_54.CurrentDuelSubject then
            p_u_54.CurrentDuelSubject:SetReplicate("IsSpectating", true)
        end
        v_u_9.CameraState:SetCustomFreecamEnabled(false)
        if p_u_54.CurrentDuelSubject then
            local v59 = p_u_54._duel_connections
            local v60 = p_u_55:GetDataChangedSignal("EnvironmentID")
            table.insert(v59, v60:Connect(function()
                p_u_54.DuelSubjectEnvironmentIDChanged:Fire()
            end))
            local v61 = p_u_54._duel_connections
            local v62 = p_u_55:GetDataChangedSignal("Status")
            table.insert(v61, v62:Connect(function()
                p_u_54.DuelSubjectStatusChanged:Fire()
            end))
            local function v_u_71()
                local v63 = p_u_54.CurrentDuelSubject.LocalDueler
                if v63 then
                    v63 = p_u_54.CurrentDuelSubject.LocalDueler:Get("TeamID")
                end
                if not v63 then
                    local v64 = {}
                    for _, v65 in pairs(p_u_55.Duelers) do
                        if not table.find(p_u_54.Subjects, v65.ClientFighter) then
                            p_u_54:AddSubject(v65.ClientFighter, true)
                        end
                        v64[v65.ClientFighter] = true
                    end
                    for _, v66 in pairs(p_u_54.Subjects) do
                        if not (v66.IsLocalPlayer or v64[v66]) then
                            p_u_54:RemoveSubject(v66, true)
                        end
                    end
                    p_u_54:_UpdateTrueSubject()
                    return
                end
                p_u_54:ClearSubjects()
                local v67 = false
                if not p_u_55:Get("IsCurrentArcadeDuel") then
                    for _, v68 in pairs(p_u_55.Duelers) do
                        if v68:Get("TeamID") == v63 and v68:IsAlive() then
                            v67 = true
                            break
                        end
                    end
                end
                local v69 = p_u_55:Get("StaggeredSpawns") and p_u_55:Get("Status") ~= "RoundFinished" and true or v67
                for _, v70 in pairs(p_u_55.Duelers) do
                    if (not v69 or v70.ClientFighter and v70:Get("TeamID") == v63) and v70:IsAlive() then
                        p_u_54:AddSubject(v70.ClientFighter, true)
                    end
                end
                p_u_54:_UpdateTrueSubject()
            end
            local v72 = p_u_54._duel_connections
            local v73 = p_u_55:GetDataChangedSignal("IsCurrentArcadeDuel")
            table.insert(v72, v73:Connect(v_u_71))
            local v74 = p_u_54._duel_connections
            local v75 = p_u_55:GetDataChangedSignal("Status")
            table.insert(v74, v75:Connect(v_u_71))
            local v76 = p_u_54._duel_connections
            local v77 = p_u_55.DuelerRemoved
            table.insert(v76, v77:Connect(function(p78)
                if p78.IsLocalPlayer then
                    p_u_54:SpectateDuelRequest(nil)
                else
                    v_u_71()
                end
            end))
            local function v93(p79, p80)
                local v81 = p_u_54._duel_connections
                local v82 = p79:GetDataChangedSignal("TeamID")
                local v83 = v_u_71
                table.insert(v81, v82:Connect(v83))
                local v84 = p_u_54._duel_connections
                local v85 = p79.EntityAdded
                local v86 = v_u_71
                table.insert(v84, v85:Connect(v86))
                local v87 = p_u_54._duel_connections
                local v88 = p79.Eliminated
                local v89 = v_u_71
                table.insert(v87, v88:Connect(v89))
                local v90 = p_u_54._duel_connections
                local v91 = p79.Died
                local v92 = v_u_71
                table.insert(v90, v91:Connect(v92))
                if not p80 then
                    v_u_71()
                end
            end
            local v94 = p_u_54._duel_connections
            local v95 = p_u_55.DuelerAdded
            table.insert(v94, v95:Connect(v93))
            for _, v96 in pairs(p_u_55.Duelers) do
                v93(v96, true)
            end
            v_u_71()
        end
    end
end
function v_u_12.Update(p97, p98)
    local v99 = p97.CurrentDuelSubject and p97.CurrentDuelSubject:GetFighters() or v_u_8:GetFightersNotInDuel()
    if v_u_8.LocalFighter and not table.find(v99, v_u_8.LocalFighter) then
        local v100 = v_u_8.LocalFighter
        table.insert(v99, v100)
    end
    for _, v101 in pairs(v99) do
        if v_u_4.IS_TESTING_SERVER then
            v101:Update(p98)
        else
            local v102, v103 = pcall(v101.Update, v101, p98)
            if not v102 then
                warn("ClientFighter::Update errored:", v103)
            end
        end
    end
end
function v_u_12._SpectatingReplicationLoop(p104)
    while true do
        wait(1)
        local v105 = p104.TrueCurrentSubject
        if v105 then
            v105 = p104.TrueCurrentSubject.Player.UserId
        end
        if v105 ~= p104._last_spectating_user_id then
            p104._last_spectating_user_id = v105
            v_u_1.Remotes.Replication.Fighter.Spectating:FireServer(p104._last_spectating_user_id)
        end
    end
end
function v_u_12._IsValidTrueSubject(p106, p107)
    if p107 then
        p107 = not (p107:IsAlive() and p106.CurrentDuelSubject) or (p106.CurrentDuelSubject.LocalDueler or not p107.IsLocalPlayer)
    end
    return p107
end
function v_u_12._GetTrueSubject(p108, p109)
    if v_u_9:GetPublicState() == v_u_9.CameraState.States.CustomFreecam then
        return nil
    end
    local v110 = not p108.CurrentDuelSubject or p108.CurrentDuelSubject.LocalDueler
    if v110 then
        v110 = p108:GetLocalSubject()
    end
    if v110 and v110:IsAlive() then
        return v110
    end
    if not p109 and p108:_IsValidTrueSubject(p108.TrueCurrentSubject) then
        return p108.TrueCurrentSubject
    end
    local v111 = table.find(p108.Subjects, p108.CurrentSubject) or 1
    for v112 = 1, #p108.Subjects do
        local v113 = (v111 + v112 - 2) % #p108.Subjects + 1
        local v114 = p108.Subjects[v113]
        if p108:_IsValidTrueSubject(v114) then
            return v114
        end
    end
end
function v_u_12._UpdateTrueSubject(p_u_115, p116)
    local v117 = p_u_115:_GetTrueSubject(p116)
    if v117 ~= p_u_115.TrueCurrentSubject then
        if p_u_115.TrueCurrentSubject then
            p_u_115.TrueCurrentSubject:SetReplicate("IsSpectating", false)
        end
        for _, v118 in pairs(p_u_115._true_subject_connections) do
            v118:Disconnect()
        end
        p_u_115._true_subject_connections = {}
        p_u_115.TrueCurrentSubject = v117
        if p_u_115.TrueCurrentSubject then
            local v119 = p_u_115._true_subject_connections
            local v120 = p_u_115.TrueCurrentSubject.EntityRemoved
            table.insert(v119, v120:Connect(function()
                p_u_115:_UpdateTrueSubject()
            end))
            local v121 = p_u_115._true_subject_connections
            local v122 = p_u_115.TrueCurrentSubject.Died
            table.insert(v121, v122:Connect(function()
                p_u_115:_UpdateTrueSubject()
            end))
            local v123 = p_u_115._true_subject_connections
            local v124 = p_u_115.TrueCurrentSubject.EntityAdded
            table.insert(v123, v124:Connect(function()
                local v125 = p_u_115.TrueCurrentSubject
                if v125 then
                    v125 = p_u_115.TrueCurrentSubject.Entity
                end
                if v125 then
                    local v126 = p_u_115._true_subject_connections
                    local v127 = v125.EmoteStatusChanged
                    local function v128()
                        p_u_115.SubjectEmoteStatusChanged:Fire()
                    end
                    table.insert(v126, v127:Connect(v128))
                end
                p_u_115:_UpdateTrueSubject()
            end))
            local v129 = p_u_115.TrueCurrentSubject
            if v129 then
                v129 = p_u_115.TrueCurrentSubject.Entity
            end
            if v129 then
                local v130 = p_u_115._true_subject_connections
                local v131 = v129.EmoteStatusChanged
                table.insert(v130, v131:Connect(function()
                    p_u_115.SubjectEmoteStatusChanged:Fire()
                end))
            end
            p_u_115.TrueCurrentSubject:SetReplicate("IsSpectating", true)
        end
        p_u_115.SubjectChanged:Fire()
        p_u_115.SubjectEmoteStatusChanged:Fire()
    end
end
function v_u_12._HookLocalFighter(p_u_132)
    local v_u_133 = v_u_8:WaitForLocalFighter()
    local function v135()
        local v134 = v_u_133:Get("SpectatingDuelObjectID")
        p_u_132:SpectateDuel(v134 and v_u_10:GetDuelByID(v134) or nil)
    end
    v_u_133:GetDataChangedSignal("SpectatingDuelObjectID"):Connect(v135)
    local v136 = v_u_133:Get("SpectatingDuelObjectID")
    p_u_132:SpectateDuel(v136 and v_u_10:GetDuelByID(v136) or nil)
end
function v_u_12._Init(p_u_137)
    p_u_137.SubjectChanged:Connect(function()
        v_u_9:SetSubject(p_u_137.TrueCurrentSubject)
    end)
    p_u_137.DuelSubjectChanged:Connect(function()
        v_u_9:SetDuelSubject(p_u_137.CurrentDuelSubject)
    end)
    v_u_2:BindToRenderStep("SpectateController", Enum.RenderPriority.Camera.Value + 1, function(p138)
        p_u_137:Update(p138)
    end)
    v_u_7.InputBegan:Connect(function(p139, p140)
        if p140 or v_u_9:GetPublicState() == v_u_9.CameraState.States.ThirdPersonUnlockedMouse and p139.UserInputType == Enum.UserInputType.MouseButton2 then
            return
        else
            local v141 = v_u_9:GetPublicState() == v_u_9.CameraState.States.CustomFreecam
            if v_u_5:InputIs(p139, "SpectateNext") and not v141 then
                p_u_137:Next()
                return
            elseif v_u_5:InputIs(p139, "SpectateLast") and not v141 then
                p_u_137:Last()
            elseif v_u_5:InputIs(p139, "SpectateExit") then
                p_u_137:Exit()
            end
        end
    end)
    v_u_8.ObjectAdded:Connect(function(p142)
        if p142.IsLocalPlayer then
            p142.EntityAdded:Connect(function()
                p_u_137:_UpdateTrueSubject()
            end)
            p142.EntityRemoved:Connect(function()
                p_u_137:_UpdateTrueSubject()
            end)
            p142.Died:Connect(function()
                p_u_137:_UpdateTrueSubject()
            end)
            p_u_137:AddSubject(p142)
        end
    end)
    v_u_8.ObjectRemoved:Connect(function(p143)
        p_u_137:RemoveSubject(p143)
    end)
    v_u_10.LocalPlayerJoinedDuel:Connect(function(p144, p145)
        p_u_137:SpectateDuelRequest(p144, p145)
    end)
    v_u_10.LocalPlayerLeftDuel:Connect(function(_, _)
        p_u_137:SpectateDuelRequest(nil)
    end)
    v_u_10.ObjectRemoved:Connect(function(p146)
        if p_u_137.CurrentDuelSubject == p146 then
            p_u_137:SpectateDuelRequest(nil)
        end
    end)
    v_u_9.CustomFreecamStateChanged:Connect(function()
        p_u_137:_UpdateTrueSubject()
    end)
    v_u_11.EnabledChanged:Connect(function()
        if v_u_11.Enabled then
            p_u_137:SpectateDuelRequest(nil)
        end
    end)
    p_u_137:_UpdateTrueSubject()
    task.spawn(p_u_137._HookLocalFighter, p_u_137)
    task.spawn(p_u_137._SpectatingReplicationLoop, p_u_137)
end
return v_u_12._new()
