local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local correctGameIds = {
    125009265613167,
    122816944483266
}
local isCorrectGame = false
for _, id in ipairs(correctGameIds) do
    if game.PlaceId == id then
        isCorrectGame = true
        break
    end
end
if not isCorrectGame then
    WindUI:Notify({
        Title = "Only InGame",
        Content = "This script only works ingame.",
        Duration = 10
    })
    return
end
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")


local aimbotLerpFactor = 0.3
local glassESPEnabled = false
local glassESPConnections = {}
local safeGlassHighlights = {}
local rlglModule = {
    _IsGreenLight = false,
    _LastRootPartCFrame = nil,
    _OriginalNamecall = nil,
    _Connection = nil,
    _CleanupFunction = nil  
}
local safeZoneToggle = nil
local bringGuardsEnabled = false
local bringGuardsConnection = nil

local Window = WindUI:CreateWindow({
    Title = "Tuff Guys | Ink Game V7.1",
    Icon = "rbxassetid://130506306640152",
    IconThemed = true,
    Author = "Tuff Agsy",
    Folder = "inkyaeg",
    Size = UDim2.fromOffset(580, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    Background = WindUI:Gradient({
        ["0"] = { Color = Color3.fromRGB(0, 255, 0), Transparency = 0.8 },
        ["100"] = { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.8 },
    }, {
        Rotation = 0,
    }),
})
Window:DisableTopbarButtons({"Fullscreen"})

Window:EditOpenButton({
    Title = "Tuff Guys | Ink Game",
    Icon = "slice",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 0)),   
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)) 
}),
    Enabled = true,
    Draggable = true,
})

MainSection = Window:Section({
    Title = "Main",
    Opened = true,
})

local Discord = MainSection:Tab({
    Title = "Important",
    Icon = "bell",
    ShowTabTitle = true,
})

local UL = MainSection:Tab({
    Title = "Update-Logs",
    Icon = "clipboard",
    ShowTabTitle = true,
})

UL:Paragraph({
    Title = "CHANGELOGS V7.1",
    Desc = "[~] Changed Freeze Rope to Delete Rope and Works Fine\n[~] Fixed Auto Pull Rope\n[-] Removed Pull Modes\n[~] In Delete Rope i Added a Platform so you wont fall",
    Image = "rbxassetid://130506306640152",
})

GameSection = Window:Section({
    Title = "Game",
    Opened = true,
})

local Main = GameSection:Tab({
    Title = "Win",
    Icon = "star",
    ShowTabTitle = true,
})

local Peabert = GameSection:Tab({
    Title = "Peabert",
    Icon = "gift",
    ShowTabTitle = true,
})

local Utility = GameSection:Tab({
    Title = "Utility",
    Icon = "settings",
    ShowTabTitle = true,
})

local Misc = GameSection:Tab({
    Title = "Misc",
    Icon = "cctv",
    ShowTabTitle = true,
})

local Combat = GameSection:Tab({
    Title = "Combat",
    Icon = "crosshair",
    ShowTabTitle = true,
})

local Visual = GameSection:Tab({
    Title = "Visual",
    Icon = "eye",
    ShowTabTitle = true,
    Locked = false
})

Window:SelectTab(1)

local lplr = game:GetService("Players").LocalPlayer

local function CopyDiscordInvite()
    setclipboard("https://discord.gg/tuffguys")
end

local function FixCamera()
    if LocalPlayer.Character then
        Camera.CameraSubject = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    end
    
    LocalPlayer.CharacterAdded:Connect(function(character)
        task.wait(0.5)
        Camera.CameraSubject = character:FindFirstChildOfClass("Humanoid")
    end)
end

FixCamera()

Discord:Paragraph({
    Title = "Join Discord To Know Updates!",
    Desc = "Stay updated with the latest features and fixes",
    Image = "rbxassetid://130506306640152",
    Thumbnail = "rbxassetid://130506306640152",
    Buttons = {
        {
            Title = "Copy Invite",
            Icon = "clipboard",
            Callback = CopyDiscordInvite,
            Variant = "Primary"
        },
        {
            Title = "Visit YouTube",
            Icon = "youtube",
            Callback = function() 
                setclipboard("https://www.youtube.com/@incrediblebread")
            end,
            Variant = "Secondary"
        }
    }
})


Main:Section({Title = "OP"})
Main:Divider()

local touchFlingEnabled = false
local touchFlingConnection = nil
local touchFlingAntiCheatHook = nil

Main:Toggle({
    Title = "Fling Aura",
    Desc = "Fling other players when they touch you",
    Value = false,
    Callback = function(state)
        touchFlingEnabled = state
        if state then
            -- Initialize
            local function FlingPlayer()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Character = LocalPlayer.Character
                local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
                local RunService = game:GetService("RunService")

                if not HumanoidRootPart then return end

                -- Disable anti-fling checks (if any)
                local velocityConnections = getconnections(HumanoidRootPart:GetPropertyChangedSignal("Velocity"))
                for _, connection in ipairs(velocityConnections) do
                    connection:Disable()
                end

                -- Main fling logic
                local flingActive = true
                local flingConnection = RunService.RenderStepped:Connect(function()
                    if not flingActive or not HumanoidRootPart or not HumanoidRootPart.Parent then
                        flingConnection:Disconnect()
                        return
                    end

                    -- Apply fling force
                    local currentVelocity = HumanoidRootPart.Velocity
                    HumanoidRootPart.Velocity = currentVelocity * 1000 + Vector3.new(0, 10000, 0)
                    
                    -- Stabilize after initial fling
                    RunService.RenderStepped:Wait()
                    if HumanoidRootPart.Parent then
                        HumanoidRootPart.Velocity = currentVelocity
                    end

                    -- Small vertical nudge to maintain fling
                    RunService.Stepped:Wait()
                    if HumanoidRootPart.Parent then
                        local nudgeDirection = ((math.floor(tick()) % 2 == 0) and 1 or -1)
                        HumanoidRootPart.Velocity = currentVelocity + Vector3.new(0, 0.1 * nudgeDirection, 0)
                    end
                end)

                -- Cleanup function
                return function()
                    flingActive = false
                    if flingConnection then flingConnection:Disconnect() end
                    for _, connection in ipairs(velocityConnections) do
                        connection:Enable() -- Re-enable anti-cheat checks
                    end
                end
            end

            touchFlingConnection = FlingPlayer()
            
            -- Reinitialize on respawn
            LocalPlayer.CharacterAdded:Connect(function()
                if touchFlingEnabled then
                    if touchFlingConnection then
                        touchFlingConnection()
                    end
                    touchFlingConnection = FlingPlayer()
                end
            end)
        else
            -- Cleanup
            if touchFlingConnection then
                touchFlingConnection()
                touchFlingConnection = nil
            end
        end
    end
})


local antiFlingEnabled = false
local antiFlingConnection
Main:Toggle({
    Title = "Anti-Fling",
    Desc = "Stops other players from flinging you",
    Value = false,
    Callback = function(state)
        antiFlingEnabled = state
        if state then
            antiFlingConnection = RunService.RenderStepped:Connect(function()
                pcall(function()
                    local character = LocalPlayer.Character
                    if character then
                        local hrp = character:FindFirstChild("HumanoidRootPart")
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        
                        if hrp and humanoid then
                            
                            local currentVel = hrp.Velocity
                            hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
                            hrp.RotVelocity = Vector3.new(0, 0, 0)
                            
                            
                            if currentVel.Magnitude > 100 and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                                hrp.Velocity = Vector3.new(currentVel.X * 0.3, currentVel.Y, currentVel.Z * 0.3)
                            end
                        end
                    end
                end)
            end)
        else
            if antiFlingConnection then
                antiFlingConnection:Disconnect()
                antiFlingConnection = nil
            end
        end
    end
})

Main:Section({Title = "Red Light Green Light"})
Main:Divider()
Main:Button({
    Title = "Complete Red Light Green Light",
    Callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(-46, 1024, 110)
        end
    end
})

local injuredMode = "Save" -- Default mode
local helpInjuredEnabled = false
local helpInjuredLoop = nil
local recentlyHelpedPlayers = {}

-- Define the polygon area (same for all modes for now)
local polygon = {
    Vector2.new(-52, -515),
    Vector2.new(115, -515),
    Vector2.new(115, 84),
    Vector2.new(-216, 84)
}

local function isPointInPolygon(point, poly)
    local inside = false
    local j = #poly
    for i = 1, #poly do
        local xi, zi = poly[i].X, poly[i].Y
        local xj, zj = poly[j].X, poly[j].Y
        if ((zi > point.Y) ~= (zj > point.Y)) and
            (point.X < (xj - xi) * (point.Y - zi) / (zj - zi + 1e-9) + xi) then
            inside = not inside
        end
        j = i
    end
    return inside
end

local function FindInjuredPlayer()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        if not plr.Character then continue end
        if not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
        if plr:GetAttribute("IsDead") then continue end
        if plr.Character:GetAttribute("SafeRedLightGreenLight") then continue end 
        if plr.Character:FindFirstChild("IsBeingHeld") then continue end
        if recentlyHelpedPlayers[plr.UserId] then continue end 

        local playerPos = plr.Character.HumanoidRootPart.Position
        local playerPos2D = Vector2.new(playerPos.X, playerPos.Z)
        if not isPointInPolygon(playerPos2D, polygon) then
            continue 
        end

        local CarryPrompt = plr.Character.HumanoidRootPart:FindFirstChild("CarryPrompt")
        if CarryPrompt then
            return plr, CarryPrompt
        end
    end
    return nil
end

local function HelpInjuredPlayer()
    local injuredPlayer, carryPrompt = FindInjuredPlayer()
    if not injuredPlayer then
        return false
    end

    recentlyHelpedPlayers[injuredPlayer.UserId] = os.time()
    
    local wasAntiFlingEnabled = false
    if antiFlingConnection then
        wasAntiFlingEnabled = true
        antiFlingConnection:Disconnect()
        antiFlingConnection = nil
    end

    local success = true
    pcall(function()
        -- Move to injured player
        LocalPlayer.Character:PivotTo(injuredPlayer.Character:GetPrimaryPartCFrame())
        task.wait(0.2)
        
        -- Pick them up
        carryPrompt.HoldDuration = 0  
        fireproximityprompt(carryPrompt)
        task.wait(0.5)
        
        -- Determine destination based on mode
        local destination
        if injuredMode == "Save" then
            destination = CFrame.new(-46, 1024, 110) -- Finish line
        elseif injuredMode == "Troll" then
            destination = CFrame.new(66.0978928, 1023.05371, -571.360046) -- Start position
        elseif injuredMode == "Void" then
            destination = CFrame.new(0, -500, 0) -- Void
        end
        
        -- Move to destination
        LocalPlayer.Character:PivotTo(destination)
        task.wait(0.5)
        
        -- Drop them
        game:GetService("ReplicatedStorage").Remotes.ClickedButton:FireServer({tryingtoleave = true})
        
        -- If Void mode, teleport back to finish line
        if injuredMode == "Void" then
            task.wait(0.5) -- Small delay before teleporting back
            LocalPlayer.Character:PivotTo(CFrame.new(-46, 1024, 110))
        end
    end)

    -- Restore anti-fling if it was enabled
    if wasAntiFlingEnabled then
        antiFlingConnection = RunService.RenderStepped:Connect(function()
            pcall(function()
                local character = LocalPlayer.Character
                if character then
                    local hrp = character:FindFirstChild("HumanoidRootPart")
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and humanoid then
                        local currentVel = hrp.Velocity
                        hrp.Velocity = Vector3.new(currentVel.X * 0.5, currentVel.Y, currentVel.Z * 0.5)
                        hrp.RotVelocity = Vector3.new(0, 0, 0)
                    end
                end
            end)
        end)
    end

    return success
end

-- Dropdown for mode selection
Main:Dropdown({
    Title = "Bring Injured Mode",
    Values = {"Save", "Troll", "Void"},
    Default = "Save",
    Callback = function(selected)
        injuredMode = selected
    end
})

-- Toggle for activating the feature
Main:Toggle({
    Title = "Bring Injured Players",
    Desc = "Automatically helps/drops injured players based on selected mode",
    Value = false,
    Callback = function(state)
        helpInjuredEnabled = state
        if state then
            -- Initialize cooldown tracker
            recentlyHelpedPlayers = {}
            local HELP_COOLDOWN = 30 
            
            -- Start cooldown cleanup loop
            task.spawn(function()
                while task.wait(10) and helpInjuredEnabled do
                    local currentTime = os.time()
                    for userId, helpTime in pairs(recentlyHelpedPlayers) do
                        if currentTime - helpTime > HELP_COOLDOWN then
                            recentlyHelpedPlayers[userId] = nil
                        end
                    end
                end
            end)

            -- Start main loop
            helpInjuredLoop = task.spawn(function()
                while task.wait(1) and helpInjuredEnabled do
                    HelpInjuredPlayer()
                end
            end)
        else
            -- Cleanup
            if helpInjuredLoop then
                task.cancel(helpInjuredLoop)
                helpInjuredLoop = nil
            end
            recentlyHelpedPlayers = nil
        end
    end
})


