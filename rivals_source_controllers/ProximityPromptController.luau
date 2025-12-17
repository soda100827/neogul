local v_u_1 = game:GetService("ProximityPromptService")
local v2 = game:GetService("ReplicatedStorage")
local v_u_3 = game:GetService("Players")
local v_u_4 = require(v2.Modules.BetterDebris)
local v_u_5 = require(v2.Modules.ItemLibrary)
local v_u_6 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers:WaitForChild("ControlsController"))
local v_u_7 = require(v_u_3.LocalPlayer.PlayerScripts.Controllers:WaitForChild("SpectateController"))
local v_u_8 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("MobileButtons"))
local v_u_9 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Teleporting"))
local v_u_10 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Shutdown"))
local v_u_11 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Queue"))
local v_u_12 = require(v_u_3.LocalPlayer.PlayerScripts.Modules.UserInterface:WaitForChild("Pages"))
local v_u_13 = require(v_u_3.LocalPlayer.PlayerScripts.Modules:WaitForChild("WeaponStatusHandler"))
local v_u_14 = require(v_u_3.LocalPlayer.PlayerScripts.Modules:WaitForChild("ButtonEffect"))
local v_u_15 = v_u_3.LocalPlayer.PlayerScripts.UserInterface:WaitForChild("ProximityPrompts")
local v_u_16 = {}
v_u_16.__index = v_u_16
function v_u_16._new()
    local v17 = v_u_16
    local v18 = setmetatable({}, v17)
    v18._custom_prompt = nil
    v18._custom_prompt_hash = 0
    v18._custom_prompt_connections = {}
    v18:_Init()
    return v18
end
function v_u_16._UpdateEnabled(_)
    local v19 = v_u_1
    local v20 = not (v_u_7.CurrentDuelSubject or (v_u_8.EditorEnabled or v_u_12.PageSystem.CurrentPage or (v_u_9.Enabled or v_u_10.Enabled)))
    if v20 then
        v20 = not v_u_11:IsVisible()
    end
    v19.Enabled = v20
end
function v_u_16._Cleanup(p21)
    p21._custom_prompt_hash = p21._custom_prompt_hash + 1
    for _, v22 in pairs(p21._custom_prompt_connections) do
        v22:Disconnect()
    end
    p21._custom_prompt_connections = {}
    if p21._custom_prompt then
        v_u_4:AddItem(p21._custom_prompt, 0.15)
        if p21._custom_prompt:FindFirstChild("Button") and p21._custom_prompt:IsDescendantOf(v_u_3) then
            p21._custom_prompt.Button:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Quint", 0.25, true)
        end
        p21._custom_prompt = nil
    end
end
function v_u_16._Create(p_u_23, p_u_24)
    p_u_23:_Cleanup()
    p_u_24:SetAttribute("ClickablePrompt", p_u_24.ClickablePrompt)
    p_u_24.ClickablePrompt = v_u_6.CurrentControls == "Touch" and true or p_u_24:GetAttribute("ClickablePrompt")
    p_u_23._custom_prompt_hash = p_u_23._custom_prompt_hash + 1
    local v_u_25 = p_u_23._custom_prompt_hash
    local v26 = v_u_15[p_u_24:GetAttribute("Style") or "Default"]
    p_u_23._custom_prompt = v26:Clone()
    p_u_23._custom_prompt.Name = "ProximityPrompt - " .. v26.Name
    p_u_23._custom_prompt.Button.Inputs.MouseKeyboard.KeyText.Text = p_u_24.KeyboardKeyCode.Name
    p_u_23._custom_prompt.Button.Inputs.Gamepad.Container:SetAttribute("EnumType", "KeyCode")
    p_u_23._custom_prompt.Button.Inputs.Gamepad.Container:SetAttribute("EnumName", p_u_24.GamepadKeyCode.Name)
    p_u_23._custom_prompt.Button.Inputs.Gamepad.Container:AddTag("UIKeybindContainer")
    p_u_23._custom_prompt.Button.Interactable = p_u_24.ClickablePrompt
    p_u_23._custom_prompt.Adornee = p_u_24.Parent
    p_u_23._custom_prompt.Parent = v_u_3.LocalPlayer.PlayerGui
    local function v30()
        p_u_23._custom_prompt.Button.ObjectText.Text = p_u_24.ObjectText
        p_u_23._custom_prompt.Button.ActionText.Text = p_u_24.ActionText
        v_u_13:ClearStatusElements(p_u_23._custom_prompt.Button.ObjectText)
        local v27 = v_u_13
        local v28 = p_u_23._custom_prompt.Button.ObjectText
        local v29 = v_u_5.Items[p_u_24.ObjectText]
        if v29 then
            v29 = v_u_5.Items[p_u_24.ObjectText].Status
        end
        v27:ApplyItemStatusToText(v28, v29)
    end
    local v31 = p_u_23._custom_prompt_connections
    local v32 = p_u_24:GetPropertyChangedSignal("ObjectText")
    table.insert(v31, v32:Connect(v30))
    local v33 = p_u_23._custom_prompt_connections
    local v34 = p_u_24:GetPropertyChangedSignal("ActionText")
    table.insert(v33, v34:Connect(v30))
    v30()
    p_u_23._custom_prompt.Button.Size = UDim2.new(p_u_23._custom_prompt.Button.Size.X.Scale * 0.5, p_u_23._custom_prompt.Button.Size.X.Offset * 0.5, p_u_23._custom_prompt.Button.Size.Y.Scale * 0.5, p_u_23._custom_prompt.Button.Size.Y.Offset * 0.5)
    p_u_23._custom_prompt.Button:TweenSize(v26.Button.Size, "Out", "Quint", 0.25, true, function()
        if p_u_23._custom_prompt_hash == v_u_25 and p_u_24.ClickablePrompt then
            p_u_23._custom_prompt.Button.MouseButton1Down:Connect(function()
                p_u_24:InputHoldBegin()
            end)
            p_u_23._custom_prompt.Button.MouseButton1Up:Connect(function()
                p_u_24:InputHoldEnd()
            end)
            p_u_23._custom_prompt.Button.MouseLeave:Connect(function()
                p_u_24:InputHoldEnd()
            end)
            v_u_14:Add(p_u_23._custom_prompt.Button, nil, {
                ["DontReposition"] = true
            })
        end
    end)
    p_u_23:_UpdateEnabled()
end
function v_u_16._Init(p_u_35)
    v_u_1.PromptShown:Connect(function(p36)
        if p36.Style == Enum.ProximityPromptStyle.Custom then
            p_u_35:_Create(p36)
        end
    end)
    v_u_1.PromptHidden:Connect(function(p37)
        if p37.Style == Enum.ProximityPromptStyle.Custom then
            p_u_35:_Cleanup()
        end
    end)
    v_u_12.PageSystem.PageOpened:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_12.PageSystem.PageClosed:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_9.EnabledChanged:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_10.EnabledChanged:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_11.VisibilityChanged:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_7.DuelSubjectChanged:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    v_u_8.EditorEnabledChanged:Connect(function()
        p_u_35:_UpdateEnabled()
    end)
    p_u_35:_UpdateEnabled()
end
return v_u_16._new()
