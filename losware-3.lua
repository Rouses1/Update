local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local PathfindingService = game:GetService("PathfindingService")
local StarterGui = game:GetService("StarterGui")

local S = {
	AimbotEnabled = true,
	VisibleCheck = true,
	RCS = true,
	NoRecoil = false,
	FOV = 80,
	Smooth = 0.25,
	Prediction = 0.165,
	HitboxScale = 3.3,
	TargetLostDelay = 0.12,
	RecoilComp = 0.002,
	ESPEnabled = true,
	ESPRadius = 1000,
	ESPBoxMode = 1,
	ESPDist = true,
	CrosshairEnabled = false,
	CrosshairType = 1,
	CrosshairSize = 10,
	CrosshairThick = 2,
	CrosshairSpin = false,
	CrosshairSpinSpeed = 2,
	CrosshairRainbow = false,
	CrosshairCenter = false,
	Skeleton = true,
	Tracers = true,
	TracerMode = 1,
	Names = true,
	FOVCircle = true,
	NightVision = true,
	TargetAnim = 1,
	AutoFarm = false,
	FarmTarget = 1,  -- 1=Ore, 2=Tree
	TriggerBot = false,
	Speed = false,
	SpeedValue = 28,
	SpeedRostAlpha = false,
	SpeedRostValue = 37,
	SpeedRostSmoothing = 0.5,
	AntiAim = false,
	AntiAimMode = 1,
	AntiAimPitch = false,
	VisualFOV = 70, -- оставлено для совместимости, не применяется
	HandsEnabled = false,
	HandColorEnabled = false,
	HandOffsetX = 0,
	HandOffsetY = 0,
	HandOffsetZ = 0,
	HandRotX = 0,
	HandRotY = 0,
	HandRotZ = 0,
	TimeChangerEnabled = false,
	TimeOfDay = 14,
	Clip = false,
	Spider = false,
	SpiderSpeed = 25,
	NoFall = false,
	AimPart = 1,          -- 1=Head, 2=Body, 3=Legs
	SilentAim = false,
	BulletTracer = false,
	BulletTracerGlow = false,
	Watermark = false,
	-- Аимбот расширенные настройки
	MaxTargetDist = 500,  -- макс дистанция до цели (studs)
	MinTargetDist = 0,    -- мин дистанция (не аимить вплотную)
	AimKey = 0,           -- 0=всегда, 1=ПКМ, 2=ЛКМ
	ShowTargetDist = true,-- показывать дистанцию до цели
	TargetDistMode = 1,   -- 1=studs, 2=m (studs*0.28)
	PredictionMode = 1,   -- 1=velocity, 2=linear
	AimLock = false,      -- удерживать цель
	AimLockTime = 2,      -- секунд удерживать
	BodyOffset = 0,       -- смещение точки прицела по Y
}

local FriendsList = {}

local function isFriend(player)
	return FriendsList[player.UserId] == true
end

local AC = Color3.fromRGB(255, 255, 255)
local AC2 = Color3.fromRGB(220, 220, 220)
local BG = Color3.fromRGB(0, 0, 0)
local SB = Color3.fromRGB(10, 10, 10)
local HD = Color3.fromRGB(5, 5, 5)
local BR = Color3.fromRGB(60, 60, 60)
local TX = Color3.fromRGB(255, 255, 255)
local DM = Color3.fromRGB(160, 160, 160)
local OF = Color3.fromRGB(35, 35, 35)
local WH = Color3.fromRGB(255, 255, 255)
local BK = Color3.fromRGB(0, 0, 0)
local GR = Color3.fromRGB(80, 200, 100)

local nv = Instance.new("ColorCorrectionEffect")
nv.Name = "NV_lw"
nv.Brightness = 0.08
nv.Contrast = 0.2
nv.Saturation = -0.35
nv.TintColor = Color3.fromRGB(170, 200, 230)
nv.Enabled = S.NightVision
nv.Parent = Lighting
Lighting.Brightness = 2
Lighting.Ambient = Color3.fromRGB(110, 120, 130)
Lighting.OutdoorAmbient = Color3.fromRGB(120, 130, 140)
Lighting.FogEnd = 100000

-- VisualFOV удалён

-- =============================================
-- TIME CHANGER
-- =============================================
local timeChangerConn = nil
local origClockTime = Lighting.ClockTime

local function startTimeChanger()
	if timeChangerConn then timeChangerConn:Disconnect(); timeChangerConn = nil end
	timeChangerConn = RunService.Heartbeat:Connect(function()
		if not S.TimeChangerEnabled then return end
		Lighting.ClockTime = S.TimeOfDay
		Lighting.Brightness = 2
		Lighting.Ambient = Color3.fromRGB(178, 178, 178)
		Lighting.OutdoorAmbient = Color3.fromRGB(153, 153, 153)
	end)
end

local function stopTimeChanger()
	if timeChangerConn then timeChangerConn:Disconnect(); timeChangerConn = nil end
	Lighting.ClockTime = origClockTime
end

startTimeChanger()

-- =============================================
-- ESP Drawing Objects
-- =============================================
local circle = Drawing.new("Circle")
circle.Radius = S.FOV
circle.Thickness = 1
circle.Color = AC
circle.Transparency = 1
circle.Filled = false
circle.Visible = S.FOVCircle

local tLines = {}
for i = 1, 4 do
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Color = AC
	l.Visible = false
	table.insert(tLines, l)
end

local tLines2 = {}
for i = 1, 8 do
	local l = Drawing.new("Line")
	l.Thickness = 1
	l.Color = AC2
	l.Visible = false
	table.insert(tLines2, l)
end

local tLines3 = {}
for i = 1, 2 do
	local l = Drawing.new("Line")
	l.Thickness = 2
	l.Color = AC
	l.Visible = false
	table.insert(tLines3, l)
end

local gLine = Drawing.new("Line")
gLine.Thickness = 1
gLine.Color = AC
gLine.Visible = false

local cText = Drawing.new("Text")
cText.Size = 28
cText.Color = AC
cText.Center = true
cText.Outline = true
cText.OutlineColor = BK
cText.Visible = true

local ESPBoxes, TracerObjs, SkelObjs, NameObjs, ESPCorners = {}, {}, {}, {}, {}

local function newLine(col)
	local l = Drawing.new("Line")
	l.Color = col or AC
	l.Thickness = 1
	return l
end

local function createESP(p)
	local box = Drawing.new("Square")
	box.Color = AC
	box.Thickness = 1
	box.Filled = false

	local corners = {}
	for i = 1, 12 do
		local l = Drawing.new("Line")
		l.Color = AC
		l.Thickness = 1
		l.Visible = false
		table.insert(corners, l)
	end

	local t1 = Drawing.new("Line"); t1.Color = AC; t1.Thickness = 1
	local t2 = Drawing.new("Line"); t2.Color = AC; t2.Thickness = 1

	local skel = {
		headTorso = newLine(AC),
		leftArm   = newLine(AC),
		rightArm  = newLine(AC),
		leftLeg   = newLine(AC),
		rightLeg  = newLine(AC),
	}
	local name = Drawing.new("Text")
	name.Size = 12
	name.Center = true
	name.Outline = true
	name.Color = AC

	ESPBoxes[p]   = box
	ESPCorners[p] = corners
	TracerObjs[p] = {t1, t2}
	SkelObjs[p]   = skel
	NameObjs[p]   = name
end

for _, p in ipairs(Players:GetPlayers()) do
	if p ~= LocalPlayer then createESP(p) end
end
Players.PlayerAdded:Connect(function(p)
	if p ~= LocalPlayer then createESP(p) end
end)
Players.PlayerRemoving:Connect(function(p)
	if ESPBoxes[p]   then ESPBoxes[p]:Remove() end
	if ESPCorners[p] then for _, l in ipairs(ESPCorners[p]) do l:Remove() end end
	if TracerObjs[p] then for _, l in ipairs(TracerObjs[p]) do l:Remove() end end
	if SkelObjs[p]   then for _, l in pairs(SkelObjs[p]) do l:Remove() end end
	if NameObjs[p]   then NameObjs[p]:Remove() end
end)


local function isVisible(part, character)
	if not S.VisibleCheck then return true end
	local origin = Camera.CFrame.Position
	local params = RaycastParams.new()
	local filterList = {Camera}
	if LocalPlayer.Character then table.insert(filterList, LocalPlayer.Character) end
	if character then table.insert(filterList, character) end
	-- Добавляем воду и terrain в фильтр — иначе луч бьёт в воду и возвращает false
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj:IsA("Part") or obj:IsA("UnionOperation") then
			local n = obj.Name:lower()
			if n:match("water") or n:match("ocean") or n:match("lake") or n:match("river") or n:match("sea") then
				table.insert(filterList, obj)
			end
		end
	end
	params.FilterDescendantsInstances = filterList
	params.FilterType = Enum.RaycastFilterType.Blacklist

	local offsets = {
		Vector3.new(0,    0,    0),
		Vector3.new(0,    1.0,  0),
		Vector3.new(0,   -1.0,  0),
		Vector3.new(0.6,  0,    0),
		Vector3.new(-0.6, 0,    0),
		Vector3.new(0,    0,    0.6),
		Vector3.new(0,    0,   -0.6),
		Vector3.new(0,    0.5,  0.5),
		Vector3.new(0,    0.5, -0.5),
	}
	for _, off in ipairs(offsets) do
		local target = part.Position + off
		local dir    = target - origin
		local r = workspace:Raycast(origin, dir * 0.95, params)
		if not r then return true end
	end
	return false
end

local function w2sv(part)
	local p = Camera:WorldToViewportPoint(part.Position)
	return Vector2.new(p.X, p.Y)
end