Main:Section({Title = "Glass Bridge"})
Main:Divider()


local glassESPEnabled = false
local glassHighlights = {}

local function RevealGlassBridge()
    local glassHolder = workspace:FindFirstChild("GlassBridge") and workspace.GlassBridge:FindFirstChild("GlassHolder")
    if not glassHolder then return end

    for _, tilePair in pairs(glassHolder:GetChildren()) do
        for _, tileModel in pairs(tilePair:GetChildren()) do
            if tileModel:IsA("Model") and tileModel.PrimaryPart then
                
                if glassHighlights[tileModel] then
                    glassHighlights[tileModel]:Destroy()
                    glassHighlights[tileModel] = nil
                end

                if not glassESPEnabled then continue end

                local isBreakable = tileModel.PrimaryPart:GetAttribute("exploitingisevil") == true
                local targetColor = isBreakable and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 255, 0)
                
                for _, part in pairs(tileModel:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Color = targetColor
                        part.Transparency = 0.5
                    end
                end

                local highlight = Instance.new("Highlight")
                highlight.FillColor = targetColor
                highlight.FillTransparency = 0.7
                highlight.OutlineTransparency = 0.5
                highlight.Parent = tileModel
                glassHighlights[tileModel] = highlight
            end
        end
    end
end

Main:Toggle({
    Title = "Glass Vision",
    Desc = "Shows safe (green) and breakable (red) tiles",
    Value = false,
    Callback = function(state)
        glassESPEnabled = state
        if state then
            RevealGlassBridge()
            
            workspace.DescendantAdded:Connect(function(descendant)
                if descendant.Name == "GlassBridge" then
                    RevealGlassBridge()
                end
            end)
        else
            
            for tile, highlight in pairs(glassHighlights) do
                if highlight then highlight:Destroy() end
            end
            table.clear(glassHighlights)
        end
    end
})

Main:Button({
    Title = "Teleport to End of Bridge",
    Desc = "Instantly completes the glass bridge",
    Callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            char:PivotTo(CFrame.new(-203.9, 520.7, -1534.3485) + Vector3.new(0, 5, 0))
        end
    end
})

Main:Section({Title = "Mingle"})
Main:Divider()


local autoChokeholdEnabled = false
local chokeholdConnection

Main:Toggle({
    Title = "Auto Power-Hold",
    Desc = "Automatically completes powerhold QTEs",
    Value = false,
    Callback = function(state)
        autoChokeholdEnabled = state
        if state then
            local function AutoPowerHold()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local Remotes = game:GetService("ReplicatedStorage").Remotes
                
                local remoteConnection
                local function handleRemote(remote)
                    if remote.Name == "RemoteForQTE" then
                        task.spawn(function()
                            while remote and remote.Parent do
                                if autoChokeholdEnabled then
                                    remote:FireServer() -- Simulates button hold
                                end
                                task.wait(0.5) -- QTE interval
                            end
                        end)
                    end
                end

                -- Hook new remotes
                remoteConnection = LocalPlayer.CharacterAdded:Connect(function(char)
                    char.ChildAdded:Connect(handleRemote)
                    for _, child in ipairs(char:GetChildren()) do
                        handleRemote(child)
                    end
                end)

                -- Cleanup function
                return function()
                    if remoteConnection then
                        remoteConnection:Disconnect()
                    end
                end
            end

            chokeholdConnection = AutoPowerHold()
        else
            if chokeholdConnection then
                chokeholdConnection()
                chokeholdConnection = nil
            end
        end
    end
})


Main:Section({Title = "Dalgona"})
Main:Divider()

local completeDalgonaEnabled = false
local dalgonaHooked = false

Main:Toggle({
    Title = "Complete Dalgona",
    Desc = "Automatically completes the Dalgona candy (no lag)",
    Value = false,
    Callback = function(state)
        completeDalgonaEnabled = state
        
        -- Show notification only when toggled on
        if state then
            WindUI:Notify({
                Title = "Complete Dalgona",
                Content = "If it doesn't work your executor is bad",
                Duration = 5
            })
        end
        
        if state then
            -- Hook the Dalgona progress function
            local function HookDalgona()
                local DalgonaClientModule = game.ReplicatedStorage.Modules.Games.DalgonaClient
                if not DalgonaClientModule then return end
                
                -- Find the RenderStepped function with the progress variables
                for _, func in ipairs(getgc()) do
                    if typeof(func) == "function" and islclosure(func) and getfenv(func).script == DalgonaClientModule then
                        local info = debug.getinfo(func)
                        if info.nups > 50 then -- The main RenderStepped function
                            -- Find v_u_107 (progress counter) and set it to complete
                            for i = 1, info.nups do
                                local name, value = debug.getupvalue(func, i)
                                if typeof(value) == "number" and value >= 0 and value < 200 then
                                    -- Find v_u_106 (total required)
                                    for j = 1, info.nups do
                                        local name2, value2 = debug.getupvalue(func, j)
                                        if typeof(value2) == "number" and value2 > value and value2 < 500 then
                                            debug.setupvalue(func, i, value2 - 5)
                                            dalgonaHooked = true
                                            return true
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
                end
                return false
            end
            
            -- Try to hook immediately
            if not HookDalgona() then
                -- If not successful, try again after a short delay
                task.spawn(function()
                    task.wait(1)
                    HookDalgona()
                end)
            end
        else
            -- Cleanup
            dalgonaHooked = false
        end
    end
})


Main:Section({Title = "Jump Rope"})
Main:Divider()


Main:Button({
    Title = "Complete Jump Rope",
    Desc = "Teleports to finish line position",
    Callback = function()
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local targetPosition = Vector3.new(
                723.2041015625, 
                197.14407348632812 + 3,
                922.08349609375
            )
            character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
        end
    end
})

Main:Button({
    Title = "Delete Rope",
    Desc = "Deletes the rope and creates a platform",
    Callback = function()
        local rope = workspace.Effects:WaitForChild("rope")
        if rope then
            rope:Destroy()
        end
        
        local collision = workspace.Map:FindFirstChild("SLIGHT_IGNORE.COLLISION1")
        if collision then
            collision:Destroy()
        end
        
        local antiFallPart = Instance.new("Part")
        antiFallPart.Name = "AntiFallPart"
        antiFallPart.Size = Vector3.new(1000, 5, 1000)
        antiFallPart.Position = Vector3.new(647.316162109375, 189.54104614257812, 924.5520629882812)
        antiFallPart.Anchored = true
        antiFallPart.CanCollide = true
        antiFallPart.Transparency = 0.5
        antiFallPart.Color = Color3.fromRGB(128, 128, 128)
        antiFallPart.Material = Enum.Material.Concrete
        antiFallPart.Parent = workspace
        
        WindUI:Notify({
            Title = "Delete Rope",
            Content = "Rope deleted and platform created",
            Duration = 3
        })
    end
})
Main:Section({Title = "Hide and Seek"})
Main:Divider()

Main:Button({
    Title = "Anti Spikes",
    Desc = "Removes spike damage in Hide and Seek",
    Callback = function()
        local map = workspace:WaitForChild("HideAndSeekMap")
        
        for _, v in pairs(map:GetDescendants()) do
            if v:IsA("Part") and v.Name == "Spikes" then
                for _, child in pairs(v:GetChildren()) do
                    if child.Name == "TouchInterest" then
                        child:Destroy()
                    end
                end
            end
        end
        
        WindUI:Notify({
            Title = "Anti Spikes",
            Content = "Spike damage has been removed",
            Duration = 3
        })
    end
})


local hiderAttachEnabled = false
local hiderAttachRange = 50
local hiderAttachBehindTarget = true
local hiderAttachBehindDistance = 1.5
local hiderAttachMovementType = "Tween" -- "Teleport", "Tween", or "Velocity"
local hiderAttachTweenDuration = 0.05
local hiderAttachUpdateInterval = 0.05
local lastHiderAttachUpdate = 0

local function HiderAttachTweenMode()
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
    local tweenDuration = hiderAttachTweenDuration / 10
    local tweenInfo = TweenInfo.new(
        tweenDuration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    hiderAttachEnabled = true

    while hiderAttachEnabled and RunService.RenderStepped:Wait() do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end

        -- Find closest hider in range
        local closestHider, closestDistance = nil, hiderAttachRange
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player:GetAttribute("IsHider") then continue end

            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end

            local distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestHider = player
                closestDistance = distance
            end
        end

        -- Apply tween if valid target exists
        if closestHider and closestHider.Character then
            local targetRoot = closestHider.Character.HumanoidRootPart
            local finalPosition = targetRoot.Position

            -- Adjust for "stay behind" mode
            if hiderAttachBehindTarget then
                local lookVector = targetRoot.CFrame.LookVector
                finalPosition = targetRoot.Position - (lookVector * hiderAttachBehindDistance)
            end

            -- Create and play tween
            local tween = TweenService:Create(
                LocalPlayer.Character.HumanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(finalPosition, targetRoot.Position)}
            )
            tween:Play()
        end
    end
end

Main:Toggle({
    Title = "Attach To Hiders",
    Desc = "Automatically attaches to nearby hiders",
    Value = false,
    Callback = function(state)
        hiderAttachEnabled = state
        if state then
            HiderAttachTweenMode()
        end
    end
})

Main:Slider({
    Title = "Hider Behind Distance",
    Value = {
        Min = 0.7,
        Max = 5,
        Default = 1.5,
    },
    Callback = function(value)
        hiderAttachBehindDistance = value
    end
})


Main:Button({
    Title = "Teleport To Hider",
    Desc = "Teleports behind the nearest hider",
    Callback = function()
        if not LocalPlayer.Character then 
            return
        end
        
        local hider = nil
        for _, player in pairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                    if humanoid and humanoid.Health > 0 then
                        hider = player.Character
                        break
                    end
                end
            end
        end
        
        if not hider then
            return
        end
        
        
        local hiderRoot = hider:FindFirstChild("HumanoidRootPart")
        local myRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not hiderRoot or not myRoot then
            return
        end
        
        
        local hiderCFrame = hiderRoot.CFrame
        local behindOffset = hiderCFrame.LookVector * -3  
        local targetPosition = hiderCFrame.Position + behindOffset
        
        
        LocalPlayer.Character:PivotTo(CFrame.new(targetPosition, hiderCFrame.Position))
        
    end
})

Main:Keybind({
    Title = "Teleport To Hider Keybind",
    Desc = "Keybind to teleport to nearest hider",
    Value = "H",
    Callback = function(v)
        local keyCode = Enum.KeyCode[v]
        
        game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
            if not gameProcessed and input.KeyCode == keyCode then
                if not LocalPlayer.Character then return end
                
                local hider = nil
                for _, player in pairs(Players:GetPlayers()) do
                    if player ~= LocalPlayer and player:GetAttribute("IsHider") then
                        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
                            if humanoid and humanoid.Health > 0 then
                                hider = player.Character
                                break
                            end
                        end
                    end
                end
                
                if hider and hider:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                    local hiderCFrame = hider.HumanoidRootPart.CFrame
                    local behindOffset = hiderCFrame.LookVector * -3
                    LocalPlayer.Character:PivotTo(CFrame.new(hiderCFrame.Position + behindOffset, hiderCFrame.Position))
                end
            end
        end)
    end
})


Main:Section({Title = "Tug of War"})
Main:Divider()

local tugOfWarAutoEnabled = false
local tugOfWarConnection = nil

Main:Toggle({
    Title = "Auto Pull Rope",
    Desc = "Automatically pulls the rope",
    Value = false,
    Callback = function(state)
        tugOfWarAutoEnabled = state
        if state then
            if tugOfWarConnection then return end
            tugOfWarConnection = RunService.Heartbeat:Connect(function()
                local args = {
                    {
                        IHateYou = true
                    }
                }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("TemporaryReachedBindable"):FireServer(unpack(args))
            end)
        else
            if tugOfWarConnection then
                tugOfWarConnection:Disconnect()
                tugOfWarConnection = nil
            end
        end
    end
})

Main:Section({Title = "Sky Squid Game"})
Main:Divider()

local antiFallEnabled = false
local antiVoidPart = nil

