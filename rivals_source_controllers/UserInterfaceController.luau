local v1 = game:GetService("ReplicatedStorage")
local v_u_2 = game:GetService("GamepadService")
local v_u_3 = game:GetService("GuiService")
local v_u_4 = game:GetService("Players")
local v_u_5 = require(v1.Modules.InputLibrary)
local v_u_6 = require(v1.Modules.Utility)
local v_u_7 = require(v1.Modules.Signal)
local v_u_8 = require(v_u_4.LocalPlayer.PlayerScripts.Controllers.ControlsController)
local v_u_9 = v_u_4.LocalPlayer.PlayerScripts.Modules:WaitForChild("UserInterface")
local v_u_10 = v_u_4.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("MainGui")
local v_u_11 = {
    "PurchasePrompt",
    "MobileButtons",
    "Inset",
    "SwitchCameraPOV",
    "Pages",
    "Panels",
    "Equipment",
    "Queue",
    "EliminatedEffect",
    "Spectate",
    "HUD",
    "Lobby",
    "Notifications",
    "SideTasks",
    "Teleporting",
    "ShootingRange",
    "MatchmadeOverlay",
    "Spotlight",
    "JoystickModal",
    "SideParty",
    "BossHealth",
    "Shutdown"
}
local v_u_12 = {}
v_u_12.__index = v_u_12
function v_u_12._new()
    local v13 = v_u_12
    local v14 = setmetatable({}, v13)
    v14.MainGui = v_u_10
    v14.Elements = {}
    v14._selected_object_connections = {}
    v14._gamepad_connections = {}
    v14._elements_loaded = false
    v14._elements_loaded_internal = v_u_7.new()
    v14:_Init()
    return v14
end
function v_u_12.GetDefaultElement(p15)
    return p15.Elements.Pages and p15.Elements.Pages:GetDefaultElement() or nil
end
function v_u_12.WaitUntilLoaded(p16)
    if not p16._elements_loaded then
        p16._elements_loaded_internal:Wait()
    end
end
function v_u_12.CloseRequest(p17)
    if p17.Elements.Pages and p17.Elements.Pages.PageSystem.CurrentPage then
        if not p17.Elements.Pages.PageSystem.CurrentPage.CantBeClosedFromInputs then
            p17.Elements.Pages:CloseRequest()
        end
        return
    elseif p17.Elements.Equipment and p17.Elements.Equipment.IsOpen then
        p17.Elements.Equipment:CloseRequest()
        return
    else
        local v18 = p17:_GetSpectatedDuelInterface()
        if v18 and (v18.FinalResults.Buttons.LeaveFrame.Visible or v18.FinalResults.Buttons.ContinueFrame.Visible) then
            if v18.FinalResults.Buttons.ContinueFrame.Visible then
                v18.FinalResults.Buttons:Continue()
            else
                v18.FinalResults.Buttons:LeaveRequest()
            end
        else
            return
        end
    end
end
function v_u_12.PrimaryAction(p19)
    if p19.Elements.Lobby and (p19.Elements.Lobby.Play and (p19.Elements.Lobby.Play.IsPlayVisible and v_u_6:IsUIElementVisible(p19.Elements.Lobby.Play.PlayButton))) then
        p19.Elements.Lobby.Play:OpenPlayPage()
        return
    else
        local v20 = p19:_GetSpectatedDuelInterface()
        if v20 and v20.FinalResults.Buttons.PlayAgainFrame.Visible then
            v20.FinalResults.Buttons:PlayAgain()
        end
    end
end
function v_u_12.SecondaryAction(p21)
    if p21.Elements.Pages then
        local v22 = p21:_GetSpectatedDuelInterface()
        if v22 and v22.FinalResults.Buttons.RematchFrame.Visible then
            v22.FinalResults.Buttons:Rematch()
        else
            local v23 = p21:_GetSpectatedSubject()
            if v23 then
                v23 = v23:Get("IsInShootingRange") or v23:Get("IsInDuel")
            end
            if not (p21.Elements.Pages.PageSystem.CurrentPage or v23) or p21.Elements.Pages.PageSystem.CurrentPage and p21.Elements.Pages.PageSystem.CurrentPage.Name ~= "Party" then
                local v24 = p21.Elements.Lobby and p21.Elements.Lobby.Party
                if v24 then
                    v24 = p21.Elements.Lobby.Party.IsVisible
                end
                local v25 = p21.Elements.SideParty
                if v25 then
                    v25 = p21.Elements.SideParty.IsVisible
                end
                if v24 or v25 then
                    p21.Elements.Pages.PageSystem:OpenPage("Party", true)
                    return
                end
            end
        end
    else
        return
    end