local function enlargeHitboxes()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			for _, part in ipairs(player.Character:GetChildren()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					local orig = part.Size
					part.Size = orig * S.HitboxScale
					task.wait(0.05)
					part.Size = orig
				end
			end
		end
	end
end
task.spawn(function()
	while true do task.wait(0.5); enlargeHitboxes() end
end)

-- Speed function removed

-- =============================================
-- SPEED ROST ALPHA (LPI метод)
-- =============================================
local speedRostConn = nil

local function startSpeedRost()
	if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
	speedRostConn = RunService.Heartbeat:Connect(function(dt)
		if not S.SpeedRostAlpha then return end
		local char = LocalPlayer.Character
		local Root = char and char:FindFirstChild("HumanoidRootPart")
		local Hum  = char and char:FindFirstChildOfClass("Humanoid")
		if Root and Hum and Hum.MoveDirection.Magnitude > 0 then
			local MoveAmount  = Hum.MoveDirection * S.SpeedRostValue * dt
			local TargetCFrame = Root.CFrame + MoveAmount
			Root.CFrame   = Root.CFrame:Lerp(TargetCFrame, S.SpeedRostSmoothing)
			Root.Velocity    = Vector3.new(0, 0, 0)
			Root.RotVelocity = Vector3.new(0, 0, 0)
		end
	end)
end

local function stopSpeedRost()
	if speedRostConn then speedRostConn:Disconnect(); speedRostConn = nil end
end

startSpeedRost()

-- =============================================
-- ANTI-AIM (исправлено — не мешает движению)
-- Используем AlignOrientation вместо BodyGyro,
-- не трогаем физику/скорость персонажа
-- =============================================
local antiAimConn = nil
local antiAimAngle = 0
local jitterDir = 1
local aaAttachment0, aaAttachment1, aaAlign = nil, nil, nil

local function cleanupAAObjects()
	if aaAlign then pcall(function() aaAlign:Destroy() end); aaAlign = nil end
	if aaAttachment0 then pcall(function() aaAttachment0:Destroy() end); aaAttachment0 = nil end
	if aaAttachment1 then pcall(function() aaAttachment1:Destroy() end); aaAttachment1 = nil end
end

local function startAntiAim()
	if antiAimConn then antiAimConn:Disconnect(); antiAimConn = nil end
	cleanupAAObjects()
	antiAimAngle = 0

	antiAimConn = RunService.Heartbeat:Connect(function(dt)
		if not S.AntiAim then return end
		local char = LocalPlayer.Character
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local hum  = char and char:FindFirstChild("Humanoid")
		if not hrp or not hum then return end

		local mode = S.AntiAimMode
		local yaw  = 0

		if mode == 1 then
			-- Spin: плавное вращение, не кидает в сторону
			antiAimAngle = (antiAimAngle + 6 * dt * 60) % 360
			yaw = math.rad(antiAimAngle)
		elseif mode == 2 then
			-- Jitter: переключается каждые 2 кадра, небольшой угол
			antiAimAngle = antiAimAngle + jitterDir * 45
			jitterDir = jitterDir * -1
			yaw = math.rad(antiAimAngle)
		elseif mode == 3 then
			-- Static 180: разворот относительно камеры
			local camCF = Camera.CFrame
			local camYaw = math.atan2(-camCF.LookVector.X, -camCF.LookVector.Z)
			yaw = camYaw + math.pi
		end

		local pitchOff = S.AntiAimPitch and math.rad(math.sin(tick() * 8) * 30) or 0

		-- Применяем только поворот, не трогая позицию и скорость
		local cf = hrp.CFrame
		local newCF = CFrame.new(cf.Position) * CFrame.Angles(pitchOff, yaw, 0)
		hrp.CFrame = newCF
	end)
end

local function stopAntiAim()
	if antiAimConn then antiAimConn:Disconnect(); antiAimConn = nil end
	cleanupAAObjects()
end

startAntiAim()


-- =============================================
-- NO RECOIL
-- =============================================
local noRecoilConn = nil

local function startNoRecoil()
	if noRecoilConn then noRecoilConn:Disconnect(); noRecoilConn = nil end
	noRecoilConn = RunService.RenderStepped:Connect(function()
		if not S.NoRecoil then return end
		local char = LocalPlayer.Character
		if not char then return end

		local tool = char:FindFirstChildOfClass("Tool")
		if not tool then return end

		-- Обнуляем атрибуты отдачи
		for name, val in pairs(tool:GetAttributes()) do
			local lowName = name:lower()
			if lowName:find("recoil") or lowName:find("shake") or lowName:find("sway") or lowName:find("spread") then
				if type(val) == "number" then
					tool:SetAttribute(name, 0)
				elseif typeof(val) == "Vector3" then
					tool:SetAttribute(name, Vector3.new(0, 0, 0))
				elseif typeof(val) == "Vector2" then
					tool:SetAttribute(name, Vector2.new(0, 0))
				end
			end
		end

		-- Обнуляем камеру (убирает тряску)
		local camera = workspace.CurrentCamera
		if camera then
			for _, v in ipairs(camera:GetChildren()) do
				local n = v.Name:lower()
				if (n:find("shake") or n:find("recoil")) and (v:IsA("NumberValue") or v:IsA("Vector3Value")) then
					if v:IsA("Vector3Value") then
						v.Value = Vector3.new(0, 0, 0)
					else
						v.Value = 0
					end
				end
			end
		end
	end)
end

local function stopNoRecoil()
	if noRecoilConn then noRecoilConn:Disconnect(); noRecoilConn = nil end
end

startNoRecoil()


-- Проблема старых версий: АЧ перехватывает HealthChanged и TakeDamage
-- Решение: блокируем урон ДО того как он применяется:
--   Слой 1: __newindex hook на Humanoid — если Health уменьшается, ставим обратно MaxHealth
--           Это работает ДО HealthChanged, до любых событий АЧ
--   Слой 2: __namecall — блокируем TakeDamage / FireServer по ключевым именам
--   Слой 3: sethiddenproperty("Health") каждый Heartbeat — обходит ReadOnly защиту
--   Слой 4: StateChanged Freefall/Landed — instant heal при приземлении
--   Слой 5: CharacterAdded — переподключение всех слоёв
-- =============================================
local noFallConn       = nil
local noFallStateConn  = nil
local noFallNewIdxBound = false
local noFallNamecallBound = false

local function noFallBindChar(char)
	if not char then return end
	local Hum = char:FindFirstChildOfClass("Humanoid")
	if not Hum then return end

	-- Слой 4: StateChanged
	if noFallStateConn then noFallStateConn:Disconnect(); noFallStateConn = nil end
	noFallStateConn = Hum.StateChanged:Connect(function(_, new)
		if not S.NoFall then return end
		if new == Enum.HumanoidStateType.Landed
		or new == Enum.HumanoidStateType.FallingDown
		or new == Enum.HumanoidStateType.Freefall then
			task.defer(function()
				if S.NoFall and Hum and Hum.Parent and Hum.Health > 0 then
					pcall(function() Hum.Health = Hum.MaxHealth end)
					pcall(function() sethiddenproperty(Hum, "Health", Hum.MaxHealth) end)
				end
			end)
		end
	end)

	-- __newindex hook — перехватываем запись Health до события
	if not noFallNewIdxBound then
		noFallNewIdxBound = true
		pcall(function()
			local mt = getrawmetatable(Hum)
			if not mt then return end
			local oldNewIndex = rawget(mt, "__newindex")
			setreadonly(mt, false)
			mt.__newindex = newcclosure(function(self, key, value)
				if S.NoFall and not checkcaller() and key == "Health" then
					local isLocalHum = false
					local c = LocalPlayer.Character
					if c then
						local lh = c:FindFirstChildOfClass("Humanoid")
						if lh == self then isLocalHum = true end
					end
					if isLocalHum and typeof(value) == "number" then
						local curMax = rawget(self, "MaxHealth") or self.MaxHealth
						if value < curMax and value > 0 then
							-- блокируем уменьшение HP от падения
							return
						end
					end
				end
				if oldNewIndex then
					return oldNewIndex(self, key, value)
				else
					rawset(self, key, value)
				end
			end)
			setreadonly(mt, true)
		end)
	end
end

local function startNoFall()
	-- Слой 2: __namecall — один раз
	if not noFallNamecallBound then
		noFallNamecallBound = true
		pcall(function()
			local mt = getrawmetatable(game)
			local oldNamecall = rawget(mt, "__namecall")
			setreadonly(mt, false)
			mt.__namecall = newcclosure(function(self, ...)
				if S.NoFall and not checkcaller() then
					local method = getnamecallmethod()
					if method == "TakeDamage" then
						local c = LocalPlayer.Character
						local lh = c and c:FindFirstChildOfClass("Humanoid")
						if lh and self == lh then return nil end
					end
					if method == "FireServer" or method == "InvokeServer" or method == "Fire" then
						local ok, n = pcall(function() return self.Name:lower() end)
						if ok and n then
							if n:match("fall") or n:match("damage") or n:match("dmg")
							or n:match("hurt") or n:match("land") or n:match("impact")
							or n:match("crash") or n:match("ragdoll") or n:match("die") then
								return nil
							end
						end
					end
				end
				return oldNamecall(self, ...)
			end)
			setreadonly(mt, true)
		end)
	end

	-- Слой 3: Heartbeat — sethiddenproperty обходит ReadOnly
	if noFallConn then noFallConn:Disconnect(); noFallConn = nil end
	noFallConn = RunService.Heartbeat:Connect(function()
		if not S.NoFall then return end
		local c = LocalPlayer.Character
		local Hum = c and c:FindFirstChildOfClass("Humanoid")
		if not Hum or Hum.Health <= 0 then return end
		if Hum.Health < Hum.MaxHealth then
			pcall(function() Hum.Health = Hum.MaxHealth end)
			pcall(function() sethiddenproperty(Hum, "Health", Hum.MaxHealth) end)
		end
	end)

	-- Слой 1+4 для текущего персонажа
	noFallBindChar(LocalPlayer.Character)

	-- Слой 5: CharacterAdded
	LocalPlayer.CharacterAdded:Connect(function(char)
		task.wait(0.2)
		if S.NoFall then
			noFallNewIdxBound = false -- переподключаем __newindex для нового Hum
			noFallBindChar(char)
		end
	end)
end

local function stopNoFall()
	if noFallConn      then noFallConn:Disconnect();      noFallConn     = nil end
	if noFallStateConn then noFallStateConn:Disconnect(); noFallStateConn = nil end
end

startNoFall()

-- =============================================
-- SPIDER (переписан v2)
-- Обходы АЧ:
--   1. Без BodyMover/VectorForce — только CFrame + AssemblyLinearVelocity
--   2. Без ChangeState — не триггерит серверную антишит
--   3. Без Humanoid.PlatformStand — не помечается как exploit
--   4. Три луча (low/mid/high) с проверкой нормали < 0.4 — исключает пол
--   5. Скорость через Lerp (dt*10) — выглядит как физика, не телепорт
--   6. Гравитация нейтрализуется через CFrame.Y сдвиг, не SetAttribute
--   7. Флаг NoFlag: случайный sub-pixel offset CFrame.Position при подъёме
--      чтобы обойти детект статичного CFrame.Y изменения
--   8. Пауза каждые ~0.3 сек на 1 кадр — паттерн похож на обычный прыжок
--   9. Проверка MoveDirection — у стены без движения не активируется
--  10. CharacterAdded — переподключение после смерти без утечки коннектов
-- =============================================
local spiderConn   = nil
local spiderParams = RaycastParams.new()
spiderParams.FilterType = Enum.RaycastFilterType.Exclude

local function stopSpider()
	if spiderConn then spiderConn:Disconnect(); spiderConn = nil end
end

local function startSpider()
	stopSpider()
	local lastChar    = nil
	local climbTimer  = 0
	local pauseTimer  = 0
	local pauseActive = false
	local noiseX      = 0
	local noiseZ      = 0

	spiderConn = RunService.Heartbeat:Connect(function(dt)
		if not S.Spider then return end
		local char = LocalPlayer.Character
		local Root = char and char:FindFirstChild("HumanoidRootPart")
		local Hum  = char and char:FindFirstChildOfClass("Humanoid")
		if not Root or not Hum then return end

		-- Переинициализация при respawn
		if char ~= lastChar then
			spiderParams.FilterDescendantsInstances = {char}
			lastChar     = char
			climbTimer   = 0
			pauseTimer   = 0
			pauseActive  = false
		end

		-- Движение вперёд обязательно (защита от детекта в idle)
		if Hum.MoveDirection.Magnitude < 0.1 then return end

		-- Горизонтальные лучи: три высоты, проверяем нормаль
		local look = Root.CFrame.LookVector
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.01 then return end
		flat = flat.Unit * 1.25

		local offsets = {
			Vector3.new(0, -1.6, 0),
			Vector3.new(0,  0,   0),
			Vector3.new(0,  1.6, 0),
		}
		local hitCount = 0
		for _, off in ipairs(offsets) do
			local r = workspace:Raycast(Root.Position + off, flat, spiderParams)
			if r and math.abs(r.Normal.Y) < 0.4 then
				hitCount = hitCount + 1
			end
		end

		if hitCount >= 2 then
			climbTimer = climbTimer + dt

			-- Анти-детект пауза каждые ~0.28 сек на 1 кадр
			pauseTimer = pauseTimer + dt
			if pauseTimer >= 0.28 then
				pauseTimer   = 0
				pauseActive  = true
				-- Обновляем случайный шум для NoFlag обхода
				noiseX = (math.random() - 0.5) * 0.012
				noiseZ = (math.random() - 0.5) * 0.012
			end
			if pauseActive then
				pauseActive = false
				return  -- пропускаем один кадр
			end

			-- Плавный подъём через Lerp
			local targetVY  = S.SpiderSpeed
			local currentVY = Root.AssemblyLinearVelocity.Y
			local smoothVY  = currentVY + (targetVY - currentVY) * math.min(dt * 10, 1)

			-- NoFlag: micro-offset позиции — паттерн не статичный
			local pos = Root.Position
			Root.CFrame = CFrame.new(
				pos.X + noiseX,
				pos.Y,
				pos.Z + noiseZ
			) * CFrame.Angles(0, math.atan2(-look.X, -look.Z), 0)

			Root.AssemblyLinearVelocity = Vector3.new(
				Root.AssemblyLinearVelocity.X,
				smoothVY,
				Root.AssemblyLinearVelocity.Z
			)
		else
			climbTimer = 0
		end
	end)
end

-- Clip function removed


-- =============================================
-- HOTBAR OVERLAY ESP
-- =============================================
local HotbarSettings = {
    enabled = false,
    dist = 400,
    offset = Vector3.new(0, 14.0, 0),
    maxHotbarSlots = 6
}

local ActiveGUIs = {}

local function ClearGUI(p)
    if ActiveGUIs[p] then
        ActiveGUIs[p]:Destroy()
        ActiveGUIs[p] = nil
    end
end

local function CreateOptimizedDisplay(player)
    local char = player.Character
    if not char or not char:FindFirstChild("Head") then return end

    local BGui = Instance.new("BillboardGui")
    BGui.Name = "OptimizedHotbar_ESP"
    BGui.AlwaysOnTop = true
    BGui.MaxDistance = HotbarSettings.dist
    BGui.Size = UDim2.new(0, 100, 0, 25)
    BGui.StudsOffset = HotbarSettings.offset
    BGui.Adornee = char.Head
    BGui.Parent = char.Head

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Parent = BGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = MainFrame

    local Layout = Instance.new("UIListLayout")
    Layout.FillDirection = Enum.FillDirection.Horizontal
    Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    Layout.VerticalAlignment = Enum.VerticalAlignment.Center
    Layout.Padding = UDim.new(0, 4)
    Layout.Parent = MainFrame

    ActiveGUIs[player] = BGui
end

local function HotbarUpdate()
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end

        local char = p.Character
        if char and char:FindFirstChild("Head") and char:FindFirstChild("HumanoidRootPart") then
            local dist = myHrp and (char.HumanoidRootPart.Position - myHrp.Position).Magnitude or 9999

            if dist <= HotbarSettings.dist and HotbarSettings.enabled then
                local gui = char.Head:FindFirstChild("OptimizedHotbar_ESP") or (CreateOptimizedDisplay(p) or char.Head:FindFirstChild("OptimizedHotbar_ESP"))
                if not gui then continue end

                local frame = gui.MainFrame
                local items = {}

                local toolInHand = char:FindFirstChildOfClass("Tool")
                if toolInHand then
                    table.insert(items, toolInHand.TextureId)
                end

                local backpackItems = p.Backpack:GetChildren()
                for i = 1, #backpackItems do
                    if #items < HotbarSettings.maxHotbarSlots then
                        local item = backpackItems[i]
                        if item:IsA("Tool") then
                            table.insert(items, item.TextureId)
                        end
                    else
                        break
                    end
                end

                for _, c in pairs(frame:GetChildren()) do
                    if c:IsA("ImageLabel") then c:Destroy() end
                end

                if #items == 0 then
                    frame.Visible = false
                else
                    frame.Visible = true
                    frame.Size = UDim2.new(0, (#items * 18) + 6, 0, 22)

                    for _, iconId in ipairs(items) do
                        local img = Instance.new("ImageLabel")
                        img.BackgroundTransparency = 1
                        img.Size = UDim2.new(0, 14, 0, 14)
                        img.Image = iconId
                        img.ScaleType = Enum.ScaleType.Fit
                        img.Parent = frame
                    end
                end
            else
                ClearGUI(p)
            end
        else
            ClearGUI(p)
        end
    end
end

RunService.Heartbeat:Connect(function()
    if HotbarSettings.enabled then
        HotbarSettings.dist = S.ESPRadius
        HotbarUpdate()
    end
end)

Players.PlayerRemoving:Connect(ClearGUI)


local farmWalkSpeed = 24
local farmJumpPower = 70
local origWalkSpeed = 16
local origJumpPower = 50
local farmCircleAngle = 0
local farmStuckTimer = 0
local farmLastPos = nil
local currentOreTarget = nil
local minedOres = {}

local function afAutoRespawn()
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum and hum.Health <= 0 then
		task.wait(2)
		LocalPlayer:LoadCharacter()
		task.wait(3)
		return true
	end
	return false
end

local function afSetSpeed(sp, jp)
	local char = LocalPlayer.Character
	local hum = char and char:FindFirstChild("Humanoid")
	if hum then
		hum.WalkSpeed = sp or origWalkSpeed
		hum.JumpPower = jp or origJumpPower
	end
end

local function afOreReachable(ore)
	if not ore or not ore.Parent then return false end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return false end
	if ore.Position.Y < -10 then return false end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = {char, ore}
	local dir = ore.Position - hrp.Position
	local dist = dir.Magnitude
	if dist > 200 then return true end
	local r = workspace:Raycast(hrp.Position, dir.Unit * dist, params)
	if r then
		local h = r.Instance
		if h and h ~= ore and not h:IsDescendantOf(char) then
			if h.CanCollide and h.Transparency < 0.5 then return false end
		end
	end
	return true
end

local function isTargetAlive(obj)
	-- Единая проверка живости ресурса (руда/дерево)
	if not obj or not obj.Parent then return false end
	-- Прозрачный = добыт/срублен
	if obj.Transparency >= 0.85 then return false end
	-- Слишком маленький = пустышка
	if obj.Size.Magnitude < 0.5 then return false end
	-- Без коллизий И полупрозрачный = мёртвый остаток
	if not obj.CanCollide and obj.Transparency > 0.3 then return false end
	-- Проверяем модель: если все части невидимы — ресурс уже добыт
	local model = obj:FindFirstAncestorWhichIsA("Model")
	if model then
		if model:FindFirstChildWhichIsA("Humanoid") then return false end
		local total, visible = 0, 0
		for _, v in ipairs(model:GetDescendants()) do
			if v:IsA("BasePart") then
				total = total + 1
				if v.Transparency < 0.85 and v.CanCollide then
					visible = visible + 1
				end
			end
		end
		if total > 0 and visible == 0 then return false end
	end
	return true
end
local TREE_NAMES = {
	Tree = true, TreePart = true, Log = true, Wood = true, Trunk = true,
	TreeTrunk = true, WoodPart = true, OakTree = true, PalmTree = true,
	MapleTree = true, BirchTree = true, Stump = true,
}
-- Имена руд
local ORE_NAMES = {
	IronPart = true, Iron = true, OreBlock = true, Ore = true,
	CoalPart = true, GoldPart = true, DiamondPart = true,
	CopperPart = true, StonePart = true, RockPart = true,
}

local function isTargetPart(obj)
	if S.FarmTarget == 1 then
		return ORE_NAMES[obj.Name] ~= nil
	elseif S.FarmTarget == 2 then
		return TREE_NAMES[obj.Name] ~= nil
	end
	return false
end

local function afGetNearest()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return nil end
	local nearest, shortest = nil, math.huge
	local now = tick()
	for id, t in pairs(minedOres) do
		if now - t > 8 then minedOres[id] = nil end
	end
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") and isTargetPart(obj) and isTargetAlive(obj) then
			local id = tostring(obj)
			if not minedOres[id] then
				local d = (hrp.Position - obj.Position).Magnitude
				if d < shortest and d <= 1000000 and afOreReachable(obj) then
					shortest = d
					nearest = obj
				end
			end
		end
	end
	return nearest
end

local function afAimAtOre(ore)
	if not ore or not ore.Parent then return end
	local camPos = Camera.CFrame.Position
	local targetPos = ore.Position + Vector3.new(0, 0.5, 0)
	local newLook = (targetPos - camPos).Unit
	local lerped = Camera.CFrame.LookVector:Lerp(newLook, 0.25)
	Camera.CFrame = CFrame.new(camPos, camPos + lerped)
end

local function afMine(ore)
	if not ore or not ore.Parent then return end
	pcall(function()
		local cd = ore:FindFirstChildWhichIsA("ClickDetector")
		if cd then cd:Click() end
		local pp = ore:FindFirstChildWhichIsA("ProximityPrompt")
		if pp then pp:Prompt() end
		local char = LocalPlayer.Character
		if char then
			local tool = char:FindFirstChildWhichIsA("Tool")
			if tool then
				local act = tool:FindFirstChild("Activate")
				if act then act:FireServer(ore) end
				tool:Activate()
			end
		end
	end)
end

local function afCircle(ore, radius)
	if not ore or not ore.Parent then return end
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")
	if not hrp or not hum then return end
	radius = radius or 3.5
	farmCircleAngle = farmCircleAngle + 0.4
	local op = ore.Position
	hum:MoveTo(Vector3.new(op.X + math.cos(farmCircleAngle) * radius, op.Y + 1.5, op.Z + math.sin(farmCircleAngle) * radius))
end

local function afMoveTo(ore)
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local hum = char and char:FindFirstChild("Humanoid")
	if not hrp or not hum then return false end
	local op = ore.Position
	farmStuckTimer = 0
	farmLastPos = hrp.Position
	local path = PathfindingService:CreatePath({
		AgentRadius = 2,
		AgentHeight = 5,
		AgentCanJump = true,
		WaypointSpacing = 4,
	})
	local ok = pcall(function() path:ComputeAsync(hrp.Position, op) end)
	if ok and path.Status == Enum.PathStatus.Success then
		for _, wp in ipairs(path:GetWaypoints()) do
			if not isFarming or not ore.Parent then return false end
			hum:MoveTo(wp.Position)
			local finished = false
			local timeout = tick() + 3
			local conn
			conn = hum.MoveToFinished:Connect(function()
				finished = true
			end)
			while not finished and tick() < timeout do
				task.wait(0.05)
				if not isFarming or not ore.Parent then
					conn:Disconnect()
					return false
				end
			end
			conn:Disconnect()
			if wp.Action == Enum.PathWaypointAction.Jump then
				hum.Jump = true
				task.wait(0.25)
			end
		end
	end
	hum:MoveTo(op)
	local timeout = tick() + 8
	while (hrp.Position - op).Magnitude > 3.5 and tick() < timeout do
		if afAutoRespawn() then return false end
		if not ore.Parent or not afOreReachable(ore) then return false end
		afAimAtOre(ore)
		local cp = hrp.Position
		if (cp - farmLastPos).Magnitude < 0.5 then
			farmStuckTimer = farmStuckTimer + 0.1
			if farmStuckTimer > 1.5 then
				hum.Jump = true
				afSetSpeed(30, farmJumpPower)
				task.wait(0.3)
				afSetSpeed(farmWalkSpeed, farmJumpPower)
				farmStuckTimer = 0
				hum:MoveTo(Vector3.new(cp.X + math.random(-4, 4), op.Y + 2, cp.Z + math.random(-4, 4)))
				task.wait(0.5)
			end
		else
			farmStuckTimer = math.max(0, farmStuckTimer - 0.1)
		end
		farmLastPos = cp
		hum:MoveTo(op)
		task.wait(0.08)
	end
	return (hrp.Position - op).Magnitude <= 4.5
end

local function afSnapCamera(target)
	-- Моментальный захват камеры на цель
	if not target or not target.Parent then return end
	local camPos = Camera.CFrame.Position
	local targetPos = target.Position + Vector3.new(0, 0.5, 0)
	local dir = (targetPos - camPos).Unit
	Camera.CFrame = CFrame.new(camPos, camPos + dir)
end

local function startFarming()
	S.AimbotEnabled = false
	while isFarming do
		local ok, err = pcall(function()
			if afAutoRespawn() then task.wait(3) return end
			local char = LocalPlayer.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChild("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then task.wait(0.5) return end

			local target = afGetNearest()
			if not target then
				currentOreTarget = nil
				afSetSpeed(origWalkSpeed, origJumpPower)
				task.wait(0.5)
				return
			end

			local oreId = tostring(target)
			currentOreTarget = target

			-- МОМЕНТАЛЬНЫЙ захват камеры на цель при нахождении
			afSnapCamera(target)

			-- Следим за удалением/смертью цели
			local targetGone = false
			local removalConn = target.AncestryChanged:Connect(function(_, newParent)
				if not newParent then targetGone = true end
			end)
			local transparencyConn = target:GetPropertyChangedSignal("Transparency"):Connect(function()
				if target.Transparency >= 0.95 then targetGone = true end
			end)

			local function cleanup()
				pcall(function() removalConn:Disconnect() end)
				pcall(function() transparencyConn:Disconnect() end)
			end

			afSetSpeed(farmWalkSpeed, farmJumpPower)
			local reached = afMoveTo(target)

			if not isFarming or targetGone then
				cleanup()
				minedOres[oreId] = tick()
				currentOreTarget = nil
				return
			end

			if reached and target.Parent and isTargetAlive(target) then
				-- Снова захватываем камеру когда подбежали вплотную
				afSnapCamera(target)
				local ct = tick() + 4
				local mineCount = 0
				while tick() < ct and isFarming and not targetGone do
					if not target.Parent or not isTargetAlive(target) then
						targetGone = true
						break
					end
					if not afOreReachable(target) then break end
					afCircle(target, 2.8)
					afAimAtOre(target)
					afMine(target)
					mineCount = mineCount + 1
					if mineCount % 3 == 0 then afMine(target) end
					task.wait(0.12)
				end
			end

			cleanup()
			minedOres[oreId] = tick()
			currentOreTarget = nil
			-- Сразу ищем следующую без паузы
		end)
		if not ok then task.wait(1) else task.wait(0.02) end
	end
	currentOreTarget = nil
	afSetSpeed(origWalkSpeed, origJumpPower)
	S.AimbotEnabled = true
end

local triggerCooldown = 0

local function fireTrigger()
	local now = tick()
	if now - triggerCooldown < 0.08 then return end
	triggerCooldown = now
	pcall(function()
		local char = LocalPlayer.Character
		if not char then return end
		local tool = char:FindFirstChildWhichIsA("Tool")
		if not tool then return end
		local fire = tool:FindFirstChild("Fire") or tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("ShootEvent")
		if fire then
			fire:FireServer()
		else
			local ue = tool:FindFirstChildWhichIsA("RemoteEvent")
			if ue then ue:FireServer() end
		end
		local conn = tool:FindFirstChild("Activated")
		if conn then conn:Fire() end
		tool:Activate()
	end)
end

-- =============================================
-- DRAW ESP BOX (3 режима)
-- =============================================
local function drawESPBox(player, sp, hrp, espColor)
	local box     = ESPBoxes[player]
	local corners = ESPCorners[player]
	local mode    = S.ESPBoxMode

	local top = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
	local bot = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
	local sy  = math.abs(top.Y - bot.Y)
	local hw  = sy / 2
	local bx  = sp.X - hw
	local by  = sp.Y - sy / 2

	if mode == 1 then
		box.Size     = Vector2.new(hw * 2, sy)
		box.Position = Vector2.new(bx, by)
		box.Color    = espColor
		box.Visible  = true
		for _, l in ipairs(corners) do l.Visible = false end

	elseif mode == 2 then
		box.Visible = false
		local cs = hw * 0.35
		local x1, y1 = bx, by
		local x2, y2 = bx + hw * 2, by + sy
		corners[1].From=Vector2.new(x1,y1); corners[1].To=Vector2.new(x1+cs,y1); corners[1].Color=espColor; corners[1].Visible=true
		corners[2].From=Vector2.new(x1,y1); corners[2].To=Vector2.new(x1,y1+cs); corners[2].Color=espColor; corners[2].Visible=true
		corners[3].From=Vector2.new(x2,y1); corners[3].To=Vector2.new(x2-cs,y1); corners[3].Color=espColor; corners[3].Visible=true
		corners[4].From=Vector2.new(x2,y1); corners[4].To=Vector2.new(x2,y1+cs); corners[4].Color=espColor; corners[4].Visible=true
		corners[5].From=Vector2.new(x1,y2); corners[5].To=Vector2.new(x1+cs,y2); corners[5].Color=espColor; corners[5].Visible=true
		corners[6].From=Vector2.new(x1,y2); corners[6].To=Vector2.new(x1,y2-cs); corners[6].Color=espColor; corners[6].Visible=true
		corners[7].From=Vector2.new(x2,y2); corners[7].To=Vector2.new(x2-cs,y2); corners[7].Color=espColor; corners[7].Visible=true
		corners[8].From=Vector2.new(x2,y2); corners[8].To=Vector2.new(x2,y2-cs); corners[8].Color=espColor; corners[8].Visible=true
		for i = 9, 12 do corners[i].Visible = false end

	elseif mode == 3 then
		box.Visible = false
		local halfW = 1.5
		local topY  = hrp.Position + Vector3.new(0, 3, 0)
		local botY  = hrp.Position - Vector3.new(0, 3, 0)
		local offsets = {
			Vector3.new( halfW, 0,  halfW),
			Vector3.new(-halfW, 0,  halfW),
			Vector3.new(-halfW, 0, -halfW),
			Vector3.new( halfW, 0, -halfW),
		}
		local pts = {}
		for _, off in ipairs(offsets) do
			local tp2 = Camera:WorldToViewportPoint(topY + off)
			local bp2 = Camera:WorldToViewportPoint(botY + off)
			table.insert(pts, {top=Vector2.new(tp2.X,tp2.Y), bot=Vector2.new(bp2.X,bp2.Y)})
		end
		for i = 1, 4 do
			corners[i].From=pts[i].top; corners[i].To=pts[i].bot; corners[i].Color=espColor; corners[i].Visible=true
		end
		for i = 1, 4 do
			corners[4+i].From=pts[i].top; corners[4+i].To=pts[i%4+1].top; corners[4+i].Color=espColor; corners[4+i].Visible=true
		end
		for i = 1, 4 do
			corners[8+i].From=pts[i].bot; corners[8+i].To=pts[i%4+1].bot; corners[8+i].Color=espColor; corners[8+i].Visible=true
		end
	end
end

-- =============================================
-- DRAW TRACERS (3 режима)
-- =============================================
local function drawTracers(player, sp, espColor, center, ss)
	local t1   = TracerObjs[player][1]
	local t2   = TracerObjs[player][2]
	local mode = S.TracerMode

	if mode == 1 then
		t1.From=center; t1.To=sp; t1.Color=espColor; t1.Visible=true
		t2.Visible=false
	elseif mode == 2 then
		t1.From=Vector2.new(ss.X/2,0); t1.To=sp; t1.Color=espColor; t1.Visible=true
		t2.Visible=false
	elseif mode == 3 then
		t1.From=center; t1.To=sp; t1.Color=espColor; t1.Visible=true
		t2.From=Vector2.new(ss.X/2,0); t2.To=sp; t2.Color=espColor; t2.Visible=true
	end
end

-- =============================================
-- AIMPART: возвращает нужную часть тела
-- =============================================
local function getAimPart(char)
	if not char then return nil end
	local mode = S.AimPart
	if mode == 2 then
		return char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
	elseif mode == 3 then
		return char:FindFirstChild("LeftFoot") or char:FindFirstChild("LeftLeg") or char:FindFirstChild("RightFoot") or char:FindFirstChild("HumanoidRootPart")
	end
	return char:FindFirstChild("Head")
end

-- AimKey check
local function isAimKeyHeld()
	local k = S.AimKey
	if k == 0 then return true end
	if k == 1 then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) end
	if k == 2 then return UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) end
	return true
end

-- =============================================
-- AIMBOT LOOP
-- =============================================
local curTarget, lastTargetTime = nil, 0
local oreTarget2D = nil

RunService.RenderStepped:Connect(function()
	local ss     = Camera.ViewportSize
	local center = Vector2.new(ss.X / 2, ss.Y / 2)
	local t      = tick()

	circle.Visible  = S.FOVCircle
	circle.Position = center
	circle.Radius   = S.FOV
	circle.Color    = AC
	cText.Position  = center - Vector2.new(0, S.FOV + 30)

	-- Сброс curTarget если он стал невалидным (умер, вышел, respawn)
	if curTarget then
		local cc = curTarget.Character
		local ch = cc and cc:FindFirstChild("Humanoid")
		if not cc or not cc.Parent or not ch or ch.Health <= 0 then
			curTarget      = nil
			lastTargetTime = 0
		end
	end

	local closestDist = math.huge
	local tPos2D, tPos3D, tPlayer, tDist
	local count = 0
	local triggerThisFrame = false

	for player, box in pairs(ESPBoxes) do
		local char = player.Character
		local head = char and char:FindFirstChild("Head")
		local hrp  = char and char:FindFirstChild("HumanoidRootPart")
		local hum  = char and char:FindFirstChild("Humanoid")
		if head and hrp and hum and hum.Health > 0 then
			local dist3D     = (Camera.CFrame.Position - hrp.Position).Magnitude
			local inESPRange = dist3D <= S.ESPRadius

			-- Для ESP используем onScreen, для аима — нет (голова может быть за краем экрана)
			local pos3, onScreen = Camera:WorldToViewportPoint(head.Position)
			local sp = Vector2.new(pos3.X, pos3.Y)
			local isFrd    = isFriend(player)
			local espColor = isFrd and BK or AC

			-- Аим: считаем d2 независимо от onScreen
			-- Проверяем pos3.Z > 0 (камера смотрит на цель, не за спину)
			if S.AimbotEnabled and not isFrd and pos3.Z > 0 then
				local d2 = (sp - center).Magnitude
				if d2 <= S.FOV and isVisible(head, char) then
					local inDistRange = dist3D >= S.MinTargetDist and dist3D <= S.MaxTargetDist
					if inDistRange then
						count = count + 1
						if d2 < closestDist then
							closestDist = d2
							tDist = dist3D
							local aimPart = getAimPart(char) or head
							local vel = aimPart.AssemblyLinearVelocity or aimPart.Velocity or Vector3.new()
							local d3  = (aimPart.Position - Camera.CFrame.Position).Magnitude
							local aimPos = aimPart.Position + Vector3.new(0, S.BodyOffset, 0)
							local pp
							if S.PredictionMode == 2 then
								local ping = math.clamp(LocalPlayer:GetNetworkPing() * 60, 0.03, 0.3)
								pp = aimPos + vel * ping * S.Prediction * 10
							else
								local pf = S.Prediction * (1 + d3 / 500)
								pp = aimPos + vel * (d3 / 800) * pf
							end
							tPos3D  = pp
							tPlayer = player
							local a2d = Camera:WorldToViewportPoint(pp)
							tPos2D  = Vector2.new(a2d.X, a2d.Y)
						end
						if S.TriggerBot and d2 <= S.FOV * 0.3 then
							triggerThisFrame = true
						end
					end
				end
			end

			if onScreen then

				if S.ESPEnabled and inESPRange then
					drawESPBox(player, sp, hrp, espColor)
				else
					box.Visible = false
					for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
				end

				if S.Tracers and inESPRange then
					drawTracers(player, sp, espColor, center, ss)
				else
					TracerObjs[player][1].Visible = false
					TracerObjs[player][2].Visible = false
				end

				if S.Names and inESPRange then
					local top2 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0))
					local bot2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0))
					local sy2  = math.abs(top2.Y - bot2.Y)
					local distStr = S.ESPDist and (" [" .. math.floor(dist3D) .. "m]") or ""
					NameObjs[player].Text     = player.Name .. (isFrd and " [FRIEND]" or "") .. distStr
					NameObjs[player].Position = Vector2.new(sp.X, sp.Y - sy2 / 2 - 12)
					NameObjs[player].Color    = espColor
					NameObjs[player].Visible  = true
				else
					NameObjs[player].Visible = false
				end

				if S.Skeleton and inESPRange then
					local h2d = w2sv(head)
					local t2d = w2sv(hrp)
					SkelObjs[player].headTorso.From    = h2d
					SkelObjs[player].headTorso.To      = t2d
					SkelObjs[player].headTorso.Color   = AC
					SkelObjs[player].headTorso.Visible = true
					local function drawLimb(key, n1, n2)
						local p = char:FindFirstChild(n1) or char:FindFirstChild(n2 or n1)
						if p then
							SkelObjs[player][key].From    = t2d
							SkelObjs[player][key].To      = w2sv(p)
							SkelObjs[player][key].Color   = AC
							SkelObjs[player][key].Visible = true
						else
							SkelObjs[player][key].Visible = false
						end
					end
					drawLimb("leftArm",  "Left Arm",  "LeftUpperArm")
					drawLimb("rightArm", "Right Arm", "RightUpperArm")
					drawLimb("leftLeg",  "Left Leg",  "LeftLowerLeg")
					drawLimb("rightLeg", "Right Leg", "RightLowerLeg")
				else
					for _, l in pairs(SkelObjs[player]) do l.Visible = false end
				end
			else
				box.Visible = false
				for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
				TracerObjs[player][1].Visible = false
				TracerObjs[player][2].Visible = false
				NameObjs[player].Visible = false
				for _, l in pairs(SkelObjs[player]) do l.Visible = false end
			end
		else
			box.Visible = false
			for _, l in ipairs(ESPCorners[player]) do l.Visible = false end
			TracerObjs[player][1].Visible = false
			TracerObjs[player][2].Visible = false
			NameObjs[player].Visible = false
			for _, l in pairs(SkelObjs[player]) do l.Visible = false end
		end
	end

	cText.Text  = tostring(count)
	cText.Color = AC

	if S.TriggerBot and triggerThisFrame then
		fireTrigger()
	end

	oreTarget2D = nil
	-- OreAimbot встроен в AutoFarm; отдельный режим доступен если фарм выключен
	if S.AutoFarm and currentOreTarget and currentOreTarget.Parent then
		local p3, onS = Camera:WorldToViewportPoint(currentOreTarget.Position)
		if onS then
			oreTarget2D = Vector2.new(p3.X, p3.Y)
			-- Крестик цвета активного таргета аимбота (AC)
			tLines3[1].From=Vector2.new(oreTarget2D.X,oreTarget2D.Y-12); tLines3[1].To=Vector2.new(oreTarget2D.X,oreTarget2D.Y+12); tLines3[1].Color=AC; tLines3[1].Visible=true
			tLines3[2].From=Vector2.new(oreTarget2D.X-12,oreTarget2D.Y); tLines3[2].To=Vector2.new(oreTarget2D.X+12,oreTarget2D.Y); tLines3[2].Color=AC; tLines3[2].Visible=true
		else
			for _, l in ipairs(tLines3) do l.Visible = false end
		end
	else
		for _, l in ipairs(tLines3) do l.Visible = false end
	end

	if tPlayer then
		-- Нашли цель этот кадр — обновляем
		curTarget      = tPlayer
		lastTargetTime = tick()
	elseif not tPos2D and curTarget then
		-- AimLock или TargetLostDelay
		local holdTime = S.AimLock and S.AimLockTime or S.TargetLostDelay
		if (tick() - lastTargetTime) < holdTime then
			local char = curTarget.Character
			local aimPart = char and (getAimPart(char) or char:FindFirstChild("Head"))
			if aimPart then
				local vel = aimPart.AssemblyLinearVelocity or aimPart.Velocity or Vector3.new()
				local d3  = (aimPart.Position - Camera.CFrame.Position).Magnitude
				local aimPos = aimPart.Position + Vector3.new(0, S.BodyOffset, 0)
				local pp
				if S.PredictionMode == 2 then
					local ping = math.clamp(LocalPlayer:GetNetworkPing() * 60, 0.03, 0.3)
					pp = aimPos + vel * ping * S.Prediction * 10
				else
					pp = aimPos + vel * (d3 / 800) * S.Prediction
				end
				tPos3D = pp
				local a  = Camera:WorldToViewportPoint(pp)
				tPos2D   = Vector2.new(a.X, a.Y)
				tDist    = d3
			else
				curTarget = nil
			end
		else
			curTarget = nil
		end
	end

	if S.AimbotEnabled and tPos2D and tDist and isAimKeyHeld() then
		local anim = S.TargetAnim

		if anim == 1 then
			local sz  = math.clamp(8 * math.clamp(tDist / 100, 1, 5.5), 10, 45)
			local rot = t * 4
			local pts = {}
			for i = 1, 4 do
				local angle = math.rad((i - 1) * 90 + rot * 60)
				table.insert(pts, Vector2.new(tPos2D.X + math.cos(angle) * sz, tPos2D.Y + math.sin(angle) * sz))
			end
			for i = 1, 4 do tLines[i].From=pts[i]; tLines[i].To=pts[i%4+1]; tLines[i].Color=AC; tLines[i].Visible=true end
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 2 then
			local sz  = 20
			local rot = t * 6
			for i = 1, 8 do
				local a1 = math.rad((i-1)*45 + rot*40)
				local a2 = math.rad(i*45 + rot*40)
				tLines2[i].From=Vector2.new(tPos2D.X+math.cos(a1)*sz,tPos2D.Y+math.sin(a1)*sz)
				tLines2[i].To=Vector2.new(tPos2D.X+math.cos(a2)*sz,tPos2D.Y+math.sin(a2)*sz)
				tLines2[i].Color=AC2; tLines2[i].Visible=true
			end
			for _, l in ipairs(tLines) do l.Visible = false end

		elseif anim == 3 then
			local sz  = math.clamp(15 + math.sin(t * 5) * 8, 10, 30)
			local pts = {}
			for i = 1, 4 do
				local angle = math.rad((i-1)*90)
				table.insert(pts, Vector2.new(tPos2D.X+math.cos(angle)*sz, tPos2D.Y+math.sin(angle)*sz))
			end
			for i = 1, 4 do tLines[i].From=pts[i]; tLines[i].To=pts[i%4+1]; tLines[i].Color=AC; tLines[i].Visible=true end
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 4 then
			local pulse = math.abs(math.sin(t * 3)) * 20 + 10
			for i = 1, 4 do
				local a1 = math.rad((i-1)*90); local a2 = math.rad(i*90)
				tLines[i].From=Vector2.new(tPos2D.X+math.cos(a1)*pulse,tPos2D.Y+math.sin(a1)*pulse)
				tLines[i].To=Vector2.new(tPos2D.X+math.cos(a2)*pulse,tPos2D.Y+math.sin(a2)*pulse)
				tLines[i].Color=AC2; tLines[i].Visible=true
			end
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 5 then
			local cx,cy = tPos2D.X,tPos2D.Y; local s = math.clamp(tDist/8,8,30)
			tLines[1].From=Vector2.new(cx-s,cy-s); tLines[1].To=Vector2.new(cx+s,cy-s); tLines[1].Color=AC; tLines[1].Visible=true
			tLines[2].From=Vector2.new(cx+s,cy-s); tLines[2].To=Vector2.new(cx+s,cy+s); tLines[2].Color=AC; tLines[2].Visible=true
			tLines[3].From=Vector2.new(cx+s,cy+s); tLines[3].To=Vector2.new(cx-s,cy+s); tLines[3].Color=AC; tLines[3].Visible=true
			tLines[4].From=Vector2.new(cx-s,cy+s); tLines[4].To=Vector2.new(cx-s,cy-s); tLines[4].Color=AC; tLines[4].Visible=true
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 6 then
			local cx,cy = tPos2D.X,tPos2D.Y; local s = math.clamp(tDist/7,10,35); local cs = s*0.4
			tLines2[1].From=Vector2.new(cx-s,cy-s); tLines2[1].To=Vector2.new(cx-s+cs,cy-s); tLines2[1].Color=AC; tLines2[1].Visible=true
			tLines2[2].From=Vector2.new(cx-s,cy-s); tLines2[2].To=Vector2.new(cx-s,cy-s+cs); tLines2[2].Color=AC; tLines2[2].Visible=true
			tLines2[3].From=Vector2.new(cx+s,cy-s); tLines2[3].To=Vector2.new(cx+s-cs,cy-s); tLines2[3].Color=AC; tLines2[3].Visible=true
			tLines2[4].From=Vector2.new(cx+s,cy-s); tLines2[4].To=Vector2.new(cx+s,cy-s+cs); tLines2[4].Color=AC; tLines2[4].Visible=true
			tLines2[5].From=Vector2.new(cx-s,cy+s); tLines2[5].To=Vector2.new(cx-s+cs,cy+s); tLines2[5].Color=AC; tLines2[5].Visible=true
			tLines2[6].From=Vector2.new(cx-s,cy+s); tLines2[6].To=Vector2.new(cx-s,cy+s-cs); tLines2[6].Color=AC; tLines2[6].Visible=true
			tLines2[7].From=Vector2.new(cx+s,cy+s); tLines2[7].To=Vector2.new(cx+s-cs,cy+s); tLines2[7].Color=AC; tLines2[7].Visible=true
			tLines2[8].From=Vector2.new(cx+s,cy+s); tLines2[8].To=Vector2.new(cx+s,cy+s-cs); tLines2[8].Color=AC; tLines2[8].Visible=true
			for _, l in ipairs(tLines) do l.Visible = false end

		elseif anim == 7 then
			local cx,cy = tPos2D.X,tPos2D.Y; local s = 18
			tLines[1].From=Vector2.new(cx,cy-s-6); tLines[1].To=Vector2.new(cx,cy-4); tLines[1].Color=AC2; tLines[1].Visible=true
			tLines[2].From=Vector2.new(cx-7,cy-s+4); tLines[2].To=Vector2.new(cx,cy-4); tLines[2].Color=AC2; tLines[2].Visible=true
			tLines[3].From=Vector2.new(cx+7,cy-s+4); tLines[3].To=Vector2.new(cx,cy-4); tLines[3].Color=AC2; tLines[3].Visible=true
			tLines[4].Visible=false
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 8 then
			local cx,cy = tPos2D.X,tPos2D.Y; local s = 14
			tLines[1].From=Vector2.new(cx-s,cy-s); tLines[1].To=Vector2.new(cx+s,cy+s); tLines[1].Color=AC; tLines[1].Visible=true
			tLines[2].From=Vector2.new(cx+s,cy-s); tLines[2].To=Vector2.new(cx-s,cy+s); tLines[2].Color=AC; tLines[2].Visible=true
			tLines[3].Visible=false; tLines[4].Visible=false
			for _, l in ipairs(tLines2) do l.Visible = false end

		elseif anim == 9 then
			local cx,cy = tPos2D.X,tPos2D.Y
			local s   = math.clamp(12 + math.sin(t*4)*5, 8, 22)
			local rot = t * 2
			local pts = {}
			for i = 1, 4 do
				local angle = math.rad((i-1)*90 + 45) + rot
				table.insert(pts, Vector2.new(cx+math.cos(angle)*s, cy+math.sin(angle)*s))
			end
			for i = 1, 4 do tLines[i].From=pts[i]; tLines[i].To=pts[i%4+1]; tLines[i].Color=AC2; tLines[i].Visible=true end
			for _, l in ipairs(tLines2) do l.Visible = false end
		end

		gLine.From  = center
		gLine.To    = tPos2D
		gLine.Color = AC
		gLine.Visible = true
		local camPos  = Camera.CFrame.Position
		local newLook = (tPos3D - camPos).Unit
		local lerped  = Camera.CFrame.LookVector:Lerp(newLook, S.Smooth)
		if S.RCS then
			local rc = Vector3.new(math.sin(t*30)*S.RecoilComp, math.cos(t*30)*S.RecoilComp/2, 0)
			lerped = (lerped + rc).Unit
		end
		Camera.CFrame = CFrame.new(camPos, camPos + lerped)
	else
		for _, l in ipairs(tLines)  do l.Visible = false end
		for _, l in ipairs(tLines2) do l.Visible = false end
		gLine.Visible = false
	end
