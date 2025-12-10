-- [[ 1. 라이브러리 및 매니저 로드 ]] --
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- [[ 2. 설정 변수 ]] --
local SilentSettings = {
    Enabled = true,
    FOV = 180,
    ShowFOV = true,
    TargetPart = "Head",
    HitChance = 100,
    SilentMode = false -- Start Hidden
}

-- 알림 억제 훅 (Silent Mode 적용 시 알림 차단)
local OriginalNotify = Fluent.Notify
Fluent.Notify = function(self, ...)
    if SilentSettings.SilentMode then 
        return 
    end
    return OriginalNotify(self, ...)
end

local TargetBodyPart = nil

local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 60
FOVCircle.Filled = false
FOVCircle.Visible = false

-- [[ 3. 윈도우 생성 ]] --
local Window = Fluent:CreateWindow({
    Title = "Rivals | Silent Aim",
    SubTitle = "Optimized & Expanded",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, 
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl 
})

-- [[ 4. 탭 생성 ]] --
local Tabs = {
    Combat = Window:AddTab({ Title = "Combat", Icon = "swords" }),
    Misc = Window:AddTab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "save" })
}

-- [[ 5. Combat 탭 UI ]] --
local CombatSection = Tabs.Combat:AddSection("Silent Aim")

Tabs.Combat:AddToggle("SilentAim", {Title = "Enabled", Default = true }):OnChanged(function(v) SilentSettings.Enabled = v end)
Tabs.Combat:AddToggle("ShowFOV", {Title = "Show FOV", Default = true }):OnChanged(function(v) SilentSettings.ShowFOV = v; FOVCircle.Visible = v end)
Tabs.Combat:AddSlider("FOVSlider", {Title = "FOV Radius", Default = 180, Min = 10, Max = 800, Rounding = 0, Callback = function(v) SilentSettings.FOV = v; FOVCircle.Radius = v end})
Tabs.Combat:AddSlider("HitChanceSlider", {Title = "Hit Chance", Default = 100, Min = 0, Max = 100, Rounding = 0, Callback = function(v) SilentSettings.HitChance = v end})

-- 타겟 파트 리스트 (R15 전체)
local TargetPartsList = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftHand", "RightHand", "LeftFoot", "RightFoot",
    "LeftLowerArm", "RightLowerArm", "LeftUpperArm", "RightUpperArm",
    "LeftLowerLeg", "RightLowerLeg", "LeftUpperLeg", "RightUpperLeg",
    "Random"
}

Tabs.Combat:AddDropdown("TargetPartDropdown", {
    Title = "Target Hitbox",
    Values = TargetPartsList,
    Default = "Head",
    Multi = false,
    Callback = function(v) SilentSettings.TargetPart = v end
})

-- [[ 6. Misc 탭 UI ]] --
local MiscSection = Tabs.Misc:AddSection("Utility")

-- 파일 저장 없이 SaveManager를 통해 상태 저장 (Start Hidden)
local SilentModeToggle = Tabs.Misc:AddToggle("SilentMode", {Title = "Silent Mode (Start Hidden)", Default = false })
SilentModeToggle:OnChanged(function(v) 
    SilentSettings.SilentMode = v 
end)

-- 오토로드 기능 토글
local AutoLoadToggle = Tabs.Misc:AddToggle("AutoLoad", {Title = "Auto Load on Teleport", Default = true })


