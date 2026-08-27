-- Load Library Urban UI
local WIND = loadstring(game:HttpGet("https://raw.githubusercontent.com/vortex-py/Urban-Ui-Library/refs/heads/main/v4.0/load-ui/urban-ui/theme/red.lua"))()

-- Inisialisasi Window Utama
local Window = WIND:CreateWindow({
    Title = "NEBOLUSVERSE - MM2 HUB",
    SubTitle = "by BELLIOT",
    Size = UDim2.fromOffset(580, 420),
    Transparent = true
})

-- TAB SETUP
local TabSheriff = Window:Tab({ Name = "Sheriff Features", Icon = "rbxassetid://4483362458" })
local TabVisuals = Window:Tab({ Name = "Visual & ESP", Icon = "rbxassetid://4483362458" })
local TabMisc    = Window:Tab({ Name = "Movement & Misc", Icon = "rbxassetid://4483362458" })

-- SERVICES & VARIABLES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local ESP_Active = false
local AutoShoot_Active = false
local Aimlock_Active = false
local Noclip_Active = false

-- DETEKSI ROLE (Murderer / Sheriff / Innocent)
local function GetPlayerRole(player)
    if not player or not player.Character then return "Innocent" end
    local backpack = player:FindFirstChild("Backpack")
    local char = player.Character

    if (backpack and backpack:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
        return "Murderer"
    elseif (backpack and backpack:FindFirstChild("Gun")) or (char and char:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local function GetMurderer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and GetPlayerRole(plr) == "Murderer" then
            return plr
        end
    end
    return nil
end

local function GetSheriff()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and GetPlayerRole(plr) == "Sheriff" then
            return plr
        end
    end
    return nil
end

-- 1. TAB SHERIFF FEATURES

-- A. Aimlock Murderer
TabSheriff:Toggle({
    Name = "Aimlock to Murderer",
    Default = false,
    Callback = function(Value)
        Aimlock_Active = Value
    end
})

RunService.RenderStepped:Connect(function()
    if Aimlock_Active then
        local murderer = GetMurderer()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local camera = Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
        end
    end
end)

-- B. Auto Shoot Murderer
TabSheriff:Toggle({
    Name = "Auto Shoot Murderer",
    Default = false,
    Callback = function(Value)
        AutoShoot_Active = Value
    end
})

task.spawn(function()
    while task.wait(0.2) do
        if AutoShoot_Active then
            local murderer = GetMurderer()
            local char = LocalPlayer.Character
            local gun = char and char:FindFirstChild("Gun")
            
            if murderer and murderer.Character and gun then
                local targetPos = murderer.Character.HumanoidRootPart.Position
                -- Memanggil event tembak pistol MM2
                if gun:FindFirstChild("Shoot") then
                    gun.Shoot:FireServer(targetPos)
                end
            end
        end
    end
end)

-- C. Auto Get Dropped Gun
TabSheriff:Button({
    Name = "Auto Grab Dropped Gun",
    Callback = function()
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        
        local droppedGun = Workspace:FindFirstChild("GunDrop", true)
        if droppedGun then
            char.HumanoidRootPart.CFrame = droppedGun.CFrame
        end
    end
})

-- D. Fling Sheriff
TabSheriff:Button({
    Name = "Fling Sheriff Target",
    Callback = function()
        local sheriff = GetSheriff()
        if sheriff and sheriff.Character and sheriff.Character:FindFirstChild("HumanoidRootPart") then
            local myRoot = LocalPlayer.Character.HumanoidRootPart
            local targetRoot = sheriff.Character.HumanoidRootPart

            local bV = Instance.new("BodyVelocity")
            bV.Velocity = Vector3.new(99999, 99999, 99999)
            bV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bV.Parent = myRoot

            local startTime = tick()
            while tick() - startTime < 1.5 do
                if not targetRoot or not targetRoot.Parent then break end
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(math.random(-1, 1), 0, math.random(-1, 1))
                myRoot.Velocity = Vector3.new(99999, 99999, 99999)
                task.wait()
            end
            bV:Destroy()
        end
    end
})

-- 2. TAB VISUALS & ESP

TabVisuals:Toggle({
    Name = "ESP Roles (Murder/Sheriff/Innocent)",
    Default = false,
    Callback = function(Value)
        ESP_Active = Value
        if not Value then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr.Character and plr.Character:FindFirstChild("NebolusESP") then
                    plr.Character.NebolusESP:Destroy()
                end
            end
        end
    end
})

RunService.RenderStepped:Connect(function()
    if ESP_Active then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local role = GetPlayerRole(plr)
                local highlight = plr.Character:FindFirstChild("NebolusESP") or Instance.new("Highlight")
                highlight.Name = "NebolusESP"
                highlight.Parent = plr.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

                if role == "Murderer" then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then
                    highlight.FillColor = Color3.fromRGB(0, 100, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end
end)

-- 3. TAB MOVEMENT & MISC

-- Noclip Toggle
TabMisc:Toggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        Noclip_Active = Value
    end
})

RunService.Stepped:Connect(function()
    if Noclip_Active and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- WalkSpeed Slider
TabMisc:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})