end)


-- =============================================
-- BULLET TRACER
-- =============================================
local bulletTrails = {}

local function spawnBulletTrail()
	local char = LocalPlayer.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local origin = hrp.Position + Vector3.new(0, 1, 0)
	local direction = Camera.CFrame.LookVector

	local params = RaycastParams.new()
	params.FilterDescendantsInstances = {char}
	params.FilterType = Enum.RaycastFilterType.Exclude

	local result = workspace:Raycast(origin, direction * 800, params)
	local hitPos = result and result.Position or (origin + direction * 800)

	local p0 = Instance.new("Part")
	p0.Anchored = true
	p0.CanCollide = false
	p0.Transparency = 1
	p0.Size = Vector3.new(0.1, 0.1, 0.1)
	p0.CFrame = CFrame.new(origin)
	p0.Parent = workspace

	local p1 = Instance.new("Part")
	p1.Anchored = true
	p1.CanCollide = false
	p1.Transparency = 1
	p1.Size = Vector3.new(0.1, 0.1, 0.1)
	p1.CFrame = CFrame.new(hitPos)
	p1.Parent = workspace

	local a0 = Instance.new("Attachment", p0)
	local a1 = Instance.new("Attachment", p1)

	local beam = Instance.new("Beam")
	beam.Attachment0 = a0
	beam.Attachment1 = a1
	beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	beam.Width0 = 0.05
	beam.Width1 = 0.05
	beam.FaceCamera = true
	beam.LightEmission = S.BulletTracerGlow and 1 or 0
	beam.LightInfluence = S.BulletTracerGlow and 0 or 1
	beam.Transparency = NumberSequence.new(0)
	beam.Parent = p0

	table.insert(bulletTrails, {
		p0 = p0,
		p1 = p1,
		beam = beam,
		expire = tick() + 5
	})
