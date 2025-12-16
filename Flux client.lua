local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

local function new(className, props)
    local obj = Instance.new(className)
    if props then
        for k,v in pairs(props) do
            obj[k] = v
        end
    end
    return obj
end

local screenGui = new("ScreenGui", {
    Name = "FluxClientGUI",
    ResetOnSpawn = false,
    Parent = playerGui,
})

-- Watermark
local watermark = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 160, 0, 30),
    Position = UDim2.new(0, 10, 0, 10),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.3,
})
new("UICorner", {Parent = watermark, CornerRadius = UDim.new(0,8)})

local watermarkText = new("TextLabel", {
    Parent = watermark,
    Size = UDim2.new(1, 0, 1, 0),
    BackgroundTransparency = 1,
    Text = "Flux Client",
    Font = Enum.Font.SourceSansSemibold,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
})

coroutine.wrap(function()
    while true do
        if watermark and watermarkText then
            local colorValue = math.sin(tick() * 5) * 0.5 + 0.5
            watermarkText.TextColor3 = Color3.new(colorValue, colorValue, colorValue)
        end
        wait(0.03)
    end
end)()

-- Login Frame
local loginFrame = new("Frame", {
    Parent = screenGui,
    Size = UDim2.new(0, 300, 0, 160),
    Position = UDim2.new(0.5, -150, 0.5, -80),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.5,
    ZIndex = 20,
})
new("UICorner", {Parent = loginFrame, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = loginFrame, Color = Color3.fromRGB(0,0,0), Transparency = 0.6})

new("TextLabel", {
    Parent = loginFrame,
    Position = UDim2.new(0, 12, 0, 8),
    Size = UDim2.new(1, -24, 0, 24),
    BackgroundTransparency = 1,
    Text = "Flux Client",
    Font = Enum.Font.SourceSansSemibold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(255,255,255),
    TextXAlignment = Enum.TextXAlignment.Center,
})

local passwordBox = new("TextBox", {
    Parent = loginFrame,
    Size = UDim2.new(0.85, 0, 0, 28),
    Position = UDim2.new(0.075, 0, 0.4, 0),
    PlaceholderText = "Введите ключ...",
    Text = "",
    Font = Enum.Font.SourceSans,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    BackgroundTransparency = 0.1,
    ClearTextOnFocus = false,
})
new("UICorner", {Parent = passwordBox, CornerRadius = UDim.new(0,6)})

local loginButton = new("TextButton", {
    Parent = loginFrame,
    Size = UDim2.new(0.5, 0, 0, 28),
    Position = UDim2.new(0.25, 0, 0.7, 0),
    BackgroundColor3 = Color3.fromRGB(40,40,40),
    Text = "Войти",
    Font = Enum.Font.SourceSans,
    TextSize = 16,
    TextColor3 = Color3.fromRGB(255,255,255),
})
new("UICorner", {Parent = loginButton, CornerRadius = UDim.new(0,6)})

local loginError = new("TextLabel", {
    Parent = loginFrame,
    Size = UDim2.new(1, 0, 0, 20),
    Position = UDim2.new(0, 0, 0.9, 0),
    BackgroundTransparency = 1,
    Text = "",
    Font = Enum.Font.SourceSans,
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255,0,0),
    TextXAlignment = Enum.TextXAlignment.Center,
})

-- Main Window
local floatBtn = new("Frame", {
    Name = "FloatButton",
    Parent = screenGui,
    Size = UDim2.new(0, 60, 0, 60),
    Position = UDim2.new(0.02, 0, 0.5, -30),
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.25,
    ZIndex = 10,
    Visible = false,
})
new("UICorner", {Parent = floatBtn, CornerRadius = UDim.new(0,12)})

local btn = new("TextButton", {
    Parent = floatBtn,
    Size = UDim2.new(1,0,1,0),
    BackgroundTransparency = 1,
    Text = "≡",
    Font = Enum.Font.SourceSansBold,
    TextSize = 28,
    TextColor3 = Color3.fromRGB(255,255,255),
    AutoButtonColor = false,
    ZIndex = 11,
})