local function createAntiVoid()
    local antiVoid = Instance.new("Part")
    antiVoid.Name = "SkySquidGameAntiVoid"
    antiVoid.Size = Vector3.new(1000, 5, 1000)
    antiVoid.Position = Vector3.new(0, 960, 0)
    antiVoid.Anchored = true
    antiVoid.CanCollide = true
    antiVoid.Transparency = 0.5
    antiVoid.Color = Color3.fromRGB(128, 128, 128)
    antiVoid.Material = Enum.Material.Concrete
    
    antiVoid.Parent = workspace
    return antiVoid
end

Main:Toggle({
    Title = "Anti Fall",
    Desc = "Creates a platform to prevent falling in Sky Squid Game",
    Value = false,
    Callback = function(state)
        antiFallEnabled = state
        if state then
            -- Create the anti-void platform
            antiVoidPart = createAntiVoid()
        else
            -- Remove the anti-void platform
            if antiVoidPart and antiVoidPart.Parent then
                antiVoidPart:Destroy()
                antiVoidPart = nil
            end
        end
    end
})

-- Add this to the Win tab after the Sky Squid Game section
local instantGrabEnabled = false
local instantGrabConnection = nil

local function SetupInstantGrab()
    if not instantGrabEnabled then return end
    
    -- Check if we're in Sky Squid Game
    local currentGame = workspace.Values.CurrentGame
    if not currentGame or currentGame.Value ~= "SkySquidGame" then return end
    
    -- Wait for the map and pole
    local success, map = pcall(function()
        return workspace:WaitForChild("SkySquidGamesMap", 5)
    end)
    
    if not success or not map then return end
    
    local poleWeapons = map:FindFirstChild("PoleWeapons")
    if not poleWeapons then return end
    
    -- Find InkPole (case insensitive search)
    local inkPole
    for _, child in ipairs(poleWeapons:GetChildren()) do
        if string.lower(child.Name):find("inkpole") then
            inkPole = child
            break
        end
    end
    
    if not inkPole then return end
    
    -- Find Pickup Pole proximity prompt
    local pickupPole = inkPole:FindFirstChild("Pickup Pole")
    if pickupPole and pickupPole:IsA("ProximityPrompt") then
        pickupPole.HoldDuration = 0
    end
end

Main:Toggle({
    Title = "Instant Grab Pole",
    Desc = "Makes grab pole instant in Sky Squid Game",
    Value = false,
    Callback = function(state)
        instantGrabEnabled = state
        if state then
            -- Run immediately
            SetupInstantGrab()
            
            -- Set up connection to monitor for new prompts
            instantGrabConnection = workspace.DescendantAdded:Connect(function(descendant)
                if instantGrabEnabled and descendant:IsA("ProximityPrompt") and descendant.Name == "Pickup Pole" then
                    descendant.HoldDuration = 0
                end
            end)
            
            -- Also monitor game changes
            local currentGame = workspace.Values.CurrentGame
            if currentGame then
                currentGame.Changed:Connect(function()
                    if instantGrabEnabled then
                        SetupInstantGrab()
                    end
                end)
            end
        else
            if instantGrabConnection then
                instantGrabConnection:Disconnect()
                instantGrabConnection = nil
            end
        end
    end
})

local autoPickupPoleEnabled = false
local autoPickupPoleConnection = nil

local function AutoPickupPole()
    if not autoPickupPoleEnabled then return end
    
    -- Check if we're in Sky Squid Game
    local currentGame = workspace.Values.CurrentGame
    if not currentGame or currentGame.Value ~= "SkySquidGame" then return end
    
    -- Check if we already have a pole
    local character = LocalPlayer.Character
    if not character then return end
    
    local hasPole = false
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.lower(tool.Name):find("pole") then
            hasPole = true
            break
        end
    end
    
    if hasPole then return end
    
    -- Wait for the map and pole
    local success, map = pcall(function()
        return workspace:WaitForChild("SkySquidGamesMap", 5)
    end)
    
    if not success or not map then return end
    
    local poleWeapons = map:FindFirstChild("PoleWeapons")
    if not poleWeapons then return end
    
    -- Find InkPole (case insensitive search)
    local inkPole
    for _, child in ipairs(poleWeapons:GetChildren()) do
        if string.lower(child.Name):find("inkpole") then
            inkPole = child
            break
        end
    end
    
    if not inkPole then return end
    
    -- Find Pickup Pole proximity prompt
    local pickupPole = inkPole:FindFirstChild("Pickup Pole")
    if not pickupPole or not pickupPole:IsA("ProximityPrompt") then return end
    
    -- Teleport to the pole (not the prompt)
    if character:FindFirstChild("HumanoidRootPart") then
        character:PivotTo(inkPole:GetPrimaryPartCFrame() + Vector3.new(0, 3, 0))
        task.wait(0.2)
        
        -- Fire the proximity prompt
        fireproximityprompt(pickupPole)
    end
end

Main:Toggle({
    Title = "Auto Pick Up Pole",
    Desc = "Automatically picks up the pole in Sky Squid Game",
    Value = false,
    Callback = function(state)
        autoPickupPoleEnabled = state
        if state then
            -- Start auto pickup loop
            autoPickupPoleConnection = task.spawn(function()
                while autoPickupPoleEnabled do
                    AutoPickupPole()
                    task.wait(1) -- Check every second
                end
            end)
            
            -- Also monitor game changes
            local currentGame = workspace.Values.CurrentGame
            if currentGame then
                currentGame.Changed:Connect(function()
                    if autoPickupPoleEnabled then
                        task.wait(2) -- Wait a bit for the game to load
                        AutoPickupPole()
                    end
                end)
            end
        else
            if autoPickupPoleConnection then
                task.cancel(autoPickupPoleConnection)
                autoPickupPoleConnection = nil
            end
        end
    end
})

Main:Section({Title = "Other"})
Main:Divider()

local collectBandageEnabled = false
local collectBandageConnection = nil

local function HasTool(toolName)
    -- Check character and backpack for the tool
    for _, v in pairs(game.Players.LocalPlayer.Character:GetChildren()) do
        if v:IsA("Tool") and v.Name == toolName then
            return true
        end
    end
    for _, v in pairs(game.Players.LocalPlayer.Backpack:GetChildren()) do
        if v:IsA("Tool") and v.Name == toolName then
            return true
        end
    end
    return false
end

local function CollectBandageLoop()
    while collectBandageEnabled do
        local OldCFrame = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        if not HasTool("Bandage") then
            repeat
                task.wait()
                if workspace:FindFirstChild("Effects") then
                    for _, v in pairs(workspace.Effects:GetChildren()) do
                        if v.Name == "DroppedBandage" and v:FindFirstChild("Handle") then
                            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.Handle.CFrame
                            break
                        end
                    end
                end
            until HasTool("Bandage") or not collectBandageEnabled
            task.wait(0.3)
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = OldCFrame
        end
        task.wait()
    end
end

Main:Toggle({
    Title = "Auto Collect Bandage",
    Desc = "Automatically collects bandages",
    Value = false,
    Callback = function(state)
        collectBandageEnabled = state
        if state then
            if collectBandageConnection then
                collectBandageConnection:Disconnect()
            end
            collectBandageConnection = task.spawn(CollectBandageLoop)
        else
            if collectBandageConnection then
                task.cancel(collectBandageConnection)
                collectBandageConnection = nil
            end
        end
    end
})

-- Add Anti Banana toggle
local antiBananaEnabled = false
local antiBananaConnection = nil

local function AntiBananaLoop()
    while antiBananaEnabled do
        if workspace:FindFirstChild("Effects") then
            for _, v in pairs(workspace.Effects:GetChildren()) do
                if v.Name:find("Banana") then
                    v:Destroy()
                end
            end
        end
        task.wait()
    end
end

Main:Toggle({
    Title = "Anti Banana",
    Desc = "Automatically removes bananas",
    Value = false,
    Callback = function(state)
        antiBananaEnabled = state
        if state then
            if antiBananaConnection then
                antiBananaConnection:Disconnect()
            end
            antiBananaConnection = task.spawn(AntiBananaLoop)
        else
            if antiBananaConnection then
                task.cancel(antiBananaConnection)
                antiBananaConnection = nil
            end
        end
    end
})

Main:Button({
    Title = "Unlock Dash",
    Desc = "Gives you Dash",
    Callback = function()
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            if boosts:FindFirstChild("Faster Sprint") then
                boosts["Faster Sprint"].Value = 5
            end
        end)
    end
})

Combat:Section({Title = "Combat"})
Combat:Divider()


local function IsGuard(model)
    return model:IsA("Model") and 
           model:FindFirstChild("TypeOfGuard") and 
           (model.Name:find("Rebel") or model.Name:find("Guard")) and
           model:FindFirstChild("Humanoid") and 
           model.Humanoid.Health > 0
end

local validGuards = {}

local function isGuard(model)
    if not model:IsA("Model") or model == LocalPlayer.Character then return false end
    if not model:FindFirstChild("TypeOfGuard") then return false end
    local lowerName = model.Name:lower()
    return (string.find(model.Name, "Rebel") or string.find(model.Name, "FinalRebel") or 
            string.find(model.Name, "HallwayGuard") or string.find(lowerName, "aggro")) and
            model:FindFirstChild("Humanoid") and model.Humanoid.Health > 0 and
            not model:FindFirstChild("Dead")
end