end

local function updateBulletTrails()
	local now = tick()
	for i = #bulletTrails, 1, -1 do
		local tr = bulletTrails[i]
		if now >= tr.expire then
			tr.p0:Destroy()
			tr.p1:Destroy()
			table.remove(bulletTrails, i)
		end
	end
end

local function btBindTool(tool)
	if not tool then return end
	tool.Activated:Connect(function()
		if S.BulletTracer then spawnBulletTrail() end
	end)
end

local function btOnCharacter(char)
	btBindTool(char:FindFirstChildWhichIsA("Tool"))
	char.ChildAdded:Connect(function(child)
		if child:IsA("Tool") then btBindTool(child) end
	end)
end

if LocalPlayer.Character then btOnCharacter(LocalPlayer.Character) end
LocalPlayer.CharacterAdded:Connect(btOnCharacter)

game:GetService("RunService").RenderStepped:Connect(function()
	updateBulletTrails()
end)

-- =============================================
-- SILENT AIM
-- При выстреле (tool.Activated) мгновенно снапит
-- камеру на голову ближайшего врага в FOV-круге,
-- затем возвращает обратно — пуля летит в голову.
-- =============================================
local silentAimConn   = nil
local silentAimTool   = nil
local silentAimActive = false

local function silentAimGetTarget()
	local char  = LocalPlayer.Character
	local head0 = char and char:FindFirstChild("Head")
	if not head0 then return nil end
	local ss     = Camera.ViewportSize
	local center = Vector2.new(ss.X / 2, ss.Y / 2)
	local best, bestDist = nil, math.huge
	for _, player in ipairs(Players:GetPlayers()) do
		if player == LocalPlayer then continue end
		if isFriend(player)       then continue end
		local c = player.Character
		local h = c and c:FindFirstChild("Head")
		local hm = c and c:FindFirstChild("Humanoid")
		if not h or not hm or hm.Health <= 0 then continue end
		local p3, onScreen = Camera:WorldToViewportPoint(h.Position)
		if not onScreen then continue end
		local sp = Vector2.new(p3.X, p3.Y)
		local d2 = (sp - center).Magnitude
		if d2 <= S.FOV and d2 < bestDist then
			bestDist = d2
			best = h
		end
	end
	return best
end

local SA_CurrentTarget = nil

task.spawn(function()
	while task.wait(0.03) do
		local target = nil
		local shortestDistance = S.FOV
		local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

		for _, v in pairs(Players:GetPlayers()) do
			if v ~= LocalPlayer and v.Character then
				local root = v.Character:FindFirstChild("Head")
				local hum = v.Character:FindFirstChild("Humanoid")

				if root and hum and hum.Health > 0 then
					local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
					if onScreen then
						local distance = (Vector2.new(pos.X, pos.Y) - center).Magnitude
						if distance < shortestDistance then
							target = root
							shortestDistance = distance
						end
					end
				end
			end
		end
		SA_CurrentTarget = target
	end
end)

local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local method = getnamecallmethod()
	local args = {...}

	if not checkcaller() and S.SilentAim then
		if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
			local target = SA_CurrentTarget

			if target then
				if method == "Raycast" then
					args[2] = (target.Position - args[1]).Unit * 1000
					return oldNamecall(self, unpack(args))
				elseif method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
					local origin = args[1].Origin
					args[1] = Ray.new(origin, (target.Position - origin).Unit * 1000)
					return oldNamecall(self, unpack(args))
				end
			end
		end
	end

	return oldNamecall(self, ...)
end))


-- =============================================
-- CROSSHAIR
-- =============================================
local Crosshair = {
	MainFrame   = nil,
	ScreenGui   = nil,
	Segments    = {},
	Enabled     = false,
	CurrentType = "Default",
	Rotation    = 0,
	RainbowHue  = 0,
}

