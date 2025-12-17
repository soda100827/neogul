return function(Globals)
local Library = Globals.Library
local Toggles = Library.Toggles
local Options = Library.Options

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Aimbot FOV Circle
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = false
FOVCircle.Radius = 150
FOVCircle.Position = Vector2.new(0, 0)

local function GetClosestPlayerToCursor()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do 
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local targetPartName = Options.AimbotTargetPart.Value
            
            if targetPartName == 'Random' then
                targetPartName = (math.random() > 0.5) and 'Head' or 'HumanoidRootPart'
            elseif targetPartName == 'Torso' then
                targetPartName = 'HumanoidRootPart' -- R15
            end
            
            local targetPart = character and character:FindFirstChild(targetPartName)

            if character and humanoid and humanoid.Health > 0 and targetPart then
                -- Team Check
                if Toggles.AimbotTeamCheck.Value and player.Team == LocalPlayer.Team then
                    continue
                end

                local screenPoint, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                local mouseLocation = UserInputService:GetMouseLocation()
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - mouseLocation).Magnitude

                if onScreen and distance < Options.AimbotFOV.Value then
                    -- Wall Check
                    if Toggles.AimbotWallCheck.Value then
                        local rayParams = RaycastParams.new()
                        rayParams.FilterDescendantsInstances = {LocalPlayer.Character, character}
                        rayParams.FilterType = Enum.RaycastFilterType.Exclude
                        
                        local rayResult = workspace:Raycast(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 500, rayParams)
                        
                        if rayResult then
                            continue -- Hit a wall
                        end
                    end

                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = targetPart
                    end
                end
            end
        end
    end
    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    -- Update FOV Circle
    local mouseLocation = UserInputService:GetMouseLocation()
    -- Check if keys exist before accessing, to prevent errors during unload/load
    if Toggles.AimbotEnabled and Options.AimbotFOV then
        FOVCircle.Visible = Toggles.AimbotEnabled.Value
        FOVCircle.Radius = Options.AimbotFOV.Value
        FOVCircle.Position = mouseLocation
        
        if Toggles.AimbotEnabled.Value and Options.AimbotKey:GetState() then
            local target = GetClosestPlayerToCursor()
            if target then
                local screenPoint, onScreen = Camera:WorldToViewportPoint(target.Position)
                
                if onScreen then
                    local relativeX = (screenPoint.X - mouseLocation.X)
                    local relativeY = (screenPoint.Y - mouseLocation.Y)
                    local smoothValue = Options.AimbotSmoothness.Value
                    
                    mousemoverel(relativeX / smoothValue, relativeY / smoothValue)
                end
            end
        end
    end
end)

Library:OnUnload(function()
    FOVCircle:Remove()
end)

-- Device Spoofing
local function UpdateCombatDeviceSpoof()
    if not (Toggles.SpoofDevice and Options.DeviceSelector) then return end
    
    if Toggles.SpoofDevice.Value then
        local mapping = {
            ['MouseKeyboard'] = 'MouseKeyboard',
            ['Controller'] = 'Gamepad',
            ['Mobile'] = 'Touch',
            ['VR'] = 'VR'
        }
        local mode = mapping[Options.DeviceSelector.Value]
        if mode then
            game:GetService("ReplicatedStorage").Remotes.Replication.Fighter.SetControls:FireServer(mode)
        end
    end
end

if Toggles.SpoofDevice then Toggles.SpoofDevice:OnChanged(UpdateCombatDeviceSpoof) end
if Options.DeviceSelector then Options.DeviceSelector:OnChanged(UpdateCombatDeviceSpoof) end

task.spawn(function()
    local success, ControlsController = pcall(function()
        return require(game:GetService("Players").LocalPlayer.PlayerScripts.Controllers.ControlsController)
    end)
    if success and ControlsController then
        ControlsController.ControlsChanged:Connect(UpdateCombatDeviceSpoof)
    end
end)

-- Sound Spammer
task.spawn(function()
    while true do
        task.wait(1)
        if Toggles.SoundSpammer and Toggles.SoundSpammer.Value and Options.SoundSelector then
            local sound = Options.SoundSelector.Value
            if sound then
                game:GetService("ReplicatedStorage").Remotes.Replication.Fighter.PlayMechanicsSound:FireServer(unpack({sound}))
            end
        end
    end
end)
end