local function PivotRebelGuardsToPlayer()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = LocalPlayer.Character.HumanoidRootPart
    local guardCount = 0
    local radius = 4
    local angleStep = (2 * math.pi) / math.max(#validGuards, 1)
    
    for _, guard in ipairs(validGuards) do
        if isGuard(guard) and guard:FindFirstChild("HumanoidRootPart") then
            guardCount = guardCount + 1
            local angle = angleStep * guardCount
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local targetCF = CFrame.new(root.Position + offset, root.Position)
            guard:PivotTo(targetCF)
        end
    end
end


task.spawn(function()
    local Live = workspace:WaitForChild("Live", 10)
    if not Live then return end
    
    
    for _, v in pairs(Live:GetChildren()) do
        if isGuard(v) then table.insert(validGuards, v) end
    end
    
    
    Live.ChildAdded:Connect(function(v)
        if isGuard(v) then table.insert(validGuards, v) end
    end)
    
    Live.ChildRemoved:Connect(function(v)
        if isGuard(v) then
            table.remove(validGuards, table.find(validGuards, v))
        end
    end)
end)

Combat:Section({Title = "Risky Features"})
Combat:Divider()

Combat:Toggle({
    Title = "Bring Guards",
    Desc = "Brings Guards",
    Value = false,
    Callback = function(state)
        bringGuardsEnabled = state
        if state then
            
            validGuards = {}
            for _, v in pairs(workspace.Live:GetChildren()) do
                if isGuard(v) then table.insert(validGuards, v) end
            end
            
            
            bringGuardsConnection = RunService.RenderStepped:Connect(function()
                PivotRebelGuardsToPlayer()
            end)
        else
            if bringGuardsConnection then
                bringGuardsConnection:Disconnect()
                bringGuardsConnection = nil
            end
        end
    end
})

Combat:Toggle({
    Title = "MP5 Mods",
    Desc = "Improved bullets, reduced spread, faster fire",
    Value = false,
    Callback = function(state)
        local MP5 = game:GetService("ReplicatedStorage").Weapons.Guns:FindFirstChild("MP5")
        if MP5 then
            if state then
                if MP5:FindFirstChild("MaxBullets") then MP5.MaxBullets.Value = 5000 end
                if MP5:FindFirstChild("Spread") then MP5.Spread.Value = 0 end
                if MP5:FindFirstChild("BulletsPerFire") then MP5.BulletsPerFire.Value = 3 end
                if MP5:FindFirstChild("FireRateCD") then MP5.FireRateCD.Value = 0 end
            else
                if MP5:FindFirstChild("MaxBullets") then MP5.MaxBullets.Value = 30 end
                if MP5:FindFirstChild("Spread") then MP5.Spread.Value = 0.1 end
                if MP5:FindFirstChild("BulletsPerFire") then MP5.BulletsPerFire.Value = 1 end
                if MP5:FindFirstChild("FireRateCD") then MP5.FireRateCD.Value = 0.1 end
            end
        end
    end
})

Combat:Section({Title = "Player Attach"})
Combat:Divider()

local playerAttachEnabled = false
local playerAttachRange = 60
local playerAttachBehindTarget = true
local playerAttachBehindDistance = 1.5
local playerAttachMovementType = "Tween" -- "Teleport", "Tween", or "Velocity"
local playerAttachTweenDuration = 0.05

local function PlayerAttachTweenMode()
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    
    local tweenDuration = playerAttachTweenDuration / 10
    local tweenInfo = TweenInfo.new(
        tweenDuration,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    playerAttachEnabled = true

    while playerAttachEnabled and RunService.RenderStepped:Wait() do
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            continue
        end

        -- Find closest player in range
        local closestPlayer, closestDistance = nil, playerAttachRange
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end

            local character = player.Character
            if not character then continue end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end
            
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end

            local distance = (rootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end

        -- Apply tween if valid target exists
        if closestPlayer and closestPlayer.Character then
            local targetRoot = closestPlayer.Character.HumanoidRootPart
            local finalPosition = targetRoot.Position

            -- Adjust for "stay behind" mode
            if playerAttachBehindTarget then
                local lookVector = targetRoot.CFrame.LookVector
                finalPosition = targetRoot.Position - (lookVector * playerAttachBehindDistance)
            end

            -- Create and play tween
            local tween = TweenService:Create(
                LocalPlayer.Character.HumanoidRootPart,
                tweenInfo,
                {CFrame = CFrame.new(finalPosition, targetRoot.Position)}
            )
            tween:Play()
        end
    end
end

Combat:Toggle({
    Title = "Attach To Players",
    Desc = "Automatically attaches to nearby players",
    Value = false,
    Callback = function(state)
        playerAttachEnabled = state
        if state then
            PlayerAttachTweenMode()
        end
    end
})

Combat:Slider({
    Title = "Player Attach Behind Distance",
    Value = {
        Min = 0.7,
        Max = 5,
        Default = 1.5,
    },
    Callback = function(value)
        playerAttachBehindDistance = value
    end
})

Combat:Toggle({
    Title = "Stay Behind Target",
    Desc = "Maintains position behind the target player",
    Value = true,
    Callback = function(state)
        playerAttachBehindTarget = state
    end
})

Combat:Section({Title = "Face"})
Combat:Divider()

local aimbotEnabled = false
local aimbotConnection = nil
local lastTarget = nil

Combat:Toggle({
    Title = "Face Nearest Player",
    Desc = "Automatically faces the closest player",
    Value = false,
    Callback = function(state)
        aimbotEnabled = state
        if state then
            -- Initialize aimbot
            local function FaceClosestPlayer()
                local Players = game:GetService("Players")
                local LocalPlayer = Players.LocalPlayer
                local RunService = game:GetService("RunService")
                local connection
                
                local function getClosestPlayer()
                    local closestPlayer, closestDistance = nil, math.huge
                    local myPosition = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position

                    if not myPosition then return nil end

                    for _, player in ipairs(Players:GetPlayers()) do
                        if player ~= LocalPlayer and player.Character then
                            local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp and hrp.Parent and player.Character.Humanoid.Health > 0 then
                                local distance = (myPosition - hrp.Position).Magnitude
                                if distance < closestDistance then
                                    closestDistance = distance
                                    closestPlayer = player
                                end
                            end
                        end
                    end
                    return closestPlayer
                end

                connection = RunService.RenderStepped:Connect(function()
                    local target = getClosestPlayer()
                    if target and target.Character then
                        local targetHrp = target.Character:FindFirstChild("HumanoidRootPart")
                        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        
                        if targetHrp and myHrp then
                            -- Face target while maintaining original Y position (horizontal only)
                            local newCF = CFrame.new(myHrp.Position, Vector3.new(
                                targetHrp.Position.X,
                                myHrp.Position.Y,
                                targetHrp.Position.Z
                            ))
                            myHrp.CFrame = newCF
                            lastTarget = target
                        end
                    end
                end)

                -- Cleanup function
                return function()
                    if connection then
                        connection:Disconnect()
                    end
                end
            end

            aimbotConnection = FaceClosestPlayer()
            
            -- Reinitialize when character respawns
            game.Players.LocalPlayer.CharacterAdded:Connect(function()
                task.wait(1) -- Wait for character to fully load
                if aimbotEnabled then
                    if aimbotConnection then
                        aimbotConnection()
                    end
                    aimbotConnection = FaceClosestPlayer()
                end
            end)
        else
            -- Cleanup
            if aimbotConnection then
                aimbotConnection()
                aimbotConnection = nil
            end
            lastTarget = nil
        end
    end
})

Combat:Section({Title = "Hitbox Expander"})
Combat:Divider()

Combat:Section({Title = "Guard"})
Combat:Divider()


local hitboxEnabled = false
local hitboxSize = 5 
local hitboxTransparency = 0.7
local hitboxColor = Color3.fromRGB(255, 0, 0)
local hitboxConnections = {}
local hitboxParts = {}


local function updateHitbox(guard)
    if not guard:IsA("Model") then return end
    local hrp = guard:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    
    if hitboxParts[guard] then
        hitboxParts[guard]:Destroy()
        hitboxParts[guard] = nil
    end
    
    if not hitboxEnabled then return end
    
    
    local hitbox = Instance.new("Part")
    hitbox.Name = "ExpandedHitbox"
    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
    hitbox.Transparency = hitboxTransparency
    hitbox.Color = hitboxColor
    hitbox.Material = Enum.Material.ForceField
    hitbox.Anchored = false
    hitbox.CanCollide = false
    hitbox.CFrame = hrp.CFrame
    
    
    local weld = Instance.new("WeldConstraint")
    weld.Part0 = hrp
    weld.Part1 = hitbox
    weld.Parent = hitbox
    
    hitbox.Parent = guard
    hitboxParts[guard] = hitbox
    
    
    hrp.Transparency = 1
    hrp.CanCollide = false
    
    
    hitboxConnections[guard] = guard.AncestryChanged:Connect(function(_, parent)
        if not parent then
            if hitboxParts[guard] then
                hitboxParts[guard]:Destroy()
                hitboxParts[guard] = nil
            end
            if hitboxConnections[guard] then
                hitboxConnections[guard]:Disconnect()
                hitboxConnections[guard] = nil
            end
            
            if guard.Parent then
                if hrp then
                    hrp.Transparency = 0
                    hrp.CanCollide = true
                end
            end
        end
    end)
end


local function setupHitboxes()
    
    for guard, hitbox in pairs(hitboxParts) do
        if hitbox and hitbox.Parent then
            hitbox:Destroy()
        end
        
        if guard and guard.Parent then
            local hrp = guard:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Transparency = 0
                hrp.CanCollide = true
            end
        end
    end
    table.clear(hitboxParts)
    
    for guard, conn in pairs(hitboxConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(hitboxConnections)

    if not hitboxEnabled then return end
    
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
           (obj.Name:lower():find("guard") or obj.Name:lower():find("triangle") or 
            obj.Name:lower():find("squid") or obj.Name:lower():find("circle")) then
            updateHitbox(obj)
        end
    end
    
    
    hitboxConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and 
           (obj.Name:lower():find("guard") or obj.Name:lower():find("triangle") or 
            obj.Name:lower():find("squid") or obj.Name:lower():find("circle")) then
            updateHitbox(obj)
        end
    end)
end


Combat:Toggle({
    Title = "Guard Hitbox Expander",
    Desc = "Makes guards easier to hit by expanding their hitbox",
    Value = false,
    Callback = function(state)
        hitboxEnabled = state
        setupHitboxes()
    end
})

Combat:Slider({
    Title = "Guard Hitbox Size",
    Value = {
        Min = 1,
        Max = 20,
        Default = 5,
    },
    Callback = function(value)
        hitboxSize = value
        if hitboxEnabled then
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                end
            end
        end
    end
})

Combat:Slider({
    Title = "Guard Hitbox Transparency",
    Value = {
        Min = 0,
        Max = 1,
        Default = 0.7,
    },
    Callback = function(value)
        hitboxTransparency = value
        if hitboxEnabled then
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Transparency = hitboxTransparency
                end
            end
        end
    end
})


Combat:Colorpicker({
    Title = "Guard Hitbox Color",
    Default = Color3.fromRGB(255, 0, 0), 
    Callback = function(color)
        hitboxColor = color
        if hitboxEnabled then
            
            for guard, hitbox in pairs(hitboxParts) do
                if hitbox and hitbox.Parent then
                    hitbox.Color = hitboxColor
                end
            end
        end
    end
})


game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    if hitboxEnabled then
        task.wait(1) 
        setupHitboxes()
    end
end)



Utility:Section({Title = "Emotes"})
Utility:Divider()


local emoteList = {}
local currentEmoteTrack = nil
local selectedEmote = nil 


local function loadEmotes()
    table.clear(emoteList)
    
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if not Animations then return end
    
    local Emotes = Animations:WaitForChild("Emotes", 10)
    if not Emotes then return end

    for _, anim in pairs(Emotes:GetChildren()) do
        if anim:IsA("Animation") and anim.AnimationId ~= "" then
            emoteList[anim.Name] = anim.AnimationId
        end
    end
end


local function playEmote(emoteName)
    
    local character = LocalPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end

    
    local animId = emoteList[emoteName]
    if not animId then return end

    local anim = Instance.new("Animation")
    anim.AnimationId = animId

    
    local track = humanoid:LoadAnimation(anim)
    track.Priority = Enum.AnimationPriority.Action
    track:Play()
    
    
    currentEmoteTrack = track
end


local function stopEmote()
    if currentEmoteTrack then
        currentEmoteTrack:Stop()
        currentEmoteTrack = nil
    end
end


local emoteDropdown = Utility:Dropdown({
    Title = "Emotes",
    Values = {}, 
    Callback = function(selected)
        selectedEmote = selected 
    end
})


Utility:Button({
    Title = "Play Emote",
    Callback = function()
        if selectedEmote then
            playEmote(selectedEmote)
        end
    end
})

Utility:Button({
    Title = "Stop Emote",
    Callback = stopEmote
})


task.spawn(function()
    loadEmotes()
    
    
    local emoteNames = {}
    for name, _ in pairs(emoteList) do
        table.insert(emoteNames, name)
    end
    table.sort(emoteNames)
    emoteDropdown:Refresh(emoteNames, true)
    
    
    local Animations = ReplicatedStorage:WaitForChild("Animations", 10)
    if Animations then
        local Emotes = Animations:WaitForChild("Emotes", 10)
        if Emotes then
            Emotes.ChildAdded:Connect(function()
                task.wait()
                loadEmotes()
                
                
                local newEmoteNames = {}
                for name, _ in pairs(emoteList) do
                    table.insert(newEmoteNames, name)
                end
                table.sort(newEmoteNames)
                emoteDropdown:Refresh(newEmoteNames, true)
            end)
        end
    end
end)

Utility:Section({Title = "Power"})
Utility:Divider()

Utility:Button({
    Title = "Change to Phantom Step",
    Desc = "Equips the Phantom Step power",
    Callback = function()
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            player:SetAttribute("_EquippedPower", "PHANTOM STEP")
        end)
    end
})

local phantomDashEnabled = false
local phantomDashCleanup = nil

Utility:Toggle({
    Title = "No Cooldown Phantom Step",
    Desc = "Removes cooldown from Phantom Step dash ability",
    Value = false,
    Callback = function(state)
        phantomDashEnabled = state
        if state then
            -- Start the infinite dash system
            local function InfinitePhantomDash()
                local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
                local dashCooldownConnection
                
                local function removeCooldown()
                    for _, child in ipairs(character:GetChildren()) do
                        if child.Name == "CDDASHSTACKSCD" then
                            child:Destroy()
                        end
                    end
                end

                -- Main handler
                dashCooldownConnection = character.ChildAdded:Connect(function(child)
                    if child.Name == "CDDASHSTACKSCD" then
                        removeCooldown()
                    end
                end)

                -- Initial cleanup
                removeCooldown()

                -- Cleanup
                return function()
                    if dashCooldownConnection then
                        dashCooldownConnection:Disconnect()
                    end
                end
            end

            phantomDashCleanup = InfinitePhantomDash()
            
            -- Reapply on respawn
            game.Players.LocalPlayer.CharacterAdded:Connect(function()
                if phantomDashEnabled then
                    if phantomDashCleanup then
                        phantomDashCleanup()
                    end
                    phantomDashCleanup = InfinitePhantomDash()
                end
            end)
        else
            -- Cleanup
            if phantomDashCleanup then
                phantomDashCleanup()
                phantomDashCleanup = nil
            end
        end
    end
})

Utility:Section({Title = "Utilities"})
Utility:Divider()

local playerDropdown = Utility:Dropdown({
    Title = "Player To Go",
    Values = {}, 
    Callback = function(selected)
        
        getgenv().selectedPlayerToTeleport = selected
    end
})

local function updatePlayerDropdown()
    local playerNames = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerNames, player.Name)
        end
    end
    table.sort(playerNames)
    playerDropdown:Refresh(playerNames, true)
end


updatePlayerDropdown()


Players.PlayerAdded:Connect(function()
    task.wait() 
    updatePlayerDropdown()
end)