local window = new("Frame", {
    Name = "MainWindow",
    Parent = screenGui,
    Size = UDim2.new(0, 520, 0, 340),
    Position = UDim2.new(0.5, -260, 0.5, -170),
    Visible = false,
    BackgroundColor3 = Color3.fromRGB(0,0,0),
    BackgroundTransparency = 0.5,
    ZIndex = 9,
})
new("UICorner", {Parent = window, CornerRadius = UDim.new(0,10)})
new("UIStroke", {Parent = window, Color = Color3.fromRGB(0,0,0), Transparency = 0.6})

local btnClose = new("TextButton", {
    Parent = window,
    Size = UDim2.new(0,28,0,28),
    Position = UDim2.new(1,-36,0,4),
    BackgroundTransparency = 1,
    Text = "×",
    Font = Enum.Font.SourceSansBold,
    TextSize = 18,
    TextColor3 = Color3.fromRGB(255,255,255),
    ZIndex = 12,
})

-- ESP, Tracer, Hitbox
local ESP_Enabled = false
local Tracer_Enabled = false
local Hitbox_Enabled = false
local InfinityJump_Enabled = false
local Speed_Enabled = false
local Wallhack_Enabled = false
local NightVision_Enabled = false
local NoFall_Enabled = false
local AntiKnockback_Enabled = false
local FastBullets_Enabled = false
local HitEffect_Enabled = false
local SwingAnimation_Enabled = false
local Derp_Enabled = false

local WalkSpeed_Value = 26
local ESP_Connections = {}
local OriginalSizes = {}
local FastBulletsConnections = {}
local SwingAnimationConnections = {}
local DerpForce = nil

-- NIGHT VISION
local function setNightVision(state)
    if state then
        Lighting.Ambient = Color3.new(1,1,1)
        Lighting.ColorShift_Bottom = Color3.new(1,1,1)
        Lighting.ColorShift_Top = Color3.new(1,1,1)
    else
        Lighting.Ambient = Color3.new(0,0,0)
        Lighting.ColorShift_Bottom = Color3.new(0,0,0)
        Lighting.ColorShift_Top = Color3.new(0,0,0)
    end
end

-- NO FALL
local function noFall()
    if NoFall_Enabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            humanoid:ChangeState("Running")
        end
    end
end

-- ANTI KNOCKBACK
local function antiKnockback()
    if AntiKnockback_Enabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end
end

-- ESP FUNCTIONS
local function createTracer()
    local tracer = Drawing.new("Line")
    tracer.Color = Color3.new(1,1,1)
    tracer.Thickness = 1
    tracer.Transparency = 1
    return tracer
end

local function createBox()
    local box = Drawing.new("Square")
    box.Color = Color3.new(1,1,1)
    box.Thickness = 1.5
    box.Transparency = 1
    box.Filled = false
    return box
end

local function createESP(plr)
    if plr == player then return end
    local box = createBox()
    local tracer = createTracer()

    local conn
    conn = RunService.RenderStepped:Connect(function()
        local visible = false
        if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = plr.Character.HumanoidRootPart
            local head = plr.Character:FindFirstChild("Head")
            local pos, vis = camera:WorldToViewportPoint(hrp.Position)

            if vis then
                local headPos = camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.5,0))
                local footPos = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
                local height = footPos.Y - headPos.Y
                local width = height / 2

                box.Size = Vector2.new(width, height)
                box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
                box.Visible = ESP_Enabled

                tracer.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                tracer.To = Vector2.new(pos.X, pos.Y)
                tracer.Visible = Tracer_Enabled

                visible = true
            end
        end
        if not visible then
            box.Visible = false
            tracer.Visible = false
        end
    end)

    plr.AncestryChanged:Connect(function()
        box:Remove()
        tracer:Remove()
        conn:Disconnect()
        ESP_Connections[plr] = nil
    end)

    ESP_Connections[plr] = conn
end

for _,plr in ipairs(Players:GetPlayers()) do
    createESP(plr)
end