end
function v_u_12.TertiaryAction(p26)
    if p26.Elements.Lobby and (p26.Elements.Lobby.Play and (p26.Elements.Lobby.Play.IsHubVisible and v_u_6:IsUIElementVisible(p26.Elements.Lobby.Play.HubButton))) then
        p26.Elements.Lobby.Play:GoBackToHub()
    end
end
function v_u_12.QuaternaryAction(p27)
    if p27.Elements.Lobby and (p27.Elements.Lobby.Play and (p27.Elements.Lobby.Play.IsRematchVisible and v_u_6:IsUIElementVisible(p27.Elements.Lobby.Play.RematchButton))) then
        p27.Elements.Lobby.Play:RematchRequest()
    end
end
function v_u_12._GetSpectatedSubject(_)
    return require(v_u_4.LocalPlayer.PlayerScripts.Controllers.SpectateController).TrueCurrentSubject
end
function v_u_12._GetSpectatedDuelInterface(_)
    local v28 = require(v_u_4.LocalPlayer.PlayerScripts.Controllers.SpectateController)
    local v29 = v28.CurrentDuelSubject
    if v29 then
        v29 = v28.CurrentDuelSubject.DuelInterface
    end
    return v29
end
function v_u_12._CheckSelectedObjectVisible(_)
    if v_u_3.SelectedObject and not v_u_6:IsUIElementVisible(v_u_3.SelectedObject) then
        v_u_2:DisableGamepadCursor()
    end
end
function v_u_12._UpdateSelectedObject(p_u_30)
    if v_u_4.LocalPlayer:FindFirstChild("PlayerGui") then
        if v_u_3.SelectedObject then
            for _, v31 in pairs(p_u_30._selected_object_connections) do
                v31:Disconnect()
            end
            p_u_30._selected_object_connections = {}
            local v32 = p_u_30._selected_object_connections
            local v33 = v_u_3.SelectedObject.AncestryChanged
            table.insert(v32, v33:Connect(function()
                p_u_30:_CheckSelectedObjectVisible()
            end))
            local v34 = p_u_30._selected_object_connections
            local v35 = v_u_3.SelectedObject:GetPropertyChangedSignal("Visible")
            table.insert(v34, v35:Connect(function()
                p_u_30:_CheckSelectedObjectVisible()
            end))
            p_u_30:_CheckSelectedObjectVisible()
            return
        else
            local v36 = p_u_30:GetDefaultElement()
            local v37
            if v36 and (v36:IsDescendantOf(v_u_4.LocalPlayer.PlayerGui) and v36) then
                v37 = v36
            else
                v37 = nil
            end
            if v36 then
                v_u_2:EnableGamepadCursor(v37)
                v_u_3.SelectedObject = v37
            else
                v_u_2:DisableGamepadCursor()
                v_u_3.SelectedObject = nil
            end
        end
    else
        return
    end
end
function v_u_12._UpdateGamepadControls(p38)
    for _, v39 in pairs(p38._gamepad_connections) do
        v39:Disconnect()
    end
    for _, v40 in pairs(p38._selected_object_connections) do
        v40:Disconnect()
    end
    p38._gamepad_connections = {}
    p38._selected_object_connections = {}
    if v_u_8.CurrentControls ~= "Gamepad" then
    end
end
function v_u_12._Setup(p_u_41)
    task.defer(function()
        for _, v42 in pairs(v_u_11) do
            p_u_41.Elements[v42] = require(v_u_9:WaitForChild(v42))
        end
        p_u_41._elements_loaded = true
        p_u_41._elements_loaded_internal:Fire()
    end)
    p_u_41.MainGui.Parent = v_u_4.LocalPlayer:WaitForChild("PlayerGui")
end
function v_u_12._Init(p_u_43)
    v_u_8.ControlsChanged:Connect(function()
        p_u_43:_UpdateGamepadControls()
    end)
    v_u_8.InputBegan:Connect(function(p44, p45)
        if p45 then
            return
        elseif v_u_5:InputIs(p44, "UICancelAction") then
            p_u_43:CloseRequest()
            return
        elseif v_u_5:InputIs(p44, "UIPrimaryAction") then
            p_u_43:PrimaryAction()
            return
        elseif v_u_5:InputIs(p44, "UISecondaryAction") then
            p_u_43:SecondaryAction()
            return
        elseif v_u_5:InputIs(p44, "UITertiaryAction") then
            p_u_43:TertiaryAction()
        elseif v_u_5:InputIs(p44, "UIQuaternaryAction") then
            p_u_43:QuaternaryAction()
        end
    end)
    p_u_43:_Setup()
    p_u_43:_UpdateGamepadControls()
end
return v_u_12._new()