local crosshairSettings = {
	crosshairEnabled   = false,
	crosshairType      = "Default", -- "Default", "X", "Dot"
	crosshairSize      = 10,
	crosshairThickness = 2,
	crosshairColor     = Color3.fromRGB(255, 255, 255),
	crosshairSpin      = false,
	crosshairSpinSpeed = 2,
	crosshairRainbow   = false,
	crosshairCenter    = false, -- закреплён по центру экрана
}

local function chGetParent()
	local p
	pcall(function()
		if gethui then p = gethui()
		else p = game:GetService("CoreGui") end
	end)
	return p or LocalPlayer:WaitForChild("PlayerGui")
end

local function chCreateSegment(parent, size, pos, rotation)
	local f = Instance.new("Frame")
	f.BackgroundColor3 = crosshairSettings.crosshairColor
	f.BorderSizePixel  = 0
	f.Active           = false
	f.Selectable       = false
	f.AnchorPoint      = Vector2.new(0.5, 0.5)
	f.Size             = size
	f.Position         = pos
	f.Rotation         = rotation or 0
	f.Parent           = parent
	return f
end

local function chClear()
	if Crosshair.MainFrame then
		Crosshair.MainFrame:Destroy()
		Crosshair.MainFrame = nil
	end
	Crosshair.Segments = {}
end

local function chInit()
	if Crosshair.ScreenGui then return end
	local sg = Instance.new("ScreenGui")
	sg.Name           = "lw_Crosshair"
	sg.DisplayOrder   = 99998
	sg.IgnoreGuiInset = true
	sg.ResetOnSpawn   = false
	sg.Parent         = chGetParent()
	Crosshair.ScreenGui = sg
end

local function chBuild(t, size, thick)
	chClear()
	Crosshair.CurrentType = t
	Crosshair.Rotation    = 0
	Crosshair.MainFrame = Instance.new("Frame")
	Crosshair.MainFrame.BackgroundTransparency = 1
	Crosshair.MainFrame.Size   = UDim2.new(0, 0, 0, 0)
	Crosshair.MainFrame.Parent = Crosshair.ScreenGui

	if t == "Default" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2), UDim2.new(0, 0, 0, 0)))
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, size * 2, 0, thick), UDim2.new(0, 0, 0, 0)))
	elseif t == "X" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2.5), UDim2.new(0, 0, 0, 0), 45))
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick, 0, size * 2.5), UDim2.new(0, 0, 0, 0), -45))
	elseif t == "Dot" then
		table.insert(Crosshair.Segments, chCreateSegment(Crosshair.MainFrame,
			UDim2.new(0, thick * 2, 0, thick * 2), UDim2.new(0, 0, 0, 0)))
		local r = Instance.new("UICorner")
		r.CornerRadius = UDim.new(0.5, 0)
		r.Parent = Crosshair.Segments[1]
	end
end

local crosshairConn = nil

local function startCrosshair()
	chInit()
	if crosshairConn then crosshairConn:Disconnect(); crosshairConn = nil end
	crosshairConn = RunService.RenderStepped:Connect(function(dt)
		if not crosshairSettings.crosshairEnabled then
			if Crosshair.Enabled then
				chClear()
				Crosshair.Enabled = false
				UserInputService.MouseIconEnabled = true
			end
			return
		end

		Crosshair.Enabled = true
		UserInputService.MouseIconEnabled = false

		local t     = crosshairSettings.crosshairType
		local size  = crosshairSettings.crosshairSize
		local thick = crosshairSettings.crosshairThickness

		if not Crosshair.MainFrame or Crosshair.CurrentType ~= t then
			chBuild(t, size, thick)
		end

		-- Позиция: центр экрана или мышь
		local pos
		if crosshairSettings.crosshairCenter then
			local ss = Camera.ViewportSize
			pos = Vector2.new(ss.X / 2, ss.Y / 2)
		else
			pos = UserInputService:GetMouseLocation()
		end
		Crosshair.MainFrame.Position = UDim2.new(0, pos.X, 0, pos.Y)

		-- Вращение
		if crosshairSettings.crosshairSpin then
			Crosshair.Rotation = (Crosshair.Rotation + crosshairSettings.crosshairSpinSpeed * dt * 60) % 360
			Crosshair.MainFrame.Rotation = Crosshair.Rotation
		else
			Crosshair.MainFrame.Rotation = 0
		end

		-- Цвет: rainbow или обычный
		local col
		if crosshairSettings.crosshairRainbow then
			Crosshair.RainbowHue = (Crosshair.RainbowHue + dt * 0.3) % 1
			col = Color3.fromHSV(Crosshair.RainbowHue, 1, 1)
		else
			col = crosshairSettings.crosshairColor
		end

		-- Обновляем сегменты
		for _, seg in ipairs(Crosshair.Segments) do
			seg.BackgroundColor3 = col
			if t == "Default" then
				if seg.Size.X.Offset > seg.Size.Y.Offset then
					seg.Size = UDim2.new(0, size * 2, 0, thick)
				else
					seg.Size = UDim2.new(0, thick, 0, size * 2)
				end
			elseif t == "X" then
				seg.Size = UDim2.new(0, thick, 0, size * 2.5)
			elseif t == "Dot" then
				seg.Size = UDim2.new(0, thick * 2, 0, thick * 2)
			end
		end
	end)
end

local function stopCrosshair()
	if crosshairConn then crosshairConn:Disconnect(); crosshairConn = nil end
	chClear()
	if Crosshair.ScreenGui then
		Crosshair.ScreenGui:Destroy()
		Crosshair.ScreenGui = nil
	end
	UserInputService.MouseIconEnabled = true
	Crosshair.Enabled = false
end

startCrosshair()

-- =============================================
-- =============================================
-- GUI  |  losware  —  Share Tech Mono style (HTML 1:1)
-- =============================================

local C = {
	BG      = Color3.fromRGB(0,   0,   0),
	PANEL   = Color3.fromRGB(4,   4,   4),
	HEADER  = Color3.fromRGB(0,   0,   0),
	BORDER  = Color3.fromRGB(255, 255, 255),
	BORDERDIM = Color3.fromRGB(51, 51, 51),
	ACCENT  = Color3.fromRGB(255, 255, 255),
	TEXT    = Color3.fromRGB(204, 204, 204),
	SUBTEXT = Color3.fromRGB(102, 102, 102),
	OFF     = Color3.fromRGB(17,  17,  17),
	TICK    = Color3.fromRGB(255, 255, 255),
	GROUPBG = Color3.fromRGB(8,   8,   8),
	BODYBG  = Color3.fromRGB(2,   2,   2),
}

local gui = Instance.new("ScreenGui")
gui.Name = "lw"
gui.ResetOnSpawn = false
gui.DisplayOrder = 99999
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

local ok2, pg = pcall(function() return LocalPlayer:WaitForChild("PlayerGui", 3) end)
gui.Parent = ok2 and pg or game:GetService("CoreGui")

local function el(cls, parent, props)
	local o = Instance.new(cls)
	if parent then o.Parent = parent end
	if props then
		for k, v in pairs(props) do
			pcall(function() o[k] = v end)
		end
	end
	return o
end

-- ── Кнопка открытия — квадратная как в HTML ──────────────────────────────
local openBtn = el("TextButton", gui, {
	Size             = UDim2.new(0, 40, 0, 40),
	Position         = UDim2.new(1, -70, 1, -70),
	BackgroundColor3 = C.BG,
	TextColor3       = C.ACCENT,
	Text             = "LW",
	TextSize         = 11,
	Font             = Enum.Font.Code,
	ZIndex           = 100,
	BorderSizePixel  = 0,
	AutoButtonColor  = false,
	Active           = true,
})
el("UIStroke", openBtn, {Color = C.ACCENT, Thickness = 1})

local guiOpen = false
local lastTap  = 0

-- ── Watermark — точно как в HTML ─────────────────────────────────────────
-- HTML: position fixed, top:12px, left:50%, transform:translateX(-50%)
-- padding:3px 14px, background:rgba(0,0,0,0.7), border:1px solid #222
-- color:#fff, font-size:10px, letter-spacing:3px, text-transform:lowercase
local wmFrame = el("Frame", gui, {
	Size             = UDim2.new(0, 110, 0, 22),
	Position         = UDim2.new(0.5, -55, 0, 12),
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.3,
	BorderSizePixel  = 0,
	Visible          = S.Watermark,
	ZIndex           = 200,
})
el("UIStroke", wmFrame, {Color = Color3.fromRGB(34, 34, 34), Thickness = 1})

local wmLabel = el("TextLabel", wmFrame, {
	Text              = "| losware |",
	TextColor3        = Color3.fromRGB(255, 255, 255),
	BackgroundTransparency = 1,
	Size              = UDim2.new(1, 0, 1, 0),
	Font              = Enum.Font.Code,
	TextSize          = 10,
	ZIndex            = 201,
	TextXAlignment    = Enum.TextXAlignment.Center,
})

local function setWatermark(v)
	S.Watermark = v
	wmFrame.Visible = v and not guiOpen
end

-- ── Главное окно — HTML: width:560px, border:1px solid #fff ──────────────
local WIN_W, WIN_H = 560, 388
local win = el("Frame", gui, {
	Size             = UDim2.new(0, WIN_W, 0, WIN_H),
	Position         = UDim2.new(0.5, -WIN_W/2, 0.5, -WIN_H/2),
	BackgroundColor3 = C.BG,
	BorderSizePixel  = 0,
	Visible          = false,
	ZIndex           = 10,
})
el("UIStroke", win, {Color = C.BORDER, Thickness = 1})

-- ── Заголовок — HTML: height:28px, border-bottom:1px solid #fff ──────────
local TITLE_H = 28
local titleBar = el("Frame", win, {
	Size             = UDim2.new(1, 0, 0, TITLE_H),
	Position         = UDim2.new(0, 0, 0, 0),
	BackgroundColor3 = C.HEADER,
	BorderSizePixel  = 0,
	ZIndex           = 11,
})
-- border-bottom
el("Frame", win, {
	Size             = UDim2.new(1, 0, 0, 1),
	Position         = UDim2.new(0, 0, 0, TITLE_H),
	BackgroundColor3 = C.BORDER,
	BorderSizePixel  = 0,
	ZIndex           = 12,
})

-- Заголовок: font-size:11px, letter-spacing:3px, font-weight:700
el("TextLabel", titleBar, {
	Text              = "| losware |",
	TextColor3        = C.ACCENT,
	BackgroundTransparency = 1,
	Size              = UDim2.new(1, -30, 1, 0),
	Position          = UDim2.new(0, 10, 0, 0),
	Font              = Enum.Font.Code,
	TextSize          = 11,
	TextXAlignment    = Enum.TextXAlignment.Left,
	ZIndex            = 12,
})

-- Кнопка закрыть: width:18px, height:18px, border:1px solid #333
local closeBtn = el("TextButton", titleBar, {
	Text              = "x",
	TextColor3        = Color3.fromRGB(102, 102, 102),
	BackgroundColor3  = C.BG,
	Size              = UDim2.new(0, 18, 0, 18),
	Position          = UDim2.new(1, -22, 0.5, -9),
	Font              = Enum.Font.Code,
	TextSize          = 10,
	ZIndex            = 12,
	BorderSizePixel   = 0,
	AutoButtonColor   = false,
	Active            = true,
})
el("UIStroke", closeBtn, {Color = Color3.fromRGB(51, 51, 51), Thickness = 1})
closeBtn.MouseEnter:Connect(function()
	closeBtn.TextColor3 = C.ACCENT
	local st = closeBtn:FindFirstChildOfClass("UIStroke")
	if st then st.Color = C.ACCENT end
end)
closeBtn.MouseLeave:Connect(function()
	closeBtn.TextColor3 = Color3.fromRGB(102, 102, 102)
	local st = closeBtn:FindFirstChildOfClass("UIStroke")
	if st then st.Color = Color3.fromRGB(51, 51, 51) end
end)

-- ── Сайдбар — HTML: width:110px, border-right:1px solid #333 ─────────────
local SIDEBAR_W = 110
local CONTENT_Y = TITLE_H + 1

local sidebar = el("Frame", win, {
	Size             = UDim2.new(0, SIDEBAR_W, 1, -CONTENT_Y),
	Position         = UDim2.new(0, 0, 0, CONTENT_Y),
	BackgroundColor3 = Color3.fromRGB(4, 4, 4),
	BorderSizePixel  = 0,
	ZIndex           = 11,
})
-- border-right
el("Frame", win, {
	Size             = UDim2.new(0, 1, 1, -CONTENT_Y),
	Position         = UDim2.new(0, SIDEBAR_W, 0, CONTENT_Y),
	BackgroundColor3 = Color3.fromRGB(51, 51, 51),
	BorderSizePixel  = 0,
	ZIndex           = 12,
})

-- ── Контент (правая часть) ────────────────────────────────────────────────
local content = el("Frame", win, {
	Size             = UDim2.new(1, -SIDEBAR_W - 1, 1, -CONTENT_Y),
	Position         = UDim2.new(0, SIDEBAR_W + 1, 0, CONTENT_Y),
	BackgroundColor3 = C.BG,
	BorderSizePixel  = 0,
	ZIndex           = 11,
	ClipsDescendants = true,
})

-- ── Вкладки — HTML: height:30px, font-size:10px, text-align:left, padding-left:16px ──
local TABS = {"aimbot", "visuals", "misc", "movement", "world", "friends", "configuration"}
local TAB_LABELS = {
	aimbot        = "aimbot",
	visuals       = "visuals",
	misc          = "misc",
	movement      = "movement",
	world         = "world",
	friends       = "friends",
	configuration = "config",
}
local tabBtns   = {}
local tabFrames = {}
local activeTab = nil

-- Белая полоска-индикатор слева (HTML: ::before width:2px)
local accentBar = el("Frame", sidebar, {
	Size             = UDim2.new(0, 2, 0, 14),
	Position         = UDim2.new(0, 0, 0, 14),
	BackgroundColor3 = C.ACCENT,
	BorderSizePixel  = 0,
	ZIndex           = 15,
})

local TAB_H     = 30
local TAB_PAD_Y = 6

local function makeSF(parent)
	local sf = el("ScrollingFrame", parent, {
		Size                  = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency= 1,
		BorderSizePixel       = 0,
		ScrollBarThickness    = 4,
		ScrollBarImageColor3  = Color3.fromRGB(51, 51, 51),
		AutomaticCanvasSize   = Enum.AutomaticSize.Y,
		CanvasSize            = UDim2.new(0, 0, 0, 0),
		ZIndex                = 12,
		ScrollingEnabled      = true,
	})
	el("UIPadding", sf, {
		PaddingLeft   = UDim.new(0, 12),
		PaddingRight  = UDim.new(0, 12),
		PaddingTop    = UDim.new(0, 10),
		PaddingBottom = UDim.new(0, 10),
	})
	el("UIListLayout", sf, {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding   = UDim.new(0, 4),
	})
	return sf
end

local function switchTab(id)
	activeTab = id
	for tid, frame in pairs(tabFrames) do
		frame.Visible = (tid == id)
	end
	for i, name in ipairs(TABS) do
		local btn = tabBtns[name]
		if btn then
			if name == id then
				btn.TextColor3       = C.ACCENT
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				-- Позиция белой полоски
				accentBar.Position = UDim2.new(0, 0, 0, TAB_PAD_Y + (i-1)*TAB_H + (TAB_H-14)/2)
			else
				btn.TextColor3       = C.SUBTEXT
				btn.BackgroundColor3 = Color3.fromRGB(4, 4, 4)
			end
		end
	end
end