-- [[ 7. Target Logic (최적화됨) ]] --
local function GetTargetPart(character)
    if not character then return nil end
    
    local targetName = SilentSettings.TargetPart
    if targetName == "Random" then
        -- Random일 경우 유효한 파트 중 하나 랜덤 선택
        -- "Random"을 제외한 리스트에서 선택
        local idx = math.random(1, #TargetPartsList - 1)
        targetName = TargetPartsList[idx]
    end

    -- 1순위: 선택된 파트
    local part = character:FindFirstChild(targetName)
    -- 2순위: R15/R6 호환성 등을 위한 대체 파트 (Head or HumanoidRootPart)
    if not part then
        part = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    end
    return part
end

local function GetClosestTarget()
    local closestPart = nil
    local maxDistSq = SilentSettings.FOV * SilentSettings.FOV -- 제곱 거리 비교 (최적화)
    local mousePos = UserInputService:GetMouseLocation()

    -- Players.GetPlayers()는 최적화된 내부 리스트 반환
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end -- 자신은 스킵

        local char = player.Character
        if not char then continue end

        local hum = char:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        
        -- 화면 밖의 적을 미리 거르는 간단한 체크 (HumanoidRootPart 기준)
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        local rootScreen, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then continue end
        
        -- FOV 내에 있는지 대략적 확인 (RootPart)
        -- 이 단계에서 너무 멀면 정밀 파트 계산 스킵
        local distSq = (mousePos - Vector2.new(rootScreen.X, rootScreen.Y)).Magnitude -- Magnitude는 필수
        -- 참고: 여기선 Magnitude를 씁니다. 2D 거리는 스퀘어가 아님.
        -- 하지만 비교할때는 FOV^2 vs Dist^2가 빠르지만 Magnitude를 구했다면 그냥 비교.
        
        if distSq > SilentSettings.FOV + 100 then continue end -- 넉넉한 예비 거리

        -- 정밀 타겟 파트 확인
        local part = GetTargetPart(char)
        if part then
            local screenPos, partOnScreen = Camera:WorldToViewportPoint(part.Position)
            if partOnScreen then
                local dist = (mousePos - Vector2.new(screenPos.X, screenPos.Y)).Magnitude
                if dist < SilentSettings.FOV then
                     -- FOV 내에 들어오면 가장 가까운지 확인 (여기선 단순 FOV 체크 후 거리 비교가 더 정확할 수 있지만 기존 로직 유지)
                     -- 기존 로직: 가장 마우스에 가까운 대상을 찾음
                     if dist * dist < maxDistSq then -- 굳이 제곱 비교 할 필요 없지만 위에서 maxDistSq씀
                        -- 그냥 dist < currentMax 로 합시다
                        -- 아니, 위에서 maxDistance 변수를 안쓰고 maxDistSq를 썼으니 제곱근을 안씌운 distSq와 비교하는게 정석
                        local realDistSq = dist * dist
                        if realDistSq < maxDistSq then
                            closestPart = part
                            maxDistSq = realDistSq
                        end
                     end
                end
            end
        end
    end
    return closestPart
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = UserInputService:GetMouseLocation()
    FOVCircle.Visible = SilentSettings.ShowFOV and SilentSettings.Enabled
    FOVCircle.Radius = SilentSettings.FOV
    
    if SilentSettings.Enabled then
        TargetBodyPart = GetClosestTarget()
    else
        TargetBodyPart = nil
    end
end)


-- [[ 8. UNIVERSAL HOOKING (Updated Logic) ]] --
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}

    if method == "Raycast" and SilentSettings.Enabled then
        local callingScript = getcallingscript()
        
        -- 요청하신 특정 스크립트 체크 (판정 개선)
        if callingScript and (tostring(callingScript) == "Equipment" 
           or tostring(callingScript) == "FighterController" 
           or tostring(callingScript) == "PlayerDataController" 
           or tostring(callingScript) == "ControlsController") then
            
            if TargetBodyPart then
                -- Origin을 카메라 위치로 변경, Direction을 카메라->타겟 방향으로 변경 (Magic Bullet)
                args[1] = Camera.CFrame.Position
                args[2] = (TargetBodyPart.Position - Camera.CFrame.Position).Unit * 1000
                
                return oldNamecall(self, unpack(args))
            end
        end
    end
    return oldNamecall(self, ...)
end)


-- [[ 9. 마무리 ]] --
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings() 
SaveManager:SetFolder("Rivals_Optimized")
SaveManager:BuildConfigSection(Tabs.Settings)
InterfaceManager:BuildInterfaceSection(Tabs.Settings)

Window:SelectTab(Tabs.Combat)

-- 설정 로드
SaveManager:LoadAutoloadConfig()

-- 로드 후 SilentMode 적용
if SilentSettings.SilentMode then
    Window:Minimize()
end