Players.PlayerRemoving:Connect(function()
    task.wait() 
    updatePlayerDropdown()
end)

Utility:Button({
    Title = "Go to Player",
    Desc = "Teleports to the selected player",
    Callback = function()
        local selectedName = getgenv().selectedPlayerToTeleport
        if not selectedName then
            WindUI:Notify({Title = "Error", Content = "No player selected", Duration = 3})
            return
        end
        
        local targetPlayer = Players:FindFirstChild(selectedName)
        if not targetPlayer then
            WindUI:Notify({Title = "Error", Content = "Player not found", Duration = 3})
            return
        end
        
        local character = LocalPlayer.Character
        local targetCharacter = targetPlayer.Character
        if not character or not targetCharacter then
            WindUI:Notify({Title = "Error", Content = "Character not found", Duration = 3})
            return
        end
        
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local targetRootPart = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart or not targetRootPart then
            WindUI:Notify({Title = "Error", Content = "Root part not found!", Duration = 3})
            return
        end
        
        
        local targetCFrame = targetRootPart.CFrame
        local behindOffset = targetCFrame.LookVector * -2
        local targetPosition = targetCFrame.Position + behindOffset
        
        
        character:PivotTo(CFrame.new(targetPosition, targetCFrame.Position))
    end
})

Utility:Toggle({
    Title = "Auto Skip Cutscenes",
    Desc = "Automatically skips all cutscenes and dialogue",
    Value = false,
    Callback = function(state)
        if state then
            getgenv().skipCutsceneConnection = RunService.RenderStepped:Connect(function()
                
                local args = {"Skipped"}
                pcall(function()
                    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("DialogueRemote"):FireServer(unpack(args))
                end)
            end)
        else
            if getgenv().skipCutsceneConnection then
                getgenv().skipCutsceneConnection:Disconnect()
                getgenv().skipCutsceneConnection = nil
            end
        end
    end
})

local function onCharacterAdded(character)
    if getgenv().currentWalkSpeed then
        task.wait(1)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = getgenv().currentWalkSpeed
        end
    end
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(onCharacterAdded)


Misc:Section({Title = "Safe"})
Misc:Divider()
local lastPosition = nil
local safeZoneFolder = nil

local function createSafeZone()
    
    if safeZoneFolder then
        safeZoneFolder:Destroy()
    end
    
    
    safeZoneFolder = Instance.new("Folder", workspace)
    safeZoneFolder.Name = "SAFEZONEMAP"
    
    
    local platform = Instance.new("Part", safeZoneFolder)
    platform.Name = "SafePlatform"
    platform.Size = Vector3.new(100, 5, 100) 
    platform.Position = Vector3.new(0, 5000, 0) 
    platform.Anchored = true
    platform.CanCollide = true
    platform.Material = Enum.Material.Slate
    platform.Color = Color3.fromRGB(150, 150, 150)
    
    
    local wallHeight = 20
    local wallThickness = 2
    
    
    local northWall = Instance.new("Part", safeZoneFolder)
    northWall.Size = Vector3.new(100 + wallThickness*2, wallHeight, wallThickness)
    northWall.Position = platform.Position + Vector3.new(0, wallHeight/2, 50 + wallThickness/2)
    northWall.Anchored = true
    northWall.CanCollide = true
    northWall.Material = Enum.Material.WoodPlanks
    northWall.Color = Color3.fromRGB(102, 70, 42)
    
    
    local southWall = northWall:Clone()
    southWall.Parent = safeZoneFolder
    southWall.Position = platform.Position + Vector3.new(0, wallHeight/2, -50 - wallThickness/2)
    
    
    local eastWall = Instance.new("Part", safeZoneFolder)
    eastWall.Size = Vector3.new(wallThickness, wallHeight, 100)
    eastWall.Position = platform.Position + Vector3.new(50 + wallThickness/2, wallHeight/2, 0)
    eastWall.Anchored = true
    eastWall.CanCollide = true
    eastWall.Material = Enum.Material.WoodPlanks
    eastWall.Color = northWall.Color
    eastWall.Parent = safeZoneFolder
    
    
    local westWall = eastWall:Clone()
    westWall.Parent = safeZoneFolder
    westWall.Position = platform.Position + Vector3.new(-50 - wallThickness/2, wallHeight/2, 0)
    
    
    local border = Instance.new("Part", safeZoneFolder)
    border.Size = Vector3.new(104, 1, 104)
    border.Position = platform.Position + Vector3.new(0, 2.5, 0)
    border.Anchored = true
    border.CanCollide = true
    border.Material = Enum.Material.WoodPlanks
    border.Color = Color3.fromRGB(102, 70, 42)
    
    
    local grassColors = {
        Color3.fromRGB(34, 139, 34),
        Color3.fromRGB(0, 100, 0),
        Color3.fromRGB(50, 205, 50)
    }
    
    for i = 1, 15 do
        local grassPatch = Instance.new("Part", safeZoneFolder)
        grassPatch.Size = Vector3.new(math.random(8, 15), 0.5, math.random(8, 15))
        grassPatch.Position = platform.Position + Vector3.new(
            math.random(-40, 40),
            2.6, 
            math.random(-40, 40)
        )
        grassPatch.Anchored = true
        grassPatch.CanCollide = false
        grassPatch.Material = Enum.Material.Grass
        grassPatch.Color = grassColors[math.random(1, #grassColors)]
        
        
        if math.random() > 0.7 then
            local rock = Instance.new("Part", safeZoneFolder)
            rock.Size = Vector3.new(math.random(2, 4), math.random(1, 2), math.random(2, 4))
            rock.Position = grassPatch.Position + Vector3.new(0, 0.5, 0)
            rock.Anchored = true
            rock.CanCollide = true
            rock.Material = Enum.Material.Slate
            rock.Color = Color3.fromRGB(100, 100, 100)
        end
    end
    
    
    local chair = Instance.new("Part", safeZoneFolder)
    chair.Name = "Chair"
    chair.Size = Vector3.new(4, 3, 4)
    chair.Position = platform.Position + Vector3.new(20, 2.5, 0)
    chair.Anchored = true
    chair.CanCollide = true
    chair.Material = Enum.Material.Wood
    chair.Color = Color3.fromRGB(139, 69, 19) 
    
    
    local backrest = Instance.new("Part", safeZoneFolder)
    backrest.Size = Vector3.new(4, 6, 0.5)
    backrest.Position = chair.Position + Vector3.new(0, 3, -2)
    backrest.Anchored = true
    backrest.CanCollide = true
    backrest.Material = Enum.Material.Wood
    backrest.Color = chair.Color
    
    
    for i = 1, 4 do
        local treePos = platform.Position + Vector3.new(
            math.random(-35, 35),
            0,
            math.random(-35, 35)
        )
        
        
        local trunk = Instance.new("Part", safeZoneFolder)
        trunk.Size = Vector3.new(3, 10, 3)
        trunk.Position = treePos + Vector3.new(0, 5, 0)
        trunk.Anchored = true
        trunk.CanCollide = true
        trunk.Material = Enum.Material.Wood
        trunk.Color = Color3.fromRGB(101, 67, 33)
        
        
        local leaves = Instance.new("Part", safeZoneFolder)
        leaves.Size = Vector3.new(12, 8, 12)
        leaves.Position = trunk.Position + Vector3.new(0, 8, 0)
        leaves.Anchored = true
        leaves.CanCollide = true
        leaves.Material = Enum.Material.Sand
        leaves.Color = Color3.fromRGB(34, 139, 34)
        leaves.Shape = Enum.PartType.Ball
    end
    
    
    local fireBase = Instance.new("Part", safeZoneFolder)
    fireBase.Size = Vector3.new(6, 1, 6)
    fireBase.Position = platform.Position + Vector3.new(-20, 2.6, 0)
    fireBase.Anchored = true
    fireBase.CanCollide = true
    fireBase.Material = Enum.Material.Slate
    fireBase.Color = Color3.fromRGB(80, 80, 80)
    
    
    local fire = Instance.new("Fire", fireBase)
    fire.Heat = 10
    fire.Size = 5
    fire.Color = Color3.new(1, 0.5, 0.1)
    fire.SecondaryColor = Color3.new(1, 0.8, 0)
    
    
    local light = Instance.new("PointLight", fireBase)
    light.Brightness = 5
    light.Range = 20
    light.Color = Color3.new(1, 0.6, 0.3)
    
    
    return platform.Position + Vector3.new(20, 7, 0)
end

local safeZoneEnabled = false

-- Store the toggle reference when creating it
safeZoneToggle = Misc:Toggle({
    Title = "SafeZone",
    Desc = "Teleports to safezone when on, returns when off",
    Value = false,
    Callback = function(state)
        safeZoneEnabled = state
        if state then
            -- Save current position and teleport to safezone
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                lastPosition = character.HumanoidRootPart.CFrame
                local safeZonePos = createSafeZone()
                character.HumanoidRootPart.CFrame = CFrame.new(safeZonePos)
            end
        else
            -- Return to original position
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") and lastPosition then
                character.HumanoidRootPart.CFrame = lastPosition
                if safeZoneFolder then
                    safeZoneFolder:Destroy()
                    safeZoneFolder = nil
                end
            end
        end
    end
})

-- Then modify the keybind to properly toggle it
Misc:Keybind({
    Title = "SafeZone Keybind", 
    Desc = "Press The Keybind to toggle safezone",
    Value = "Z",
    Callback = function()
        if safeZoneToggle then
            safeZoneToggle:Set(not safeZoneToggle:Get())
        else
            WindUI:Notify({
                Title = "Error",
                Content = "SafeZone toggle not initialized",
                Duration = 3
            })
        end
    end
})


local antiVoidEnabled = false
local antiVoidPart = nil
local antiVoidLoop = nil
local lastSafePosition = nil

local function createAntiVoid()
    
    antiVoidPart = Instance.new("Part")
    antiVoidPart.Name = "AntiVoidPlatform"
    antiVoidPart.Anchored = true
    antiVoidPart.CanCollide = true
    antiVoidPart.Size = Vector3.new(2000, 2, 2000) 
    antiVoidPart.Transparency = 0.7
    antiVoidPart.Material = Enum.Material.Neon
    antiVoidPart.Color = Color3.fromRGB(0, 255, 255)
    antiVoidPart.Parent = workspace

    
    local forceField = Instance.new("ForceField")
    forceField.Visible = false
    forceField.Parent = antiVoidPart

    
    local bouncePad = Instance.new("BodyVelocity")
    bouncePad.MaxForce = Vector3.new(0, math.huge, 0)
    bouncePad.Velocity = Vector3.new(0, 150, 0) 
    bouncePad.Parent = antiVoidPart
end

local function updateAntiVoid()
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end

    local character = LocalPlayer.Character
    local rootPart = character.HumanoidRootPart
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character, antiVoidPart}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    
    if rootPart.Velocity.Y > -50 then 
        lastSafePosition = rootPart.Position
    end

    
    local rayOrigin = rootPart.Position
    local rayDirection = Vector3.new(0, -1000, 0)
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)

    if raycastResult then
        
        antiVoidPart.Position = Vector3.new(
            lastSafePosition.X, 
            raycastResult.Position.Y - 15, 
            lastSafePosition.Z
        )
    elseif lastSafePosition then
        
        antiVoidPart.Position = Vector3.new(
            lastSafePosition.X, 
            rootPart.Position.Y - 50, 
            lastSafePosition.Z
        )
    end

    
    if rootPart.Velocity.Y < -100 then
        character:PivotTo(CFrame.new(lastSafePosition + Vector3.new(0, 5, 0)))
    end
end

Misc:Toggle({
    Title = "Anti-Void",
    Desc = "Prevents falling through the map",
    Value = false,
    Callback = function(state)
        antiVoidEnabled = state
        if state then
            createAntiVoid()
            antiVoidLoop = RunService.RenderStepped:Connect(updateAntiVoid)
            
            
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                lastSafePosition = LocalPlayer.Character.HumanoidRootPart.Position
            end
        else
            if antiVoidLoop then
                antiVoidLoop:Disconnect()
                antiVoidLoop = nil
            end
            if antiVoidPart then
                antiVoidPart:Destroy()
                antiVoidPart = nil
            end
            lastSafePosition = nil
        end
    end
})


LocalPlayer.CharacterAdded:Connect(function(character)
    if antiVoidEnabled then
        task.wait(1) 
        createAntiVoid()
        if not antiVoidLoop then
            antiVoidLoop = RunService.RenderStepped:Connect(updateAntiVoid)
        end
    end
end)

Misc:Section({Title = "Flight"})
Misc:Divider()

local flySpeed = 50
local flyEnabled = false

