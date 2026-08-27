-- Import WindUI Official
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- Bikin Window Utama
local Window = WindUI:CreateWindow({
    Title = "NEBOLUSVERSE MM2",
    Author = "by BELLIOT",
    Folder = "NebolusMM2",
    Size = UDim2.fromOffset(580, 400),
    Transparent = true
})

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- States
local ESP_Active = false
local Aimlock_Active = false
local AutoShoot_Active = false
local Noclip_Active = false

-- Helper Functions
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

local function GetTarget(role)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and GetPlayerRole(plr) == role then
            return plr
        end
    end
    return nil
end

-- TABS
local TabSheriff = Window:Tab({ Title = "Sheriff Features", Icon = "crosshair" })
local TabVisuals = Window:Tab({ Title = "Visual & ESP", Icon = "eye" })
local TabMisc    = Window:Tab({ Title = "Movement & Misc", Icon = "zap" })

-- 1. SHERIFF TAB
TabSheriff:Toggle({
    Title = "Aimlock to Murderer",
    Value = false,
    Callback = function(Value) Aimlock_Active = Value end
})

TabSheriff:Toggle({
    Title = "Auto Shoot Murderer",
    Value = false,
    Callback = function(Value) AutoShoot_Active = Value end
})

TabSheriff:Button({
    Title = "Auto Grab Dropped Gun",
    Callback = function()
        local char = LocalPlayer.Character
        local droppedGun = Workspace:FindFirstChild("GunDrop", true)
        if char and char:FindFirstChild("HumanoidRootPart") and droppedGun then
            char.HumanoidRootPart.CFrame = droppedGun.CFrame
        end
    end
})

-- 2. VISUALS TAB
TabVisuals:Toggle({
    Title = "ESP Roles",
    Value = false,
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

-- 3. MISC TAB
TabMisc:Toggle({
    Title = "Noclip",
    Value = false,
    Callback = function(Value) Noclip_Active = Value end
})

TabMisc:Slider({
    Title = "WalkSpeed",
    Min = 16,
    Max = 100,
    Value = 16,
    Callback = function(Value)
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

-- MAIN LOOPS
RunService.RenderStepped:Connect(function()
    if ESP_Active then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local role = GetPlayerRole(plr)
                local highlight = plr.Character:FindFirstChild("NebolusESP") or Instance.new("Highlight")
                highlight.Name = "NebolusESP"
                highlight.Parent = plr.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                if role == "Murderer" then highlight.FillColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then highlight.FillColor = Color3.fromRGB(0, 100, 255)
                else highlight.FillColor = Color3.fromRGB(0, 255, 0) end
            end
        end
    end

    if Aimlock_Active then
        local murderer = GetTarget("Murderer")
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Noclip_Active and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if AutoShoot_Active then
            local murderer = GetTarget("Murderer")
            local char = LocalPlayer.Character
            local gun = char and char:FindFirstChild("Gun")
            if murderer and murderer.Character and gun and gun:FindFirstChild("Shoot") then
                gun.Shoot:FireServer(murderer.Character.HumanoidRootPart.Position)
            end
        end
    end
end)

SheriffTab:CreateButton({
   Name = "Auto Grab Dropped Gun",
   Callback = function()
       local char = LocalPlayer.Character
       local droppedGun = Workspace:FindFirstChild("GunDrop", true)
       if char and char:FindFirstChild("HumanoidRootPart") and droppedGun then
           char.HumanoidRootPart.CFrame = droppedGun.CFrame
       end
   end,
})

SheriffTab:CreateButton({
   Name = "Fling Sheriff Target",
   Callback = function()
       local sheriff = GetTarget("Sheriff")
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
               task.wait()
           end
           bV:Destroy()
       end
   end,
})

-- 2. VISUALS TAB
VisualsTab:CreateToggle({
   Name = "ESP Roles (Murderer/Sheriff/Innocent)",
   CurrentValue = false,
   Flag = "ESPToggle",
   Callback = function(Value)
       ESP_Active = Value
       if not Value then
           for _, plr in pairs(Players:GetPlayers()) do
               if plr.Character and plr.Character:FindFirstChild("NebolusESP") then
                   plr.Character.NebolusESP:Destroy()
               end
           end
       end
   end,
})

-- 3. MISC TAB
MiscTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "NoclipToggle",
   Callback = function(Value) Noclip_Active = Value end,
})

MiscTab:CreateSlider({
   Name = "WalkSpeed",
   Range = {16, 100},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
           LocalPlayer.Character.Humanoid.WalkSpeed = Value
       end
   end,
})

-- MAIN LOOPS
RunService.RenderStepped:Connect(function()
    if ESP_Active then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local role = GetPlayerRole(plr)
                local highlight = plr.Character:FindFirstChild("NebolusESP") or Instance.new("Highlight")
                highlight.Name = "NebolusESP"
                highlight.Parent = plr.Character
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                if role == "Murderer" then highlight.FillColor = Color3.fromRGB(255, 0, 0)
                elseif role == "Sheriff" then highlight.FillColor = Color3.fromRGB(0, 100, 255)
                else highlight.FillColor = Color3.fromRGB(0, 255, 0) end
            end
        end
    end

    if Aimlock_Active then
        local murderer = GetTarget("Murderer")
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            Workspace.CurrentCamera.CFrame = CFrame.new(Workspace.CurrentCamera.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Noclip_Active and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if AutoShoot_Active then
            local murderer = GetTarget("Murderer")
            local char = LocalPlayer.Character
            local gun = char and char:FindFirstChild("Gun")
            if murderer and murderer.Character and gun and gun:FindFirstChild("Shoot") then
                gun.Shoot:FireServer(murderer.Character.HumanoidRootPart.Position)
            end
        end
    end
end)
    end
})

TabSheriff:Toggle({
    Name = "Auto Shoot Murderer",
    Default = false,
    Callback = function(Value)
        AutoShoot_Active = Value
    end
})

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

-- 3. TAB MOVEMENT & MISC
TabMisc:Toggle({
    Name = "Noclip",
    Default = false,
    Callback = function(Value)
        Noclip_Active = Value
    end
})

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

-- REALTIME LOGIC LOOPS
RunService.RenderStepped:Connect(function()
    -- ESP Logic
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

    -- Aimlock Logic
    if Aimlock_Active then
        local murderer = GetMurderer()
        if murderer and murderer.Character and murderer.Character:FindFirstChild("HumanoidRootPart") then
            local camera = Workspace.CurrentCamera
            camera.CFrame = CFrame.new(camera.CFrame.Position, murderer.Character.HumanoidRootPart.Position)
        end
    end
end)

RunService.Stepped:Connect(function()
    if Noclip_Active and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

task.spawn(function()
    while task.wait(0.2) do
        if AutoShoot_Active then
            local murderer = GetMurderer()
            local char = LocalPlayer.Character
            local gun = char and char:FindFirstChild("Gun")
            
            if murderer and murderer.Character and gun then
                local targetPos = murderer.Character.HumanoidRootPart.Position
                if gun:FindFirstChild("Shoot") then
                    gun.Shoot:FireServer(targetPos)
                end
            end
        end
    end
end)
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