-- HITBOX EXPAND
local function applyHitboxToPlayer(plr)
    if not Hitbox_Enabled or plr == player then return end
    local function apply(character)
        local hrp = character:WaitForChild("HumanoidRootPart",5)
        local head = character:WaitForChild("Head",5)
        if not hrp or not head then return end
        if not OriginalSizes[plr] then
            OriginalSizes[plr] = {
                HRP_Size = hrp.Size,
                HRP_CanCollide = hrp.CanCollide,
                Head_Size = head.Size,
                Head_CanCollide = head.CanCollide
            }
        end
        hrp.Size = OriginalSizes[plr].HRP_Size * 3
        hrp.CanCollide = false
        head.Size = OriginalSizes[plr].Head_Size * 10
        head.CanCollide = false
    end
    if plr.Character then
        apply(plr.Character)
    end
    plr.CharacterAdded:Connect(function(char)
        task.wait(0.8)
        if Hitbox_Enabled then
            apply(char)
        end
    end)
end

Players.PlayerAdded:Connect(applyHitboxToPlayer)
for _,plr in ipairs(Players:GetPlayers()) do
    applyHitboxToPlayer(plr)
end

-- WALLHACK
local function setWallhack(state)
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(player.Character) then
            if state then
                obj.LocalTransparencyModifier = 0.5
                obj.CanCollide = false
            else
                obj.LocalTransparencyModifier = 0
                obj.CanCollide = true
            end
        end
    end
end

-- DERP FUNCTION
local function setDerp(state)
    if not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if state then
        if not DerpForce then
            DerpForce = Instance.new("BodyAngularVelocity")
            DerpForce.AngularVelocity = Vector3.new(0,80,0)
            DerpForce.MaxTorque = Vector3.new(0,math.huge,0)
            DerpForce.P = 10000
            DerpForce.Parent = hrp
        end
    else
        if DerpForce then
            DerpForce:Destroy()
            DerpForce = nil
        end
    end
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    if Derp_Enabled then
        setDerp(true)
    end
end)

-- INFINITY JUMP
UserInputService.JumpRequest:Connect(function()
    if InfinityJump_Enabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.FloorMaterial ~= Enum.Material.Air then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- SPEED & ANTI FALL & ANTI KNOCKBACK
RunService.Heartbeat:Connect(function()
    if Speed_Enabled and player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = WalkSpeed_Value
        end
    elseif player.Character then
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.WalkSpeed ~= 16 then
            humanoid.WalkSpeed = 16
        end
    end
    noFall()
    antiKnockback()
end)

-- UI BUTTONS (ESP, Hitbox, Wallhack, Tracer, InfinityJump, Speed, NightVision, NoFall, AntiKnockback, Derp)
local btnWidth, btnHeight, btnSpacingY = 0.4, 28, 30
local function createToggleButton(name,posX,posY,callback)
    local button = new("TextButton",{
        Parent = window,
        Size = UDim2.new(btnWidth,0,0,btnHeight),
        Position = UDim2.new(posX,0,0,posY),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        BackgroundTransparency = 0,
        Text = name,
        Font = Enum.Font.SourceSans,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255,255,255),
    })
    new("UICorner",{Parent=button,CornerRadius=UDim.new(0,6)})
    button.MouseButton1Click:Connect(function()
        local state = callback()
        if state then
            button.BackgroundColor3 = Color3.fromRGB(255,255,255)
            button.BackgroundTransparency = 0.7
        else
            button.BackgroundColor3 = Color3.fromRGB(40,40,40)
            button.BackgroundTransparency = 0
        end
    end)
    return button
end