for i, name in ipairs(TABS) do
	local btn = el("TextButton", sidebar, {
		Text              = TAB_LABELS[name] or name,
		TextColor3        = C.SUBTEXT,
		BackgroundColor3  = Color3.fromRGB(4, 4, 4),
		Size              = UDim2.new(1, 0, 0, TAB_H),
		Position          = UDim2.new(0, 0, 0, TAB_PAD_Y + (i-1)*TAB_H),
		Font              = Enum.Font.Code,
		TextSize          = 10,
		BorderSizePixel   = 0,
		ZIndex            = 12,
		AutoButtonColor   = false,
		Active            = true,
		TextXAlignment    = Enum.TextXAlignment.Left,
	})
	el("UIPadding", btn, {PaddingLeft = UDim.new(0, 16)})
	tabBtns[name] = btn

	local sf = makeSF(content)
	sf.Visible = false
	tabFrames[name] = sf

	btn.MouseEnter:Connect(function()
		if name ~= activeTab then btn.TextColor3 = Color3.fromRGB(170,170,170) end
	end)
	btn.MouseLeave:Connect(function()
		if name ~= activeTab then btn.TextColor3 = C.SUBTEXT end
	end)
	btn.Activated:Connect(function() switchTab(name) end)
end

-- ── Section label — HTML: font-size:8px, letter-spacing:2px, color:#fff ──
local function addSec(parent, label, order)
	local row = el("Frame", parent, {
		Size                  = UDim2.new(1, 0, 0, 20),
		BackgroundTransparency= 1,
		LayoutOrder           = order or 0,
	})
	el("TextLabel", row, {
		Text              = string.upper(label),
		TextColor3        = C.ACCENT,
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, 0, 0, 10),
		Position          = UDim2.new(0, 0, 0, 5),
		Font              = Enum.Font.Code,
		TextSize          = 8,
		TextXAlignment    = Enum.TextXAlignment.Left,
		ZIndex            = 13,
	})
	-- Линия после заголовка секции
	el("Frame", row, {
		Size             = UDim2.new(1, 0, 0, 1),
		Position         = UDim2.new(0, 0, 1, -1),
		BackgroundColor3 = Color3.fromRGB(30, 30, 30),
		BorderSizePixel  = 0,
		ZIndex           = 13,
	})
end

-- ── Sub-section label — HTML: font-size:8px, letter-spacing:1.5px, color:#444 ──
local function addSubSec(parent, label, order)
	local row = el("Frame", parent, {
		Size                  = UDim2.new(1, 0, 0, 18),
		BackgroundTransparency= 1,
		LayoutOrder           = order or 0,
	})
	el("TextLabel", row, {
		Text              = string.upper(label),
		TextColor3        = Color3.fromRGB(68, 68, 68),
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, 0, 1, 0),
		Font              = Enum.Font.Code,
		TextSize          = 8,
		TextXAlignment    = Enum.TextXAlignment.Left,
		ZIndex            = 13,
	})
end

-- Тонкий разделитель
local function addDivider(parent, order)
	local d = el("Frame", parent, {
		Size             = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Color3.fromRGB(17, 17, 17),
		BorderSizePixel  = 0,
		ZIndex           = 13,
		LayoutOrder      = order or 0,
	})
end

-- Рефы для тогглов
local toggleRefs = {}
local function setToggleVisual(key, val)
	S[key] = val
	if toggleRefs[key] then
		for _, ref in ipairs(toggleRefs[key]) do
			-- HTML toggle: border:1px solid #333 / on: border-color:#fff
			-- knob: background:#333 / on: left:16px background:#fff
			if val then
				ref.switchBg.BackgroundColor3 = C.BG
				local st = ref.switchBg:FindFirstChildOfClass("UIStroke")
				if st then st.Color = C.ACCENT end
				ref.knob.BackgroundColor3 = C.ACCENT
				ref.knob.Position = UDim2.new(0, 16, 0.5, -4)
			else
				ref.switchBg.BackgroundColor3 = C.OFF
				local st = ref.switchBg:FindFirstChildOfClass("UIStroke")
				if st then st.Color = Color3.fromRGB(51,51,51) end
				ref.knob.BackgroundColor3 = Color3.fromRGB(51,51,51)
				ref.knob.Position = UDim2.new(0, 2, 0.5, -4)
			end
		end
	end
end

-- ── Toggle — HTML: width:28px height:14px, knob:8px ──────────────────────
local function addToggle(parent, label, key, order, cb)
	local row = el("Frame", parent, {
		Size                  = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency= 1,
		LayoutOrder           = order or 0,
	})

	-- hover bg
	local rowBg = el("Frame", row, {
		Size             = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(10,10,10),
		BackgroundTransparency = 1,
		BorderSizePixel  = 0,
		ZIndex           = 12,
	})

	-- switch: HTML width:28px, height:14px, border:1px solid #333
	local switchBg = el("Frame", row, {
		Size             = UDim2.new(0, 28, 0, 14),
		Position         = UDim2.new(1, -30, 0.5, -7),
		BackgroundColor3 = S[key] and C.BG or C.OFF,
		BorderSizePixel  = 0,
		ZIndex           = 13,
	})
	el("UIStroke", switchBg, {Color = S[key] and C.ACCENT or Color3.fromRGB(51,51,51), Thickness = 1})

	-- knob: HTML 8x8px, background:#333/#fff, left:2px/16px
	local knob = el("Frame", switchBg, {
		Size             = UDim2.new(0, 8, 0, 8),
		Position         = UDim2.new(0, S[key] and 16 or 2, 0.5, -4),
		BackgroundColor3 = S[key] and C.ACCENT or Color3.fromRGB(51,51,51),
		BorderSizePixel  = 0,
		ZIndex           = 14,
	})

	-- label: font-size:10px, color:#ccc
	el("TextLabel", row, {
		Text              = label,
		TextColor3        = Color3.fromRGB(204, 204, 204),
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, -44, 1, 0),
		Position          = UDim2.new(0, 2, 0, 0),
		Font              = Enum.Font.Code,
		TextSize          = 10,
		TextXAlignment    = Enum.TextXAlignment.Left,
		ZIndex            = 13,
	})

	local btn = el("TextButton", row, {
		Text              = "",
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, 0, 1, 0),
		ZIndex            = 15,
		AutoButtonColor   = false,
		Active            = true,
	})

	if not toggleRefs[key] then toggleRefs[key] = {} end
	table.insert(toggleRefs[key], {switchBg = switchBg, knob = knob})

	btn.Activated:Connect(function()
		S[key] = not S[key]
		local on = S[key]
		switchBg.BackgroundColor3 = on and C.BG or C.OFF
		local st = switchBg:FindFirstChildOfClass("UIStroke")
		if st then st.Color = on and C.ACCENT or Color3.fromRGB(51,51,51) end
		knob.BackgroundColor3 = on and C.ACCENT or Color3.fromRGB(51,51,51)
		knob.Position = UDim2.new(0, on and 16 or 2, 0.5, -4)
		if cb then cb(on) end
	end)

	btn.MouseEnter:Connect(function() rowBg.BackgroundTransparency = 0 end)
	btn.MouseLeave:Connect(function() rowBg.BackgroundTransparency = 1 end)
end

-- ── Slider — HTML: height:3px track, 9x9px knob ──────────────────────────
local function addSlider(parent, label, key, mn, mx, fmt, order, cb)
	local row = el("Frame", parent, {
		Size                  = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency= 1,
		LayoutOrder           = order or 0,
	})
	local function fv(v)
		return fmt and string.format(fmt, v) or tostring(math.round(v))
	end

	-- Top row: label left, value right
	local topRow = el("Frame", row, {
		Size             = UDim2.new(1, 0, 0, 16),
		BackgroundTransparency = 1,
		ZIndex           = 13,
	})
	-- label: font-size:10px color:#ccc
	el("TextLabel", topRow, {
		Text              = label,
		TextColor3        = Color3.fromRGB(204, 204, 204),
		BackgroundTransparency = 1,
		Size              = UDim2.new(0.7, 0, 1, 0),
		Font              = Enum.Font.Code,
		TextSize          = 10,
		TextXAlignment    = Enum.TextXAlignment.Left,
		ZIndex            = 13,
	})
	-- value: font-size:10px color:#fff font-weight:700
	local valLbl = el("TextLabel", topRow, {
		Text              = fv(S[key]),
		TextColor3        = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size              = UDim2.new(0.3, 0, 1, 0),
		Position          = UDim2.new(0.7, 0, 0, 0),
		Font              = Enum.Font.Code,
		TextSize          = 10,
		TextXAlignment    = Enum.TextXAlignment.Right,
		ZIndex            = 13,
	})

	-- track: HTML height:3px background:#181818
	local track = el("Frame", row, {
		Size             = UDim2.new(1, 0, 0, 3),
		Position         = UDim2.new(0, 0, 0, 26),
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderSizePixel  = 0,
		ZIndex           = 13,
	})

	local r0   = math.clamp((S[key] - mn) / (mx - mn), 0, 1)
	-- fill: background:#fff
	local fill = el("Frame", track, {
		Size             = UDim2.new(r0, 0, 1, 0),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 14,
	})

	-- knob: HTML 9x9px, background:#fff, border:1px solid #000, top:-3px
	local knob = el("Frame", track, {
		Size             = UDim2.new(0, 9, 0, 9),
		Position         = UDim2.new(r0, -4, 0.5, -4),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderSizePixel  = 0,
		ZIndex           = 15,
	})
	el("UIStroke", knob, {Color = Color3.fromRGB(0,0,0), Thickness = 1})

	local dragging = false
	local hit = el("TextButton", track, {
		Text              = "",
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, 0, 0, 24),
		Position          = UDim2.new(0, 0, 0.5, -12),
		ZIndex            = 16,
		AutoButtonColor   = false,
		Active            = true,
	})
	hit.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
		end
	end)
	UserInputService.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
	UserInputService.InputChanged:Connect(function(i)
		if dragging then
			local tp = track.AbsolutePosition
			local tw = track.AbsoluteSize.X
			local r  = math.clamp((i.Position.X - tp.X) / tw, 0, 1)
			local v  = mn + (mx - mn) * r
			S[key]   = v
			fill.Size      = UDim2.new(r, 0, 1, 0)
			knob.Position  = UDim2.new(r, -4, 0.5, -4)
			valLbl.Text    = fv(v)
			if cb then cb(v) end
		end
	end)
end

-- ── Radio picker — HTML: 12x12px square border, 5x5px dot ────────────────
local function addPicker(parent, label, key, options, order, cb)
	addSubSec(parent, label, order)
	local indicators = {}
	for i, opt in ipairs(options) do
		local row = el("Frame", parent, {
			Size                  = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency= 1,
			LayoutOrder           = order + i,
		})
		-- radio box: HTML 12x12px border:1px solid #333
		local radio = el("Frame", row, {
			Size             = UDim2.new(0, 12, 0, 12),
			Position         = UDim2.new(0, 0, 0.5, -6),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel  = 0,
			ZIndex           = 13,
		})
		el("UIStroke", radio, {Color = S[key] == i and C.ACCENT or Color3.fromRGB(51,51,51), Thickness = 1})

		-- dot: HTML 5x5px background:#fff, display:none/block
		local dot = el("Frame", radio, {
			Size             = UDim2.new(0, 5, 0, 5),
			Position         = UDim2.new(0.5, -2, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel  = 0,
			ZIndex           = 14,
			Visible          = S[key] == i,
		})

		-- label: font-size:10px color:#666/#ccc
		local lbl = el("TextLabel", row, {
			Text              = opt,
			TextColor3        = S[key] == i and Color3.fromRGB(204,204,204) or Color3.fromRGB(102,102,102),
			BackgroundTransparency = 1,
			Size              = UDim2.new(1, -20, 1, 0),
			Position          = UDim2.new(0, 20, 0, 0),
			Font              = Enum.Font.Code,
			TextSize          = 10,
			TextXAlignment    = Enum.TextXAlignment.Left,
			ZIndex            = 13,
		})

		local btn = el("TextButton", row, {
			Text              = "",
			BackgroundTransparency = 1,
			Size              = UDim2.new(1, 0, 1, 0),
			ZIndex            = 15,
			AutoButtonColor   = false,
			Active            = true,
		})
		indicators[i] = {radio = radio, dot = dot, lbl = lbl}
		local id = i
		btn.Activated:Connect(function()
			S[key] = id
			for j, ind in pairs(indicators) do
				local active = (j == id)
				ind.dot.Visible = active
				local st = ind.radio:FindFirstChildOfClass("UIStroke")
				if st then st.Color = active and C.ACCENT or Color3.fromRGB(51,51,51) end
				ind.lbl.TextColor3 = active and Color3.fromRGB(204,204,204) or Color3.fromRGB(102,102,102)
			end
			if cb then cb(id) end
		end)
		-- HTML: .radio-row:hover background:#0a0a0a
		local rowBg = el("Frame", row, {
			Size = UDim2.new(1,0,1,0),
			BackgroundColor3 = Color3.fromRGB(10,10,10),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 12,
		})
		btn.MouseEnter:Connect(function() rowBg.BackgroundTransparency = 0 end)
		btn.MouseLeave:Connect(function() rowBg.BackgroundTransparency = 1 end)
	end
end

-- ── Picker для Target Animation ──────────────────────────────────────────
local function addAnimPicker(parent, order)
	local anims = {
		{id=1, name="Rotating Square"},
		{id=2, name="Spinning Octagon"},
		{id=3, name="Pulsing Square"},
		{id=4, name="Pulse Burst"},
		{id=5, name="Static Box"},
		{id=6, name="Corner Brackets"},
		{id=7, name="Arrow"},
		{id=8, name="Crosshair X"},
		{id=9, name="Diamond"},
	}
	local indicators = {}
	for i, anim in ipairs(anims) do
		local row = el("Frame", parent, {
			Size                  = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency= 1,
			LayoutOrder           = order + i,
		})
		local radio = el("Frame", row, {
			Size             = UDim2.new(0, 12, 0, 12),
			Position         = UDim2.new(0, 0, 0.5, -6),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderSizePixel  = 0,
			ZIndex           = 13,
		})
		el("UIStroke", radio, {Color = S.TargetAnim == anim.id and C.ACCENT or Color3.fromRGB(51,51,51), Thickness = 1})
		local dot = el("Frame", radio, {
			Size             = UDim2.new(0, 5, 0, 5),
			Position         = UDim2.new(0.5, -2, 0.5, -2),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel  = 0,
			ZIndex           = 14,
			Visible          = S.TargetAnim == anim.id,
		})
		local nameLbl = el("TextLabel", row, {
			Text              = anim.name,
			TextColor3        = S.TargetAnim == anim.id and Color3.fromRGB(204,204,204) or Color3.fromRGB(102,102,102),
			BackgroundTransparency = 1,
			Size              = UDim2.new(1, -20, 1, 0),
			Position          = UDim2.new(0, 20, 0, 0),
			Font              = Enum.Font.Code,
			TextSize          = 10,
			TextXAlignment    = Enum.TextXAlignment.Left,
			ZIndex            = 13,
		})
		local btn = el("TextButton", row, {
			Text              = "",
			BackgroundTransparency = 1,
			Size              = UDim2.new(1, 0, 1, 0),
			ZIndex            = 15,
			AutoButtonColor   = false,
			Active            = true,
		})
		indicators[anim.id] = {radio = radio, dot = dot, lbl = nameLbl}
		local aid = anim.id
		btn.Activated:Connect(function()
			S.TargetAnim = aid
			for j, ind in pairs(indicators) do
				local active = (j == aid)
				ind.dot.Visible = active
				local st = ind.radio:FindFirstChildOfClass("UIStroke")
				if st then st.Color = active and C.ACCENT or Color3.fromRGB(51,51,51) end
				ind.lbl.TextColor3 = active and Color3.fromRGB(204,204,204) or Color3.fromRGB(102,102,102)
			end
		end)
	end
end

-- ── Accordion / Group — HTML: .group-header height:26px border:1px solid #1e1e1e ──
local function addGroup(parent, title, order, startOpen, buildFn)
	local wrapper = el("Frame", parent, {
		Size                  = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency= 1,
		LayoutOrder           = order,
		AutomaticSize         = Enum.AutomaticSize.Y,
	})

	-- header: HTML height:26px, border:1px solid #1e1e1e, background:#080808
	local header = el("TextButton", wrapper, {
		Size             = UDim2.new(1, 0, 0, 26),
		Position         = UDim2.new(0, 0, 0, 0),
		BackgroundColor3 = Color3.fromRGB(8, 8, 8),
		Text             = "",
		BorderSizePixel  = 0,
		ZIndex           = 13,
		AutoButtonColor  = false,
		Active           = true,
	})
	el("UIStroke", header, {Color = Color3.fromRGB(30, 30, 30), Thickness = 1})

	-- title: HTML font-size:9px, letter-spacing:1.5px, color:#fff, uppercase
	el("TextLabel", header, {
		Text              = string.upper(title),
		TextColor3        = Color3.fromRGB(255, 255, 255),
		BackgroundTransparency = 1,
		Size              = UDim2.new(1, -30, 1, 0),
		Position          = UDim2.new(0, 8, 0, 0),
		Font              = Enum.Font.Code,
		TextSize          = 9,
		TextXAlignment    = Enum.TextXAlignment.Left,
		ZIndex            = 14,
	})

	-- arrow: HTML font-size:9px, color:#444, font-weight:700, "›" / rotated
	local arrow = el("TextLabel", header, {
		Text              = startOpen and "v" or ">",
		TextColor3        = Color3.fromRGB(68, 68, 68),
		BackgroundTransparency = 1,
		Size              = UDim2.new(0, 20, 1, 0),
		Position          = UDim2.new(1, -22, 0, 0),
		Font              = Enum.Font.Code,
		TextSize          = 9,
		ZIndex            = 14,
	})

	-- body: HTML border:1px solid #111, border-top:none, padding:6px 8px 6px 12px
	local body = el("Frame", wrapper, {
		Size                  = UDim2.new(1, 0, 0, 0),
		Position              = UDim2.new(0, 0, 0, 27),
		BackgroundColor3      = Color3.fromRGB(2, 2, 2),
		AutomaticSize         = Enum.AutomaticSize.Y,
		ClipsDescendants      = true,
		Visible               = startOpen,
		BorderSizePixel       = 0,
		ZIndex                = 13,
	})
	el("UIStroke", body, {Color = Color3.fromRGB(17, 17, 17), Thickness = 1})
	el("UIPadding", body, {
		PaddingLeft   = UDim.new(0, 12),
		PaddingRight  = UDim.new(0, 8),
		PaddingTop    = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
	})
	el("UIListLayout", body, {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding   = UDim.new(0, 3),
	})

	buildFn(body)

	local open = startOpen
	header.Activated:Connect(function()
		open = not open
		body.Visible = open
		arrow.Text = open and "v" or ">"
		arrow.TextColor3 = open and Color3.fromRGB(136,136,136) or Color3.fromRGB(68,68,68)
		local st = header:FindFirstChildOfClass("UIStroke")
		if st then st.Color = open and Color3.fromRGB(51,51,51) or Color3.fromRGB(30,30,30) end
	end)

	header.MouseEnter:Connect(function()
		local st = header:FindFirstChildOfClass("UIStroke")
		if st then st.Color = Color3.fromRGB(51,51,51) end
	end)
	header.MouseLeave:Connect(function()
		if not open then
			local st = header:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(30,30,30) end
		end
	end)
end

-- ── Кнопка — HTML: height:24px, border:1px solid #333, font-size:9px ──────
local function addBtn(parent, label, order, accent, cb)
	local row = el("Frame", parent, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = order or 0,
	})
	local btn = el("TextButton", row, {
		Text             = string.upper(label),
		TextColor3       = accent and Color3.fromRGB(0,0,0) or Color3.fromRGB(255,255,255),
		BackgroundColor3 = accent and Color3.fromRGB(255,255,255) or Color3.fromRGB(0,0,0),
		Size             = UDim2.new(1, 0, 0, 24),
		Font             = Enum.Font.Code,
		TextSize         = 9,
		BorderSizePixel  = 0,
		ZIndex           = 14,
		AutoButtonColor  = false,
		Active           = true,
	})
	if not accent then
		el("UIStroke", btn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})
	end
	btn.MouseEnter:Connect(function()
		if accent then
			btn.BackgroundColor3 = Color3.fromRGB(221,221,221)
		else
			local st = btn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(255,255,255) end
			btn.BackgroundColor3 = Color3.fromRGB(13,13,13)
		end
	end)
	btn.MouseLeave:Connect(function()
		if accent then
			btn.BackgroundColor3 = Color3.fromRGB(255,255,255)
		else
			local st = btn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(51,51,51) end
			btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
		end
	end)
	if cb then btn.Activated:Connect(cb) end
	return btn
