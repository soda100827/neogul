return function(Globals)
local Library = Globals.Library
local Toggles = Library.Toggles
local Options = Library.Options

--------------------------------------------------------------------------------
-- Slide Boost Implementation
--------------------------------------------------------------------------------
task.spawn(function()
    local Players = game:GetService("Players")
    
    -- Wait for LocalPlayer and Controllers
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then 
        Players:GetPropertyChangedSignal("LocalPlayer"):Wait() 
        LocalPlayer = Players.LocalPlayer
    end
    
    local MechanicsController = require(LocalPlayer.PlayerScripts.Controllers:WaitForChild("MechanicsController"))
    
    while not MechanicsController.LocalFighter do
        task.wait()
    end
    
    local LocalFighter = MechanicsController.LocalFighter
    local oldGet = LocalFighter.Get
    
    LocalFighter.Get = function(self, key, ...)
        if key == "SlidingSpeedMax" and Toggles.SlideBoost and Toggles.SlideBoost.Value and Options.SlideBoostMultiplier then
            local multiplier = Options.SlideBoostMultiplier.Value
            local val = oldGet(self, key, ...)
            return (val or 3) * multiplier
        end
        return oldGet(self, key, ...)
    end
end)

--------------------------------------------------------------------------------
-- Noclip Implementation
--------------------------------------------------------------------------------
game:GetService('RunService').Stepped:Connect(function()
    if Toggles.Noclip and Toggles.Noclip.Value and Options.NoclipKey and Options.NoclipKey:GetState() then
        if game:GetService("Players").LocalPlayer.Character then
            for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide == true then
                    v.CanCollide = false
                end
            end
        end
    end
end)
end
