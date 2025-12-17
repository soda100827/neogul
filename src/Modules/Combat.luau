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
-- Ragebot & Target Strafe Implementation
local function GetRagebotTarget()
    local closestPlayer = nil
    local shortestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do 
        if player ~= LocalPlayer then
            local character = player.Character
            local humanoid = character and character:FindFirstChild("Humanoid")
            local root = character and character:FindFirstChild("HumanoidRootPart")

            if character and humanoid and humanoid.Health > 0 and root then
                -- Team Check
                if Toggles.Ragebot and Toggles.AimbotTeamCheck.Value and player.Team == LocalPlayer.Team then
                    continue
                end
                
                -- Ragebot has no FOV limit usually, or uses a large one. 
                -- We select based on distance for now, or visibility if wallcheck is considered.
                local distance = (root.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                
                if distance < shortestDistance then
                    shortestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end
    return closestPlayer
end

-- Star Pattern Target Strafe
local strafeAngle = 0
RunService.RenderStepped:Connect(function(deltaTime)
    local target = nil
    
    -- Determine target for Strafe
    if Toggles.Ragebot and Toggles.Ragebot.Value then
        target = GetRagebotTarget()
    elseif Toggles.TargetStrafe and Toggles.TargetStrafe.Value and Options.TargetStrafeKey:GetState() then
         -- Manual Target Strafe (Legit)
         target = GetClosestPlayerToCursor()
         if not target then 
             local p = GetRagebotTarget()
             if p and p.Character then target = p.Character.HumanoidRootPart end
         end
    end

    local useStrafe = (Toggles.Ragebot and Toggles.Ragebot.Value and Toggles.TargetStrafeRage and Toggles.TargetStrafeRage.Value and target)
                   or (Toggles.TargetStrafe and Toggles.TargetStrafe.Value and Options.TargetStrafeKey:GetState() and target)

    if useStrafe then
        local targetRoot = (typeof(target) == "Instance" and target:IsA("Player")) and target.Character.HumanoidRootPart or target
        if targetRoot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local root = LocalPlayer.Character.HumanoidRootPart
            
            local speed = Options.TargetStrafeSpinSpeed.Value
            local xOff = Options.TargetStrafeXOffset.Value
            local yOff = Options.TargetStrafeYOffset.Value
            
            strafeAngle = strafeAngle + (deltaTime * speed)
            
            -- Star Pattern / Erratic Movement
            local dynamicRadius = xOff * 5 + (math.sin(strafeAngle * 3) * 5)
            local dynamicHeight = yOff * 5 + (math.cos(strafeAngle * 5) * 3)
            
            local offset = Vector3.new(
                math.cos(strafeAngle) * dynamicRadius,
                dynamicHeight,
                math.sin(strafeAngle) * dynamicRadius
            )
            
            local newPos = targetRoot.Position + offset
            
            if LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = true
            end
            
            root.CFrame = CFrame.new(newPos, targetRoot.Position)
            root.Velocity = Vector3.new(0,0,0)
        else
             if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.PlatformStand = false
            end
        end
    else
         if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.PlatformStand = false
        end
    end
end)


-- Silent Aim Hook (Universal-ish)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if Toggles.Ragebot and Toggles.Ragebot.Value or (Toggles.AimbotEnabled and Toggles.AimbotEnabled.Value) then
       -- Hook generic projectile/cast methods
       if method == "FireServer" and (string.find(self.Name, "Bullet") or string.find(self.Name, "Cast") or string.find(self.Name, "Fire") or string.find(self.Name, "Shoot") or string.find(self.Name, "Hit")) then
            local target = GetRagebotTarget()
            if target and target.Character and target.Character:FindFirstChild("Head") then
                local headPos = target.Character.Head.Position
                
                 for i, v in pairs(args) do
                    if typeof(v) == "Vector3" then
                        -- Replace direction vector
                        -- We assume the vector with largest magnitude or unit vector is the direction
                        args[i] = (headPos - Camera.CFrame.Position).Unit * v.Magnitude 
                    elseif typeof(v) == "CFrame" then
                        -- Replace CFrame lookAt
                         args[i] = CFrame.new(args[i].Position, headPos)
                    end
                end
                
                return oldNamecall(self, unpack(args))
            end
       end
    end
    
    return oldNamecall(self, ...)
end)

-- Auto Fire (Using MechanicsController)
task.spawn(function()
    local MechanicsController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
    
    while true do
        task.wait(0.1) -- Fire rate
        if Toggles.Ragebot and Toggles.Ragebot.Value then
            local target = GetRagebotTarget()
            if target then
                -- Use the game's internal controller to fire
                if MechanicsController then
                    MechanicsController:EquippedItemInput("StartShooting")
                    -- Short delay simulating click duration, might not be needed for full auto, but safe
                    task.wait(0.05) 
                    MechanicsController:EquippedItemInput("FinishShooting")
                end
            end
        end
    end
end)

end