Misc:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flight speed",
    Value = {
        Min = 50,
        Max = 200,
        Default = 50,
    },
    Callback = function(value)
        flySpeed = value
    end
})

Misc:Toggle({
    Title = "Fly",
    Desc = "Enable flight mode",
    Value = false,
    Callback = function(state)
        flyEnabled = state
        
        if state then
            -- Initialize fly system
            local UIS = game:GetService("UserInputService")
            local RS = game:GetService("RunService")
            local Players = game:GetService("Players")
            local Workspace = game:GetService("Workspace")
            local player = Players.LocalPlayer

            local flyConnection = nil
            local antiFallConnection = nil
            local speed = flySpeed
            local inputVector = Vector3.zero
            local currentVelocity = Vector3.zero
            local lerpSpeed = 35
            local ySpeed = flySpeed
            local currentYVelocity = 0

            local rotationLerpSpeed = 12
            local decelerationMultiplier = 1.8

            local joystickTouch = nil
            local joystickStartPos = nil
            local keysPressed = {}

            local camera = workspace.CurrentCamera

            local lastPosition = Vector3.zero
            local velocityHistory = {}
            local frameCount = 0
            local ref = cloneref or function(x) return x end
            local S = function(n) return ref(game:GetService(n)) end

            local Plrs, UIS, RS, Wk = S("Players"), S("UserInputService"), S("RunService"), S("Workspace")
            local plr = Plrs.LocalPlayer

            local function getParts()
                local c = plr.Character or plr.CharacterAdded:Wait()
                local hum, hrp
                for _, d in ipairs(c:GetDescendants()) do
                    if not hum and d:IsA("Humanoid") then hum = d end
                    if not hrp and d:IsA("BasePart") and d.Name == "HumanoidRootPart" then hrp = d end
                    if hum and hrp then break end
                end
                hum = hum or c:WaitForChild("Humanoid")
                hrp = hrp or c:WaitForChild("HumanoidRootPart")
                return c, hum, hrp
            end

            local function lockMouse(v)
                if UIS.MouseEnabled then
                    UIS.MouseBehavior = v and Enum.MouseBehavior.LockCenter or Enum.MouseBehavior.Default
                end
            end

            local rotCon, oldAR
            local function faceCam(h, hrp, v)
                if rotCon then rotCon:Disconnect() rotCon = nil end
                if v then
                    oldAR = h.AutoRotate
                    h.AutoRotate = false
                    rotCon = RS.RenderStepped:Connect(function()
                        local cam = Wk.CurrentCamera
                        if not (hrp and cam) then return end
                        local lv = cam.CFrame.LookVector
                        local flat = Vector3.new(lv.X, 0, lv.Z)
                        if flat.Magnitude > 1e-4 then
                            hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + flat.Unit, Vector3.yAxis)
                        end
                    end)
                else
                    if oldAR ~= nil then h.AutoRotate = oldAR end
                end
            end

            local function reapply(v)
                task.defer(function()
                    local _, h, r = getParts()
                    lockMouse(v)
                    faceCam(h, r, v)
                end)
            end

            local shiftLockEnabled = true
            reapply(shiftLockEnabled)

            plr.CharacterAdded:Connect(function()
                reapply(shiftLockEnabled)
            end)

            local lastCam = Wk.CurrentCamera
            Wk:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
                local c = Wk.CurrentCamera
                if c ~= lastCam then
                    lastCam = c
                    reapply(shiftLockEnabled)
                end
            end)

            local function InitializeFly()
                local char = player.Character or player.CharacterAdded:Wait()
                local root = char:WaitForChild("HumanoidRootPart")
                local humanoid = char:WaitForChild("Humanoid")

                humanoid.PlatformStand = true
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                lastPosition = root.Position
                velocityHistory = {}
                frameCount = 0
                
                root.Velocity = Vector3.zero
                root.RotVelocity = Vector3.zero
                root.CanCollide = false
            end

            UIS.TouchStarted:Connect(function(input)
                if flyEnabled and not joystickTouch then
                    local screenSize = workspace.CurrentCamera.ViewportSize
                    if input.Position.X < screenSize.X / 2 then
                        joystickTouch = input
                        joystickStartPos = input.Position
                    end
                end
            end)

            UIS.TouchMoved:Connect(function(input)
                if flyEnabled and input == joystickTouch then
                    local delta = input.Position - joystickStartPos
                    local maxRadius = 100
                    if delta.Magnitude > maxRadius then
                        delta = delta.Unit * maxRadius
                    end
                    inputVector = Vector3.new(delta.X / maxRadius, 0, delta.Y / maxRadius)
                end
            end)

            UIS.TouchEnded:Connect(function(input)
                if flyEnabled and input == joystickTouch then
                    joystickTouch = nil
                    inputVector = Vector3.zero
                end
            end)

            UIS.InputBegan:Connect(function(input, gameProcessed)
                if gameProcessed or not flyEnabled then return end
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keysPressed[input.KeyCode] = true
                end
            end)

            UIS.InputEnded:Connect(function(input, gameProcessed)
                if input.UserInputType == Enum.UserInputType.Keyboard then
                    keysPressed[input.KeyCode] = false
                end
            end)

            player.CharacterAdded:Connect(function()
                task.wait(0.1)
                if flyEnabled then
                    InitializeFly()
                end
            end)

            local function IsMoving()
                local hasKeyboardInput = keysPressed[Enum.KeyCode.W] or keysPressed[Enum.KeyCode.A] or 
                                        keysPressed[Enum.KeyCode.S] or keysPressed[Enum.KeyCode.D] or
                                        keysPressed[Enum.KeyCode.Q] or keysPressed[Enum.KeyCode.E]
                
                local hasTouchInput = inputVector.Magnitude > 0.1
                
                return hasKeyboardInput or hasTouchInput
            end

            local function StartFlyLoop()
                if flyConnection then
                    flyConnection:Disconnect()
                end
                
                if antiFallConnection then
                    antiFallConnection:Disconnect()
                end
                
                antiFallConnection = RS.Heartbeat:Connect(function()
                    local char = player.Character
                    if not char or not flyEnabled then return end
                    
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChild("Humanoid")
                    if not root or not humanoid then return end
                    
                    pcall(function()
                        humanoid.PlatformStand = true
                    end)
                    
                    pcall(function()
                        root.Velocity = Vector3.zero
                        root.RotVelocity = Vector3.zero
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.AssemblyAngularVelocity = Vector3.zero
                    end)
                end)
                
                flyConnection = RS.RenderStepped:Connect(function(dt)
                    local char = player.Character
                    if not char or not flyEnabled then return end
                    
                    local root = char:FindFirstChild("HumanoidRootPart")
                    local humanoid = char:FindFirstChild("Humanoid")
                    if not root or not humanoid then return end

                    frameCount = frameCount + 1
                    local camCF = camera.CFrame
                    local camRight = camCF.RightVector
                    local camForward = camCF.LookVector

                    local moveDir = Vector3.zero
                    local moving = IsMoving()
                    
                    if keysPressed[Enum.KeyCode.W] or keysPressed[Enum.KeyCode.A] or 
                       keysPressed[Enum.KeyCode.S] or keysPressed[Enum.KeyCode.D] or
                       keysPressed[Enum.KeyCode.Q] or keysPressed[Enum.KeyCode.E] then
                        
                        local keyboardInput = Vector3.zero
                        if keysPressed[Enum.KeyCode.W] then keyboardInput = keyboardInput + Vector3.new(0, 0, -1) end
                        if keysPressed[Enum.KeyCode.S] then keyboardInput = keyboardInput + Vector3.new(0, 0, 1) end
                        if keysPressed[Enum.KeyCode.A] then keyboardInput = keyboardInput + Vector3.new(-1, 0, 0) end
                        if keysPressed[Enum.KeyCode.D] then keyboardInput = keyboardInput + Vector3.new(1, 0, 0) end
                        
                        local camRightFlat = Vector3.new(camRight.X, 0, camRight.Z).Unit
                        local camForwardFlat = Vector3.new(camForward.X, 0, camForward.Z).Unit
                        
                        moveDir = (camRightFlat * keyboardInput.X + camForwardFlat * keyboardInput.Z)
                        local targetVelocity = moveDir * speed
                        currentVelocity = currentVelocity:Lerp(targetVelocity, math.clamp(lerpSpeed * dt, 0, 0.9))
                        
                        local yInput = 0
                        if keysPressed[Enum.KeyCode.E] then yInput = 1 end
                        if keysPressed[Enum.KeyCode.Q] then yInput = -1 end
                        
                        local targetYVelocity = yInput * ySpeed * 1.5
                        currentYVelocity = currentYVelocity + (targetYVelocity - currentYVelocity) * math.clamp(lerpSpeed * dt * 0.8, 0, 0.9)
                        
                    elseif inputVector.Magnitude > 0.1 then
                        local camRightFlat = Vector3.new(camRight.X, 0, camRight.Z).Unit
                        local camForwardFlat = Vector3.new(camForward.X, 0, camForward.Z).Unit
                        
                        moveDir = (camRightFlat * inputVector.X + camForwardFlat * -inputVector.Z)
                        local targetVelocity = moveDir * speed
                        currentVelocity = currentVelocity:Lerp(targetVelocity, math.clamp(lerpSpeed * dt, 0, 0.9))
                        
                        local targetYVelocity = -camForward.Y * inputVector.Z * ySpeed * 1.5
                        currentYVelocity = currentYVelocity + (targetYVelocity - currentYVelocity) * math.clamp(lerpSpeed * dt * 0.8, 0, 0.9)
                    else
                        currentVelocity = currentVelocity:Lerp(Vector3.zero, math.clamp(lerpSpeed * dt * decelerationMultiplier, 0, 0.95))
                        currentYVelocity = currentYVelocity:Lerp(0, math.clamp(lerpSpeed * dt * decelerationMultiplier, 0, 0.95))
                    end

                    local finalVelocity = Vector3.new(currentVelocity.X, currentYVelocity, currentVelocity.Z)
                    local newPosition = root.Position + (finalVelocity * dt)
                    
                    local lookDirection
                    if moving and moveDir.Magnitude > 0.1 then
                        local currentLook = root.CFrame.LookVector
                        local currentLookFlat = Vector3.new(currentLook.X, 0, currentLook.Z).Unit
                        lookDirection = currentLookFlat:Lerp(moveDir, math.clamp(rotationLerpSpeed * dt, 0, 1))
                    else
                        local camLookVector = camCF.LookVector
                        lookDirection = Vector3.new(camLookVector.X, 0, camLookVector.Z).Unit
                    end
                    
                    local distance = (newPosition - root.Position).Magnitude
                    if distance > 0.005 then
                        if distance > 3 then
                            local steps = math.min(2, math.ceil(distance / 2.5))
                            for i = 1, steps do
                                local stepPos = root.Position:Lerp(newPosition, i / steps)
                                pcall(function()
                                    if lookDirection.Magnitude > 0 then
                                        root.CFrame = CFrame.lookAt(stepPos, stepPos + lookDirection)
                                    else
                                        root.CFrame = CFrame.new(stepPos)
                                    end
                                end)
                                if i < steps then
                                    task.wait(0.016)
                                end
                            end
                        else
                            local randomMicro = Vector3.new(
                                math.random(-1, 1) / 5000000,
                                math.random(-1, 1) / 5000000,
                                math.random(-1, 1) / 5000000
                            )
                            newPosition = newPosition + randomMicro
                            
                            pcall(function()
                                if lookDirection.Magnitude > 0 then
                                    root.CFrame = CFrame.lookAt(newPosition, newPosition + lookDirection)
                                else
                                    root.CFrame = CFrame.new(newPosition)
                                end
                            end)
                        end
                    else
                        pcall(function()
                            if lookDirection.Magnitude > 0 then
                                root.CFrame = CFrame.lookAt(root.Position, root.Position + lookDirection)
                            end
                        end)
                    end
                    
                    table.insert(velocityHistory, finalVelocity)
                    if #velocityHistory > 10 then
                        table.remove(velocityHistory, 1)
                    end
                    
                    lastPosition = root.Position
                end)
            end

            InitializeFly()
            StartFlyLoop()
        else
            -- Clean up fly system
            if flyConnection then
                flyConnection:Disconnect()
                flyConnection = nil
            end
            
            if antiFallConnection then
                antiFallConnection:Disconnect()
                antiFallConnection = nil
            end
            
            -- Reset shiftlock/mouse behavior
            if UIS.MouseEnabled then
                UIS.MouseBehavior = Enum.MouseBehavior.Default
            end
            
            -- Reset character state
            local char = game.Players.LocalPlayer.Character
            if char then
                local humanoid = char:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.Running)
                end
                
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CanCollide = true
                end
            end
        end
    end
})