createToggleButton("ESP",0.05,85,function() ESP_Enabled = not ESP_Enabled return ESP_Enabled end)
createToggleButton("Hitbox",0.55,85,function() Hitbox_Enabled = not Hitbox_Enabled return Hitbox_Enabled end)
createToggleButton("Wallhack",0.05,85+btnSpacingY,function() Wallhack_Enabled = not Wallhack_Enabled setWallhack(Wallhack_Enabled) return Wallhack_Enabled end)
createToggleButton("Tracer",0.55,85+btnSpacingY,function() Tracer_Enabled = not Tracer_Enabled return Tracer_Enabled end)
createToggleButton("Infinity Jump",0.05,85+btnSpacingY*2,function() InfinityJump_Enabled = not InfinityJump_Enabled return InfinityJump_Enabled end)
createToggleButton("Speed",0.55,85+btnSpacingY*2,function() Speed_Enabled = not Speed_Enabled return Speed_Enabled end)
createToggleButton("Night Vision",0.05,85+btnSpacingY*3,function() NightVision_Enabled = not NightVision_Enabled setNightVision(NightVision_Enabled) return NightVision_Enabled end)
createToggleButton("No Fall",0.55,85+btnSpacingY*3,function() NoFall_Enabled = not NoFall_Enabled return NoFall_Enabled end)
createToggleButton("Anti Knockback",0.05,85+btnSpacingY*4,function() AntiKnockback_Enabled = not AntiKnockback_Enabled return AntiKnockback_Enabled end)
createToggleButton("Derp",0.55,85+btnSpacingY*4,function() Derp_Enabled = not Derp_Enabled setDerp(Derp_Enabled) return Derp_Enabled end)

-- PLAYER LIST
local playerListFrame = new("ScrollingFrame", {
    Parent = window,
    Position = UDim2.new(0.05, 0, 0.7, 0),
    Size = UDim2.new(0.9, 0, 0.25, 0),
    BackgroundColor3 = Color3.fromRGB(30,30,30),
    BackgroundTransparency = 0,
    ScrollBarThickness = 6,
    CanvasSize = UDim2.new(0,0,0,0),
})
new("UICorner", {Parent = playerListFrame, CornerRadius = UDim.new(0,6)})

local uiListLayout = new("UIListLayout", {
    Parent = playerListFrame,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0,4),
})

local function updateCanvasSize()
    playerListFrame.CanvasSize = UDim2.new(0,0,0,uiListLayout.AbsoluteContentSize.Y + 4)
end

uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

-- Функция для добавления игрока в список
local function addPlayerToList(plr)
    if plr == player then return end
    local item = new("Frame", {
        Parent = playerListFrame,
        Size = UDim2.new(1,0,0,28),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
    })
    new("UICorner", {Parent=item, CornerRadius=UDim.new(0,4)})

    local nameLabel = new("TextLabel", {
        Parent = item,
        Size = UDim2.new(0.7,0,1,0),
        Position = UDim2.new(0,4,0,0),
        BackgroundTransparency = 1,
        Text = plr.Name,
        Font = Enum.Font.SourceSans,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local espToggle = new("TextButton", {
        Parent = item,
        Size = UDim2.new(0.25,0,0.7,0),
        Position = UDim2.new(0.72,0,0.15,0),
        BackgroundColor3 = Color3.fromRGB(40,40,40),
        Text = "ESP",
        Font = Enum.Font.SourceSans,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255,255,255),
    })
    new("UICorner",{Parent=espToggle, CornerRadius=UDim.new(0,4)})

    local espState = false
    espToggle.MouseButton1Click:Connect(function()
        espState = not espState
        if espState then
            espToggle.BackgroundColor3 = Color3.fromRGB(0,200,0)
            createESP(plr)
        else
            espToggle.BackgroundColor3 = Color3.fromRGB(40,40,40)
            if ESP_Connections[plr] then
                ESP_Connections[plr]:Disconnect()
                ESP_Connections[plr] = nil
            end
        end
    end)
end

-- Добавляем всех игроков при запуске
for _, plr in ipairs(Players:GetPlayers()) do
    addPlayerToList(plr)
end

-- Слушаем новых игроков
Players.PlayerAdded:Connect(addPlayerToList)

-- Закрытие окна
btnClose.MouseButton1Click:Connect(function()
    window.Visible = false
end)

-- Переключение основного окна через кнопку
btn.MouseButton1Click:Connect(function()
    window.Visible = not window.Visible
end)

-- ЛОГИН
local VALID_KEYS = {
    ["1234"] = true,
    ["flux"] = true,
    ["admin"] = true,
}

loginButton.MouseButton1Click:Connect(function()
    local key = passwordBox.Text
    if VALID_KEYS[key] then
        loginFrame.Visible = false
        floatBtn.Visible = true
    else
        loginError.Text = "Неверный ключ!"
    end
end)