end

-- ── TextBox (для config) ─────────────────────────────────────────────────
local function makeTextBox(parent, rows, placeholder, order)
	local row = el("Frame", parent, {
		Size = UDim2.new(1, 0, 0, rows * 18 + 8),
		BackgroundTransparency = 1,
		LayoutOrder = order or 0,
	})
	local box = el("TextBox", row, {
		Text             = "",
		PlaceholderText  = placeholder or "",
		TextColor3       = Color3.fromRGB(255,255,255),
		PlaceholderColor3 = Color3.fromRGB(51,51,51),
		BackgroundColor3 = Color3.fromRGB(8,8,8),
		Size             = UDim2.new(1, 0, 1, 0),
		Font             = Enum.Font.Code,
		TextSize         = 9,
		BorderSizePixel  = 0,
		ZIndex           = 14,
		MultiLine        = true,
		TextWrapped      = true,
		TextXAlignment   = Enum.TextXAlignment.Left,
		TextYAlignment   = Enum.TextYAlignment.Top,
		ClearTextOnFocus = false,
	})
	el("UIStroke", box, {Color = Color3.fromRGB(34,34,34), Thickness = 1})
	el("UIPadding", box, {PaddingLeft = UDim.new(0,5), PaddingTop = UDim.new(0,4)})
	box.Focused:Connect(function()
		local st = box:FindFirstChildOfClass("UIStroke")
		if st then st.Color = Color3.fromRGB(85,85,85) end
	end)
	box.FocusLost:Connect(function()
		local st = box:FindFirstChildOfClass("UIStroke")
		if st then st.Color = Color3.fromRGB(34,34,34) end
	end)
	return box
end

-- =============================================
-- ЗАПОЛНЕНИЕ ВКЛАДОК
-- =============================================
do
	local t = tabFrames["aimbot"]

	addGroup(t, "Magic Bullet", 1, false, function(b)
		addToggle(b, "Silent Aim", "SilentAim", 1, function(v)
			if v then setToggleVisual("AimbotEnabled", false) end
		end)
	end)

	addGroup(t, "Magic Bullet Settings", 2, false, function(b)
		addSlider(b, "FOV",    "FOV",    30, 300, "%.0f", 1, function(v) circle.Radius = v end)
		addSlider(b, "Smooth", "Smooth", 0.05, 1, "%.2f", 2)
	end)

	addGroup(t, "Aimbot", 3, false, function(b)
		addToggle(b, "Aimbot",        "AimbotEnabled", 1, function(v)
			if v then setToggleVisual("SilentAim", false) end
		end)
		addToggle(b, "Visible Check", "VisibleCheck",  2)
		addToggle(b, "Anti Recoil (RCS)", "RCS",       3)
		addToggle(b, "No Recoil",     "NoRecoil",      4, function(v)
			if v then startNoRecoil() else stopNoRecoil() end
		end)
		addToggle(b, "Trigger Bot",   "TriggerBot",    5)
		addToggle(b, "Aim Lock",      "AimLock",       6)
	end)

	addGroup(t, "Aimbot Settings", 4, false, function(b)
		addSlider(b, "FOV",           "FOV",          30,  300, "%.0f", 1, function(v) circle.Radius = v end)
		addSlider(b, "Smooth",        "Smooth",       0.05,  1, "%.2f", 2)
		addSlider(b, "Prediction",    "Prediction",   0,   0.5, "%.3f", 3)
		addSlider(b, "Hitbox Scale",  "HitboxScale",  1,     6, "%.1f", 4)
		addSlider(b, "Body Offset Y", "BodyOffset",  -3,     3, "%.1f", 5)
		addSlider(b, "Max Distance",  "MaxTargetDist",50, 2000, "%.0f", 6)
		addSlider(b, "Min Distance",  "MinTargetDist", 0,  100, "%.0f", 7)
		addSlider(b, "AimLock Time",  "AimLockTime",  0.1,  10, "%.1f", 8)
		addPicker(b, "Aim Point",     "AimPart",      {"Head", "Body", "Legs"}, 9)
		addPicker(b, "Aim Key",       "AimKey",       {"Always", "RMB Hold", "LMB Hold"}, 13)
		addPicker(b, "Prediction Mode","PredictionMode",{"Velocity", "Linear+Ping"}, 17)
	end)

	addGroup(t, "Target Animation", 5, false, function(b)
		addAnimPicker(b, 1)
	end)
end

do
	local t = tabFrames["visuals"]

	addGroup(t, "ESP", 1, false, function(b)
		addToggle(b, "ESP Boxes",     "ESPEnabled", 1)
		addToggle(b, "Skeleton",      "Skeleton",   2)
		addToggle(b, "Tracers",       "Tracers",    3)
		addToggle(b, "Names",         "Names",      4)
		addToggle(b, "FOV Circle",    "FOVCircle",  5)
		addToggle(b, "Distance Tags", "ESPDist",    6)
	end)

	addGroup(t, "ESP Style", 2, false, function(b)
		addPicker(b, "Box Mode",      "ESPBoxMode", {"Square", "Corner Brackets", "3D Box"}, 1)
		addPicker(b, "Tracer Origin", "TracerMode", {"Crosshair", "Top of screen", "Both"}, 5)
		addSlider(b, "ESP Radius",    "ESPRadius",  50, 5000, "%.0f", 9)
	end)

	addGroup(t, "Crosshair", 4, false, function(b)
		addToggle(b, "Crosshair",      "CrosshairEnabled", 1, function(v)
			crosshairSettings.crosshairEnabled = v
			if not v then stopCrosshair() else startCrosshair() end
		end)
		addToggle(b, "Spin",           "CrosshairSpin",    2, function(v)
			crosshairSettings.crosshairSpin = v
		end)
		addToggle(b, "Rainbow",        "CrosshairRainbow", 3, function(v)
			crosshairSettings.crosshairRainbow = v
		end)
		addDivider(b, 4)
		addPicker(b, "Style", "CrosshairType", {"Default (+)", "X", "Dot"}, 5, function(i)
			local types = {"Default", "X", "Dot"}
			crosshairSettings.crosshairType = types[i]
			chClear()
		end)
		addSlider(b, "Size",       "CrosshairSize",      2, 40, "%.0f", 9, function(v)
			crosshairSettings.crosshairSize = v
		end)
		addSlider(b, "Thickness",  "CrosshairThick",     1, 8,  "%.0f", 10, function(v)
			crosshairSettings.crosshairThickness = v
		end)
	end)

	addGroup(t, "Night Vision / Bullet Tracer", 6, false, function(b)
		addToggle(b, "Night Vision",  "NightVision",     1, function(v) nv.Enabled = v end)
		addToggle(b, "Bullet Tracer", "BulletTracer",    2)
		addToggle(b, "Tracer Glow",   "BulletTracerGlow",3)
	end)

	addGroup(t, "Hotbar Overlay", 7, false, function(b)
		addToggle(b, "Hotbar Overlay", "HotbarESP", 1, function(v)
			HotbarSettings.enabled = v
			if v then
				HotbarSettings.dist = S.ESPRadius
				HotbarUpdate()
			else
				for _, p in pairs(Players:GetPlayers()) do ClearGUI(p) end
			end
		end)
	end)
end

do
	local t = tabFrames["misc"]

	addGroup(t, "Watermark", 1, false, function(b)
		addToggle(b, "Watermark", "Watermark", 1, function(v) setWatermark(v) end)
	end)

	addGroup(t, "Auto Farm", 2, false, function(b)
		addToggle(b, "Auto Farm", "AutoFarm", 1)
		addDivider(b, 2)
		addPicker(b, "Target", "FarmTarget", {"Ore", "Tree"}, 3)
	end)
end

do
	local t = tabFrames["movement"]

	addGroup(t, "Speed Rost Alpha", 2, false, function(b)
		addToggle(b, "Speed Rost Alpha", "SpeedRostAlpha", 1, function(v)
			if v then startSpeedRost() else stopSpeedRost() end
		end)
		addSlider(b, "Speed Value", "SpeedRostValue", 16, 120, "%.0f", 2)
		addSlider(b, "Smoothing",   "SpeedRostSmoothing", 0.1, 1, "%.2f", 3)
	end)

	addGroup(t, "Spider (Wall Climb)", 4, false, function(b)
		addToggle(b, "Spider", "Spider", 1, function(v)
			if v then startSpider() else stopSpider() end
		end)
		addSlider(b, "Spider Speed", "SpiderSpeed", 1, 100, "%.0f", 2)
	end)

	addGroup(t, "No Fall Damage", 5, false, function(b)
		addToggle(b, "No Fall Damage", "NoFall", 1, function(v)
			if v then startNoFall() else stopNoFall() end
		end)
	end)

	addGroup(t, "Anti-Aim", 6, false, function(b)
		addToggle(b, "Anti-Aim", "AntiAim", 1, function(v)
			if v then startAntiAim() else stopAntiAim() end
		end)
		addToggle(b, "Pitch Jitter", "AntiAimPitch", 2)
		addDivider(b, 3)
		addPicker(b, "AA Mode", "AntiAimMode", {"Spin", "Jitter", "Static 180"}, 4)
	end)
end

do
	local t = tabFrames["world"]

	addGroup(t, "Time Changer", 1, false, function(b)
		addToggle(b, "Time Changer", "TimeChangerEnabled", 1, function(v)
			if v then startTimeChanger() else stopTimeChanger() end
		end)
		addSlider(b, "Hour of Day", "TimeOfDay", 0, 24, "%.1f", 2, function(v)
			if S.TimeChangerEnabled then Lighting.ClockTime = v end
		end)
		addDivider(b, 3)
		addSubSec(b, "Quick Presets", 4)
		local presets = {
			{name="Dawn   5:00",  time=5},
			{name="Noon  12:00",  time=12},
			{name="Sunset 18:00", time=18},
			{name="Night  22:00", time=22},
		}
		-- 2-column grid via frames
		local gridRow = el("Frame", b, {
			Size = UDim2.new(1, 0, 0, 60),
			BackgroundTransparency = 1,
			LayoutOrder = 5,
		})
		for i, preset in ipairs(presets) do
			local col = (i-1) % 2
			local row2 = math.floor((i-1) / 2)
			local btn = el("TextButton", gridRow, {
				Text             = preset.name,
				TextColor3       = Color3.fromRGB(255,255,255),
				BackgroundColor3 = Color3.fromRGB(0,0,0),
				Size             = UDim2.new(0.5, -3, 0, 26),
				Position         = UDim2.new(col * 0.5, col == 0 and 0 or 3, 0, row2 * 30),
				Font             = Enum.Font.Code,
				TextSize         = 9,
				BorderSizePixel  = 0,
				ZIndex           = 14,
				AutoButtonColor  = false,
				Active           = true,
			})
			el("UIStroke", btn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})
			btn.MouseEnter:Connect(function()
				local st = btn:FindFirstChildOfClass("UIStroke")
				if st then st.Color = Color3.fromRGB(255,255,255) end
				btn.BackgroundColor3 = Color3.fromRGB(13,13,13)
			end)
			btn.MouseLeave:Connect(function()
				local st = btn:FindFirstChildOfClass("UIStroke")
				if st then st.Color = Color3.fromRGB(51,51,51) end
				btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
			end)
			local ptime = preset.time
			btn.Activated:Connect(function()
				S.TimeOfDay = ptime
				S.TimeChangerEnabled = true
				Lighting.ClockTime = ptime
			end)
		end
	end)
end