Misc:Section({Title = "Character Modifications"})
Misc:Divider()



local disableInjuriesEnabled = false
local injuriesConnection

Misc:Toggle({
    Title = "Disable Injuries",
    Desc = "Removes injured walking",
    Value = false,
    Callback = function(state)
        disableInjuriesEnabled = state
        if state then
            -- Function to remove injured walking
            local function removeInjuredWalking(character)
                if not character then return end
                local old = character:FindFirstChild("InjuredWalking")
                if old then old:Destroy() end
            end
            
            -- Remove from current character
            local currentChar = game.Players.LocalPlayer.Character
            if currentChar then
                removeInjuredWalking(currentChar)
            end
            
            -- Set up connection for future characters
            injuriesConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Wait for character to fully load
                removeInjuredWalking(character)
                
                -- Also monitor for new InjuredWalking objects being added
                character.ChildAdded:Connect(function(child)
                    if child.Name == "InjuredWalking" then
                        child:Destroy()
                    end
                end)
            end)
        else
            if injuriesConnection then
                injuriesConnection:Disconnect()
                injuriesConnection = nil
            end
        end
    end
})

local disableStunEnabled = false
local stunConnection

Misc:Toggle({
    Title = "Disable Stun/Slow",
    Desc = "Removes stun and slow effects",
    Value = false,
    Callback = function(state)
        disableStunEnabled = state
        if state then
            -- Function to remove stun/slow effects (case insensitive)
            local function removeStunEffects(character)
                if not character then return end
                
                for _, child in pairs(character:GetChildren()) do
                    if string.lower(child.Name):find("stun") or string.lower(child.Name):find("slow") then
                        child:Destroy()
                    end
                end
            end
            
            -- Remove from current character
            local currentChar = game.Players.LocalPlayer.Character
            if currentChar then
                removeStunEffects(currentChar)
            end
            
            -- Set up connection for future characters and monitoring
            stunConnection = game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) -- Wait for character to fully load
                removeStunEffects(character)
                
                -- Monitor for new stun/slow objects being added
                character.ChildAdded:Connect(function(child)
                    if string.lower(child.Name):find("stun") or string.lower(child.Name):find("slow") then
                        child:Destroy()
                    end
                end)
            end)
        else
            if stunConnection then
                stunConnection:Disconnect()
                stunConnection = nil
            end
        end
    end
})


local antiRagdollEnabled = false
local antiRagdollConnections = {}

local function BypassRagdoll()
    local character = LocalPlayer.Character
    if not character then return end

    
    for _, child in ipairs(character:GetChildren()) do
        if child.Name == "Ragdoll" then
            child:Destroy()
        elseif table.find({"Stun", "RotateDisabled", "RagdollWakeupImmunity", "InjuredWalking"}, child.Name) then
            child:Destroy()
        end
    end

    
    if antiRagdollConnections[character] then
        antiRagdollConnections[character]:Disconnect()
    end
    
    antiRagdollConnections[character] = character.ChildAdded:Connect(function(child)
        if child.Name == "Ragdoll" then
            task.spawn(function()
                child:Destroy()
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                end
            end)
        elseif table.find({"Stun", "RotateDisabled"}, child.Name) then
            task.spawn(function() child:Destroy() end)
        end
    end)

    
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        for _, obj in ipairs(humanoidRootPart:GetChildren()) do
            if obj:IsA("BallSocketConstraint") or obj.Name:match("^CacheAttachment") then
                obj:Destroy()
            end
        end
    end

    
    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        for _, jointName in ipairs({"Left Hip", "Left Shoulder", "Neck", "Right Hip", "Right Shoulder"}) do
            local motor = torso:FindFirstChild(jointName)
            if motor and motor:IsA("Motor6D") and not motor.Part0 then
                motor.Part0 = torso
            end
        end
    end

    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part:FindFirstChild("BoneCustom") then
            part.BoneCustom:Destroy()
        end
    end
end

Misc:Toggle({
    Title = "Anti Ragdoll",
    Desc = "Prevents ragdoll effects and stuns",
    Value = false,
    Callback = function(state)
        antiRagdollEnabled = state
        if state then
            
            BypassRagdoll()
            
            
            antiRagdollConnections.charAdded = LocalPlayer.CharacterAdded:Connect(function(character)
                task.wait(0.5) 
                BypassRagdoll()
            end)
        else
            
            for _, conn in pairs(antiRagdollConnections) do
                if conn then conn:Disconnect() end
            end
            antiRagdollConnections = {}
        end
    end
})


local speedBoostEnabled = false
local originalSpeedValue = nil

Misc:Toggle({
    Title = "Speed Boost",
    Desc = "Boosts your speed",
    Value = false,
    Callback = function(state)
        speedBoostEnabled = state
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            local fasterSprint = boosts:FindFirstChild("Faster Sprint")
            
            if fasterSprint then
                if state then
                    
                    if originalSpeedValue == nil then
                        originalSpeedValue = fasterSprint.Value
                    end
                    
                    fasterSprint.Value = 10
                else
                    
                    if originalSpeedValue then
                        fasterSprint.Value = originalSpeedValue
                    else
                        
                        fasterSprint.Value = 1
                    end
                end
            end
        end)
    end
})


LocalPlayer.CharacterAdded:Connect(function(character)
    if speedBoostEnabled then
        task.wait(1) 
        pcall(function()
            local boosts = game:GetService("Players").LocalPlayer:WaitForChild("Boosts")
            if boosts:FindFirstChild("Faster Sprint") then
                boosts["Faster Sprint"].Value = 10
            end
        end)
    end
end)


Misc:Slider({
    Title = "Jump Boost",
    Desc = "Boosts your jump power",
    Value = {
        Min = 50,
        Max = 100,
        Default = 50,
    },
    Callback = function(value)
        pcall(function()
            local player = game:GetService("Players").LocalPlayer
            local character = workspace.Live:FindFirstChild(player.Name)
            if character then
                local jumpPower = character:FindFirstChild("JumpPowerAmount")
                if jumpPower then
                    jumpPower.Value = value
                end
            end
        end)
    end
})


LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(1) 
    local slider = Misc:FindFirstChild("Jump Boost")
    if slider then
        
        slider.Callback(slider:GetValue())
    end
end)


local noclipEnabled = false
local noclipConnection

local function noclipLoop()
    if noclipEnabled and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end

Misc:Toggle({
    Title = "NoClip",
    Desc = "Walk through walls and objects",
    Value = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            
            noclipConnection = RunService.Stepped:Connect(noclipLoop)
            
            
            LocalPlayer.CharacterAdded:Connect(function(char)
                task.wait(0.5) 
                if noclipEnabled then
                    noclipLoop()
                end
            end)
        else
            
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
            
            
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end
})


Visual:Section({Title = "ESP"})
Visual:Divider()


local playerESPEnabled = false
local playerHighlights = {}
local playerConnections = {}

local function createPlayerESP(player)
    if not player or player == LocalPlayer then return end

    
    if playerHighlights[player] then
        playerHighlights[player]:Destroy()
        playerHighlights[player] = nil
    end

    if not playerESPEnabled then return end

    local function setupESP(character)
        if not character or not character:FindFirstChild("Humanoid") then return end

        
        local highlight = Instance.new("Highlight")
        highlight.Name = "PlayerESP"
        highlight.Adornee = character
        highlight.FillColor = Color3.fromRGB(0, 170, 255) 
        highlight.OutlineColor = Color3.fromRGB(0, 100, 255)
        highlight.FillTransparency = 0.5
        highlight.Parent = character
        playerHighlights[player] = highlight

        
        playerConnections[player] = character:GetPropertyChangedSignal("Parent"):Connect(function()
            if not character.Parent then
                highlight:Destroy()
                playerHighlights[player] = nil
            end
        end)
    end

    
    if player.Character then
        setupESP(player.Character)
    end

    
    playerConnections[player.."Added"] = player.CharacterAdded:Connect(setupESP)
end

local function updatePlayerESP()
    
    for player, highlight in pairs(playerHighlights) do
        if highlight then highlight:Destroy() end
    end
    table.clear(playerHighlights)

    for player, conn in pairs(playerConnections) do
        if conn then conn:Disconnect() end
    end
    table.clear(playerConnections)

    if not playerESPEnabled then return end

    
    for _, player in ipairs(Players:GetPlayers()) do
        createPlayerESP(player)
    end

    
    playerConnections.playerAdded = Players.PlayerAdded:Connect(createPlayerESP)
end

Visual:Toggle({
    Title = "ESP Players",
    Desc = "Highlights all players in the game",
    Value = false,
    Callback = function(state)
        playerESPEnabled = state
        updatePlayerESP()
    end
})


local guardESPEnabled = false
local guardESPConnections = {}
local guardHighlights = {}
local guardBillboards = {}

local function CreateGuardESP(guardModel)
    if not guardModel:FindFirstChild("Humanoid") then return end

    
    if guardHighlights[guardModel] then
        guardHighlights[guardModel]:Destroy()
        guardHighlights[guardModel] = nil
    end
    if guardBillboards[guardModel] then
        guardBillboards[guardModel]:Destroy()
        guardBillboards[guardModel] = nil
    end

    if not guardESPEnabled then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "GuardESP"
    highlight.Adornee = guardModel
    highlight.FillColor = Color3.fromRGB(255, 100, 0)  
    highlight.OutlineColor = Color3.fromRGB(200, 50, 0)
    highlight.FillTransparency = 0.4
    highlight.Parent = guardModel
    guardHighlights[guardModel] = highlight

    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = guardModel:WaitForChild("Head")
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "GUARD"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = billboard
    billboard.Parent = guardModel
    guardBillboards[guardModel] = billboard

    
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        guardHighlights[guardModel] = nil
        guardBillboards[guardModel] = nil
    end

    
    guardESPConnections[guardModel] = guardModel.Humanoid.Died:Connect(cleanup)

    
    guardESPConnections[guardModel.."Removing"] = guardModel.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
            if guardESPConnections[guardModel] then
                guardESPConnections[guardModel]:Disconnect()
                guardESPConnections[guardModel] = nil
            end
        end
    end)
end