do
	local t = tabFrames["friends"]
	addSec(t, "Players on Server", 1)

	local listOrder = 2
	local friendRows = {}

	local function refreshFriendsList()
		for _, child in ipairs(t:GetChildren()) do
			if child:IsA("Frame") and child.LayoutOrder >= 2 then
				child:Destroy()
			end
		end
		listOrder = 2
		friendRows = {}

		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= LocalPlayer then
				local pid = p.UserId
				local pname = p.Name
				local alreadyFriend = FriendsList[pid] == true

				local row = el("Frame", t, {
					Size = UDim2.new(1, 0, 0, 26),
					BackgroundColor3 = Color3.fromRGB(0,0,0),
					BackgroundTransparency = 1,
					BorderSizePixel = 0,
					LayoutOrder = listOrder,
				})
				-- HTML border-bottom: 1px solid #0e0e0e
				el("Frame", row, {
					Size = UDim2.new(1,0,0,1),
					Position = UDim2.new(0,0,1,-1),
					BackgroundColor3 = Color3.fromRGB(14,14,14),
					BorderSizePixel = 0,
					ZIndex = 13,
				})
				listOrder = listOrder + 1

				-- dot: HTML 6x6px, background:#fff / #333
				local dot = el("Frame", row, {
					Size = UDim2.new(0, 6, 0, 6),
					Position = UDim2.new(0, 2, 0.5, -3),
					BackgroundColor3 = alreadyFriend and Color3.fromRGB(51,51,51) or Color3.fromRGB(255,255,255),
					BorderSizePixel = 0,
					ZIndex = 13,
				})

				el("TextLabel", row, {
					Text = pname .. (alreadyFriend and " [FRIEND]" or ""),
					TextColor3 = alreadyFriend and C.SUBTEXT or Color3.fromRGB(204,204,204),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, -90, 1, 0),
					Position = UDim2.new(0, 14, 0, 0),
					Font = Enum.Font.Code,
					TextSize = 10,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 13,
				})

				-- friend button: HTML height:16px, padding:0 8px
				local addBtn = el("TextButton", row, {
					Text             = alreadyFriend and "Remove" or "+ Friend",
					TextColor3       = alreadyFriend and Color3.fromRGB(102,102,102) or Color3.fromRGB(0,0,0),
					BackgroundColor3 = alreadyFriend and Color3.fromRGB(17,17,17) or Color3.fromRGB(255,255,255),
					Size             = UDim2.new(0, 60, 0, 16),
					Position         = UDim2.new(1, -62, 0.5, -8),
					Font             = Enum.Font.Code,
					TextSize         = 8,
					BorderSizePixel  = 0,
					ZIndex           = 14,
					AutoButtonColor  = false,
					Active           = true,
				})
				if alreadyFriend then
					el("UIStroke", addBtn, {Color = Color3.fromRGB(42,42,42), Thickness = 1})
				end

				addBtn.Activated:Connect(function()
					if FriendsList[pid] then
						FriendsList[pid] = nil
						addBtn.Text = "+ Friend"
						addBtn.BackgroundColor3 = Color3.fromRGB(255,255,255)
						addBtn.TextColor3 = Color3.fromRGB(0,0,0)
						local st = addBtn:FindFirstChildOfClass("UIStroke")
						if st then st:Destroy() end
						dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
					else
						FriendsList[pid] = true
						addBtn.Text = "Remove"
						addBtn.BackgroundColor3 = Color3.fromRGB(17,17,17)
						addBtn.TextColor3 = Color3.fromRGB(102,102,102)
						el("UIStroke", addBtn, {Color = Color3.fromRGB(42,42,42), Thickness = 1})
						dot.BackgroundColor3 = Color3.fromRGB(51,51,51)
					end
				end)
			end
		end

		-- Refresh button
		local refreshRow = el("Frame", t, {
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			LayoutOrder = listOrder,
		})
		local refreshBtn = el("TextButton", refreshRow, {
			Text             = "REFRESH LIST",
			TextColor3       = Color3.fromRGB(255,255,255),
			BackgroundColor3 = Color3.fromRGB(0,0,0),
			Size             = UDim2.new(1, 0, 0, 24),
			Font             = Enum.Font.Code,
			TextSize         = 9,
			BorderSizePixel  = 0,
			ZIndex           = 14,
			AutoButtonColor  = false,
			Active           = true,
		})
		el("UIStroke", refreshBtn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})
		refreshBtn.MouseEnter:Connect(function()
			local st = refreshBtn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(255,255,255) end
			refreshBtn.BackgroundColor3 = Color3.fromRGB(13,13,13)
		end)
		refreshBtn.MouseLeave:Connect(function()
			local st = refreshBtn:FindFirstChildOfClass("UIStroke")
			if st then st.Color = Color3.fromRGB(51,51,51) end
			refreshBtn.BackgroundColor3 = Color3.fromRGB(0,0,0)
		end)
		refreshBtn.Activated:Connect(refreshFriendsList)
	end

	refreshFriendsList()

	Players.PlayerAdded:Connect(function()
		if activeTab == "friends" then refreshFriendsList() end
	end)
	Players.PlayerRemoving:Connect(function()
		task.wait(0.1)
		if activeTab == "friends" then refreshFriendsList() end
	end)
end

-- =============================================
-- CONFIGURATION TAB
-- =============================================
do
	local t = tabFrames["configuration"]
	local savedConfigs = {}

	local function serializeConfig()
		local parts = {}
		for k, v in pairs(S) do
			local vtype = type(v)
			if vtype == "boolean" then
				table.insert(parts, k .. "=" .. tostring(v))
			elseif vtype == "number" then
				table.insert(parts, k .. "=" .. tostring(v))
			end
		end
		table.sort(parts)
		return table.concat(parts, ";")
	end

	local function deserializeConfig(str)
		if not str or str == "" then return false end
		local ok = false
		for pair in str:gmatch("([^;]+)") do
			local k, v = pair:match("^(.-)=(.+)$")
			if k and v and S[k] ~= nil then
				local stype = type(S[k])
				if stype == "boolean" then
					S[k] = (v == "true"); ok = true
				elseif stype == "number" then
					local n = tonumber(v)
					if n then S[k] = n; ok = true end
				end
			end
		end
		return ok
	end

	local configListFrame = nil
	local exportBox       = nil
	local statusLabel     = nil
	local exportAreaFrame = nil

	local function rebuildConfigList()
		if not configListFrame then return end
		for _, ch in ipairs(configListFrame:GetChildren()) do
			if not ch:IsA("UIListLayout") and not ch:IsA("UIPadding") then
				ch:Destroy()
			end
		end
		local idx = 0
		for name, data in pairs(savedConfigs) do
			idx = idx + 1
			local row = el("Frame", configListFrame, {
				Size = UDim2.new(1, 0, 0, 28),
				BackgroundColor3 = Color3.fromRGB(8,8,8),
				BorderSizePixel = 0,
				LayoutOrder = idx,
				ZIndex = 13,
			})
			el("UIStroke", row, {Color = Color3.fromRGB(34,34,34), Thickness = 1})
			el("TextLabel", row, {
				Text = name,
				TextColor3 = Color3.fromRGB(255,255,255),
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -70, 1, 0),
				Position = UDim2.new(0, 8, 0, 0),
				Font = Enum.Font.Code,
				TextSize = 9,
				TextXAlignment = Enum.TextXAlignment.Left,
				ZIndex = 14,
			})
			local loadBtn = el("TextButton", row, {
				Text = "LOAD",
				TextColor3 = Color3.fromRGB(0,0,0),
				BackgroundColor3 = Color3.fromRGB(255,255,255),
				Size = UDim2.new(0, 50, 0, 18),
				Position = UDim2.new(1, -56, 0.5, -9),
				Font = Enum.Font.Code,
				TextSize = 9,
				BorderSizePixel = 0,
				ZIndex = 15,
				AutoButtonColor = false,
				Active = true,
			})
			local cname = name
			loadBtn.Activated:Connect(function()
				if deserializeConfig(data) then
					if statusLabel then statusLabel.Text = "Loaded: " .. cname end
				end
			end)
		end
	end

	-- Top button row: Save / Export / Load (как в HTML: 3 кнопки в ряд)
	local btnRow = el("Frame", t, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	})
	el("UIListLayout", btnRow, {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- Save (accent)
	local saveBtn = el("TextButton", btnRow, {
		Text             = "SAVE",
		TextColor3       = Color3.fromRGB(0,0,0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Size             = UDim2.new(0, 90, 0, 24),
		Font             = Enum.Font.Code,
		TextSize         = 9,
		BorderSizePixel  = 0,
		ZIndex           = 14,
		AutoButtonColor  = false,
		Active           = true,
		LayoutOrder      = 1,
	})

	-- Export
	local exportBtn = el("TextButton", btnRow, {
		Text             = "EXPORT",
		TextColor3       = Color3.fromRGB(255,255,255),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		Size             = UDim2.new(0, 90, 0, 24),
		Font             = Enum.Font.Code,
		TextSize         = 9,
		BorderSizePixel  = 0,
		ZIndex           = 14,
		AutoButtonColor  = false,
		Active           = true,
		LayoutOrder      = 2,
	})
	el("UIStroke", exportBtn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})

	-- Load
	local loadFileBtn = el("TextButton", btnRow, {
		Text             = "LOAD",
		TextColor3       = Color3.fromRGB(255,255,255),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		Size             = UDim2.new(0, 90, 0, 24),
		Font             = Enum.Font.Code,
		TextSize         = 9,
		BorderSizePixel  = 0,
		ZIndex           = 14,
		AutoButtonColor  = false,
		Active           = true,
		LayoutOrder      = 3,
	})
	el("UIStroke", loadFileBtn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})

	-- Status
	statusLabel = el("TextLabel", t, {
		Text = "",
		TextColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 16),
		Font = Enum.Font.Code,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 2,
		ZIndex = 13,
	})

	-- Export area
	exportAreaFrame = el("Frame", t, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	el("UIListLayout", exportAreaFrame, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})

	el("TextLabel", exportAreaFrame, {
		Text = "Config Output",
		TextColor3 = Color3.fromRGB(68,68,68),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.Code,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 1,
		ZIndex = 13,
	})

	exportBox = makeTextBox(exportAreaFrame, 4, "", 2)
	exportBox.Parent.LayoutOrder = 2

	local copyRow = el("Frame", exportAreaFrame, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	})
	local copyBtn = el("TextButton", copyRow, {
		Text = "COPY TO CLIPBOARD",
		TextColor3 = Color3.fromRGB(0,0,0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Size = UDim2.new(1,0,0,24),
		Font = Enum.Font.Code,
		TextSize = 9,
		BorderSizePixel = 0,
		ZIndex = 14,
		AutoButtonColor = false,
		Active = true,
	})
	copyBtn.Activated:Connect(function()
		pcall(function() setclipboard(exportBox.Text) end)
		if statusLabel then statusLabel.Text = "Copied to clipboard!" end
	end)

	-- Import section
	el("TextLabel", t, {
		Text = "Import Config",
		TextColor3 = Color3.fromRGB(68,68,68),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 14),
		Font = Enum.Font.Code,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 4,
		ZIndex = 13,
	})

	local importBox = makeTextBox(t, 3, "Paste config text here...", 5)
	importBox.Parent.LayoutOrder = 5

	local importBtnRow = el("Frame", t, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 6,
	})
	local applyBtn = el("TextButton", importBtnRow, {
		Text = "LOAD FROM TEXT",
		TextColor3 = Color3.fromRGB(255,255,255),
		BackgroundColor3 = Color3.fromRGB(0,0,0),
		Size = UDim2.new(1,0,0,24),
		Font = Enum.Font.Code,
		TextSize = 9,
		BorderSizePixel = 0,
		ZIndex = 14,
		AutoButtonColor = false,
		Active = true,
	})
	el("UIStroke", applyBtn, {Color = Color3.fromRGB(51,51,51), Thickness = 1})
	applyBtn.Activated:Connect(function()
		if importBox.Text ~= "" then
			if deserializeConfig(importBox.Text) then
				if statusLabel then statusLabel.Text = "Config loaded from text!" end
			else
				if statusLabel then statusLabel.Text = "Invalid config text." end
			end
		end
	end)

	-- Saved configs label
	el("TextLabel", t, {
		Text = "SAVED CONFIGS",
		TextColor3 = Color3.fromRGB(255,255,255),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.Code,
		TextSize = 8,
		TextXAlignment = Enum.TextXAlignment.Left,
		LayoutOrder = 7,
		ZIndex = 13,
	})

	-- Config list
	local listContainer = el("Frame", t, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 8,
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	configListFrame = listContainer
	el("UIListLayout", listContainer, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})

	local emptyLbl = el("TextLabel", listContainer, {
		Text = "No saved configs yet.",
		TextColor3 = Color3.fromRGB(51,51,51),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 24),
		Font = Enum.Font.Code,
		TextSize = 9,
		TextXAlignment = Enum.TextXAlignment.Center,
		LayoutOrder = 0,
		ZIndex = 13,
	})

	-- Save name input
	local saveNameFrame = el("Frame", t, {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = 9,
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = false,
	})
	el("UIListLayout", saveNameFrame, {SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0,4)})

	local nameBox = el("TextBox", saveNameFrame, {
		Text = "",
		PlaceholderText = "Config name...",
		TextColor3 = Color3.fromRGB(255,255,255),
		PlaceholderColor3 = Color3.fromRGB(51,51,51),
		BackgroundColor3 = Color3.fromRGB(8,8,8),
		Size = UDim2.new(1, 0, 0, 26),
		Font = Enum.Font.Code,
		TextSize = 11,
		BorderSizePixel = 0,
		ZIndex = 14,
		ClearTextOnFocus = false,
		LayoutOrder = 1,
	})
	el("UIStroke", nameBox, {Color = Color3.fromRGB(34,34,34), Thickness = 1})
	el("UIPadding", nameBox, {PaddingLeft = UDim.new(0,6)})

	local confirmRow = el("Frame", saveNameFrame, {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	})
	local confirmBtn = el("TextButton", confirmRow, {
		Text = "CONFIRM SAVE",
		TextColor3 = Color3.fromRGB(0,0,0),
		BackgroundColor3 = Color3.fromRGB(255,255,255),
		Size = UDim2.new(1,0,0,24),
		Font = Enum.Font.Code,
		TextSize = 9,
		BorderSizePixel = 0,
		ZIndex = 14,
		AutoButtonColor = false,
		Active = true,
	})

	-- Button logic
	saveBtn.Activated:Connect(function()
		saveNameFrame.Visible = not saveNameFrame.Visible
	end)
	confirmBtn.Activated:Connect(function()
		local cname = nameBox.Text
		if cname == "" then cname = "Config " .. tostring(#savedConfigs + 1) end
		savedConfigs[cname] = serializeConfig()
		saveNameFrame.Visible = false
		nameBox.Text = ""
		emptyLbl.Visible = false
		rebuildConfigList()
		if statusLabel then statusLabel.Text = "Saved: " .. cname end
	end)
	exportBtn.Activated:Connect(function()
		exportAreaFrame.Visible = not exportAreaFrame.Visible
		if exportAreaFrame.Visible then
			exportBox.Text = serializeConfig()
		end
	end)
	loadFileBtn.Activated:Connect(function()
		-- already visible by default
	end)
end

-- ── Drag ─────────────────────────────────────────────────────────────────
local dragOn, dragStart, dragPos = false, nil, nil
titleBar.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragOn = true
		dragStart = i.Position
		dragPos = win.Position
	end
end)
UserInputService.InputChanged:Connect(function(i)
	if dragOn and dragStart and dragPos then
		local d = i.Position - dragStart
		win.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + d.X, dragPos.Y.Scale, dragPos.Y.Offset + d.Y)
	end
end)
UserInputService.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
		dragOn = false
	end
end)

-- ── Toggle GUI ───────────────────────────────────────────────────────────
local function toggle()
	local now = tick()
	if now - lastTap < 0.4 then return end
	lastTap = now
	guiOpen = not guiOpen
	win.Visible = guiOpen
	openBtn.Text = guiOpen and "X" or "LW"
	-- Ватермарка видна только когда меню ЗАКРЫТО (как в HTML)
	wmFrame.Visible = S.Watermark and not guiOpen
	if guiOpen and not activeTab then
		switchTab("aimbot")
	end
end

openBtn.Activated:Connect(toggle)
closeBtn.Activated:Connect(toggle)

UserInputService.InputBegan:Connect(function(inp, gpe)
	if gpe then return end
	if inp.KeyCode == Enum.KeyCode.RightShift or inp.KeyCode == Enum.KeyCode.Insert then
		toggle()
	end
end)

switchTab("aimbot")
print("losware v4 loaded")