local function SetupGuardESP()
    
    for guard, highlight in pairs(guardHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(guardHighlights)
    
    for guard, billboard in pairs(guardBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(guardBillboards)
    
    for guard, conn in pairs(guardESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(guardESPConnections)

    if not guardESPEnabled then return end

    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():find("guard") then
            CreateGuardESP(obj)
        end
    end

    
    guardESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and obj.Name:lower():find("guard") then
            CreateGuardESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Guards",
    Desc = "Highlights all guards in the game",
    Value = false,
    Callback = function(state)
        guardESPEnabled = state
        SetupGuardESP()
    end
})

Visual:Section({Title = "Hide and Seek"})
Visual:Divider()


local HidersESPEnabled = false
local HuntersESPEnabled = false
local hiderHighlights = {}
local hunterHighlights = {}
local hiderBillboards = {}
local hunterBillboards = {}


local HIDER_COLOR = Color3.fromRGB(0, 170, 255)  
local HUNTER_COLOR = Color3.fromRGB(255, 50, 50) 

local function applyESP(player)
    if player == LocalPlayer then return end 

    
    if hiderHighlights[player] then
        hiderHighlights[player]:Destroy()
        hiderHighlights[player] = nil
    end
    if hunterHighlights[player] then
        hunterHighlights[player]:Destroy()
        hunterHighlights[player] = nil
    end
    if hiderBillboards[player] then
        hiderBillboards[player]:Destroy()
        hiderBillboards[player] = nil
    end
    if hunterBillboards[player] then
        hunterBillboards[player]:Destroy()
        hunterBillboards[player] = nil
    end

    local character = player.Character or player.CharacterAdded:Wait()
    if not character then return end

    
    local isHider = player:GetAttribute("IsHider")
    local isHunter = player:GetAttribute("IsHunter")

    
    if (isHider and HidersESPEnabled) or (isHunter and HuntersESPEnabled) then
        
        local highlight = Instance.new("Highlight")
        highlight.Adornee = character
        highlight.FillColor = isHider and HIDER_COLOR or HUNTER_COLOR
        highlight.OutlineColor = Color3.new(1, 1, 1)
        highlight.FillTransparency = 0.5
        highlight.Parent = character

        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "RoleLabel"
        billboard.Adornee = character:WaitForChild("Head") or character:WaitForChild("HumanoidRootPart")
        billboard.Size = UDim2.new(0, 100, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        billboard.AlwaysOnTop = true
        billboard.LightInfluence = 1
        billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local label = Instance.new("TextLabel")
        label.Text = isHider and "HIDER" or "HUNTER"
        label.TextColor3 = isHider and HIDER_COLOR or HUNTER_COLOR
        label.TextSize = 14
        label.Font = Enum.Font.Oswald
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextStrokeTransparency = 0.5
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Parent = billboard
        billboard.Parent = character

        
        if isHider then
            hiderHighlights[player] = highlight
            hiderBillboards[player] = billboard
        else
            hunterHighlights[player] = highlight
            hunterBillboards[player] = billboard
        end
    end

    
    player:GetAttributeChangedSignal("IsHider"):Connect(function()
        applyESP(player) 
    end)
    player:GetAttributeChangedSignal("IsHunter"):Connect(function()
        applyESP(player) 
    end)
end

local function updateAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        applyESP(player)
    end
end


Players.PlayerAdded:Connect(applyESP)
Players.PlayerRemoving:Connect(function(player)
    if hiderHighlights[player] then
        hiderHighlights[player]:Destroy()
        hiderHighlights[player] = nil
    end
    if hunterHighlights[player] then
        hunterHighlights[player]:Destroy()
        hunterHighlights[player] = nil
    end
    if hiderBillboards[player] then
        hiderBillboards[player]:Destroy()
        hiderBillboards[player] = nil
    end
    if hunterBillboards[player] then
        hunterBillboards[player]:Destroy()
        hunterBillboards[player] = nil
    end
end)


Visual:Toggle({
    Title = "ESP Hiders",
    Desc = "Highlights hiders",
    Value = false,
    Callback = function(state)
        HidersESPEnabled = state
        updateAllESP()
    end
})

Visual:Toggle({
    Title = "ESP Hunters",
    Desc = "Highlights hunters",
    Value = false,
    Callback = function(state)
        HuntersESPEnabled = state
        updateAllESP()
    end
})


for _, player in ipairs(Players:GetPlayers()) do
    applyESP(player)
end


for _, player in ipairs(Players:GetPlayers()) do
    applyESP(player)
end


local keyESPEnabled = false
local keyESPConnections = {}
local keyHighlights = {}
local keyBillboards = {}

local function KeyESP(keyModel)
    if not keyModel or not keyModel:IsA("Model") or not keyModel.PrimaryPart then
        return
    end

    
    if keyHighlights[keyModel] then
        keyHighlights[keyModel]:Destroy()
        keyHighlights[keyModel] = nil
    end
    if keyBillboards[keyModel] then
        keyBillboards[keyModel]:Destroy()
        keyBillboards[keyModel] = nil
    end

    if not keyESPEnabled then return end

    
    local highlight = Instance.new("Highlight")
    highlight.Name = "KeyESP"
    highlight.Adornee = keyModel
    highlight.FillColor = Color3.fromRGB(255, 255, 0)  
    highlight.OutlineColor = Color3.fromRGB(255, 215, 0) 
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.Parent = keyModel
    keyHighlights[keyModel] = highlight

    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "KeyLabel"
    billboard.Adornee = keyModel.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 1
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local label = Instance.new("TextLabel")
    label.Text = "KEY"
    label.TextColor3 = Color3.fromRGB(255, 255, 0) 
    label.TextSize = 14
    label.Font = Enum.Font.Oswald
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextStrokeTransparency = 0.5
    label.TextStrokeColor3 = Color3.new(0, 0, 0) 
    label.Parent = billboard
    billboard.Parent = keyModel
    keyBillboards[keyModel] = billboard

    
    local connection
    connection = keyModel.AncestryChanged:Connect(function(_, parent)
        if not parent or not keyModel:IsDescendantOf(game) then
            if highlight and highlight.Parent then
                highlight:Destroy()
            end
            if billboard and billboard.Parent then
                billboard:Destroy()
            end
            if connection then
                connection:Disconnect()
            end
            keyHighlights[keyModel] = nil
            keyBillboards[keyModel] = nil
        end
    end)

    keyESPConnections[keyModel] = connection
end

local function SetupKeyESP()
    
    for key, highlight in pairs(keyHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(keyHighlights)
    
    for key, billboard in pairs(keyBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(keyBillboards)
    
    for key, conn in pairs(keyESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(keyESPConnections)

    if not keyESPEnabled then return end

    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name:lower():find("key") and obj:IsA("Model") then
            KeyESP(obj)
        end
    end

    
    keyESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj.Name:lower():find("key") and obj:IsA("Model") then
            KeyESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Key",
    Desc = "Highlights keys in Hide and Seek with billboard text",
    Value = false,
    Callback = function(state)
        keyESPEnabled = state
        SetupKeyESP()
    end
})


local escapeDoorESPEnabled = false
local escapeDoorHighlights = {}
local escapeDoorBillboards = {}
local escapeDoorConnections = {}

local function EscapeDoorESP(door)
    
    if not door or not door:IsA("Model") then return end
    if not door.PrimaryPart then return end
    
    
    if escapeDoorHighlights[door] or escapeDoorBillboards[door] then return end

    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = door
    highlight.FillColor = Color3.fromRGB(0, 255, 0)  
    highlight.OutlineColor = Color3.fromRGB(0, 200, 0)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.Parent = door
    escapeDoorHighlights[door] = highlight

    
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = door.PrimaryPart
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "ESCAPE DOOR"
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextSize = 14
    label.Font = Enum.Font.Oswald
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Parent = billboard
    billboard.Parent = door
    escapeDoorBillboards[door] = billboard

    
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        escapeDoorHighlights[door] = nil
        escapeDoorBillboards[door] = nil
    end

    
    escapeDoorConnections[door] = door.AncestryChanged:Connect(function(_, parent)
        if not parent then cleanup() end
    end)
end

local function SetupEscapeDoorESP()
    
    for door, highlight in pairs(escapeDoorHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(escapeDoorHighlights)
    
    for door, billboard in pairs(escapeDoorBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(escapeDoorBillboards)
    
    for door, conn in pairs(escapeDoorConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(escapeDoorConnections)

    if not escapeDoorESPEnabled then return end

    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj.Name == "EXITDOOR" then
            EscapeDoorESP(obj)
        end
    end

    
    escapeDoorConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj.Name == "EXITDOOR" then
            EscapeDoorESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Escape Doors",
    Desc = "Highlights escape doors in Hide and Seek",
    Value = false,
    Callback = function(state)
        escapeDoorESPEnabled = state
        SetupEscapeDoorESP()
    end
})


local doorESPEnabled = false
local doorESPConnections = {}
local doorHighlights = {}
local doorBillboards = {}

local function DoorESP(door)
    if not door:IsA("Model") or not door.PrimaryPart then return end
    
    
    if not (door.Name:find("Door") or door.Name:find("door")) then return end

    
    if doorHighlights[door] then
        doorHighlights[door]:Destroy()
        doorHighlights[door] = nil
    end
    if doorBillboards[door] then
        doorBillboards[door]:Destroy()
        doorBillboards[door] = nil
    end

    if not doorESPEnabled then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DoorESP"
    highlight.Adornee = door
    highlight.FillColor = Color3.fromRGB(255, 165, 0)  
    highlight.OutlineColor = Color3.fromRGB(255, 100, 0)
    highlight.FillTransparency = 0.6
    highlight.Parent = door
    doorHighlights[door] = highlight

    
    local keyNeeded = door:GetAttribute("KeyNeeded") or "Unknown"
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = door.PrimaryPart
    billboard.Size = UDim2.new(0, 150, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.AlwaysOnTop = true

    local label = Instance.new("TextLabel")
    label.Text = "DOOR (Key: "..keyNeeded..")"
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextSize = 14
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Parent = billboard
    billboard.Parent = door
    doorBillboards[door] = billboard

    
    local function cleanup()
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
        doorHighlights[door] = nil
        doorBillboards[door] = nil
    end

    
    doorESPConnections[door] = door.AncestryChanged:Connect(function(_, parent)
        if not parent then
            cleanup()
            if doorESPConnections[door] then
                doorESPConnections[door]:Disconnect()
                doorESPConnections[door] = nil
            end
        end
    end)
end

local function SetupDoorESP()
    
    for door, highlight in pairs(doorHighlights) do
        if highlight and highlight.Parent then
            highlight:Destroy()
        end
    end
    table.clear(doorHighlights)
    
    for door, billboard in pairs(doorBillboards) do
        if billboard and billboard.Parent then
            billboard:Destroy()
        end
    end
    table.clear(doorBillboards)
    
    for door, conn in pairs(doorESPConnections) do
        if conn then
            conn:Disconnect()
        end
    end
    table.clear(doorESPConnections)

    if not doorESPEnabled then return end

    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            DoorESP(obj)
        end
    end

    
    doorESPConnections.descendantAdded = workspace.DescendantAdded:Connect(function(obj)
        if obj:IsA("Model") then
            DoorESP(obj)
        end
    end)
end

Visual:Toggle({
    Title = "ESP Door and Required Key",
    Desc = "Highlights doors and shows required key",
    Value = false,
    Callback = function(state)
        doorESPEnabled = state
        SetupDoorESP()
    end
})

Peabert:Section({Title = "Peabert"})
Peabert:Divider()

-- Variables for Peabert functionality
local peabertList = {}
local selectedPeabert = nil
local peabertDropdown -- Declare the variable at a higher scope

-- Function to find and populate Peabert dropdown
local function updatePeabertDropdown()
    table.clear(peabertList)
    
    -- Search for specific FREEPEABERT objects (1-6)
    for i = 1, 6 do
        local peabertName = "FREEPEABERT" .. i
        local peabert = workspace:FindFirstChild(peabertName)
        if peabert then
            table.insert(peabertList, peabertName)
        end
    end
    
    -- Update dropdown only if it exists
    if peabertDropdown then
        if #peabertList > 0 then
            peabertDropdown:Refresh(peabertList, true)
            selectedPeabert = peabertList[1] -- Set first as default
        else
            peabertDropdown:Refresh({"No Peaberts Found"}, false)
            selectedPeabert = nil
        end
    end
end

-- Create Peabert dropdown
peabertDropdown = Peabert:Dropdown({
    Title = "Select Peabert",
    Values = {"Searching for Peaberts..."},
    Callback = function(selected)
        selectedPeabert = selected
    end
})

-- Button to refresh Peabert list
Peabert:Button({
    Title = "Refresh Peabert List",
    Callback = function()
        updatePeabertDropdown()
        if #peabertList > 0 then
            WindUI:Notify({
                Title = "Peabert",
                Content = "Found " .. #peabertList .. " Peabert(s)",
                Duration = 3
            })
        else
            WindUI:Notify({
                Title = "Peabert",
                Content = "No Peaberts found in workspace",
                Duration = 3
            })
        end
    end
})

-- Button to teleport to selected Peabert
Peabert:Button({
    Title = "Teleport to Selected Peabert",
    Desc = "Teleports to the selected Peabert and sets up free power rolls",
    Callback = function()
        if not selectedPeabert or selectedPeabert == "No Peaberts Found" then
            WindUI:Notify({
                Title = "Error",
                Content = "No Peabert selected or found",
                Duration = 3
            })
            return
        end
        
        local peabert = workspace:FindFirstChild(selectedPeabert)
        if not peabert then
            return
        end
        
        -- Teleport to Peabert
        local character = LocalPlayer.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            character:PivotTo(peabert:GetPrimaryPartCFrame() + Vector3.new(0, 3, 0))
            
            -- Find and modify the proximity prompt
            local function findAndModifyPrompt(model)
                for _, descendant in ipairs(model:GetDescendants()) do
                    if descendant:IsA("ProximityPrompt") and descendant.Name:find("2 FREE POWER ROLLS") then
                        descendant.HoldDuration = 0
                        WindUI:Notify({
                            Title = "Peabert",
                            Content = "Teleported",
                            Duration = 3
                        })
                        return true
                    end
                end
                return false
            end
            
            -- Check Body.Root path first
            local body = peabert:FindFirstChild("Body")
            if body then
                local root = body:FindFirstChild("Root")
                if root and findAndModifyPrompt(root) then
                    return
                end
            end
            
            -- If not found in Body.Root, search the entire Peabert
            if not findAndModifyPrompt(peabert) then
                WindUI:Notify({
                    Title = "Warning",
                    Content = "Teleported but couldn't find power roll prompt",
                    Duration = 3
                })
            end
        end
    end
})

-- Auto-refresh Peabert list on startup and when objects are added
task.spawn(function()
    task.wait(2) -- Wait a bit for game to load
    updatePeabertDropdown()
    
    -- Monitor for new objects being added
    workspace.ChildAdded:Connect(function(child)
        if child.Name:match("^FREEPEABERT[1-6]$") then
            task.wait(0.5) -- Small delay to ensure object is fully loaded
            updatePeabertDropdown()
        end
    end)
end)