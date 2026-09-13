	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local TS = game:GetService("TweenService")
	local RS = game:GetService("RunService")
	local LP = Players.LocalPlayer
	local CAM = workspace.CurrentCamera
	local _connections = {}
	local _drawObjects = {}
	local _threads = {}

	local function trackConn(c)
		table.insert(_connections, c)
		return c
	end

	local function trackDraw(d)
		table.insert(_drawObjects, d)
		return d
	end

	local function trackThread(t)
		table.insert(_threads, t)
		return t
	end

	local RED = Color3.fromRGB(17, 255, 0)
	local BLACK = Color3.fromRGB(31, 31, 31)
	local WHITE = Color3.fromRGB(255, 255, 255)
	local DIM = Color3.fromRGB(85, 85, 85)
	local LINE = Color3.fromRGB(85, 85, 85)

	local S = {
		AimbotEnabled = false,
		AimbotMode = "Smooth",
		AimbotSpeed = 5,
		AimPart = "Head",
		ESPEnabled = false,
		BoxEnabled = false,
		NameEnabled = false,
		HealthEnabled = false,
		WallCheck = false,
		TeamCheck = false,
		ShowFOV = false,
		FOVRadius = 80,
		TriggerEnabled = false,
		TriggerMode = "hold",
		ToolCheckEnabled = false,
		Precision = 50,
		TriggerDelay = 1,
		MaxDistance = 500,
		KnifeCheck = false,
		ForceFieldCheck = false,
		MagneticEnabled = false,
		MagFOV = 10,
		WalkEnabled = false,
		WalkSpeed = 16,
		JumpEnabled = false,
		JumpPower = 50,
		WhitelistEnabled = false,
		MenuKey = Enum.KeyCode.Insert,
		AimbotKey = nil,
		AimbotKeyName = "MB2",
		InfJump = false,
		NoClip = false,
		FlyEnabled = false,
		FlySpeed = 50,
		FlyKey = Enum.KeyCode.F,
		FreecamEnabled = false,
		FreecamSpeed = 50,
		FreecamKey = Enum.KeyCode.V,
		TrackAllEnabled = false,
		TrackAllKey = Enum.KeyCode.T,
		SpeedEnabled = false,
		SpeedValue = 16,
		
		-- radar settings
		
		RadarEnabled = false,
		RadarSize = 150,
		RadarRange = 200,
		RadarShowNames = false,
		RadarShowDistance = false,
		RadarShowHealth = false,
		RadarTeamCheck = false,
		RadarWhitelistEnabled = false,
		RadarPosition = "BottomRight",
		RadarOpacity = 40,
		RadarBorderColor = "Purple",
		RadarEnemyColor = "Red",
		RadarFriendlyColor = "Green",
		RadarTeamColor = "Blue",
		RadarShowAll = false,
		RadarRotateWithPlayer = true,
		RadarDotSize = 8,
	}

	local WhitelistState = {}
	local toggleFired = false
	local menuKeyCapturing = false
	local espObjects = {}

	local function tw(o, p, t)
		TS:Create(o, TweenInfo.new(t or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
	end

	local function rnd(p, r)
		local c = Instance.new("UICorner", p)
		c.CornerRadius = UDim.new(0, r or 6)
		return c
	end

	local function pill(p)
		local c = Instance.new("UICorner", p)
		c.CornerRadius = UDim.new(1, 0)
		return c
	end

	local function stk(p, col, th)
		local s = Instance.new("UIStroke", p)
		s.Color = Color3.fromRGB(0, 0, 0)
		s.Thickness = th or 1
		s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		return s
	end

	local function fr(parent, sz, pos, bg, tr)
		local mAIN = Instance.new("Frame", parent)
		mAIN.Size = sz
		mAIN.Position = pos or UDim2.new(0, 0, 0, 0)
		mAIN.BackgroundColor3 = bg or BLACK

		if tr then
			mAIN.BackgroundTransparency = tr
		end

		mAIN.BorderSizePixel = 0
		return mAIN
	end

	local function lbl(parent, txt, tsz, col, bold, xa)
		local l = Instance.new("TextLabel", parent)
		l.BackgroundTransparency = 1
		l.Text = txt
		l.TextSize = tsz or 12
		l.TextColor3 = col or WHITE
		l.Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham
		l.TextXAlignment = xa or Enum.TextXAlignment.Left
		l.TextYAlignment = Enum.TextYAlignment.Center
		return l
	end

	local function mkSearchBox(parent, yPos, w, placeholder)
		local box = Instance.new("TextBox", parent)
		box.Size = UDim2.fromOffset(w - 8, 26)
		box.Position = UDim2.fromOffset(4, yPos)
		box.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
		box.BorderSizePixel = 0
		box.Text = ""
		box.PlaceholderText = "" .. placeholder
		box.PlaceholderColor3 = Color3.fromRGB(55, 55, 55)
		box.TextColor3 = WHITE
		box.TextSize = 11
		box.Font = Enum.Font.Gotham
		box.ClearTextOnFocus = false
		rnd(box, 6)

		local stkBox = Instance.new("UIStroke", box)
		stkBox.Color = Color3.fromRGB(0, 0, 0)
		stkBox.Thickness = 1
		stkBox.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local pad = Instance.new("UIPadding", box)
		pad.PaddingLeft = UDim.new(0, 8)

		box.Focused:Connect(function()
			TS:Create(stkBox, TweenInfo.new(0.15), { Color = RED }):Play()
		end)

		box.FocusLost:Connect(function()
			TS:Create(stkBox, TweenInfo.new(0.15), { Color = Color3.fromRGB(0, 0, 0) }):Play()
		end)

		return box
	end

	local function mkToggle(parent, rightX, centerY, default, cb)
		local BOX_SIZE = 18
		local state = default or false
		local container = Instance.new("Frame", parent)
		container.Size = UDim2.fromOffset(BOX_SIZE, BOX_SIZE)
		container.Position = UDim2.fromOffset(rightX - BOX_SIZE - 4, centerY - BOX_SIZE / 2)
		container.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		container.BorderSizePixel = 0
		rnd(container, 4)

		local stroke = Instance.new("UIStroke", container)
		stroke.Color = state and RED or Color3.fromRGB(45, 45, 45)
		stroke.Thickness = 1.5
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local fill = Instance.new("Frame", container)
		fill.Size = UDim2.new(1, -4, 1, -4)
		fill.Position = UDim2.fromOffset(2, 2)
		fill.BackgroundColor3 = RED
		fill.BorderSizePixel = 0
		fill.BackgroundTransparency = state and 0 or 1
		rnd(fill, 2)

		local check = Instance.new("TextLabel", container)
		check.Size = UDim2.new(1, 0, 1, 0)
		check.BackgroundTransparency = 1
		check.Text = ""
		check.TextColor3 = WHITE
		check.TextSize = 11
		check.Font = Enum.Font.GothamBold
		check.TextXAlignment = Enum.TextXAlignment.Center
		check.TextYAlignment = Enum.TextYAlignment.Center
		check.TextTransparency = state and 0 or 1
		check.ZIndex = container.ZIndex + 2

		local btn = Instance.new("TextButton", container)
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.BorderSizePixel = 0
		btn.ZIndex = container.ZIndex + 3

		btn.MouseButton1Click:Connect(function()
			state = not state
			stroke.Color = state and RED or Color3.fromRGB(45, 45, 45)
			TS:Create(fill, TweenInfo.new(0.1), { BackgroundTransparency = state and 0 or 1 }):Play()
			TS:Create(check, TweenInfo.new(0.1), { TextTransparency = state and 0 or 1 }):Play()

			if cb then
				cb(state)
			end
		end)

		local function setState(v)
			state = v
			stroke.Color = v and RED or Color3.fromRGB(45, 45, 45)
			fill.BackgroundTransparency = v and 0 or 1
			check.TextTransparency = v and 0 or 1
		end

		return container, function() return state end, setState
	end

	local function mkRow(parent, yPos, w, labelTxt, default, cb)
		local ROW_H = 30
		local mAIN = fr(parent, UDim2.fromOffset(w, ROW_H), UDim2.fromOffset(0, yPos), BLACK, 1)
		local l = lbl(mAIN, labelTxt, 12, WHITE)
		l.Size = UDim2.new(1, -30, 1, 0)
		l.Position = UDim2.fromOffset(0, 0)
		mkToggle(mAIN, w - 2, ROW_H / 2, default, cb)
		fr(parent, UDim2.new(0, w, 0, 1), UDim2.fromOffset(0, yPos + ROW_H), LINE)
		return mAIN
	end

	local function mkSlider(parent, yPos, w, labelTxt, minV, maxV, default, cb)
		local TOTAL_H = 48
		local mAIN = fr(parent, UDim2.fromOffset(w, TOTAL_H), UDim2.fromOffset(0, yPos), BLACK, 1)
		local topRow = fr(mAIN, UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 0), BLACK, 1)
		local l = lbl(topRow, labelTxt, 11, Color3.fromRGB(180, 180, 180))
		l.Size = UDim2.new(0.65, 0, 1, 0)
		l.Position = UDim2.fromOffset(0, 0)

		local valLbl = lbl(topRow, tostring(default), 11, RED, true, Enum.TextXAlignment.Right)
		valLbl.Size = UDim2.new(0.35, -0, 1, 0)
		valLbl.Position = UDim2.new(0.65, 0, 0, 0)

		local trackBg = fr(mAIN, UDim2.new(1, 0, 0, 6), UDim2.new(0, 0, 0, 30), Color3.fromRGB(22, 22, 22))
		rnd(trackBg, 3)

		local pct = math.clamp((default - minV) / (maxV - minV), 0, 1)
		local trackFill = fr(trackBg, UDim2.new(pct, 0, 1, 0), UDim2.new(0, 0, 0, 0), RED)
		rnd(trackFill, 3)

		local dragging = false
		local hitArea = Instance.new("TextButton", trackBg)
		hitArea.Size = UDim2.new(1, 0, 0, 28)
		hitArea.Position = UDim2.new(0, 0, 0.5, -14)
		hitArea.BackgroundTransparency = 1
		hitArea.Text = ""
		hitArea.ZIndex = trackBg.ZIndex + 3

		local function applyX(screenX)
			local ax = trackBg.AbsolutePosition.X
			local aw = trackBg.AbsoluteSize.X
			local pct = math.clamp((screenX - ax) / aw, 0, 1)
			local val = math.floor(minV + (maxV - minV) * pct)
			trackFill.Size = UDim2.new(pct, 0, 1, 0)
			valLbl.Text = tostring(val)

			if cb then
				cb(val)
			end
		end

		hitArea.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
				applyX(UIS:GetMouseLocation().X)
			end
		end)

		trackConn(UIS.InputChanged:Connect(function(i)
			if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
				applyX(UIS:GetMouseLocation().X)
			end
		end))

		trackConn(UIS.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end))

		fr(parent, UDim2.new(0, w, 0, 1), UDim2.fromOffset(0, yPos + TOTAL_H), LINE)
		return mAIN, valLbl
	end

	local function mkBadgeRow(parent, yPos, w, labelTxt, badgeTxt, cb)
		local ROW_H = 30
		local mAIN = fr(parent, UDim2.fromOffset(w, ROW_H), UDim2.fromOffset(0, yPos), BLACK, 1)
		local l = lbl(mAIN, labelTxt, 12, WHITE)
		l.Size = UDim2.new(1, -80, 1, 0)
		l.Position = UDim2.fromOffset(0, 0)

		local badge = Instance.new("TextButton", mAIN)
		badge.Size = UDim2.fromOffset(66, 20)
		badge.Position = UDim2.new(1, -68, 0.5, -10)
		badge.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		badge.BorderSizePixel = 0
		badge.Text = tostring(badgeTxt)
		badge.TextColor3 = WHITE
		badge.TextSize = 10
		badge.Font = Enum.Font.Gotham
		rnd(badge, 5)

		local bs = Instance.new("UIStroke", badge)
		bs.Color = Color3.fromRGB(0, 0, 0)
		bs.Thickness = 1
		bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		if cb then
			badge.MouseButton1Click:Connect(function()
				cb(badge)
			end)

			badge.MouseEnter:Connect(function()
				tw(badge, { BackgroundColor3 = Color3.fromRGB(22, 22, 22) })
			end)

			badge.MouseLeave:Connect(function()
				tw(badge, { BackgroundColor3 = Color3.fromRGB(12, 12, 12) })
			end)
		end

		fr(parent, UDim2.new(0, w, 0, 1), UDim2.fromOffset(0, yPos + ROW_H), LINE)
		return mAIN, badge
	end

	local function mkSelectorRow(parent, yPos, w, labelTxt, opts, current, cb)
		local ROW_H = 30
		local mAIN = fr(parent, UDim2.fromOffset(w, ROW_H), UDim2.fromOffset(0, yPos), BLACK, 1)
		local l = lbl(mAIN, labelTxt, 12, WHITE)
		l.Size = UDim2.new(0.45, 0, 1, 0)
		l.Position = UDim2.fromOffset(0, 0)

		local bW = 46
		local gap = 3
		local totalW = #opts * bW + (#opts - 1) * gap
		local sx = w - totalW
		local btns = {}

		for i, opt in ipairs(opts) do
			local bx = sx + (i - 1) * (bW + gap)
			local b = Instance.new("TextButton", mAIN)
			b.Size = UDim2.fromOffset(bW, 20)
			b.Position = UDim2.new(0, bx, 0.5, -10)
			b.BackgroundColor3 = (opt == current) and RED or Color3.fromRGB(12, 12, 12)
			b.BorderSizePixel = 0
			b.Text = opt
			b.TextColor3 = WHITE
			b.TextSize = 10
			b.Font = Enum.Font.Gotham
			rnd(b, 5)

			local bs = Instance.new("UIStroke", b)
			bs.Color = Color3.fromRGB(0, 0, 0)
			bs.Thickness = 1
			bs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			table.insert(btns, { btn = b, opt = opt })

			b.MouseButton1Click:Connect(function()
				current = opt

				for _, bd in pairs(btns) do
					tw(bd.btn, { BackgroundColor3 = bd.opt == current and RED or Color3.fromRGB(12, 12, 12) })
				end

				if cb then
					cb(opt)
				end
			end)
		end

		fr(parent, UDim2.new(0, w, 0, 1), UDim2.fromOffset(0, yPos + ROW_H), LINE)
		return mAIN
	end

	local function secLabel(parent, yPos, w, txt)
		local H = 26
		local mAIN = fr(parent, UDim2.fromOffset(w, H), UDim2.fromOffset(0, yPos), BLACK, 1)
		local accent = fr(mAIN, UDim2.fromOffset(2, 12), UDim2.fromOffset(0, 7), RED)
		local l = lbl(mAIN, txt, 10, DIM, true)
		l.Size = UDim2.new(1, -12, 1, 0)
		l.Position = UDim2.fromOffset(8, 0)
		return mAIN
	end

	local mNXHub = Instance.new("ScreenGui")
	mNXHub.Name = "MNXHub"
	mNXHub.ResetOnSpawn = false
	mNXHub.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mNXHub.IgnoreGuiInset = true
	pcall(function()
		mNXHub.Parent = game:GetService("CoreGui")
	end)

	if not mNXHub.Parent then
		mNXHub.Parent = LP.PlayerGui
	end

	local WIN_W, WIN_H = 580, 450
	local SIDE_W = 160
	local Win = fr(mNXHub,
		UDim2.fromOffset(WIN_W, WIN_H),
		UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
		BLACK)
	Win.ClipsDescendants = true
	rnd(Win, 12)

	local winStroke = Instance.new("UIStroke", Win)
	winStroke.Color = Color3.fromRGB(22, 22, 22)
	winStroke.Thickness = 1
	winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	trackThread(task.spawn(function()
		while mNXHub and mNXHub.Parent do
			if Win.Visible then
				local px = math.random(20, WIN_W - 20)
				local sz = math.random(1, 2)
				local dot = fr(Win,
					UDim2.fromOffset(sz, sz),
					UDim2.fromOffset(px, WIN_H - 4),
					RED)
				dot.BackgroundTransparency = 0.3 + math.random() * 0.5
				dot.BorderSizePixel = 0
				dot.ZIndex = 1
				pill(dot)
				local dur = 3.5 + math.random() * 2
				TS:Create(dot, TweenInfo.new(dur, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Position = UDim2.fromOffset(px + math.random(-20, 20), math.random(WIN_H // 3, WIN_H // 2)),
					BackgroundTransparency = 1,
					Size = UDim2.fromOffset(1, 1),
				}):Play()
				task.delay(dur + 0.3, function()
					pcall(function()
						dot:Destroy()
					end)
				end)
			end

			task.wait(0.6)
		end
	end))

	local SBar = fr(Win, UDim2.fromOffset(SIDE_W, WIN_H), UDim2.new(0, 0, 0, 0), BLACK)
	SBar.ClipsDescendants = true
	fr(Win, UDim2.fromOffset(1, WIN_H), UDim2.fromOffset(SIDE_W, 0), Color3.fromRGB(16, 16, 16))

	local logoBar = fr(SBar, UDim2.new(1, 0, 0, 54), UDim2.new(0, 0, 0, 0), BLACK)
	fr(SBar, UDim2.new(1, 0, 0, 1), UDim2.fromOffset(0, 54), RED)

	local accentBar = fr(logoBar, UDim2.fromOffset(3, 26), UDim2.fromOffset(12, 14), RED)
	rnd(accentBar, 2)

	local titleL = lbl(logoBar, " WILD MENU", 17, WHITE, true)
	titleL.Size = UDim2.new(1, -10, 0, 22)
	titleL.Position = UDim2.fromOffset(20, 6)

	local subL = lbl(logoBar, "  coded by @ https://pornhub.x", 9, RED, false)
	subL.Size = UDim2.new(1, -10, 0, 14)
	subL.Position = UDim2.fromOffset(20, 29)

	local _d, _ds, _dp = false, nil, nil
	local logoBtn = Instance.new("TextButton", logoBar)
	logoBtn.Size = UDim2.new(1, 0, 1, 0)
	logoBtn.BackgroundTransparency = 1
	logoBtn.Text = ""
	logoBtn.ZIndex = 20

	trackConn(logoBtn.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			_d = true
			_ds = i.Position
			_dp = Win.Position
		end
	end))

	trackConn(logoBtn.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			_d = false
		end
	end))

	trackConn(UIS.InputChanged:Connect(function(i)
		if _d and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
			local dv = i.Position - _ds
			Win.Position = UDim2.new(_dp.X.Scale, _dp.X.Offset + dv.X, _dp.Y.Scale, _dp.Y.Offset + dv.Y)
		end
	end))

	local CloseBtn = Instance.new("TextButton", Win)
	CloseBtn.Size = UDim2.fromOffset(22, 22)
	CloseBtn.Position = UDim2.new(1, -26, 0, 5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = ""
	CloseBtn.TextColor3 = DIM
	CloseBtn.TextSize = 13
	CloseBtn.Font = Enum.Font.Gotham
	CloseBtn.ZIndex = 60

	CloseBtn.MouseEnter:Connect(function()
		tw(CloseBtn, { TextColor3 = WHITE })
	end)

	CloseBtn.MouseLeave:Connect(function()
		tw(CloseBtn, { TextColor3 = DIM })
	end)

	CloseBtn.MouseButton1Click:Connect(function()
		Win.Visible = false
	end)

	local SIDE_TABS = {
		{ label = "Combat", icon = "⊕", key = "Combat" },
		{ label = "Visuals", icon = "◈", key = "Visuals" },
		{ label = "Local", icon = "◉", key = "Local" },
		{ label = "World", icon = "⊛", key = "World" },
		{ label = "Exploits", icon = "⊞", key = "Exploits" },
		{ label = "Settings", icon = "◎", key = "Settings" },
	}

	local SIDE_GROUPS_LABELS = {
		{ label = "AIM ASSIST", tabs = { "Combat" } },
		{ label = "GAME", tabs = { "Visuals", "Local", "World", "Exploits" } },
		{ label = "SYSTEM", tabs = { "Settings" } },
	}

	local sideTabBtns = {}
	local currentMainTab = nil
	local _showSubTabs

	local function switchMainTab(key)
		currentMainTab = key

		for _, tb in pairs(sideTabBtns) do
			local on = tb.key == key
			tb.lbl.TextColor3 = on and WHITE or Color3.fromRGB(155, 155, 155)
			tb.bar.Visible = on
			tb.bg.BackgroundColor3 = on and Color3.fromRGB(16, 0, 0) or BLACK
		end

		for _, c in pairs(Win:GetChildren()) do
			if c:IsA("Frame") and c.Name:sub(1, 5) == "MAIN_" then
				c.Visible = (c.Name == "MAIN_" .. key)
			end
		end

		if _showSubTabs then
			_showSubTabs(key)
		end
	end

	local CON_X = SIDE_W + 1
	local CON_W = WIN_W - SIDE_W - 1
	local PAD = 14
	local PATH_H = 34

	local pathBar = fr(Win, UDim2.fromOffset(CON_W, PATH_H), UDim2.fromOffset(CON_X, 0), BLACK)
	fr(pathBar, UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 1, -1), Color3.fromRGB(16, 16, 16))

	local SUB_TABS = {
		Combat = { { name = "Aimbot", key = "Aimbot" }, { name = "Silent Aim", key = "SilentAim" }, { name = "TriggerBot", key = "Trigger" }, { name = "Big Head", key = "BigHead" } },
		Visuals = { { name = "ESP", key = "ESP" }, { name = "Player List", key = "PlayerList" }, { name = "Whitelist", key = "Whitelist" } },
		Local = { { name = "Main", key = "Main" }, { name = "Movement", key = "Movement" } },
		World = { { name = "Teleport", key = "Teleport" }, { name = "Sky", key = "Sky" } },
		Exploits = { { name = "Bypass", key = "Games" }, { name = "Gun Mode", key = "GunMode" }, { name = "Body", key = "Shop" }, { name = "Exclusive", key = "Exclu" } },
		Settings = { { name = "Settings", key = "Settings" } },
	}

	local currentSubKey = nil
	local pathBtnsData = {}

	local function switchSubTab(key)
		currentSubKey = key

		for _, pb in pairs(pathBtnsData) do
			local on = pb.key == key
			pb.lbl.TextColor3 = on and WHITE or DIM
			pb.lbl.Font = on and Enum.Font.GothamBold or Enum.Font.Gotham
			pb.ul.Visible = on
		end

		for _, c in pairs(Win:GetChildren()) do
			if c:IsA("Frame") and c.Name:sub(1, 4) == "TAB_" then
				c.Visible = (c.Name == "TAB_" .. key)
			end
		end
	end

	_showSubTabs = function(mainKey)
		for _, pb in pairs(pathBtnsData) do
			pb.lbl:Destroy()
			pb.ul:Destroy()
		end

		pathBtnsData = {}
		local subs = SUB_TABS[mainKey]

		if not subs then
			return
		end

		local xOff = 14

		for _, sub in ipairs(subs) do
			local pb = Instance.new("TextButton", pathBar)
			pb.BackgroundTransparency = 1
			pb.BorderSizePixel = 0
			pb.Text = sub.name
			pb.TextColor3 = DIM
			pb.TextSize = 12
			pb.Font = Enum.Font.Gotham
			pb.AutomaticSize = Enum.AutomaticSize.X
			pb.Size = UDim2.new(0, 0, 1, -2)
			pb.Position = UDim2.fromOffset(xOff, 1)
			pb.ZIndex = pathBar.ZIndex + 2

			local ul = fr(pb, UDim2.new(1, 0, 0, 2), UDim2.new(0, 0, 1, -2), RED)
			ul.Visible = false

			local subKey = sub.key

			pb.MouseButton1Click:Connect(function()
				switchSubTab(subKey)
			end)

			table.insert(pathBtnsData, { lbl = pb, ul = ul, key = subKey })
			xOff = xOff + #sub.name * 7 + 22
		end

		if subs[1] then
			switchSubTab(subs[1].key)
		end
	end

	local sideScroll = Instance.new("ScrollingFrame", SBar)
	sideScroll.Size = UDim2.new(1, 0, 1, -56)
	sideScroll.Position = UDim2.fromOffset(0, 56)
	sideScroll.BackgroundTransparency = 1
	sideScroll.BorderSizePixel = 0
	sideScroll.ScrollBarThickness = 2
	sideScroll.ScrollBarImageColor3 = RED
	sideScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	sideScroll.ElasticBehavior = Enum.ElasticBehavior.Never

	local sideY = 8

	for gi, grp in ipairs(SIDE_GROUPS_LABELS) do
		local gh = lbl(sideScroll, grp.label, 8, Color3.fromRGB(50, 50, 50), true)
		gh.Size = UDim2.new(1, -20, 0, 16)
		gh.Position = UDim2.fromOffset(10, sideY)
		sideY = sideY + 18

		for _, tabKey in ipairs(grp.tabs) do
			local tabDef

			for _, t in ipairs(SIDE_TABS) do
				if t.key == tabKey then
					tabDef = t
					break
				end
			end

			if tabDef then
				local itemH = 34
				local ibg = fr(sideScroll, UDim2.new(1, -6, 0, itemH), UDim2.fromOffset(3, sideY), BLACK, 1)
				rnd(ibg, 6)

				local bar = fr(ibg, UDim2.fromOffset(2, 16), UDim2.fromOffset(0, 9), RED)
				rnd(bar, 2)
				bar.Visible = false

				local il = lbl(ibg, tabDef.label, 12, Color3.fromRGB(155, 155, 155), true)
				il.Size = UDim2.new(1, -14, 1, 0)
				il.Position = UDim2.fromOffset(12, 0)

				local ibtn = Instance.new("TextButton", ibg)
				ibtn.Size = UDim2.new(1, 0, 1, 0)
				ibtn.BackgroundTransparency = 1
				ibtn.Text = ""
				ibtn.ZIndex = ibg.ZIndex + 4

				local tKey = tabDef.key

				ibtn.MouseButton1Click:Connect(function()
					switchMainTab(tKey)
				end)

				ibtn.MouseEnter:Connect(function()
					if currentMainTab ~= tKey then
						il.TextColor3 = Color3.fromRGB(200, 200, 200)
					end
				end)

				ibtn.MouseLeave:Connect(function()
					if currentMainTab ~= tKey then
						il.TextColor3 = Color3.fromRGB(155, 155, 155)
					end
				end)

				table.insert(sideTabBtns, { key = tKey, bg = ibg, lbl = il, bar = bar })
				sideY = sideY + itemH + 2
			end
		end

		if gi < #SIDE_GROUPS_LABELS then
			sideY = sideY + 10
			local divLine = fr(sideScroll, UDim2.new(1, -20, 0, 1), UDim2.fromOffset(10, sideY), Color3.fromRGB(16, 16, 16))
			sideY = sideY + 8
		end
	end

	sideScroll.CanvasSize = UDim2.fromOffset(0, sideY + 8)

	local function mkMainFrame(key)
		local mAIN = fr(Win, UDim2.fromOffset(CON_W, WIN_H - PATH_H), UDim2.fromOffset(CON_X, PATH_H), BLACK, 1)
		mAIN.Name = "MAIN_" .. key
		mAIN.Visible = false
		mAIN.ClipsDescendants = true
		return mAIN
	end

	local function mkSubFrame(key)
		local mAIN = fr(Win, UDim2.fromOffset(CON_W, WIN_H - PATH_H), UDim2.fromOffset(CON_X, PATH_H), BLACK, 1)
		mAIN.Name = "TAB_" .. key
		mAIN.Visible = false
		mAIN.ClipsDescendants = true
		return mAIN
	end

	local function mkScrollContent(parent, contentH)
		local scroll = Instance.new("ScrollingFrame", parent)
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.Position = UDim2.new(0, 0, 0, 0)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 3
		scroll.ScrollBarImageColor3 = RED
		scroll.CanvasSize = UDim2.fromOffset(0, contentH)
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.ElasticBehavior = Enum.ElasticBehavior.Never
		return scroll
	end

	local function mkTwoCols(parent)
		local colW = math.floor((CON_W - PAD * 3) / 2)
		local L = fr(parent, UDim2.fromOffset(colW, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD, PAD), BLACK, 1)
		local R = fr(parent, UDim2.fromOffset(colW, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD * 2 + colW, PAD), BLACK, 1)
		return L, R, colW
	end

	local fovCircle
	
	
	
	do
		local AimTab = mkSubFrame("Aimbot")
		local L, R, colW = mkTwoCols(AimTab)
		local yL = 0
		secLabel(L, yL, colW, "AIMBOT"); yL = yL + 26
		mkRow(L, yL, colW, "Enable Aimbot", S.AimbotEnabled, function(v) S.AimbotEnabled=v end); yL = yL + 31
		local _, aimKeyBadge = mkBadgeRow(L, yL, colW, "Aimbot Key", S.AimbotKeyName, function(badge)
			badge.Text = "Press..."
			badge.TextColor3 = RED
			local conn
			conn = UIS.InputBegan:Connect(function(inp, gp)
				if gp then return end
				local name
				if inp.UserInputType==Enum.UserInputType.MouseButton1 then
					S.AimbotKey=nil; S.AimbotKeyName="MB1"; name="MB1"
				elseif inp.UserInputType==Enum.UserInputType.MouseButton2 then
					S.AimbotKey=nil; S.AimbotKeyName="MB2"; name="MB2"
				elseif inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode~=Enum.KeyCode.Unknown then
					S.AimbotKey=inp.KeyCode; S.AimbotKeyName=inp.KeyCode.Name; name=inp.KeyCode.Name
				end
				if name then badge.Text=name; badge.TextColor3=WHITE; conn:Disconnect() end
			end)
		end); yL = yL + 31
		mkSelectorRow(L, yL, colW, "Mode", {"Smooth","Instant"}, S.AimbotMode, function(v) S.AimbotMode=v end); yL = yL + 31
		mkSlider(L, yL, colW, "Smoothing", 1, 10, S.AimbotSpeed, function(v) S.AimbotSpeed=v end); yL = yL + 49
		secLabel(L, yL, colW, "AIM PART"); yL = yL + 26
		local PARTS = {"Head","Torso","Left Arm","Right Arm","Left Leg","Right Leg"}
		local PART_MAP = {Head="Head",Torso="UpperTorso",["Left Arm"]="LeftHand",["Right Arm"]="RightHand",["Left Leg"]="LeftFoot",["Right Leg"]="RightFoot"}
		local partBtns = {}
		local curPart = "Head"
		local rowDefs = {{PARTS[1],PARTS[2],PARTS[3]},{PARTS[4],PARTS[5],PARTS[6]}}
		for _, row in ipairs(rowDefs) do
			local bW = math.floor((colW - 4*2) / 3)
			local rowF = fr(L, UDim2.fromOffset(colW,22), UDim2.fromOffset(0,yL), BLACK, 1)
			for ci, opt in ipairs(row) do
				local b = Instance.new("TextButton", rowF)
				b.Size = UDim2.fromOffset(bW,20)
				b.Position = UDim2.fromOffset((ci-1)*(bW+4), 1)
				b.BackgroundColor3 = (opt==curPart) and RED or Color3.fromRGB(12,12,12)
				b.BorderSizePixel = 0; b.Text = opt; b.TextColor3 = WHITE
				b.TextSize = 9; b.Font = Enum.Font.Gotham
				rnd(b,5)
				local bss = Instance.new("UIStroke", b)
				bss.Color = Color3.fromRGB(0,0,0); bss.Thickness = 1
				bss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				table.insert(partBtns, {btn=b,opt=opt})
			end
			yL = yL + 24
		end
		local yR = 0
		secLabel(R, yR, colW, "FOV"); yR = yR + 26
		mkRow(R, yR, colW, "Show FOV Circle", S.ShowFOV, function(v) S.ShowFOV=v end); yR = yR + 31
		mkSlider(R, yR, colW, "FOV Radius", 10, 500, S.FOVRadius, function(v) S.FOVRadius=v end); yR = yR + 49
		secLabel(R, yR, colW, "FILTERS"); yR = yR + 26
		mkRow(R, yR, colW, "Team Check", false, function(v) S.TeamCheck=v end); yR = yR + 31
		mkRow(R, yR, colW, "Visible Only", false, function(v) S.WallCheck=v end); yR = yR + 31

		-- STICKY AIM TOGGLE (Checkbox - ito lang ang nag-aactivate ng lock feature)
		mkRow(R, yR, colW, "Sticky Aim (Lock)", S.StickyAim or false, function(v) 
			S.StickyAim = v
			if not v then
				lockedTarget = nil -- Clear lock kapag na-off
			end
		end); yR = yR + 31

		if Drawing then
			fovCircle = trackDraw(Drawing.new("Circle"))
			fovCircle.Thickness=1; fovCircle.NumSides=64; fovCircle.Filled=false
			fovCircle.Transparency=1; fovCircle.Color=WHITE; fovCircle.Visible=false
			trackConn(RS.RenderStepped:Connect(function()
				fovCircle.Radius=S.FOVRadius; fovCircle.Visible=S.ShowFOV
				if S.ShowFOV then fovCircle.Position=UIS:GetMouseLocation() end
			end))
		end

		local aimbotActive = false
		local lockedTarget = nil

		-- HOLD parin ang key (hindi toggle)
		trackConn(UIS.InputBegan:Connect(function(inp, gp)
			if gp then return end

			local isAimKey = false
			if S.AimbotKey then
				if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==S.AimbotKey then
					isAimKey = true
				end
			elseif S.AimbotKeyName=="MB1" then
				if inp.UserInputType==Enum.UserInputType.MouseButton1 then
					isAimKey = true
				end
			else
				if inp.UserInputType==Enum.UserInputType.MouseButton2 then
					isAimKey = true
				end
			end

			if isAimKey and S.AimbotEnabled then
				aimbotActive = true -- Hold: activate aimbot
			end
		end))

		trackConn(UIS.InputEnded:Connect(function(inp)
			local isAimKey = false
			if S.AimbotKey then
				if inp.UserInputType==Enum.UserInputType.Keyboard and inp.KeyCode==S.AimbotKey then
					isAimKey = true
				end
			elseif S.AimbotKeyName=="MB1" then
				if inp.UserInputType==Enum.UserInputType.MouseButton1 then
					isAimKey = true
				end
			else
				if inp.UserInputType==Enum.UserInputType.MouseButton2 then
					isAimKey = true
				end
			end

			if isAimKey then
				aimbotActive = false -- Release: deactivate aimbot
				-- Hindi nami-clear ang lockedTarget para magamit ulit pag press ulit
			end
		end))

		local function isVisible(part)
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.FilterDescendantsInstances = {LP.Character or Instance.new("Folder"), part.Parent}
			return workspace:Raycast(CAM.CFrame.Position, part.Position-CAM.CFrame.Position, params) == nil
		end

		local function isTeammate(pl) return S.TeamCheck and pl.Team~=nil and pl.Team==LP.Team end
		local function isWhitelisted(pl) return S.WhitelistEnabled and WhitelistState[pl.UserId]==true end

		local function getAimTarget()
			-- Kung naka-sticky aim at may locked target
			if S.StickyAim and lockedTarget and aimbotActive then
				-- Check if locked target is still valid
				local pl = Players:GetPlayerFromCharacter(lockedTarget.Parent)
				if pl and pl.Character then
					local hum = pl.Character:FindFirstChildOfClass("Humanoid")
					if hum and hum.Health > 0 then
						-- Check visibility if WallCheck is enabled
						if S.WallCheck and not isVisible(lockedTarget) then
							lockedTarget = nil -- Lost visibility, find new
						else
							return lockedTarget -- Still valid, keep locked
						end
					else
						lockedTarget = nil -- Target died
					end
				else
					lockedTarget = nil -- Character missing
				end
			end

			-- Find new target (normal aimbot behavior)
			local closestDist = math.huge
			local target = nil
			local mp = UIS:GetMouseLocation()

			for _, pl in pairs(Players:GetPlayers()) do
				if pl == LP then continue end
				if not pl.Character then continue end
				local hum = pl.Character:FindFirstChildOfClass("Humanoid")
				if not hum or hum.Health <= 0 then continue end
				if isTeammate(pl) or isWhitelisted(pl) then continue end
				local part = pl.Character:FindFirstChild(S.AimPart) or pl.Character:FindFirstChild("Head")
				if not part then continue end
				if S.WallCheck and not isVisible(part) then continue end
				local sp, onScreen = CAM:WorldToViewportPoint(part.Position)
				if not onScreen then continue end
				local dist = (Vector2.new(sp.X, sp.Y) - mp).Magnitude
				if dist < closestDist and dist <= S.FOVRadius then
					closestDist = dist
					target = part
				end
			end

			-- If sticky aim is on and we found a target, lock onto it
			if target and S.StickyAim and aimbotActive then
				lockedTarget = target
			end

			return target
		end

		trackConn(RS.RenderStepped:Connect(function()
			if not S.AimbotEnabled or not aimbotActive or not LP.Character then return end
			local target = getAimTarget()
			if not target then return end

			local sp = CAM:WorldToViewportPoint(target.Position)
			local mouse = UIS:GetMouseLocation()
			local dx = sp.X - mouse.X
			local dy = sp.Y - mouse.Y

			if S.AimbotMode == "Instant" then
				if mousemoverel then mousemoverel(dx, dy) end
			else
				local speed = math.clamp(S.AimbotSpeed / 10, 0.01, 1)
				if mousemoverel then mousemoverel(dx * speed, dy * speed) end
			end
		end))
	end
	local saFov
		do
			local SATab = mkSubFrame("SilentAim")
			local L, R, colW = mkTwoCols(SATab)
			local saState = {
				Enabled=false, VisibleOnly=false, ShowFOV=false,
				Smoothing=1, FOVRadius=150, AimPart="Head", MaxDist=500,
			}
			local SA_PART_MAP = {
				Head="Head", Torso="UpperTorso",
				["L Hand"]="LeftHand", ["R Hand"]="RightHand",
				["L Leg"]="LeftFoot", ["R Leg"]="RightFoot",
			}
			if Drawing then
				saFov = trackDraw(Drawing.new("Circle"))
				saFov.Thickness=1.5; saFov.NumSides=100; saFov.Filled=false
				saFov.Color=RED; saFov.Visible=false; saFov.Radius=saState.FOVRadius
				trackConn(RS.RenderStepped:Connect(function()
					saFov.Radius=saState.FOVRadius
					if saState.ShowFOV then
						local mp=UIS:GetMouseLocation()
						saFov.Position=Vector2.new(mp.X,mp.Y); saFov.Visible=true
					else saFov.Visible=false end
				end))
			end
			local yL = 0
			secLabel(L, yL, colW, "SILENT AIM HITMARK"); yL = yL + 26
			mkRow(L, yL, colW, "Enable", false, function(v) saState.Enabled=v end); yL = yL + 31
			mkRow(L, yL, colW, "Visible Only", false, function(v) saState.VisibleOnly=v end); yL = yL + 31
			mkRow(L, yL, colW, "Show FOV", false, function(v) saState.ShowFOV=v end); yL = yL + 31
			mkSlider(L, yL, colW, "Smoothing", 1, 20, 1, function(v) saState.Smoothing=v end); yL = yL + 49
			mkSlider(L, yL, colW, "Max Distance", 50, 1000, 500, function(v) saState.MaxDist=v end); yL = yL + 49
			secLabel(L, yL, colW, "KEYBIND"); yL = yL + 26
			local saHint = lbl(L, "RIGHT CLICK", 10, DIM)
			saHint.Size = UDim2.fromOffset(colW,18); saHint.Position = UDim2.fromOffset(0,yL)
			local yR = 0
			secLabel(R, yR, colW, "FOV"); yR = yR + 26
			mkSlider(R, yR, colW, "Field of View", 10, 500, 150, function(v) saState.FOVRadius=v end); yR = yR + 49
			secLabel(R, yR, colW, "AIM PART"); yR = yR + 26
			local saParts = {"Head","Torso","L Hand","R Hand","L Leg","R Leg"}
			local saPartBtns = {}
			local rows = {{saParts[1],saParts[2],saParts[3]},{saParts[4],saParts[5],saParts[6]}}
			for _, row in ipairs(rows) do
				local bW = math.floor((colW-4*2)/3)
				local rowF = fr(R, UDim2.fromOffset(colW,22), UDim2.fromOffset(0,yR), BLACK, 1)
				for ci, opt in ipairs(row) do
					local b = Instance.new("TextButton", rowF)
					b.Size = UDim2.fromOffset(bW,20)
					b.Position = UDim2.fromOffset((ci-1)*(bW+4),1)
					b.BackgroundColor3 = (opt=="Head") and RED or Color3.fromRGB(12,12,12)
					b.BorderSizePixel=0; b.Text=opt; b.TextColor3=WHITE
					b.TextSize=9; b.Font=Enum.Font.Gotham
					rnd(b,5)
					local bss = Instance.new("UIStroke", b)
					bss.Color = Color3.fromRGB(0,0,0); bss.Thickness = 1
					bss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					table.insert(saPartBtns,{btn=b,opt=opt})
				end
				yR = yR + 24
			end
			trackConn(RS.Heartbeat:Connect(function()
				if not saState.Enabled then return end
				if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
				local mp=UIS:GetMouseLocation()
				local closest, closestDist = nil, math.huge
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl==LP then continue end
					local char=pl.Character; if not char then continue end
					local hum=char:FindFirstChildOfClass("Humanoid")
					if not hum or hum.Health<=0 then continue end
					local partName=SA_PART_MAP[saState.AimPart] or "Head"
					local part=char:FindFirstChild(partName) or char:FindFirstChild("Head")
					if not part then continue end
					if saState.VisibleOnly then
						local rp=RaycastParams.new()
						rp.FilterType=Enum.RaycastFilterType.Blacklist
						rp.FilterDescendantsInstances={LP.Character,CAM}
						local res=workspace:Raycast(CAM.CFrame.Position,(part.Position-CAM.CFrame.Position),rp)
						if res and not (res.Instance and res.Instance:IsDescendantOf(char)) then continue end
					end
					local sp, onScreen=CAM:WorldToViewportPoint(part.Position)
					if not onScreen then continue end
					local dist=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
					if dist<=saState.FOVRadius and dist<closestDist then
						closestDist=dist; closest=part
					end
				end
				if closest then
					local lookCF=CFrame.lookAt(CAM.CFrame.Position, closest.Position)
					CAM.CFrame = CAM.CFrame:Lerp(lookCF, 1/math.max(1,saState.Smoothing))
				end
			end))
		end
	do
		local TrigTab = mkSubFrame("Trigger")
		local L, R, colW = mkTwoCols(TrigTab)
		local yL = 0
		secLabel(L, yL, colW, "TRIGGER BOT")
		yL = yL + 26
		mkRow(L, yL, colW, "Enable Trigger Bot", S.TriggerEnabled, function(v)
			S.TriggerEnabled = v
		end)
		yL = yL + 31
		mkBadgeRow(L, yL, colW, "Trigger Key", "MB2")
		yL = yL + 31
		mkSelectorRow(L, yL, colW, "Mode", { "hold", "toggle" }, S.TriggerMode, function(v)
			S.TriggerMode = v
		end)
		yL = yL + 31
		secLabel(L, yL, colW, "CHECKS")
		yL = yL + 26
		mkRow(L, yL, colW, "Tool Check", S.ToolCheckEnabled, function(v)
			S.ToolCheckEnabled = v
		end)
		yL = yL + 31
		mkRow(L, yL, colW, "Knife Check", S.KnifeCheck, function(v)
			S.KnifeCheck = v
		end)
		yL = yL + 31
		mkRow(L, yL, colW, "Force Field Check", S.ForceFieldCheck, function(v)
			S.ForceFieldCheck = v
		end)
		yL = yL + 31

		local yR = 0
		secLabel(R, yR, colW, "CONFIGURATION")
		yR = yR + 26
		mkSlider(R, yR, colW, "Precision", 0, 100, S.Precision, function(v)
			S.Precision = v
		end)
		yR = yR + 49
		mkSlider(R, yR, colW, "Trigger Delay (ms)", 0, 500, S.TriggerDelay, function(v)
			S.TriggerDelay = v
		end)
		yR = yR + 49
		mkSlider(R, yR, colW, "Max Distance", 0, 1000, S.MaxDistance, function(v)
			S.MaxDistance = v
		end)
		yR = yR + 49
		secLabel(R, yR, colW, "MAGNETIC")
		yR = yR + 26
		mkRow(R, yR, colW, "Enable Magnetic", S.MagneticEnabled, function(v)
			S.MagneticEnabled = v
		end)
		yR = yR + 31
		mkSlider(R, yR, colW, "Magnetic FOV", 0, 200, S.MagFOV, function(v)
			S.MagFOV = v
		end)
		yR = yR + 49

		trackConn(RS.RenderStepped:Connect(function()
			if not S.TriggerEnabled then
				return
			end

			local char = LP.Character

			if not char then
				return
			end

			local hum = char:FindFirstChildOfClass("Humanoid")

			if not hum or hum.Health <= 0 then
				return
			end

			if S.TriggerMode == "hold" then
				if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
					return
				end
			elseif S.TriggerMode == "toggle" then
				if not toggleFired then
					return
				end
			end

			local vs = CAM.ViewportSize
			local ray = CAM:ViewportPointToRay(vs.X / 2, vs.Y / 2)
			local rp = RaycastParams.new()
			rp.FilterType = Enum.RaycastFilterType.Exclude
			rp.FilterDescendantsInstances = { CAM, char }
			local dist = S.MaxDistance > 0 and S.MaxDistance or 1000
			local result = workspace:Raycast(ray.Origin, ray.Direction * dist, rp)

			if result and result.Instance then
				local model = result.Instance:FindFirstAncestorOfClass("Model")

				if model and model:FindFirstChildOfClass("Humanoid") then
					local pl = Players:GetPlayerFromCharacter(model)

					if pl and pl ~= LP then
						local hitHum = model:FindFirstChildOfClass("Humanoid")

						if hitHum and hitHum.Health > 0 then
							if mouse1click then
								mouse1click()
							end
						end
					end
				end
			end
		end))

		trackConn(UIS.InputBegan:Connect(function(inp, gp)
			if gp then
				return
			end

			if S.TriggerMode == "toggle" and inp.UserInputType == Enum.UserInputType.MouseButton2 then
				toggleFired = not toggleFired
			end
		end))
	end

	local bhFovCircle

	do
		local BHTab = mkSubFrame("BigHead")
		local L, R, colW = mkTwoCols(BHTab)
		local BH = { Enabled = false, Size = 1, Transparency = 0,
			Parts = { Head = true, Torso = false, RightArm = false, LeftArm = false, RightLeg = false, LeftLeg = false } }
		local PART_NAMES = {
			Head = { "Head" },
			Torso = { "Torso", "UpperTorso", "LowerTorso" },
			RightArm = { "Right Arm", "RightUpperArm", "RightLowerArm", "RightHand" },
			LeftArm = { "Left Arm", "LeftUpperArm", "LeftLowerArm", "LeftHand" },
			RightLeg = { "Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot" },
			LeftLeg = { "Left Leg", "LeftUpperLeg", "LeftLowerLeg", "LeftFoot" },
		}
		local OriginalSizes = {}
		local yL = 0
		secLabel(L, yL, colW, "BIG HEAD / BODY")
		yL = yL + 26
		mkRow(L, yL, colW, "Enable Big Head", false, function(v)
			BH.Enabled = v
		end)
		yL = yL + 31
		mkSlider(L, yL, colW, "Part Size", 1, 50, 1, function(v)
			BH.Size = v
		end)
		yL = yL + 49
		mkSlider(L, yL, colW, "Transparency", 0, 100, 0, function(v)
			BH.Transparency = v / 100
		end)
		yL = yL + 49
		secLabel(L, yL, colW, "SELECT PARTS")
		yL = yL + 26

		local PART_LABELS = {
			{ key = "Head", label = "Head" },
			{ key = "Torso", label = "Torso" },
			{ key = "RightArm", label = "Right Arm" },
			{ key = "LeftArm", label = "Left Arm" },
			{ key = "RightLeg", label = "Right Leg" },
			{ key = "LeftLeg", label = "Left Leg" },
		}

		for _, pDef in ipairs(PART_LABELS) do
			mkRow(L, yL, colW, pDef.label, BH.Parts[pDef.key], function(v)
				BH.Parts[pDef.key] = v
			end)
			yL = yL + 31
		end

		local yR = 0
		secLabel(R, yR, colW, "FOV")
		yR = yR + 26
		local BH_FOV_ENABLED = false

		if Drawing then
			bhFovCircle = trackDraw(Drawing.new("Circle"))
			bhFovCircle.Thickness = 1.5
			bhFovCircle.NumSides = 100
			bhFovCircle.Filled = false
			bhFovCircle.Color = Color3.fromRGB(255, 255, 255)
			bhFovCircle.Visible = false
			bhFovCircle.Radius = 60

			trackConn(RS.RenderStepped:Connect(function()
				if BH_FOV_ENABLED then
					local vp = CAM.ViewportSize / 2
					bhFovCircle.Position = Vector2.new(vp.X, vp.Y)
					bhFovCircle.Radius = BH.Size * 10
					bhFovCircle.Visible = true
				else
					bhFovCircle.Visible = false
				end
			end))
		end

		mkRow(R, yR, colW, "Show FOV Circle", false, function(v)
			BH_FOV_ENABLED = v
		end)
		yR = yR + 31
		secLabel(R, yR, colW, "OUTLINE ESP")
		yR = yR + 26

		local BH_ESP_Outlines = {}
		local outlineEnabled = false

		mkRow(R, yR, colW, "Outline ESP", false, function(v)
			outlineEnabled = v
			if not v then
				for pl, hl in pairs(BH_ESP_Outlines) do
					pcall(function()
						hl:Destroy()
					end)
					BH_ESP_Outlines[pl] = nil
				end
			end
		end)
		yR = yR + 31

		local function updateOutlines()
			if not outlineEnabled then
				return
			end
			for _, pl in pairs(Players:GetPlayers()) do
				if pl ~= LP and pl.Character then
					local shouldOutline = true
					local hl = BH_ESP_Outlines[pl]
					if shouldOutline then
						if not hl then
							hl = Instance.new("Highlight")
							hl.FillTransparency = 1
							hl.OutlineTransparency = 0
							hl.OutlineColor = Color3.fromRGB(255, 0, 0)
							hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							BH_ESP_Outlines[pl] = hl
						end
						hl.Adornee = pl.Character
						hl.Parent = pl.Character
						hl.Enabled = true
					else
						if hl then
							hl.Enabled = false
						end
					end
				end
			end
		end

		local function storeOriginalSizes(pl, char)
			if not OriginalSizes[pl] then
				OriginalSizes[pl] = {}
			end
			for _, partList in pairs(PART_NAMES) do
				for _, pName in ipairs(partList) do
					local part = char:FindFirstChild(pName)
					if part and part:IsA("BasePart") and not OriginalSizes[pl][pName] then
						OriginalSizes[pl][pName] = part.Size
					end
				end
			end
		end

		local function applyBigHead(pl, char)
			if pl == LP or not char then
				return
			end
			storeOriginalSizes(pl, char)
			for partKey, enabled in pairs(BH.Parts) do
				for _, pName in ipairs(PART_NAMES[partKey]) do
					local part = char:FindFirstChild(pName)
					if part and part:IsA("BasePart") then
						if BH.Enabled and enabled then
							part.Size = Vector3.new(BH.Size, BH.Size, BH.Size)
							part.Transparency = BH.Transparency
							part.CanCollide = false
							part.Massless = true
						else
							if OriginalSizes[pl] and OriginalSizes[pl][pName] then
								part.Size = OriginalSizes[pl][pName]
								part.Transparency = 0
							end
						end
					end
				end
			end
		end

		local bhTimer = 0

		trackConn(RS.Heartbeat:Connect(function(dt)
			bhTimer = bhTimer + dt
			if bhTimer < 1.5 then
				return
			end
			bhTimer = 0
			if BH.Enabled then
				for _, pl in pairs(Players:GetPlayers()) do
					if pl ~= LP and pl.Character then
						pcall(applyBigHead, pl, pl.Character)
					end
				end
			end
			updateOutlines()
		end))

		trackConn(Players.PlayerAdded:Connect(function(pl)
			pl.CharacterAdded:Connect(function(c)
				task.wait(0.2)
				pcall(applyBigHead, pl, c)
				task.wait(0.1)
				updateOutlines()
			end)
		end))
	end

	local activeTracers = {}

	do
		local ESPTab = mkSubFrame("ESP")
		local L, R, colW = mkTwoCols(ESPTab)
		local yL = 0
		secLabel(L, yL, colW, "ESP"); yL = yL + 26
		mkRow(L, yL, colW, "Enable ESP", S.ESPEnabled, function(v) S.ESPEnabled=v end); yL = yL + 31
		mkRow(L, yL, colW, "Box ESP", S.BoxEnabled, function(v) S.BoxEnabled=v end); yL = yL + 31
		mkRow(L, yL, colW, "Name ESP", S.NameEnabled, function(v) S.NameEnabled=v end); yL = yL + 31
		mkRow(L, yL, colW, "Health Bar", S.HealthEnabled, function(v) S.HealthEnabled=v end); yL = yL + 31
		mkRow(L, yL, colW, "Visible Only", S.WallCheck, function(v) S.WallCheck=v end); yL = yL + 31
		mkRow(L, yL, colW, "Team Check", S.TeamCheck, function(v) S.TeamCheck=v end); yL = yL + 31

		S.RenderDistance = S.RenderDistance or 0
		if typeof(mkSlider) == "function" then
			mkSlider(L, yL, colW, "Max Distance", 0, 3000, 0, function(v) S.RenderDistance = v end); yL = yL + 31
		elseif typeof(mkRow) == "function" then
			mkRow(L, yL, colW, "Distance (0-3k)", S.RenderDistance, function(v) S.RenderDistance = tonumber(v) or 0 end); yL = yL + 31
		end

		local yR = 0
		secLabel(R, yR, colW, "TRACER"); yR = yR + 26
		local tracerEnabled = false
		mkRow(R, yR, colW, "Enable Tracer", false, function(v)
			tracerEnabled = v
			if not v then
				for _, line in pairs(activeTracers) do pcall(function() line:Remove() end) end
				activeTracers = {}
			end
		end); yR = yR + 31

		local function isTeammate(pl) return S.TeamCheck and pl.Team~=nil and pl.Team==LP.Team end
		local function isWhitelisted(pl) return S.WhitelistEnabled and WhitelistState[pl.UserId]==true end

		local function removeESP(uid)
			local obj=espObjects[uid]; if not obj then return end
			pcall(function() if obj.highlight then obj.highlight:Destroy() end end)
			pcall(function() if obj.billboard then obj.billboard:Destroy() end end)
			espObjects[uid]=nil
		end

		local function addESP(pl)
			if pl==LP then return end
			removeESP(pl.UserId)
			local uid=pl.UserId
			espObjects[uid]={player=pl}

			local function setupChar(char)
				if not char then return end
				local hum=char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
				local hrp=char:WaitForChild("HumanoidRootPart", 5) or char:FindFirstChild("HumanoidRootPart")
				if not hum or not hrp then return end

				espObjects[uid].humanoid=hum

				local hl=Instance.new("Highlight")
				hl.Adornee=char; hl.FillColor=WHITE; hl.FillTransparency=0.75
				hl.OutlineColor=WHITE; hl.OutlineTransparency=0
				hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Enabled=false; hl.Parent=char
				espObjects[uid].highlight=hl

				local bb=Instance.new("BillboardGui")
				bb.Size=UDim2.fromOffset(140,36); bb.StudsOffset=Vector3.new(0,3.2,0)
				bb.AlwaysOnTop=true; bb.Adornee=hrp; bb.Parent=hrp

				local nameL=Instance.new("TextLabel",bb)
				nameL.Size=UDim2.new(1,0,0,18); nameL.BackgroundTransparency=1
				nameL.Text="[ "..pl.DisplayName.." ]"; nameL.TextColor3=WHITE
				nameL.TextSize=11; nameL.Font=Enum.Font.GothamBold
				nameL.TextStrokeTransparency=0.5; nameL.TextXAlignment=Enum.TextXAlignment.Center
				nameL.Visible=false; espObjects[uid].nameLabel=nameL

				local hbg=Instance.new("Frame",bb)
				hbg.Size=UDim2.new(1,0,0,5); hbg.Position=UDim2.fromOffset(0,20)
				hbg.BackgroundColor3=Color3.fromRGB(18,18,18); hbg.BorderSizePixel=0; hbg.Visible=false
				if typeof(pill) == "function" then pill(hbg) end

				local maxHp=hum.MaxHealth>0 and hum.MaxHealth or 100
				local hfill=Instance.new("Frame",hbg)
				hfill.Size=UDim2.new(math.clamp(hum.Health/maxHp,0,1),0,1,0)
				hfill.BackgroundColor3=WHITE; hfill.BorderSizePixel=0; if typeof(pill) == "function" then pill(hfill) end

				espObjects[uid].billboard=bb; espObjects[uid].healthBg=hbg; espObjects[uid].healthFill=hfill
			end

			if pl.Character then task.spawn(setupChar, pl.Character) end
		end

		trackConn(RS.Heartbeat:Connect(function()
			local myChar = LP.Character
			local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

			for uid, obj in pairs(espObjects) do
				local pl=obj.player
				if not pl or not pl.Parent then removeESP(uid); continue end
				if not pl.Character then continue end

				local hrp = pl.Character:FindFirstChild("HumanoidRootPart")
				local inRange = true

				if S.RenderDistance and S.RenderDistance >= 300 and myHrp and hrp then
					local dist = (myHrp.Position - hrp.Position).Magnitude
					if dist > S.RenderDistance then
						inRange = false
					end
				end

				local skip=isTeammate(pl) or isWhitelisted(pl) or not inRange

				if obj.highlight then
					local on=S.ESPEnabled and S.BoxEnabled and not skip
					obj.highlight.Enabled=on
					obj.highlight.FillTransparency=on and 0.75 or 1
					obj.highlight.OutlineTransparency=on and 0 or 1
				end
				if obj.nameLabel then obj.nameLabel.Visible=S.ESPEnabled and S.NameEnabled and not skip end
				if obj.healthBg then
					obj.healthBg.Visible=S.ESPEnabled and S.HealthEnabled and not skip
					if obj.humanoid and obj.healthFill then
						local maxHp=obj.humanoid.MaxHealth>0 and obj.humanoid.MaxHealth or 100
						obj.healthFill.Size=UDim2.new(math.clamp(obj.humanoid.Health/maxHp,0,1),0,1,0)
					end
				end
			end

			if tracerEnabled and Drawing then
				local center=Vector2.new(CAM.ViewportSize.X/2,CAM.ViewportSize.Y)
				for _, pl in ipairs(Players:GetPlayers()) do
					if pl==LP then continue end
					if pl.Character and pl.Character:FindFirstChild("Head") and pl.Character:FindFirstChild("HumanoidRootPart") then
						local hrp = pl.Character.HumanoidRootPart
						local inRange = true
						if S.RenderDistance and S.RenderDistance >= 300 and myHrp then
							if (myHrp.Position - hrp.Position).Magnitude > S.RenderDistance then
								inRange = false
							end
						end

						local skip = isTeammate(pl) or isWhitelisted(pl) or not inRange
						local sp,onScreen=CAM:WorldToViewportPoint(pl.Character.Head.Position)

						if onScreen and not skip then
							if not activeTracers[pl] then
								local line=Drawing.new("Line")
								line.Thickness=1.5; line.Color=RED; line.Transparency=0.4
								activeTracers[pl]=line
							end
							activeTracers[pl].From=center
							activeTracers[pl].To=Vector2.new(sp.X,sp.Y)
							activeTracers[pl].Visible=true
						else
							if activeTracers[pl] then activeTracers[pl].Visible=false end
						end
					else
						if activeTracers[pl] then activeTracers[pl].Visible=false end
					end
				end
			end
		end))

		local function hookPlayer(pl)
			if pl==LP then return end
			trackConn(pl.CharacterAdded:Connect(function(char)
				task.spawn(addESP, pl)
			end))
			if pl.Character then task.spawn(addESP, pl) end
		end

		for _, pl in pairs(Players:GetPlayers()) do hookPlayer(pl) end
		trackConn(Players.PlayerAdded:Connect(hookPlayer))
		trackConn(Players.PlayerRemoving:Connect(function(pl) removeESP(pl.UserId); if activeTracers[pl] then pcall(function() activeTracers[pl]:Remove() end) activeTracers[pl]=nil end end))
	end
	
	do
		local PLTab = mkSubFrame("PlayerList")
		local PL_W = CON_W - PAD * 2
		local PLp = fr(PLTab, UDim2.fromOffset(PL_W, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD, PAD), BLACK)
		rnd(PLp, 8)

		local plStroke = Instance.new("UIStroke", PLp)
		plStroke.Color = Color3.fromRGB(0, 0, 0)
		plStroke.Thickness = 1
		plStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		secLabel(PLp, 8, PL_W, "PLAYER LIST")

		local plSearch = mkSearchBox(PLp, 36, PL_W, "Search")
		local plScroll = Instance.new("ScrollingFrame", PLp)
		plScroll.Size = UDim2.new(1, -8, 1, -70)
		plScroll.Position = UDim2.fromOffset(4, 68)
		plScroll.BackgroundTransparency = 1
		plScroll.BorderSizePixel = 0
		plScroll.ScrollBarThickness = 3
		plScroll.ScrollBarImageColor3 = RED
		plScroll.CanvasSize = UDim2.fromOffset(0, 0)

		local plLayout = Instance.new("UIListLayout", plScroll)
		plLayout.SortOrder = Enum.SortOrder.LayoutOrder
		plLayout.Padding = UDim.new(0, 4)

		local espHighlights = {}
		local plSearchQuery = ""

		local function makePLCard(player)
			local uid = player.UserId
			local card = fr(plScroll, UDim2.new(1, -6, 0, 52), UDim2.fromOffset(3, 0), BLACK)
			rnd(card, 6)

			local cs = Instance.new("UIStroke", card)
			cs.Color = Color3.fromRGB(0, 0, 0)
			cs.Thickness = 1
			cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local ava = Instance.new("ImageLabel", card)
			ava.Size = UDim2.fromOffset(34, 34)
			ava.Position = UDim2.fromOffset(6, 9)
			ava.BackgroundColor3 = BLACK
			ava.BorderSizePixel = 0
			ava.Image = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=48&sectionHdr=48"
			pill(ava)

			local tPName = lbl(card, player.DisplayName, 11, WHITE, true)
			tPName.Name = "DisplayName"
			tPName.Size = UDim2.fromOffset(PL_W - 170, 14)
			tPName.Position = UDim2.fromOffset(48, 8)

			local userName = lbl(card, "@" .. player.Name, 9, DIM, false)
			userName.Name = "UserName"
			userName.Size = UDim2.fromOffset(PL_W - 170, 12)
			userName.Position = UDim2.fromOffset(48, 22)

			local BW, BG = 44, 3
			local bX = PL_W - 150

			local function makePLBtn(txt, cb)
				local b = Instance.new("TextButton", card)
				b.Size = UDim2.fromOffset(BW, 20)
				b.Position = UDim2.fromOffset(bX, 16)
				b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				b.BorderSizePixel = 0
				b.Text = txt
				b.TextColor3 = WHITE
				b.TextSize = 9
				b.Font = Enum.Font.Gotham
				rnd(b, 5)

				local bss = Instance.new("UIStroke", b)
				bss.Color = Color3.fromRGB(0, 0, 0)
				bss.Thickness = 1
				bss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				b.MouseEnter:Connect(function()
					b.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				end)

				b.MouseLeave:Connect(function()
					b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				end)

				if cb then
					b.MouseButton1Click:Connect(cb)
				end

				bX = bX + BW + BG
				return b
			end

			local viewing = false
			local vb = makePLBtn("View", nil)

			vb.MouseButton1Click:Connect(function()
				viewing = not viewing
				vb.Text = viewing and "Unview" or "View"

				if viewing and player.Character then
					local hl = Instance.new("Highlight")
					hl.Adornee = player.Character
					hl.FillTransparency = 0.7
					hl.OutlineColor = WHITE
					hl.OutlineTransparency = 0
					hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					hl.Parent = player.Character
					espHighlights[uid] = hl
				else
					if espHighlights[uid] then
						pcall(function()
							espHighlights[uid]:Destroy()
						end)
						espHighlights[uid] = nil
					end
				end
			end)

			makePLBtn("Teleport", function()
				local char = player.Character

				if not char then
					return
				end

				local myChar = LP.Character

				if not myChar then
					return
				end

				local hrp = char:FindFirstChild("HumanoidRootPart")

				if not hrp then
					return
				end

				local myHrp = myChar:FindFirstChild("HumanoidRootPart")

				if not myHrp then
					return
				end

				myHrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3)
			end)

			local brought = false
			local bringBtn = makePLBtn("Bring", nil)

			bringBtn.MouseButton1Click:Connect(function()
				brought = not brought
				bringBtn.Text = brought and "Unbring" or "Bring"

				if brought then
					local myChar = LP.Character
					local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
					local tChar = player.Character
					local tHrp = tChar and tChar:FindFirstChild("HumanoidRootPart")

					if myHrp and tHrp then
						tHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0, -5)
					end
				end
			end)
		end

		local function refreshPLList()
			for _, c in pairs(plScroll:GetChildren()) do
				if c:IsA("Frame") then
					c:Destroy()
				end
			end

			local count = 0
			local q = plSearchQuery:lower()

			for _, pl in pairs(Players:GetPlayers()) do
				if pl ~= LP then
					local matches = q == "" or
						pl.DisplayName:lower():find(q, 1, true) or
						pl.Name:lower():find(q, 1, true)

					if matches then
						makePLCard(pl)
						count = count + 1
					end
				end
			end

			plScroll.CanvasSize = UDim2.fromOffset(0, count * 56)
		end

		plSearch:GetPropertyChangedSignal("Text"):Connect(function()
			plSearchQuery = plSearch.Text
			refreshPLList()
		end)

		trackConn(Players.PlayerAdded:Connect(function()
			task.wait(1)
			refreshPLList()
		end))

		trackConn(Players.PlayerRemoving:Connect(function(pl)
			if espHighlights[pl.UserId] then
				pcall(function()
					espHighlights[pl.UserId]:Destroy()
				end)
				espHighlights[pl.UserId] = nil
			end

			task.wait(0.3)
			refreshPLList()
		end))

		task.spawn(refreshPLList)
	end

	do
		-- Ilagay natin ang GangIDs sa itaas ng do block para accessible sa buong sakop nito
		local GangIDs = {
			{name = "POLICE", id = 1012070570},
			{name = "GIMENEZ", id = 35595447},
			{name = "COSA NOSTRA", id = 35151924},
			{name = "LA MUERTE", id = 35556137},
			{name = "LUCIANO", id = 35353599},
			{name = "FRATELLANZA", id = 35344424},
			{name = "T6M", id = 467200285},
			{name = "MARTINEZ", id = 35948668},
			{name = "LOS VATOS", id = 568129737},
			{name = "ESCOBAR", id = 124826922},
			{name = "LOS VAGOS", id = 764565226},
			{name = "GROUND ZERO", id = 834797917},
			{name = "MS13", id = 299569143}
		}

		local WLTab = mkSubFrame("Whitelist")
		local WLS_W = math.floor(CON_W * 0.36)
		local WLP_W = CON_W - WLS_W - PAD * 3

		local WLSp = fr(WLTab, UDim2.fromOffset(WLS_W, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD, PAD), BLACK)
		rnd(WLSp, 8)

		local wls = Instance.new("UIStroke", WLSp)
		wls.Color = Color3.fromRGB(0, 0, 0)
		wls.Thickness = 1
		wls.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local leftScroll = Instance.new("ScrollingFrame", WLSp)
		leftScroll.Size = UDim2.new(1, -4, 1, -4)
		leftScroll.Position = UDim2.fromOffset(2, 2)
		leftScroll.BackgroundTransparency = 1
		leftScroll.BorderSizePixel = 0
		leftScroll.ScrollBarThickness = 2
		leftScroll.ScrollBarImageColor3 = RED
		leftScroll.CanvasSize = UDim2.fromOffset(0, 0)
		leftScroll.ClipsDescendants = true

		local leftContainer = Instance.new("Frame", leftScroll)
		leftContainer.Size = UDim2.new(1, 0, 0, 0)
		leftContainer.BackgroundTransparency = 1
		leftContainer.AutomaticSize = Enum.AutomaticSize.Y

		local yS = 8

		secLabel(leftContainer, yS, WLS_W, "WHITELIST")
		yS = yS + 26

		mkRow(leftContainer, yS, WLS_W, "Enable Whitelist", S.WhitelistEnabled or false, function(v)
			S.WhitelistEnabled = v
			refreshPlayerList()
		end)
		yS = yS + 31

		secLabel(leftContainer, yS, WLS_W, "GROUPS")
		yS = yS + 26

		if not S.GroupWhitelist then
			S.GroupWhitelist = {}
		end

		for _, gang in pairs(GangIDs) do
			if S.GroupWhitelist[gang.id] == nil then
				S.GroupWhitelist[gang.id] = false
			end

			mkRow(leftContainer, yS, WLS_W, gang.name, S.GroupWhitelist[gang.id], function(v)
				S.GroupWhitelist[gang.id] = v
				refreshPlayerList()
			end)
			yS = yS + 31
		end

		local infoL = lbl(leftContainer, "Players on whitelist\nskipped by Aimbot\nBigHead / TriggerBot", 10, DIM, false)
		infoL.Size = UDim2.fromOffset(WLS_W - 24, 34)
		infoL.Position = UDim2.fromOffset(8, yS)
		infoL.TextWrapped = true
		infoL.TextYAlignment = Enum.TextYAlignment.Top
		yS = yS + 40

		local refreshBtn = Instance.new("TextButton", leftContainer)
		refreshBtn.Size = UDim2.fromOffset(WLS_W - 24, 26)
		refreshBtn.Position = UDim2.fromOffset(8, yS)
		refreshBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		refreshBtn.BorderSizePixel = 0
		refreshBtn.Text = "Refresh"
		refreshBtn.TextColor3 = WHITE
		refreshBtn.TextSize = 11
		refreshBtn.Font = Enum.Font.Gotham
		rnd(refreshBtn, 6)

		local rfStroke = Instance.new("UIStroke", refreshBtn)
		rfStroke.Color = Color3.fromRGB(0, 0, 0)
		rfStroke.Thickness = 1
		rfStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		refreshBtn.MouseEnter:Connect(function()
			refreshBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		end)

		refreshBtn.MouseLeave:Connect(function()
			refreshBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		end)

		refreshBtn.MouseButton1Click:Connect(function()
			refreshBtn.Text = "Refreshing..."
			refreshPlayerList()
			task.wait(0.5)
			refreshBtn.Text = "Refresh"
		end)

		local function updateLeftCanvas()
			local totalHeight = yS + 40
			leftScroll.CanvasSize = UDim2.fromOffset(0, totalHeight + 20)
			leftContainer.Size = UDim2.new(1, 0, 0, totalHeight + 20)
		end

		local WLPp = fr(WLTab, UDim2.fromOffset(WLP_W, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD * 2 + WLS_W, PAD), BLACK)
		rnd(WLPp, 8)

		local wls2 = Instance.new("UIStroke", WLPp)
		wls2.Color = Color3.fromRGB(0, 0, 0)
		wls2.Thickness = 1
		wls2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		secLabel(WLPp, 8, WLP_W, "PLAYERS")

		local wlSearch = mkSearchBox(WLPp, 36, WLP_W, "Search")
		local cardScroll = Instance.new("ScrollingFrame", WLPp)
		cardScroll.Size = UDim2.new(1, -8, 1, -70)
		cardScroll.Position = UDim2.fromOffset(4, 68)
		cardScroll.BackgroundTransparency = 1
		cardScroll.BorderSizePixel = 0
		cardScroll.ScrollBarThickness = 3
		cardScroll.ScrollBarImageColor3 = RED
		cardScroll.CanvasSize = UDim2.fromOffset(0, 0)

		local UIList = Instance.new("UIListLayout", cardScroll)
		UIList.SortOrder = Enum.SortOrder.LayoutOrder
		UIList.Padding = UDim.new(0, 4)

		local wlSearchQuery = ""

		-- Pcall wrapper para hindi mag-crash ang script kapag nag-error ang Roblox API
		local function isPlayerInGroup(player, groupId)
			local success, inGroup = pcall(function()
				return player:IsInGroup(groupId)
			end)
			return success and inGroup
		end

		local function makePlayerCard(player)
			local uid = player.UserId

			if WhitelistState[uid] == nil then
				WhitelistState[uid] = false
			end

			local card = fr(cardScroll, UDim2.new(1, -6, 0, 46), UDim2.fromOffset(3, 0), BLACK)
			rnd(card, 6)

			local wcs = Instance.new("UIStroke", card)
			wcs.Color = Color3.fromRGB(0, 0, 0)
			wcs.Thickness = 1
			wcs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local ava = Instance.new("ImageLabel", card)
			ava.Size = UDim2.fromOffset(30, 30)
			ava.Position = UDim2.fromOffset(6, 8)
			ava.BackgroundColor3 = BLACK
			ava.BorderSizePixel = 0
			ava.Image = "rbxthumb://type=AvatarHeadShot&id=" .. uid .. "&w=48&sectionHdr=48"
			pill(ava)

			local tPName = lbl(card, player.DisplayName, 11, WHITE, true)
			tPName.Size = UDim2.new(0, WLP_W - 100, 0, 14)
			tPName.Position = UDim2.fromOffset(44, 6)

			local userName = lbl(card, "@" .. player.Name, 9, DIM, false)
			userName.Size = UDim2.new(0, WLP_W - 100, 0, 12)
			userName.Position = UDim2.fromOffset(44, 20)

			local isGroupWhitelisted = false
			local groupNames = {}
			for _, gang in pairs(GangIDs) do
				if S.GroupWhitelist[gang.id] and isPlayerInGroup(player, gang.id) then
					isGroupWhitelisted = true
					table.insert(groupNames, gang.name)
				end
			end

			if isGroupWhitelisted then
				local badge = lbl(card, "👥 " .. table.concat(groupNames, ", "), 8, Color3.fromRGB(255, 255, 0), false)
				badge.Size = UDim2.new(0, WLP_W - 100, 0, 14)
				badge.Position = UDim2.fromOffset(44, 34)
				badge.TextXAlignment = Enum.TextXAlignment.Left
			end

			local isWhitelistedToggle = WhitelistState[uid] or isGroupWhitelisted

			mkToggle(card, WLP_W - 10, 23, isWhitelistedToggle, function(v)
				WhitelistState[uid] = v
				refreshPlayerList()
			end)
		end

		local function refreshPlayerList()
			for _, c in pairs(cardScroll:GetChildren()) do
				if c:IsA("Frame") then
					c:Destroy()
				end
			end

			local count = 0
			local q = wlSearchQuery:lower()

			for _, pl in pairs(Players:GetPlayers()) do
				if pl ~= LP then
					local matches = q == "" or
						pl.DisplayName:lower():find(q, 1, true) or
						pl.Name:lower():find(q, 1, true)

					if matches then
						makePlayerCard(pl)
						count = count + 1
					end
				end
			end

			cardScroll.CanvasSize = UDim2.fromOffset(0, count * 50)
		end

		wlSearch:GetPropertyChangedSignal("Text"):Connect(function()
			wlSearchQuery = wlSearch.Text
			refreshPlayerList()
		end)

		trackConn(Players.PlayerAdded:Connect(function()
			task.wait(1)
			refreshPlayerList()
		end))

		trackConn(Players.PlayerRemoving:Connect(function()
			task.wait(0.3)
			refreshPlayerList()
		end))

		task.spawn(refreshPlayerList)

		task.wait(0.1)
		updateLeftCanvas()
		leftContainer:GetPropertyChangedSignal("Size"):Connect(updateLeftCanvas)

		-- Dito natin i-override ang global/outer function para sakop niya ang GangIDs at S table
		local originalIsWhitelisted = isWhitelisted
		isWhitelisted = function(pl)
			if not pl then return false end
			if not S.WhitelistEnabled then return false end

			-- 1. Check kung manually whitelisted ang player
			if WhitelistState[pl.UserId] == true then
				return true
			end

			-- 2. Check kung naka-enable ang group nila sa Group Whitelist
			for _, gang in pairs(GangIDs) do
				if S.GroupWhitelist[gang.id] == true then
					if isPlayerInGroup(pl, gang.id) then
						return true
					end
				end
			end

			return false
		end
	end

	local flyBody = nil
	local clearTrack, toggleTrack
	
	do
		local MainTab = mkSubFrame("Main")
		local L, R, colW = mkTwoCols(MainTab)
		local flyAllowed = false
		local trackAllowed = false
		local trackOn = false
		local yL = 0
		secLabel(L, yL, colW, "MOVEMENT")
		yL = yL + 26
		mkRow(L, yL, colW, "Infinite Jump", false, function(v)
			S.InfJump = v
		end)
		yL = yL + 31

		trackConn(UIS.InputBegan:Connect(function(inp, gp)
			if gp then
				return
			end

			if S.InfJump and inp.KeyCode == Enum.KeyCode.Space then
				pcall(function()
					LP.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end
		end))

		mkRow(L, yL, colW, "No Clip", false, function(v)
			S.NoClip = v
		end)
		yL = yL + 31

		trackConn(RS.Stepped:Connect(function()
			if S.NoClip and LP.Character then
				for _, p in pairs(LP.Character:GetDescendants()) do
					if p:IsA("BasePart") then
						p.CanCollide = false
					end
				end
			end
		end))

		mkRow(L, yL, colW, "Speed Hack", false, function(v)
			S.SpeedEnabled = v
			pcall(function()
				LP.Character.Humanoid.WalkSpeed = v and S.SpeedValue or 16
			end)
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Speed Value", 16, 500, 16, function(v)
			S.SpeedValue = v

			if S.SpeedEnabled then
				pcall(function()
					LP.Character.Humanoid.WalkSpeed = v
				end)
			end
		end)
		yL = yL + 49

		mkRow(L, yL, colW, "Fly", false, function(v)
			flyAllowed = v

			if not v then
				S.FlyEnabled = false
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Fly Speed", 10, 300, 50, function(v)
			S.FlySpeed = v
		end)
		yL = yL + 49

		local _, flyBadge = mkBadgeRow(L, yL, colW, "Fly Key", S.FlyKey.Name, function(badge)
			badge.Text = "Press..."
			local conn
			conn = UIS.InputBegan:Connect(function(inp, gp)
				if gp then
					return
				end

				if inp.UserInputType == Enum.UserInputType.Keyboard then
					S.FlyKey = inp.KeyCode
					badge.Text = inp.KeyCode.Name
					conn:Disconnect()
				end
			end)
		end)
		yL = yL + 31

		trackConn(RS.RenderStepped:Connect(function()
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")

			if not hrp or not hum then
				return
			end

			if S.FlyEnabled then
				hum.PlatformStand = true

				if not flyBody then
					flyBody = Instance.new("BodyVelocity", hrp)
					flyBody.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					flyBody.Velocity = Vector3.zero
				end

				local vel = Vector3.zero

				if UIS:IsKeyDown(Enum.KeyCode.W) then
					vel = vel + CAM.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.S) then
					vel = vel - CAM.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.A) then
					vel = vel - CAM.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.D) then
					vel = vel + CAM.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.Space) then
					vel = vel + Vector3.new(0, 1, 0)
				end

				if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
					vel = vel - Vector3.new(0, 1, 0)
				end

				flyBody.Velocity = vel * S.FlySpeed
			else
				if flyBody then
					flyBody:Destroy()
					flyBody = nil
				end

				if hum then
					hum.PlatformStand = false
				end
			end
		end))

		trackConn(UIS.InputBegan:Connect(function(inp, gp)
			if gp then
				return
			end

			if inp.KeyCode == S.FlyKey and flyAllowed then
				S.FlyEnabled = not S.FlyEnabled
			end
		end))

		local yR = 0
		secLabel(R, yR, colW, "UTILITIES")
		yR = yR + 26
		mkRow(R, yR, colW, "Freecam", false, function(v)
			S.FreecamEnabled = v

			if not v then
				CAM.CameraType = Enum.CameraType.Custom
			end
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Freecam Speed", 10, 300, 50, function(v)
			S.FreecamSpeed = v
		end)
		yR = yR + 49

		local _, fcBadge = mkBadgeRow(R, yR, colW, "Freecam Key", S.FreecamKey.Name, function(badge)
			badge.Text = "Press..."
			local conn
			conn = UIS.InputBegan:Connect(function(inp, gp)
				if gp then
					return
				end

				if inp.UserInputType == Enum.UserInputType.Keyboard then
					S.FreecamKey = inp.KeyCode
					badge.Text = inp.KeyCode.Name
					conn:Disconnect()
				end
			end)
		end)
		yR = yR + 31

		mkRow(R, yR, colW, "Track All ESP", false, function(v)
			trackAllowed = v
			S.TrackAllEnabled = v

			if not v and trackOn and toggleTrack then
				toggleTrack()
			end
		end)
		yR = yR + 31

		local _, taBadge = mkBadgeRow(R, yR, colW, "Track Key", S.TrackAllKey.Name, function(badge)
			badge.Text = "Press..."
			local conn
			conn = UIS.InputBegan:Connect(function(inp, gp)
				if gp then
					return
				end

				if inp.UserInputType == Enum.UserInputType.Keyboard then
					S.TrackAllKey = inp.KeyCode
					badge.Text = inp.KeyCode.Name
					conn:Disconnect()
				end
			end)
		end)
		yR = yR + 31
		secLabel(R, yR, colW, "SERVER")
		yR = yR + 26

		local rjBtn = Instance.new("TextButton", R)
		rjBtn.Size = UDim2.fromOffset(colW, 26)
		rjBtn.Position = UDim2.fromOffset(0, yR)
		rjBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		rjBtn.BorderSizePixel = 0
		rjBtn.Text = "Rejoin Server"
		rjBtn.TextColor3 = WHITE
		rjBtn.TextSize = 11
		rjBtn.Font = Enum.Font.Gotham
		rnd(rjBtn, 6)

		local rjS = Instance.new("UIStroke", rjBtn)
		rjS.Color = Color3.fromRGB(0, 0, 0)
		rjS.Thickness = 1
		rjS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		rjBtn.MouseEnter:Connect(function()
			rjBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		end)

		rjBtn.MouseLeave:Connect(function()
			rjBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		end)

		rjBtn.MouseButton1Click:Connect(function()
			pcall(function()
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
			end)
		end)

		trackConn(RS.RenderStepped:Connect(function()
			if S.FreecamEnabled then
				CAM.CameraType = Enum.CameraType.Scriptable
				local vel = Vector3.zero

				if UIS:IsKeyDown(Enum.KeyCode.W) then
					vel = vel + CAM.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.S) then
					vel = vel - CAM.CFrame.LookVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.A) then
					vel = vel - CAM.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.D) then
					vel = vel + CAM.CFrame.RightVector
				end

				if UIS:IsKeyDown(Enum.KeyCode.E) then
					vel = vel + Vector3.new(0, 1, 0)
				end

				if UIS:IsKeyDown(Enum.KeyCode.Q) then
					vel = vel - Vector3.new(0, 1, 0)
				end

				CAM.CFrame = CAM.CFrame * CFrame.new(vel * (S.FreecamSpeed / 60))
			else
				if CAM.CameraType == Enum.CameraType.Scriptable then
					CAM.CameraType = Enum.CameraType.Custom
				end
			end
		end))

		local trackLines, trackTags, trackConns, trackRender = {}, {}, {}, nil

		local function removeTrack(pl)
			if trackLines[pl] then
				pcall(function()
					trackLines[pl]:Destroy()
				end)
				trackLines[pl] = nil
			end

			if trackTags[pl] then
				pcall(function()
					trackTags[pl]:Destroy()
				end)
				trackTags[pl] = nil
			end
		end

		local function createTrack(pl)
			if pl == LP then
				return
			end

			local function setup()
				removeTrack(pl)
				local char = pl.Character

				if not char then
					return
				end

				local hrp = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")

				if not hrp or not head then
					return
				end

				local line = Instance.new("Part")
				line.Anchored = true
				line.CanCollide = false
				line.Color = WHITE
				line.Material = Enum.Material.Neon
				line.Transparency = 0
				line.Size = Vector3.new(0.1, 0.1, 1)
				line.CastShadow = false
				line.Parent = workspace
				trackLines[pl] = line

				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.fromOffset(100, 30)
				bb.StudsOffset = Vector3.new(0, 2.2, 0)
				bb.AlwaysOnTop = true
				bb.Adornee = head

				local tl = Instance.new("TextLabel", bb)
				tl.Size = UDim2.new(1, 0, 1, 0)
				tl.BackgroundTransparency = 1
				tl.Text = pl.DisplayName .. "\n(" .. pl.Name .. ")"
				tl.TextColor3 = WHITE
				tl.TextStrokeTransparency = 0.4
				tl.Font = Enum.Font.Gotham
				tl.TextSize = 11
				bb.Parent = head
				trackTags[pl] = bb
			end

			if pl.Character then
				setup()
			end

			local c = pl.CharacterAdded:Connect(function()
				task.wait(1)
				setup()
			end)
			table.insert(trackConns, c)
		end

		local function updateTrack()
			local myChar = LP.Character
			local origin = myChar and myChar:FindFirstChild("HumanoidRootPart")

			if not origin then
				return
			end

			for pl, line in pairs(trackLines) do
				local tChar = pl.Character
				local target = tChar and tChar:FindFirstChild("HumanoidRootPart")

				if target and target:IsDescendantOf(workspace) then
					local dir = target.Position - origin.Position
					local dist = dir.Magnitude
					line.Size = Vector3.new(0.1, 0.1, dist)
					line.CFrame = CFrame.new(origin.Position, target.Position) * CFrame.new(0, 0, -dist / 2)
				else
					removeTrack(pl)
				end
			end
		end

		clearTrack = function()
			for _, line in pairs(trackLines) do
				pcall(function()
					line:Destroy()
				end)
			end

			for _, tag in pairs(trackTags) do
				pcall(function()
					tag:Destroy()
				end)
			end

			for _, c in ipairs(trackConns) do
				pcall(function()
					c:Disconnect()
				end)
			end

			if trackRender then
				trackRender:Disconnect()
				trackRender = nil
			end

			trackLines = {}
			trackTags = {}
			trackConns = {}
		end

		toggleTrack = function()
			trackOn = not trackOn
			S.TrackAllEnabled = trackOn

			if trackOn then
				for _, pl in ipairs(Players:GetPlayers()) do
					createTrack(pl)
				end

				local pc = Players.PlayerAdded:Connect(createTrack)
				table.insert(trackConns, pc)
				trackRender = RS.RenderStepped:Connect(updateTrack)
			else
				clearTrack()
			end
		end

		trackConn(UIS.InputBegan:Connect(function(inp, gp)
			if gp then
				return
			end

			if inp.KeyCode == S.TrackAllKey and trackAllowed then
				toggleTrack()
			end
		end))
	end

	do
		local MovTab = mkSubFrame("Movement")
		local L, R, colW = mkTwoCols(MovTab)
		local yL = 0
		secLabel(L, yL, colW, "WALKSPEED")
		yL = yL + 26
		mkRow(L, yL, colW, "Enable Walkspeed", false, function(v)
			S.WalkEnabled = v
			pcall(function()
				LP.Character.Humanoid.WalkSpeed = v and S.WalkSpeed or 16
			end)
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Speed", 16, 500, 16, function(v)
			S.WalkSpeed = v

			if S.WalkEnabled then
				pcall(function()
					LP.Character.Humanoid.WalkSpeed = v
				end)
			end
		end)
		yL = yL + 49

		local yR = 0
		secLabel(R, yR, colW, "JUMP POWER")
		yR = yR + 26
		mkRow(R, yR, colW, "Enable Jump Power", false, function(v)
			S.JumpEnabled = v
			pcall(function()
				LP.Character.Humanoid.JumpPower = v and S.JumpPower or 50
			end)
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Power", 50, 500, 50, function(v)
			S.JumpPower = v

			if S.JumpEnabled then
				pcall(function()
					LP.Character.Humanoid.JumpPower = v
				end)
			end
		end)
		yR = yR + 49
	end

	do
		local TPTab = mkSubFrame("Teleport")
		local TP_W = CON_W - PAD * 2
		local TPPanel = fr(TPTab, UDim2.fromOffset(TP_W, WIN_H - PATH_H - PAD * 2), UDim2.fromOffset(PAD, PAD), BLACK)
		rnd(TPPanel, 8)

		local tpPanStroke = Instance.new("UIStroke", TPPanel)
		tpPanStroke.Color = Color3.fromRGB(0, 0, 0)
		tpPanStroke.Thickness = 1
		tpPanStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		secLabel(TPPanel, 8, TP_W, "TELEPORT")

		local tpSearch = mkSearchBox(TPPanel, 36, TP_W, "Search")
		local tpScroll = Instance.new("ScrollingFrame", TPPanel)
		tpScroll.Size = UDim2.new(1, -8, 1, -70)
		tpScroll.Position = UDim2.fromOffset(4, 68)
		tpScroll.BackgroundTransparency = 1
		tpScroll.BorderSizePixel = 0
		tpScroll.ScrollBarThickness = 3
		tpScroll.ScrollBarImageColor3 = RED
		tpScroll.CanvasSize = UDim2.fromOffset(0, 0)

		local tpLayout = Instance.new("UIListLayout", tpScroll)
		tpLayout.SortOrder = Enum.SortOrder.LayoutOrder
		tpLayout.Padding = UDim.new(0, 3)

		local function tpToPos(pos)
			local char = LP.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")

			if hrp then
				hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
			end
		end

		local function mkTPCard(name, pos)
			local card = fr(tpScroll, UDim2.new(1, -6, 0, 42), UDim2.fromOffset(3, 0), BLACK)
			rnd(card, 6)

			local tcs = Instance.new("UIStroke", card)
			tcs.Color = Color3.fromRGB(0, 0, 0)
			tcs.Thickness = 1
			tcs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local dot = fr(card, UDim2.fromOffset(3, 3), UDim2.fromOffset(8, 20), RED)
			rnd(dot, 2)

			local tPName = lbl(card, name, 11, WHITE, true)
			tPName.Name = "TPName"
			tPName.Size = UDim2.new(1, -160, 0, 18)
			tPName.Position = UDim2.fromOffset(18, 4)

			local cL = lbl(card, math.floor(pos.X) .. "," .. math.floor(pos.Y) .. "," .. math.floor(pos.Z), 9, DIM, false)
			cL.Size = UDim2.new(1, -160, 0, 14)
			cL.Position = UDim2.fromOffset(18, 22)

			local BW = 56
			local bX = TP_W - 6 - BW * 2 - 4

			local function mkTPBtn(txt, cb)
				local b = Instance.new("TextButton", card)
				b.Size = UDim2.fromOffset(BW, 24)
				b.Position = UDim2.fromOffset(bX, 9)
				b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				b.BorderSizePixel = 0
				b.Text = txt
				b.TextColor3 = WHITE
				b.TextSize = 9
				b.Font = Enum.Font.Gotham
				rnd(b, 5)

				local tbss = Instance.new("UIStroke", b)
				tbss.Color = Color3.fromRGB(0, 0, 0)
				tbss.Thickness = 1
				tbss.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				if cb then
					b.MouseButton1Click:Connect(cb)
				end

				bX = bX + BW + 4
				return b
			end

			mkTPBtn("Teleport", function()
				tpToPos(pos)
			end)

			local viewing = false
			local vb = mkTPBtn("View", nil)
			return card
		end

		local function mkSectionHdr(txt)
			local sectionHdr = fr(tpScroll, UDim2.new(1, -6, 0, 22), UDim2.fromOffset(3, 0), Color3.fromRGB(8, 8, 8))
			sectionHdr.Name = "SectionHdr"
			rnd(sectionHdr, 4)
			local hl = lbl(sectionHdr, txt, 9, DIM, true)
			hl.Size = UDim2.new(1, -12, 1, 0)
			hl.Position = UDim2.fromOffset(8, 0)
			return sectionHdr
		end

		local LOCATIONS = {
			{ name = "BARNEY CO", pos = Vector3.new(-161.38, 93.08, 178.98) },
			{ name = "AMMUNATION", pos = Vector3.new(4619.75537, 61.3672485, -1804.77222, -0.660558462, 0, -0.750774682, 0, 1, 0, 0.750774682, 0, -0.660558462) },
			{ name = "UWU", pos = Vector3.new(-1403.61, 93.00, 453.11) },
			{ name = "CLOTHING", pos = Vector3.new(-1132.42, 93.32, 513.72) },
			{ name = "CLOTHING 2", pos = Vector3.new(4243.47363, 61.6253052, -1181.20178, -0.977508187, 0, -0.210897222, 0, 1, 0, 0.210897222, 0, -0.977508187) },
			{ name = "PUBLIC STASH", pos = Vector3.new(-1522.46, 93.70, -38.58) },
			{ name = "OLD HP", pos = Vector3.new(-1612.62, 93.13, 172.90) },
			{ name = "NEW HP", pos = Vector3.new(3565.00879, 59.4970322, -1559.41028, 6.61015511e-05, 0.850445628, 0.526062965, -1, 6.61015511e-05, 1.87754631e-05, -1.87754631e-05, -0.526062965, 0.850445628) },
			{ name = "CAR DEALER", pos = Vector3.new(-1396.30, 93.26, 1140.94) },
			{ name = "TRAPHOUSE 1", pos = Vector3.new(-1057.14, 93.31, 1619.93) },
			{ name = "TRAPHOUSE 2", pos = Vector3.new(-896.50, 93.30, 1756.91) },
			{ name = "POLICE DEPARTMENT", pos = Vector3.new(599.79, 92.95, 931.60) },
			{ name = "JAVIER FARMER", pos = Vector3.new(2124.66, 97.19, -852.52) },
			{ name = "BLACK MARKET", pos = Vector3.new(5064.99, 546.38, -121.22) },
			{ name = "HP STASH", pos = Vector3.new(3836.01489, 69.6145706, -1360.91309, -0.526110291, 0, 0.850416362, 0, 1, 0, -0.850416362, 0, -0.526110291) },
		}

		local GANG_STASHES = {
			{ name = "COSA NOSTRA", pos = Vector3.new(312.64, 114.02, 2472.16) },
			{ name = "ESCOBAR", pos = Vector3.new(2201.83228, 116.857552, -33.416523, -1.1920929e-07, -0, -1.00000012, 0, 1, -0, 1.00000012, 0, -1.1920929e-07) },
			{ name = "EL3K", pos = Vector3.new(4249.79, 81.98, -2280.57) },
			{ name = "ELIJAH", pos = Vector3.new(3166.03, 82.03, 1263.66) },
			{ name = "GIMENEZ", pos = Vector3.new(3183.75, 81.57, -932.19) },
			{ name = "LFF", pos = Vector3.new(889.84, 113.87, 1377.75) },
			{ name = "MS13", pos = Vector3.new(1738.07, 113.66, 1157.19) },
			{ name = "MARTINEZ", pos = Vector3.new(1437.20923, 106.136688, -696.930786, 0.99996084, -3.68468463e-05, -0.00885068625, -0.00885035284, 0.00546658039, -0.999945998, 8.52295198e-05, 0.999985218, 0.00546604395) },
			{ name = "MUERTE", pos = Vector3.new(-1051.93, 113.95, -594.72) },
			{ name = "T6M", pos = Vector3.new(539.76, 114.22, -21.86) },
			{ name = "USL", pos = Vector3.new(4155.53, 82.01, 1304.20) },
		}

		local tpSearchQuery = ""

		local function rebuildTPList()
			for _, c in pairs(tpScroll:GetChildren()) do
				if c:IsA("Frame") or c:IsA("TextLabel") then
					c:Destroy()
				end
			end

			local q = tpSearchQuery:lower()
			local locMatches = {}

			for _, loc in ipairs(LOCATIONS) do
				if q == "" or loc.name:lower():find(q, 1, true) then
					table.insert(locMatches, loc)
				end
			end

			if #locMatches > 0 then
				mkSectionHdr("LOCATIONS")

				for _, loc in ipairs(locMatches) do
					mkTPCard(loc.name, loc.pos)
				end
			end

			local gangMatches = {}

			for _, gang in ipairs(GANG_STASHES) do
				if q == "" or gang.name:lower():find(q, 1, true) then
					table.insert(gangMatches, gang)
				end
			end

			if #gangMatches > 0 then
				mkSectionHdr("GANG STASHES")

				for _, gang in ipairs(gangMatches) do
					mkTPCard(gang.name, gang.pos)
				end
			end

			task.delay(0.1, function()
				local total = 0

				for _, c in pairs(tpScroll:GetChildren()) do
					if c:IsA("Frame") then
						total = total + c.AbsoluteSize.Y + 3
					end
				end

				tpScroll.CanvasSize = UDim2.fromOffset(0, total)
			end)
		end

		tpSearch:GetPropertyChangedSignal("Text"):Connect(function()
			tpSearchQuery = tpSearch.Text
			rebuildTPList()
		end)

		task.spawn(rebuildTPList)
	end
	
	-- Define Lighting at the top of your script
	local Lighting = game:GetService("Lighting")
	local CAM = workspace.CurrentCamera

	do
		local WorldTab = mkSubFrame("Sky")

		local scrollFrame = Instance.new("ScrollingFrame", WorldTab)
		scrollFrame.Size = UDim2.new(1, -10, 1, -10)
		scrollFrame.Position = UDim2.fromOffset(5, 5)
		scrollFrame.BackgroundTransparency = 1
		scrollFrame.BorderSizePixel = 0
		scrollFrame.ScrollBarThickness = 4
		scrollFrame.ScrollBarImageColor3 = RED
		scrollFrame.CanvasSize = UDim2.fromOffset(0, 0)
		scrollFrame.ClipsDescendants = true

		local container = Instance.new("Frame", scrollFrame)
		container.Size = UDim2.new(1, 0, 0, 0)
		container.BackgroundTransparency = 1
		container.AutomaticSize = Enum.AutomaticSize.Y

		local L, R, colW = mkTwoCols(container)
		local yL = 0
		local yR = 0

		secLabel(L, yL, colW, "WORLD VISUALS")
		yL = yL + 26

		mkRow(L, yL, colW, "No Fog", S.NoFog or false, function(v)
			S.NoFog = v
			if v then
				Lighting.FogEnd = 100000
				Lighting.FogStart = 0
			else
				Lighting.FogEnd = 28622
				Lighting.FogStart = 0
			end
		end)
		yL = yL + 31

		mkRow(L, yL, colW, "Full Bright", S.FullBright or false, function(v)
			S.FullBright = v
			if v then
				Lighting.Brightness = 10
				Lighting.Ambient = Color3.fromRGB(255, 255, 255)
			else
				Lighting.Brightness = 1
				Lighting.Ambient = Color3.fromRGB(127, 127, 127)
			end
		end)
		yL = yL + 31

		mkRow(L, yL, colW, "Custom FOV", S.CustomFOV or false, function(v)
			S.CustomFOV = v
			if not v then
				CAM.FieldOfView = 70
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "FOV", 50, 120, S.FOVValue or 70, function(v)
			S.FOVValue = math.round(v)
			if S.CustomFOV then
				CAM.FieldOfView = math.round(v)
			end
		end)
		yL = yL + 49

		secLabel(L, yL, colW, "LIGHTING")
		yL = yL + 26

		mkRow(L, yL, colW, "Custom Exposure", S.CustomExposure or false, function(v)
			S.CustomExposure = v
			if v then
				Lighting.ExposureCompensation = S.ExposureValue or 0
			else
				Lighting.ExposureCompensation = 0
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Exposure", -5, 5, S.ExposureValue or 0, function(v)
			S.ExposureValue = math.round(v * 100) / 100
			if S.CustomExposure then
				Lighting.ExposureCompensation = S.ExposureValue
			end
		end)
		yL = yL + 49

		mkRow(L, yL, colW, "Custom Brightness", S.CustomBrightness or false, function(v)
			S.CustomBrightness = v
			if v then
				Lighting.Brightness = S.BrightnessValue or 1
			else
				Lighting.Brightness = 1
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Brightness", 0, 10, S.BrightnessValue or 1, function(v)
			S.BrightnessValue = math.round(v * 100) / 100
			if S.CustomBrightness then
				Lighting.Brightness = S.BrightnessValue
			end
		end)
		yL = yL + 49

		mkRow(L, yL, colW, "Color Correction", S.ColorCorrection or false, function(v)
			S.ColorCorrection = v
			if v then
				local cc = Lighting:FindFirstChild("ColorCorrection") or Instance.new("ColorCorrectionEffect", Lighting)
				cc.Enabled = true
				cc.Brightness = S.ColorBrightness or 0
				cc.Contrast = S.ColorContrast or 0
				cc.Saturation = S.ColorSaturation or 0
				cc.TintColor = S.ColorTint or Color3.fromRGB(255, 255, 255)
			else
				local cc = Lighting:FindFirstChild("ColorCorrection")
				if cc then cc.Enabled = false end
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Brightness", -1, 1, S.ColorBrightness or 0, function(v)
			S.ColorBrightness = math.round(v * 100) / 100
			if S.ColorCorrection then
				local cc = Lighting:FindFirstChild("ColorCorrection")
				if cc then cc.Brightness = S.ColorBrightness end
			end
		end)
		yL = yL + 49

		mkSlider(L, yL, colW, "Contrast", -1, 1, S.ColorContrast or 0, function(v)
			S.ColorContrast = math.round(v * 100) / 100
			if S.ColorCorrection then
				local cc = Lighting:FindFirstChild("ColorCorrection")
				if cc then cc.Contrast = S.ColorContrast end
			end
		end)
		yL = yL + 49

		mkSlider(L, yL, colW, "Saturation", -1, 1, S.ColorSaturation or 0, function(v)
			S.ColorSaturation = math.round(v * 100) / 100
			if S.ColorCorrection then
				local cc = Lighting:FindFirstChild("ColorCorrection")
				if cc then cc.Saturation = S.ColorSaturation end
			end
		end)
		yL = yL + 49

		secLabel(L, yL, colW, "TIME")
		yL = yL + 26

		mkRow(L, yL, colW, "Custom Time", S.CustomTime or false, function(v)
			S.CustomTime = v
			if v then
				Lighting.ClockTime = S.TimeValue or 12
			else
				Lighting.ClockTime = 12
			end
		end)
		yL = yL + 31

		mkSlider(L, yL, colW, "Time of Day", 0, 24, S.TimeValue or 12, function(v)
			S.TimeValue = math.round(v * 100) / 100
			if S.CustomTime then
				Lighting.ClockTime = S.TimeValue
			end
		end)
		yL = yL + 49

		secLabel(R, yR, colW, "EXTRA")
		yR = yR + 26

		mkRow(R, yR, colW, "Anti Fog", S.AntiFog or false, function(v)
			S.AntiFog = v
			if v then
				Lighting.FogEnd = 100000
				Lighting.FogStart = 0
				Lighting.FogColor = Color3.fromRGB(0, 0, 0)
			else
				Lighting.FogEnd = 28622
				Lighting.FogStart = 0
				Lighting.FogColor = Color3.fromRGB(127, 127, 127)
			end
		end)
		yR = yR + 31

		mkRow(R, yR, colW, "Remove Water", S.RemoveWater or false, function(v)
			S.RemoveWater = v
			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Water") then
					obj.Transparency = v and 1 or 0
					obj.Reflectance = v and 0 or 0.5
				end
			end
		end)
		yR = yR + 31

		mkRow(R, yR, colW, "Remove Sky", S.RemoveSky or false, function(v)
			S.RemoveSky = v
			local sky = Lighting:FindFirstChildOfClass("Sky")
			if sky then
				if v then
					if not S._OriginalSkyProperties then
						S._OriginalSkyProperties = {
							SkyboxBk = sky.SkyboxBk,
							SkyboxDn = sky.SkyboxDn,
							SkyboxFt = sky.SkyboxFt,
							SkyboxLf = sky.SkyboxLf,
							SkyboxRt = sky.SkyboxRt,
							SkyboxUp = sky.SkyboxUp,
							SunTextureId = sky.SunTextureId,
							MoonTextureId = sky.MoonTextureId,
							StarCount = sky.StarCount,
						}
					end
					sky.SkyboxBk = "rbxassetid://0"
					sky.SkyboxDn = "rbxassetid://0"
					sky.SkyboxFt = "rbxassetid://0"
					sky.SkyboxLf = "rbxassetid://0"
					sky.SkyboxRt = "rbxassetid://0"
					sky.SkyboxUp = "rbxassetid://0"
					sky.SunTextureId = "rbxassetid://0"
					sky.MoonTextureId = "rbxassetid://0"
					sky.StarCount = 0
				else
					if S._OriginalSkyProperties then
						sky.SkyboxBk = S._OriginalSkyProperties.SkyboxBk
						sky.SkyboxDn = S._OriginalSkyProperties.SkyboxDn
						sky.SkyboxFt = S._OriginalSkyProperties.SkyboxFt
						sky.SkyboxLf = S._OriginalSkyProperties.SkyboxLf
						sky.SkyboxRt = S._OriginalSkyProperties.SkyboxRt
						sky.SkyboxUp = S._OriginalSkyProperties.SkyboxUp
						sky.SunTextureId = S._OriginalSkyProperties.SunTextureId
						sky.MoonTextureId = S._OriginalSkyProperties.MoonTextureId
						sky.StarCount = S._OriginalSkyProperties.StarCount
						S._OriginalSkyProperties = nil
					end
				end
			end
		end)
		yR = yR + 31

		mkRow(R, yR, colW, "No Shadows", S.NoShadows or false, function(v)
			S.NoShadows = v
			Lighting.GlobalShadows = not v
			for _, part in pairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CastShadow = not v
				end
			end
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Ambient", 0, 100, S.AmbientValue or 50, function(v)
			S.AmbientValue = math.round(v)
			local ambient = S.AmbientValue / 100
			Lighting.Ambient = Color3.fromRGB(ambient * 255, ambient * 255, ambient * 255)
		end)
		yR = yR + 49

		secLabel(R, yR, colW, "BLOOM EFFECT")
		yR = yR + 26

		mkRow(R, yR, colW, "Bloom Enabled", S.BloomEnabled or false, function(v)
			S.BloomEnabled = v
			local bloom = Lighting:FindFirstChild("Bloom") or Instance.new("BloomEffect", Lighting)
			bloom.Enabled = v
			if v then
				bloom.Intensity = S.BloomIntensity or 2
				bloom.Size = S.BloomSize or 4
				bloom.Threshold = S.BloomThreshold or 0.8
			end
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Bloom Intensity", 0, 10, S.BloomIntensity or 2, function(v)
			S.BloomIntensity = math.round(v * 100) / 100
			if S.BloomEnabled then
				local bloom = Lighting:FindFirstChild("Bloom")
				if bloom then bloom.Intensity = S.BloomIntensity end
			end
		end)
		yR = yR + 49

		mkSlider(R, yR, colW, "Bloom Size", 1, 10, S.BloomSize or 4, function(v)
			S.BloomSize = math.round(v * 100) / 100
			if S.BloomEnabled then
				local bloom = Lighting:FindFirstChild("Bloom")
				if bloom then bloom.Size = S.BloomSize end
			end
		end)
		yR = yR + 49

		mkSlider(R, yR, colW, "Bloom Threshold", 0, 1, S.BloomThreshold or 0.8, function(v)
			S.BloomThreshold = math.round(v * 100) / 100
			if S.BloomEnabled then
				local bloom = Lighting:FindFirstChild("Bloom")
				if bloom then bloom.Threshold = S.BloomThreshold end
			end
		end)
		yR = yR + 49

		secLabel(R, yR, colW, "SUN RAYS")
		yR = yR + 26

		mkRow(R, yR, colW, "Sun Rays", S.SunRaysEnabled or false, function(v)
			S.SunRaysEnabled = v
			local sunRays = Lighting:FindFirstChild("SunRays") or Instance.new("SunRaysEffect", Lighting)
			sunRays.Enabled = v
			if v then
				sunRays.Intensity = S.SunRaysIntensity or 0.5
				sunRays.Spread = S.SunRaysSpread or 0.8
			end
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Sun Rays Intensity", 0, 1, S.SunRaysIntensity or 0.5, function(v)
			S.SunRaysIntensity = math.round(v * 100) / 100
			if S.SunRaysEnabled then
				local sunRays = Lighting:FindFirstChild("SunRays")
				if sunRays then sunRays.Intensity = S.SunRaysIntensity end
			end
		end)
		yR = yR + 49

		mkSlider(R, yR, colW, "Sun Rays Spread", 0, 1, S.SunRaysSpread or 0.8, function(v)
			S.SunRaysSpread = math.round(v * 100) / 100
			if S.SunRaysEnabled then
				local sunRays = Lighting:FindFirstChild("SunRays")
				if sunRays then sunRays.Spread = S.SunRaysSpread end
			end
		end)
		yR = yR + 49

		secLabel(R, yR, colW, "ATMOSPHERE")
		yR = yR + 26

		mkRow(R, yR, colW, "Atmosphere Enabled", S.AtmosphereEnabled or false, function(v)
			S.AtmosphereEnabled = v
			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			if atmosphere then
				atmosphere.Enabled = v
			end
		end)
		yR = yR + 31

		mkSlider(R, yR, colW, "Atmosphere Density", 0, 1, S.AtmosphereDensity or 0.4, function(v)
			S.AtmosphereDensity = math.round(v * 100) / 100
			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			if atmosphere and S.AtmosphereEnabled then
				atmosphere.Density = S.AtmosphereDensity
			end
		end)
		yR = yR + 49

		mkSlider(R, yR, colW, "Atmosphere Offset", 0, 1, S.AtmosphereOffset or 0, function(v)
			S.AtmosphereOffset = math.round(v * 100) / 100
			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			if atmosphere and S.AtmosphereEnabled then
				atmosphere.Offset = S.AtmosphereOffset
			end
		end)
		yR = yR + 49

		local resetBtn = Instance.new("TextButton", R)
		resetBtn.Size = UDim2.fromOffset(100, 30)
		resetBtn.Position = UDim2.fromOffset(0, yR + 10)
		resetBtn.BackgroundColor3 = RED
		resetBtn.BorderSizePixel = 0
		resetBtn.Text = "Reset All"
		resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		resetBtn.TextSize = 11
		resetBtn.Font = Enum.Font.GothamBold
		rnd(resetBtn, 6)

		resetBtn.MouseButton1Click:Connect(function()
			S.NoFog = false
			S.FullBright = false
			S.CustomFOV = false
			S.FOVValue = 70
			S.CustomExposure = false
			S.ExposureValue = 0
			S.CustomBrightness = false
			S.BrightnessValue = 1
			S.CustomTime = false
			S.TimeValue = 12
			S.AntiFog = false
			S.RemoveWater = false
			S.RemoveSky = false
			S.NoShadows = false
			S.AmbientValue = 50
			S.ColorCorrection = false
			S.ColorBrightness = 0
			S.ColorContrast = 0
			S.ColorSaturation = 0
			S.BloomEnabled = false
			S.BloomIntensity = 2
			S.BloomSize = 4
			S.BloomThreshold = 0.8
			S.SunRaysEnabled = false
			S.SunRaysIntensity = 0.5
			S.SunRaysSpread = 0.8
			S.AtmosphereEnabled = false
			S.AtmosphereDensity = 0.4
			S.AtmosphereOffset = 0

			Lighting.FogEnd = 28622
			Lighting.FogStart = 0
			Lighting.FogColor = Color3.fromRGB(127, 127, 127)
			Lighting.Brightness = 1
			Lighting.Ambient = Color3.fromRGB(127, 127, 127)
			Lighting.ExposureCompensation = 0
			Lighting.ClockTime = 12
			Lighting.GlobalShadows = true
			CAM.FieldOfView = 70

			local cc = Lighting:FindFirstChild("ColorCorrection")
			if cc then cc.Enabled = false end

			local bloom = Lighting:FindFirstChild("Bloom")
			if bloom then bloom.Enabled = false end

			local sunRays = Lighting:FindFirstChild("SunRays")
			if sunRays then sunRays.Enabled = false end

			local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
			if atmosphere then
				atmosphere.Enabled = true
				atmosphere.Density = 0.4
				atmosphere.Offset = 0
			end

			for _, obj in pairs(workspace:GetDescendants()) do
				if obj:IsA("Water") then
					obj.Transparency = 0
					obj.Reflectance = 0.5
				end
			end

			local sky = Lighting:FindFirstChildOfClass("Sky")
			if sky and S._OriginalSkyProperties then
				sky.SkyboxBk = S._OriginalSkyProperties.SkyboxBk
				sky.SkyboxDn = S._OriginalSkyProperties.SkyboxDn
				sky.SkyboxFt = S._OriginalSkyProperties.SkyboxFt
				sky.SkyboxLf = S._OriginalSkyProperties.SkyboxLf
				sky.SkyboxRt = S._OriginalSkyProperties.SkyboxRt
				sky.SkyboxUp = S._OriginalSkyProperties.SkyboxUp
				sky.SunTextureId = S._OriginalSkyProperties.SunTextureId
				sky.MoonTextureId = S._OriginalSkyProperties.MoonTextureId
				sky.StarCount = S._OriginalSkyProperties.StarCount
				S._OriginalSkyProperties = nil
			end

			for _, part in pairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CastShadow = true
				end
			end
		end)

		local function updateCanvas()
			local totalHeight = math.max(yL, yR + 60)
			scrollFrame.CanvasSize = UDim2.fromOffset(0, totalHeight + 50)
			container.Size = UDim2.new(1, 0, 0, totalHeight + 50)
		end

		task.wait(0.1)
		updateCanvas()
		container:GetPropertyChangedSignal("Size"):Connect(updateCanvas)
	end

	
	
	do
		local GamesTab = mkSubFrame("Games")
		local gW = CON_W - PAD * 2
		local gScroll = mkScrollContent(GamesTab, 800)
		secLabel(gScroll, 4, gW, "CITY SCRIPTS")
		local yOff = 30

		local function makeGameEntry(labelTxt, whitelistFn, script)
			local entry = fr(gScroll, UDim2.fromOffset(gW, 48), UDim2.fromOffset(0, yOff), BLACK)
			rnd(entry, 6)

			local ges = Instance.new("UIStroke", entry)
			ges.Color = Color3.fromRGB(0, 0, 0)
			ges.Thickness = 1
			ges.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local tPName = lbl(entry, labelTxt, 11, WHITE, true)
			tPName.Size = UDim2.fromOffset(gW - 110, 20)
			tPName.Position = UDim2.fromOffset(12, 6)

			local lockL = lbl(entry, whitelistFn and "Whitelisted" or "Public", 9, DIM, false)
			lockL.Size = UDim2.fromOffset(gW - 110, 14)
			lockL.Position = UDim2.fromOffset(12, 26)

			local bypassBtn = Instance.new("TextButton", entry)
			bypassBtn.Size = UDim2.fromOffset(86, 28)
			bypassBtn.Position = UDim2.new(1, -94, 0.5, -14)
			bypassBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
			bypassBtn.BorderSizePixel = 0
			bypassBtn.Text = "Bypass"
			bypassBtn.TextColor3 = WHITE
			bypassBtn.TextSize = 11
			bypassBtn.Font = Enum.Font.Gotham
			bypassBtn.ZIndex = entry.ZIndex + 2
			rnd(bypassBtn, 6)

			local bbs = Instance.new("UIStroke", bypassBtn)
			bbs.Color = Color3.fromRGB(0, 0, 0)
			bbs.Thickness = 1
			bbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			bypassBtn.MouseEnter:Connect(function()
				bypassBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
			end)

			bypassBtn.MouseLeave:Connect(function()
				bypassBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
			end)

			bypassBtn.MouseButton1Click:Connect(function()
				if whitelistFn and not whitelistFn() then
					bypassBtn.Text = "No Access"
					bypassBtn.TextColor3 = RED
					task.delay(1.5, function()
						bypassBtn.Text = "Bypass"
						bypassBtn.TextColor3 = WHITE
					end)
					return
				end

				local ok = pcall(function()
					loadstring(script)()
				end)
				bypassBtn.Text = ok and "Done" or "Error"

				if not ok then
					bypassBtn.TextColor3 = RED
				end

				task.delay(2, function()
					bypassBtn.Text = "Bypass"
					bypassBtn.TextColor3 = WHITE
				end)
			end)

			yOff = yOff + 52
		end

		
		local PINAS_WL = { ["theyluvzmonsy"] = true, ["KramDaRealest"] = true, ["Cheaterakohahaha4"] = true, ["Daixwqa"] = true, ["iluvpadz"] = true, ["Hannamitcheyski"] = true, ["angxlyvars"] = true, ["Notti_osama123az"] = true, ["steezywyd"] = true }
		local FANTASY_WL = { ["theyluvzmonsy"] = true, ["KramDaRealest"] = true, ["Cheaterakohahaha4"] = true, ["Daixwqa"] = true, ["iluvpadz"] = true, ["Hannamitcheyski"] = true, ["angxlyvars"] = true, ["Notti_osama123az"] = true, ["steezywyd"] = true }

		makeGameEntry("Haraya City", nil, [[local RS=game:GetService("ReplicatedStorage"); local u=RS:FindFirstChild("Unknown"); if u then u:Destroy() end]])
		makeGameEntry("Hitmark PVP", nil, [[local r=game:GetService("ReplicatedStorage"):WaitForChild("Remotes"); local g=r:FindFirstChild("GiveDust"); if g then g:Destroy() end]])
		makeGameEntry("Pinas Battle Grounds", function()
			return PINAS_WL[LP.Name] == true
		end,
		[[local RS=game:GetService("ReplicatedStorage"); local sectionHdr=RS.AntiEvents.Expand.hEvent; if sectionHdr then sectionHdr:Destroy() end; local k=RS.AntiEvents.Expand.kEvent; if k then k:Destroy() end]])
		makeGameEntry("Fantasy City Roleplay", function()
			return FANTASY_WL[LP.Name] == true
		end,
		[[local RS=game:GetService("ReplicatedStorage"); local hcr=RS:FindFirstChild("HeadCheckRemote"); if hcr then hcr:Destroy() end]])

		local COMSERVE_WL = { ["roblox_user_5366417028"] = true, ["Migiezz"] = true, ["Cheaterakohahaha4"] = true, ["Gian_Hitsdiff"] = true, ["X"] = true }
		local comserveActive = false
		local comserveThread = nil

		do
			local entryH = 52
			local entry = fr(gScroll, UDim2.fromOffset(gW, entryH), UDim2.fromOffset(0, yOff), BLACK)
			rnd(entry, 6)
			stk(entry, LINE, 1)

			local tPName = lbl(entry, "Haraya Comserve Bypass", 12, WHITE, true)
			tPName.Size = UDim2.fromOffset(gW - 110, 20)
			tPName.Position = UDim2.fromOffset(12, 8)

			local sL = lbl(entry, "Whitelisted", 9, DIM)
			sL.Size = UDim2.fromOffset(gW - 110, 14)
			sL.Position = UDim2.fromOffset(12, 28)

			local toggleBtn = Instance.new("TextButton", entry)
			toggleBtn.Size = UDim2.fromOffset(64, 28)
			toggleBtn.Position = UDim2.new(1, -72, 0.5, -14)
			toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
			toggleBtn.BorderSizePixel = 0
			toggleBtn.Text = "Off"
			toggleBtn.TextColor3 = WHITE
			toggleBtn.TextSize = 11
			toggleBtn.Font = Enum.Font.Gotham
			toggleBtn.ZIndex = entry.ZIndex + 2
			rnd(toggleBtn, 6)
			stk(toggleBtn, LINE, 1)

			toggleBtn.MouseEnter:Connect(function()
				if not comserveActive then
					toggleBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
				end
			end)

			toggleBtn.MouseLeave:Connect(function()
				if not comserveActive then
					toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
				end
			end)

			toggleBtn.MouseButton1Click:Connect(function()
				if not COMSERVE_WL[LP.Name] then
					toggleBtn.Text = "No Access"
					toggleBtn.TextColor3 = RED
					task.delay(1.5, function()
						toggleBtn.Text = comserveActive and "On" or "Off"
						toggleBtn.TextColor3 = WHITE
					end)
					return
				end

				comserveActive = not comserveActive

				if comserveActive then
					toggleBtn.Text = "On"
					toggleBtn.BackgroundColor3 = RED

					comserveThread = task.spawn(function()
						local VU = game:GetService("VirtualUser")
						local idleConn = LP.Idled:Connect(function()
							VU:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
							task.wait(0.1)
							VU:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
						end)

						while comserveActive do
							local char = LP.Character
							local hrp = char and char:FindFirstChild("HumanoidRootPart")

							if hrp then
								local ok, tasks_list = pcall(function()
									return {
										{ obj = workspace.Comserve.Task, prompt = workspace.Comserve.Task.ProximityPrompt },
										{ obj = workspace.Comserve.Task2, prompt = workspace.Comserve.Task2.ProximityPrompt },
										{ obj = workspace.Comserve.Task3, prompt = workspace.Comserve.Task3.ProximityPrompt },
										{ obj = workspace.Comserve.Task4, prompt = workspace.Comserve.Task4.ProximityPrompt },
										{ obj = workspace.Comserve.Task5, prompt = workspace.Comserve.Task5.ProximityPrompt },
									}
								end)

								if ok then
									for _, t in ipairs(tasks_list) do
										if not comserveActive then
											break
										end

										local curHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")

										if curHrp then
											curHrp.CFrame = CFrame.new(t.obj.Position + Vector3.new(0, 4, 0))
										end

										task.wait(0.4)

										if not comserveActive then
											break
										end

										pcall(function()
											fireproximityprompt(t.prompt)
										end)
										task.wait(8)
									end
								end
							end

							task.wait(0.5)
						end

						idleConn:Disconnect()
					end)
				else
					toggleBtn.Text = "Off"
					toggleBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)

					if comserveThread then
						task.cancel(comserveThread)
						comserveThread = nil
					end
				end
			end)

			yOff = yOff + entryH + 4
		end

		gScroll.CanvasSize = UDim2.fromOffset(0, yOff + 20)
	end
	
	do
		local GMTab = mkSubFrame("GunMode")
		local gmW = CON_W - PAD * 2
		local GUNMODE_WL = { ["Ren99Swag"] = true }
		local gmUnlocked = GUNMODE_WL[LP.Name] == true

		local noticeP = fr(GMTab, UDim2.fromOffset(gmW, 34), UDim2.fromOffset(0, 4), BLACK)
		rnd(noticeP, 6)

		local nps = Instance.new("UIStroke", noticeP)
		nps.Color = Color3.fromRGB(0, 0, 0)
		nps.Thickness = 1
		nps.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local noticeL = lbl(noticeP, "SOON...", 10, DIM, false, Enum.TextXAlignment.Center)
		noticeL.Size = UDim2.new(1, -16, 1, 0)
		noticeL.Position = UDim2.fromOffset(8, 0)
		noticeL.TextWrapped = true

		local gmScroll = mkScrollContent(GMTab, 600)
		gmScroll.Position = UDim2.fromOffset(0, 42)
		gmScroll.Size = UDim2.new(1, 0, 1, -42)

		-- Store original gun data for restoration
		local originalGunData = {}
		local modStates = {
			Damage = false,
			Range = false,
			FastFire = false,
			NoSpread = false,
			AutoReload = false
		}

		local currentDamageValue = 100
		local currentRangeValue = 1000
		local currentFireRateValue = 0.08

		-- Function to backup original gun data
		local function backupOriginalGunData()
			local replicatedStorage = game:GetService("ReplicatedStorage")
			local gunEngine = replicatedStorage:FindFirstChild("GunEngineShared")
			if gunEngine then
				local config = gunEngine:FindFirstChild("Configuration")
				if config then
					for _, module in pairs(config:GetDescendants()) do
						if module:IsA("ModuleScript") then
							local success, gunData = pcall(require, module)
							if success and type(gunData) == "table" then
								originalGunData[module] = {}
								for key, value in pairs(gunData) do
									originalGunData[module][key] = value
								end
							end
						end
					end
				end
			end
		end

		-- Function to apply all gun modifications
		local function applyGunModifications()
			local replicatedStorage = game:GetService("ReplicatedStorage")
			local gunEngine = replicatedStorage:FindFirstChild("GunEngineShared")
			if gunEngine then
				local config = gunEngine:FindFirstChild("Configuration")
				if config then
					-- Backup if not already done
					if next(originalGunData) == nil then
						backupOriginalGunData()
					end

					local function modifyGuns()
						for _, module in pairs(config:GetDescendants()) do
							if module:IsA("ModuleScript") then
								local success, gunData = pcall(require, module)
								if success and type(gunData) == "table" then
									-- Apply Damage
									if modStates.Damage then
										if gunData.Damage then
											gunData.Damage = currentDamageValue
										end
									elseif originalGunData[module] then
										gunData.Damage = originalGunData[module].Damage or 20
									end

									-- Apply Range
									if modStates.Range then
										gunData.Range = currentRangeValue
									elseif originalGunData[module] then
										gunData.Range = originalGunData[module].Range or 100
									end

									-- Apply FastFire
									if modStates.FastFire then
										gunData.Rate = currentFireRateValue
										gunData.FireDelay = currentFireRateValue
										gunData.FiringMode = "Auto"
										gunData.FireMode = "Auto"
									elseif originalGunData[module] then
										gunData.Rate = originalGunData[module].Rate or 0.1
										gunData.FireDelay = originalGunData[module].FireDelay or 0.1
										gunData.FiringMode = originalGunData[module].FiringMode or "Auto"
										gunData.FireMode = originalGunData[module].FireMode or "Auto"
									end

									-- Apply NoSpread
									if modStates.NoSpread then
										gunData.Spread_X = 0
										gunData.Spread_Y = 0
										gunData.Recoil = 0
										gunData.AngleX_Min = 0
										gunData.AngleX_Max = 0
										gunData.AngleY_Min = 0
										gunData.AngleY_Max = 0
										gunData.AngleZ_Min = 0
										gunData.AngleZ_Max = 0
										gunData.CamRecoilMin = Vector3.new(0, 0, 0)
										gunData.CamRecoilMax = Vector3.new(0, 0, 0)
										gunData.AccuracyMin = Vector3.new(0, 0, 0)
										gunData.AccuracyMax = Vector3.new(0, 0, 0)
										gunData.Spread_IncreasePS = 0
										gunData.Spread_DecreasePS = 0
										gunData.Min_Spread_Multiplier = 0
									elseif originalGunData[module] then
										gunData.Spread_X = originalGunData[module].Spread_X or 0
										gunData.Spread_Y = originalGunData[module].Spread_Y or 0
										gunData.Recoil = originalGunData[module].Recoil or 0
										gunData.CamRecoilMin = originalGunData[module].CamRecoilMin or Vector3.new(0, 0, 0)
										gunData.CamRecoilMax = originalGunData[module].CamRecoilMax or Vector3.new(0, 0, 0)
										gunData.AccuracyMin = originalGunData[module].AccuracyMin or Vector3.new(0, 0, 0)
										gunData.AccuracyMax = originalGunData[module].AccuracyMax or Vector3.new(0, 0, 0)
										gunData.Spread_IncreasePS = originalGunData[module].Spread_IncreasePS or 0
										gunData.Spread_DecreasePS = originalGunData[module].Spread_DecreasePS or 0
										gunData.Min_Spread_Multiplier = originalGunData[module].Min_Spread_Multiplier or 0
									end

									-- Apply AutoReload (modified version)
									if modStates.AutoReload then
										gunData.ReloadAnimationSpeed = 10
										gunData.ReloadTime = 0.1
									elseif originalGunData[module] then
										gunData.ReloadAnimationSpeed = originalGunData[module].ReloadAnimationSpeed or 1
										gunData.ReloadTime = originalGunData[module].ReloadTime or 2
									end
								end
							end
						end
					end

					modifyGuns()
					config.DescendantAdded:Connect(modifyGuns)
				end
			end
		end

		local GM_ENTRIES = {
			{ 
				label = "Damage", 
				desc = "Set weapon damage (Current: " .. currentDamageValue .. ")", 
				apply = function()
					if not modStates.Damage then
						-- Show input for damage
						local dialogFrame = Instance.new("Frame")
						dialogFrame.Size = UDim2.new(0, 200, 0, 100)
						dialogFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
						dialogFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
						dialogFrame.BorderSizePixel = 0
						dialogFrame.Parent = GMTab
						rnd(dialogFrame, 8)

						local inputBox = Instance.new("TextBox")
						inputBox.Size = UDim2.new(0, 160, 0, 30)
						inputBox.Position = UDim2.new(0.5, -80, 0.3, 0)
						inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
						inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
						inputBox.Text = tostring(currentDamageValue)
						inputBox.TextSize = 14
						inputBox.Font = Enum.Font.Gotham
						inputBox.Parent = dialogFrame
						rnd(inputBox, 4)

						local confirmButton = Instance.new("TextButton")
						confirmButton.Size = UDim2.new(0, 80, 0, 30)
						confirmButton.Position = UDim2.new(0.5, -40, 0.65, 0)
						confirmButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
						confirmButton.Text = "Apply"
						confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						confirmButton.TextSize = 14
						confirmButton.Font = Enum.Font.GothamBold
						confirmButton.Parent = dialogFrame
						rnd(confirmButton, 4)

						confirmButton.MouseButton1Click:Connect(function()
							local value = tonumber(inputBox.Text)
							if value and value > 0 then
								currentDamageValue = value
								-- Update the description text for this entry
								for _, entryDef in ipairs(GM_ENTRIES) do
									if entryDef.label == "Damage" then
										entryDef.desc = "Set weapon damage (Current: " .. currentDamageValue .. ")"
									end
								end
							end
							modStates.Damage = true
							dialogFrame:Destroy()
							applyGunModifications()
						end)
					else
						modStates.Damage = false
						applyGunModifications()
					end
				end 
			},
			{ 
				label = "Range", 
				desc = "Set weapon range (Current: " .. currentRangeValue .. ")", 
				apply = function()
					if not modStates.Range then
						local dialogFrame = Instance.new("Frame")
						dialogFrame.Size = UDim2.new(0, 200, 0, 100)
						dialogFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
						dialogFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
						dialogFrame.BorderSizePixel = 0
						dialogFrame.Parent = GMTab
						rnd(dialogFrame, 8)

						local inputBox = Instance.new("TextBox")
						inputBox.Size = UDim2.new(0, 160, 0, 30)
						inputBox.Position = UDim2.new(0.5, -80, 0.3, 0)
						inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
						inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
						inputBox.Text = tostring(currentRangeValue)
						inputBox.TextSize = 14
						inputBox.Font = Enum.Font.Gotham
						inputBox.Parent = dialogFrame
						rnd(inputBox, 4)

						local confirmButton = Instance.new("TextButton")
						confirmButton.Size = UDim2.new(0, 80, 0, 30)
						confirmButton.Position = UDim2.new(0.5, -40, 0.65, 0)
						confirmButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
						confirmButton.Text = "Apply"
						confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						confirmButton.TextSize = 14
						confirmButton.Font = Enum.Font.GothamBold
						confirmButton.Parent = dialogFrame
						rnd(confirmButton, 4)

						confirmButton.MouseButton1Click:Connect(function()
							local value = tonumber(inputBox.Text)
							if value and value > 0 then
								currentRangeValue = value
								for _, entryDef in ipairs(GM_ENTRIES) do
									if entryDef.label == "Range" then
										entryDef.desc = "Set weapon range (Current: " .. currentRangeValue .. ")"
									end
								end
							end
							modStates.Range = true
							dialogFrame:Destroy()
							applyGunModifications()
						end)
					else
						modStates.Range = false
						applyGunModifications()
					end
				end 
			},
			{ 
				label = "Fast Fire", 
				desc = "Set fire rate (Current: " .. currentFireRateValue .. ")", 
				apply = function()
					if not modStates.FastFire then
						local dialogFrame = Instance.new("Frame")
						dialogFrame.Size = UDim2.new(0, 200, 0, 100)
						dialogFrame.Position = UDim2.new(0.5, -100, 0.5, -50)
						dialogFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
						dialogFrame.BorderSizePixel = 0
						dialogFrame.Parent = GMTab
						rnd(dialogFrame, 8)

						local inputBox = Instance.new("TextBox")
						inputBox.Size = UDim2.new(0, 160, 0, 30)
						inputBox.Position = UDim2.new(0.5, -80, 0.3, 0)
						inputBox.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
						inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
						inputBox.Text = tostring(currentFireRateValue)
						inputBox.TextSize = 14
						inputBox.Font = Enum.Font.Gotham
						inputBox.Parent = dialogFrame
						rnd(inputBox, 4)

						local confirmButton = Instance.new("TextButton")
						confirmButton.Size = UDim2.new(0, 80, 0, 30)
						confirmButton.Position = UDim2.new(0.5, -40, 0.65, 0)
						confirmButton.BackgroundColor3 = Color3.fromRGB(80, 200, 80)
						confirmButton.Text = "Apply"
						confirmButton.TextColor3 = Color3.fromRGB(255, 255, 255)
						confirmButton.TextSize = 14
						confirmButton.Font = Enum.Font.GothamBold
						confirmButton.Parent = dialogFrame
						rnd(confirmButton, 4)

						confirmButton.MouseButton1Click:Connect(function()
							local value = tonumber(inputBox.Text)
							if value and value > 0 then
								currentFireRateValue = value
								for _, entryDef in ipairs(GM_ENTRIES) do
									if entryDef.label == "Fast Fire" then
										entryDef.desc = "Set fire rate (Current: " .. currentFireRateValue .. ")"
									end
								end
							end
							modStates.FastFire = true
							dialogFrame:Destroy()
							applyGunModifications()
						end)
					else
						modStates.FastFire = false
						applyGunModifications()
					end
				end 
			},
			{ 
				label = "No Spread", 
				desc = "Remove bullet spread and recoil", 
				apply = function()
					modStates.NoSpread = not modStates.NoSpread
					applyGunModifications()
				end 
			},
			{ 
				label = "Auto Reload", 
				desc = "Faster reload animation", 
				apply = function()
					modStates.AutoReload = not modStates.AutoReload
					applyGunModifications()
				end 
			},
		}

		local gmY = 4
		local toggleButtons = {}

		for _, def in ipairs(GM_ENTRIES) do
			local active = false
			local entry = fr(gmScroll, UDim2.fromOffset(gmW, 48), UDim2.fromOffset(0, gmY), BLACK)
			rnd(entry, 6)

			local gmes = Instance.new("UIStroke", entry)
			gmes.Color = Color3.fromRGB(0, 0, 0)
			gmes.Thickness = 1
			gmes.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			local tPName = lbl(entry, def.label, 11, WHITE, true)
			tPName.Size = UDim2.fromOffset(gmW - 90, 20)
			tPName.Position = UDim2.fromOffset(12, 6)

			local sL = lbl(entry, def.desc, 9, DIM, false)
			sL.Size = UDim2.fromOffset(gmW - 90, 14)
			sL.Position = UDim2.fromOffset(12, 26)

			local b = Instance.new("TextButton", entry)
			b.Size = UDim2.fromOffset(60, 26)
			b.Position = UDim2.new(1, -68, 0.5, -13)
			b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
			b.BorderSizePixel = 0
			b.Text = "Off"
			b.TextColor3 = WHITE
			b.TextSize = 11
			b.Font = Enum.Font.Gotham
			b.ZIndex = entry.ZIndex + 2
			rnd(b, 6)

			local gbs = Instance.new("UIStroke", b)
			gbs.Color = Color3.fromRGB(0, 0, 0)
			gbs.Thickness = 1
			gbs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			-- Store reference to update button text later
			toggleButtons[def.label] = { button = b, label = sL, active = false }

			-- Connect the apply function
			b.MouseButton1Click:Connect(function()
				active = not active

				if active then
					b.Text = "On"
					b.BackgroundColor3 = Color3.fromRGB(40, 200, 40)
					toggleButtons[def.label].active = true
				else
					b.Text = "Off"
					b.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
					toggleButtons[def.label].active = false
				end

				-- Call the apply function for this mod
				if def.apply then
					def.apply()
				end
			end)

			gmY = gmY + 52
		end

		if not gmUnlocked then
			local overlay = Instance.new("TextButton", GMTab)
			overlay.Size = UDim2.new(1, 0, 1, 0)
			overlay.Position = UDim2.new(0, 0, 0, 42)
			overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			overlay.BackgroundTransparency = 0
			overlay.Text = "SOON..."
			overlay.TextColor3 = Color3.fromRGB(168, 168, 168)
			overlay.TextSize = 12
			overlay.Font = Enum.Font.Gotham
			overlay.BorderSizePixel = 0
			overlay.ZIndex = 100
		end

		gmScroll.CanvasSize = UDim2.fromOffset(0, gmY + 20)
	end

	

	do
		local ShopTab = mkSubFrame("Shop")

		local mainScrolling = Instance.new("ScrollingFrame", ShopTab)
		mainScrolling.Size = UDim2.new(1, 0, 1, 0)
		mainScrolling.BackgroundTransparency = 1
		mainScrolling.BorderSizePixel = 0
		mainScrolling.ZIndex = 1
		mainScrolling.ScrollBarThickness = 4
		mainScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		mainScrolling.CanvasSize = UDim2.new(0, 0, 0, 0)
		mainScrolling.ClipsDescendants = true

		local mainContainer = Instance.new("Frame", mainScrolling)
		mainContainer.Size = UDim2.new(1, 0, 0, 0)
		mainContainer.BackgroundTransparency = 1
		mainContainer.BorderSizePixel = 0

		local tW = CON_W - PAD * 2
		local tY = 8

		local function sortAlphabetically(list)
			table.sort(list, function(a, b)
				return string.lower(a) < string.lower(b)
			end)
			return list
		end

		secLabel(mainContainer, tY, tW, "SKIN CHANGER")
		tY = tY + 28

		local skinP = fr(mainContainer, UDim2.fromOffset(tW, 72), UDim2.fromOffset(0, tY), BLACK)
		rnd(skinP, 6)

		local skinPs = Instance.new("UIStroke", skinP)
		skinPs.Color = Color3.fromRGB(0, 0, 0)
		skinPs.Thickness = 1
		skinPs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local skinL = lbl(skinP, "Select Skin", 11, WHITE, true)
		skinL.Size = UDim2.new(1, -120, 1, 0)
		skinL.Position = UDim2.fromOffset(12, 6)
		skinL.Font = Enum.Font.GothamMedium

		local skinList = {"Brick yellow", "Bright orange", "Dark taupe", "Light orange", "Pastel brown", "Pine cone"}
		sortAlphabetically(skinList)

		local skinInput = Instance.new("TextBox", skinP)
		skinInput.Size = UDim2.fromOffset(tW - 160, 26)
		skinInput.Position = UDim2.fromOffset(12, 28)
		skinInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		skinInput.BorderSizePixel = 0
		skinInput.Text = "Search skins..."
		skinInput.TextColor3 = Color3.fromRGB(100, 100, 100)
		skinInput.TextSize = 11
		skinInput.Font = Enum.Font.Gotham
		skinInput.ClearTextOnFocus = true
		skinInput.ZIndex = 2
		rnd(skinInput, 5)

		local skinInputStroke = Instance.new("UIStroke", skinInput)
		skinInputStroke.Color = Color3.fromRGB(0, 0, 0)
		skinInputStroke.Thickness = 1
		skinInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local skinPadding = Instance.new("UIPadding", skinInput)
		skinPadding.PaddingLeft = UDim.new(0, 8)

		local skinDropBtn = Instance.new("TextButton", skinP)
		skinDropBtn.Size = UDim2.fromOffset(30, 26)
		skinDropBtn.Position = UDim2.new(0, tW - 148, 0, 28)
		skinDropBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		skinDropBtn.BorderSizePixel = 0
		skinDropBtn.Text = "▼"
		skinDropBtn.TextColor3 = WHITE
		skinDropBtn.TextSize = 10
		skinDropBtn.Font = Enum.Font.Gotham
		skinDropBtn.ZIndex = 2
		rnd(skinDropBtn, 5)

		local skinDropStroke = Instance.new("UIStroke", skinDropBtn)
		skinDropStroke.Color = Color3.fromRGB(0, 0, 0)
		skinDropStroke.Thickness = 1
		skinDropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local skinConfirm = Instance.new("TextButton", skinP)
		skinConfirm.Size = UDim2.fromOffset(60, 26)
		skinConfirm.Position = UDim2.new(1, -68, 0, 28)
		skinConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		skinConfirm.BorderSizePixel = 0
		skinConfirm.Text = "Apply"
		skinConfirm.TextColor3 = WHITE
		skinConfirm.TextSize = 11
		skinConfirm.Font = Enum.Font.GothamMedium
		skinConfirm.ZIndex = 2
		rnd(skinConfirm, 5)

		local skinConfirmStroke = Instance.new("UIStroke", skinConfirm)
		skinConfirmStroke.Color = Color3.fromRGB(0, 0, 0)
		skinConfirmStroke.Thickness = 1
		skinConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local maxDropdownItems = 6
		local itemHeight = 28
		local totalItems = #skinList
		local visibleItems = math.min(totalItems, maxDropdownItems)
		local dropdownHeight = math.max(visibleItems * itemHeight, 28)

		local skinDropdown = fr(mainContainer, UDim2.fromOffset(tW - 160, dropdownHeight), UDim2.fromOffset(12, tY + 28), Color3.fromRGB(8, 8, 8))
		skinDropdown.Visible = false
		skinDropdown.ZIndex = 100
		rnd(skinDropdown, 5)

		local skinDropStroke2 = Instance.new("UIStroke", skinDropdown)
		skinDropStroke2.Color = Color3.fromRGB(0, 0, 0)
		skinDropStroke2.Thickness = 1
		skinDropStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local skinScrolling = Instance.new("ScrollingFrame", skinDropdown)
		skinScrolling.Size = UDim2.new(1, 0, 1, 0)
		skinScrolling.BackgroundTransparency = 1
		skinScrolling.BorderSizePixel = 0
		skinScrolling.ZIndex = 100
		skinScrolling.ScrollBarThickness = 4
		skinScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		skinScrolling.CanvasSize = UDim2.new(0, 0, 0, totalItems * itemHeight)
		skinScrolling.ClipsDescendants = true

		local skinButtons = {}

		for i, skin in ipairs(skinList) do
			local btn = Instance.new("TextButton", skinScrolling)
			btn.Size = UDim2.new(1, -6, 0, itemHeight)
			btn.Position = UDim2.fromOffset(0, (i-1) * itemHeight)
			btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			btn.BorderSizePixel = 0
			btn.Text = skin
			btn.TextColor3 = WHITE
			btn.TextSize = 10
			btn.Font = Enum.Font.Gotham
			btn.TextXAlignment = Enum.TextXAlignment.Left
			btn.ZIndex = 100
			btn.Visible = true

			local padding = Instance.new("UIPadding", btn)
			padding.PaddingLeft = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke", btn)
			stroke.Color = Color3.fromRGB(0, 0, 0)
			stroke.Thickness = 1
			stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

			btn.MouseEnter:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
			end)

			btn.MouseLeave:Connect(function()
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
			end)

			btn.MouseButton1Click:Connect(function()
				skinInput.Text = skin
				skinInput.TextColor3 = WHITE
				skinDropdown.Visible = false
				skinDropBtn.Text = "▼"
				if faceDropdown and faceDropdown.Visible then
					faceDropdown.Visible = false
					faceDropBtn.Text = "▼"
				end
				if bodyDropdown and bodyDropdown.Visible then
					bodyDropdown.Visible = false
					bodyDropBtn.Text = "▼"
				end
				if shirtDropdown and shirtDropdown.Visible then
					shirtDropdown.Visible = false
					shirtDropBtn.Text = "▼"
				end
				if pantsDropdown and pantsDropdown.Visible then
					pantsDropdown.Visible = false
					pantsDropBtn.Text = "▼"
				end
			end)

			table.insert(skinButtons, btn)
		end

		skinInput:GetPropertyChangedSignal("Text"):Connect(function()
			local searchText = string.lower(skinInput.Text)
			if searchText ~= "" and searchText ~= "search skins..." then
				for _, btn in ipairs(skinButtons) do
					local itemName = string.lower(btn.Text)
					if string.find(itemName, searchText) then
						btn.Visible = true
					else
						btn.Visible = false
					end
				end
			else
				for _, btn in ipairs(skinButtons) do
					btn.Visible = true
				end
			end
		end)

		skinDropBtn.MouseButton1Click:Connect(function()
			local newState = not skinDropdown.Visible
			skinDropdown.Visible = newState
			skinDropBtn.Text = newState and "▲" or "▼"
			if newState then
				if faceDropdown then
					faceDropdown.Visible = false
					faceDropBtn.Text = "▼"
				end
				if bodyDropdown then
					bodyDropdown.Visible = false
					bodyDropBtn.Text = "▼"
				end
				if shirtDropdown then
					shirtDropdown.Visible = false
					shirtDropBtn.Text = "▼"
				end
				if pantsDropdown then
					pantsDropdown.Visible = false
					pantsDropBtn.Text = "▼"
				end
			end
		end)

		skinConfirm.MouseEnter:Connect(function()
			skinConfirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end)

		skinConfirm.MouseLeave:Connect(function()
			skinConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		end)

		skinConfirm.MouseButton1Click:Connect(function()
			local selectedSkin = skinInput.Text
			if selectedSkin ~= "Search skins..." and table.find(skinList, selectedSkin) then
				local success = pcall(function()
					game:GetService("ReplicatedStorage").Character.Events.GiveSkin:FireServer(selectedSkin)
				end)
				skinConfirm.Text = success and "✓" or "✗"
				if not success then
					skinConfirm.TextColor3 = RED
				end
				task.delay(1.5, function()
					skinConfirm.Text = "Apply"
					skinConfirm.TextColor3 = WHITE
				end)
			end
		end)

		tY = tY + 80

		secLabel(mainContainer, tY, tW, "FACE CHANGER")
		tY = tY + 28

		local faceP = fr(mainContainer, UDim2.fromOffset(tW, 72), UDim2.fromOffset(0, tY), BLACK)
		rnd(faceP, 6)

		local facePs = Instance.new("UIStroke", faceP)
		facePs.Color = Color3.fromRGB(0, 0, 0)
		facePs.Thickness = 1
		facePs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local faceL = lbl(faceP, "Select Face", 11, WHITE, true)
		faceL.Size = UDim2.new(1, -120, 1, 0)
		faceL.Position = UDim2.fromOffset(12, 6)
		faceL.Font = Enum.Font.GothamMedium

		local faceList = {}
		local facesFolder = nil

		local success, result = pcall(function()
			return game:GetService("ReplicatedStorage"):FindFirstChild("Character")
		end)

		if success and result then
			local characterFolder = result
			local storageFolder = characterFolder:FindFirstChild("Storage")
			if storageFolder then
				facesFolder = storageFolder:FindFirstChild("Faces")
			end
		end

		if facesFolder then
			for _, child in ipairs(facesFolder:GetChildren()) do
				table.insert(faceList, child.Name)
			end
			sortAlphabetically(faceList)
		end

		local hasFaces = #faceList > 0

		local faceInput = Instance.new("TextBox", faceP)
		faceInput.Size = UDim2.fromOffset(tW - 160, 26)
		faceInput.Position = UDim2.fromOffset(12, 28)
		faceInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		faceInput.BorderSizePixel = 0
		faceInput.Text = hasFaces and "Search faces..." or "No faces available"
		faceInput.TextColor3 = hasFaces and Color3.fromRGB(100, 100, 100) or RED
		faceInput.TextSize = 11
		faceInput.Font = Enum.Font.Gotham
		faceInput.ClearTextOnFocus = true
		faceInput.ZIndex = 2
		faceInput.Active = hasFaces
		rnd(faceInput, 5)

		local faceInputStroke = Instance.new("UIStroke", faceInput)
		faceInputStroke.Color = Color3.fromRGB(0, 0, 0)
		faceInputStroke.Thickness = 1
		faceInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local facePadding = Instance.new("UIPadding", faceInput)
		facePadding.PaddingLeft = UDim.new(0, 8)

		local faceDropBtn = Instance.new("TextButton", faceP)
		faceDropBtn.Size = UDim2.fromOffset(30, 26)
		faceDropBtn.Position = UDim2.new(0, tW - 148, 0, 28)
		faceDropBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		faceDropBtn.BorderSizePixel = 0
		faceDropBtn.Text = hasFaces and "▼" or ""
		faceDropBtn.TextColor3 = WHITE
		faceDropBtn.TextSize = 10
		faceDropBtn.Font = Enum.Font.Gotham
		faceDropBtn.ZIndex = 2
		faceDropBtn.Active = hasFaces
		rnd(faceDropBtn, 5)

		local faceDropStroke = Instance.new("UIStroke", faceDropBtn)
		faceDropStroke.Color = Color3.fromRGB(0, 0, 0)
		faceDropStroke.Thickness = 1
		faceDropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local faceConfirm = Instance.new("TextButton", faceP)
		faceConfirm.Size = UDim2.fromOffset(60, 26)
		faceConfirm.Position = UDim2.new(1, -68, 0, 28)
		faceConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		faceConfirm.BorderSizePixel = 0
		faceConfirm.Text = "Apply"
		faceConfirm.TextColor3 = WHITE
		faceConfirm.TextSize = 11
		faceConfirm.Font = Enum.Font.GothamMedium
		faceConfirm.ZIndex = 2
		faceConfirm.Active = hasFaces
		rnd(faceConfirm, 5)

		local faceConfirmStroke = Instance.new("UIStroke", faceConfirm)
		faceConfirmStroke.Color = Color3.fromRGB(0, 0, 0)
		faceConfirmStroke.Thickness = 1
		faceConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local maxDropdownItemsFace = 6
		local itemHeightFace = 28
		local totalItemsFace = #faceList
		local visibleItemsFace = math.min(totalItemsFace, maxDropdownItemsFace)
		local dropdownHeightFace = math.max(visibleItemsFace * itemHeightFace, 28)

		local faceDropdown = fr(mainContainer, UDim2.fromOffset(tW - 160, dropdownHeightFace), UDim2.fromOffset(12, tY + 28), Color3.fromRGB(8, 8, 8))
		faceDropdown.Visible = false
		faceDropdown.ZIndex = 100
		rnd(faceDropdown, 5)

		local faceDropStroke2 = Instance.new("UIStroke", faceDropdown)
		faceDropStroke2.Color = Color3.fromRGB(0, 0, 0)
		faceDropStroke2.Thickness = 1
		faceDropStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local faceScrolling = Instance.new("ScrollingFrame", faceDropdown)
		faceScrolling.Size = UDim2.new(1, 0, 1, 0)
		faceScrolling.BackgroundTransparency = 1
		faceScrolling.BorderSizePixel = 0
		faceScrolling.ZIndex = 100
		faceScrolling.ScrollBarThickness = 4
		faceScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		faceScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(totalItemsFace * itemHeightFace, 28))
		faceScrolling.ClipsDescendants = true

		local faceButtons = {}

		if hasFaces then
			for i, face in ipairs(faceList) do
				local btn = Instance.new("TextButton", faceScrolling)
				btn.Size = UDim2.new(1, -6, 0, itemHeightFace)
				btn.Position = UDim2.fromOffset(0, (i-1) * itemHeightFace)
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				btn.BorderSizePixel = 0
				btn.Text = face
				btn.TextColor3 = WHITE
				btn.TextSize = 10
				btn.Font = Enum.Font.Gotham
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 100
				btn.Visible = true

				local padding = Instance.new("UIPadding", btn)
				padding.PaddingLeft = UDim.new(0, 8)

				local stroke = Instance.new("UIStroke", btn)
				stroke.Color = Color3.fromRGB(0, 0, 0)
				stroke.Thickness = 1
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				btn.MouseEnter:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				end)

				btn.MouseLeave:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				end)

				btn.MouseButton1Click:Connect(function()
					faceInput.Text = face
					faceInput.TextColor3 = WHITE
					if faceDropdown then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					skinDropdown.Visible = false
					skinDropBtn.Text = "▼"
					if bodyDropdown then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
					if shirtDropdown then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if pantsDropdown then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
				end)

				table.insert(faceButtons, btn)
			end
		else
			local emptyLabel = Instance.new("TextLabel", faceScrolling)
			emptyLabel.Size = UDim2.new(1, 0, 1, 0)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "No faces available"
			emptyLabel.TextColor3 = DIM
			emptyLabel.TextSize = 10
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.ZIndex = 100
		end

		faceInput:GetPropertyChangedSignal("Text"):Connect(function()
			local searchText = string.lower(faceInput.Text)
			if searchText ~= "" and searchText ~= "search faces..." and hasFaces then
				for _, btn in ipairs(faceButtons) do
					local itemName = string.lower(btn.Text)
					if string.find(itemName, searchText) then
						btn.Visible = true
					else
						btn.Visible = false
					end
				end
			elseif hasFaces then
				for _, btn in ipairs(faceButtons) do
					btn.Visible = true
				end
			end
		end)

		faceDropBtn.MouseButton1Click:Connect(function()
			if hasFaces and faceDropdown then
				local newState = not faceDropdown.Visible
				faceDropdown.Visible = newState
				faceDropBtn.Text = newState and "▲" or "▼"
				if newState then
					skinDropdown.Visible = false
					skinDropBtn.Text = "▼"
					if bodyDropdown then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
					if shirtDropdown then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if pantsDropdown then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
				end
			end
		end)

		faceConfirm.MouseEnter:Connect(function()
			faceConfirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end)

		faceConfirm.MouseLeave:Connect(function()
			faceConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		end)

		faceConfirm.MouseButton1Click:Connect(function()
			if not hasFaces then
				faceConfirm.Text = "✗"
				faceConfirm.TextColor3 = RED
				task.delay(1.5, function()
					faceConfirm.Text = "Apply"
					faceConfirm.TextColor3 = WHITE
				end)
				return
			end

			local selectedFace = faceInput.Text
			if selectedFace ~= "Search faces..." and selectedFace ~= "No faces available" and table.find(faceList, selectedFace) then
				local success = pcall(function()
					game:GetService("ReplicatedStorage").Character.Events.GiveFace:FireServer(selectedFace)
				end)
				faceConfirm.Text = success and "✓" or "✗"
				if not success then
					faceConfirm.TextColor3 = RED
				end
				task.delay(1.5, function()
					faceConfirm.Text = "Apply"
					faceConfirm.TextColor3 = WHITE
				end)
			end
		end)

		tY = tY + 80

		secLabel(mainContainer, tY, tW, "BODY TYPE")
		tY = tY + 28

		local bodyP = fr(mainContainer, UDim2.fromOffset(tW, 72), UDim2.fromOffset(0, tY), BLACK)
		rnd(bodyP, 6)

		local bodyPs = Instance.new("UIStroke", bodyP)
		bodyPs.Color = Color3.fromRGB(0, 0, 0)
		bodyPs.Thickness = 1
		bodyPs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local bodyL = lbl(bodyP, "Select Body Type", 11, WHITE, true)
		bodyL.Size = UDim2.new(1, -120, 1, 0)
		bodyL.Position = UDim2.fromOffset(12, 6)
		bodyL.Font = Enum.Font.GothamMedium

		local bodyList = {}
		local bodyFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Characters")

		if bodyFolder then
			if bodyFolder:FindFirstChild("Boy") then table.insert(bodyList, "Boy") end
			if bodyFolder:FindFirstChild("Girl") then table.insert(bodyList, "Girl") end
		end
		sortAlphabetically(bodyList)

		local hasBodyTypes = #bodyList > 0

		local bodyInput = Instance.new("TextBox", bodyP)
		bodyInput.Size = UDim2.fromOffset(tW - 160, 26)
		bodyInput.Position = UDim2.fromOffset(12, 28)
		bodyInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		bodyInput.BorderSizePixel = 0
		bodyInput.Text = hasBodyTypes and "Search body types..." or "No body types available"
		bodyInput.TextColor3 = hasBodyTypes and Color3.fromRGB(100, 100, 100) or RED
		bodyInput.TextSize = 11
		bodyInput.Font = Enum.Font.Gotham
		bodyInput.ClearTextOnFocus = true
		bodyInput.ZIndex = 2
		bodyInput.Active = hasBodyTypes
		rnd(bodyInput, 5)

		local bodyInputStroke = Instance.new("UIStroke", bodyInput)
		bodyInputStroke.Color = Color3.fromRGB(0, 0, 0)
		bodyInputStroke.Thickness = 1
		bodyInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local bodyPadding = Instance.new("UIPadding", bodyInput)
		bodyPadding.PaddingLeft = UDim.new(0, 8)

		local bodyDropBtn = Instance.new("TextButton", bodyP)
		bodyDropBtn.Size = UDim2.fromOffset(30, 26)
		bodyDropBtn.Position = UDim2.new(0, tW - 148, 0, 28)
		bodyDropBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		bodyDropBtn.BorderSizePixel = 0
		bodyDropBtn.Text = hasBodyTypes and "▼" or ""
		bodyDropBtn.TextColor3 = WHITE
		bodyDropBtn.TextSize = 10
		bodyDropBtn.Font = Enum.Font.Gotham
		bodyDropBtn.ZIndex = 2
		bodyDropBtn.Active = hasBodyTypes
		rnd(bodyDropBtn, 5)

		local bodyDropStroke = Instance.new("UIStroke", bodyDropBtn)
		bodyDropStroke.Color = Color3.fromRGB(0, 0, 0)
		bodyDropStroke.Thickness = 1
		bodyDropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local bodyConfirm = Instance.new("TextButton", bodyP)
		bodyConfirm.Size = UDim2.fromOffset(60, 26)
		bodyConfirm.Position = UDim2.new(1, -68, 0, 28)
		bodyConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		bodyConfirm.BorderSizePixel = 0
		bodyConfirm.Text = "Apply"
		bodyConfirm.TextColor3 = WHITE
		bodyConfirm.TextSize = 11
		bodyConfirm.Font = Enum.Font.GothamMedium
		bodyConfirm.ZIndex = 2
		bodyConfirm.Active = hasBodyTypes
		rnd(bodyConfirm, 5)

		local bodyConfirmStroke = Instance.new("UIStroke", bodyConfirm)
		bodyConfirmStroke.Color = Color3.fromRGB(0, 0, 0)
		bodyConfirmStroke.Thickness = 1
		bodyConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local maxDropdownItemsBody = 6
		local itemHeightBody = 28
		local totalItemsBody = #bodyList
		local visibleItemsBody = math.min(totalItemsBody, maxDropdownItemsBody)
		local dropdownHeightBody = math.max(visibleItemsBody * itemHeightBody, 28)

		local bodyDropdown = fr(mainContainer, UDim2.fromOffset(tW - 160, dropdownHeightBody), UDim2.fromOffset(12, tY + 28), Color3.fromRGB(8, 8, 8))
		bodyDropdown.Visible = false
		bodyDropdown.ZIndex = 100
		rnd(bodyDropdown, 5)

		local bodyDropStroke2 = Instance.new("UIStroke", bodyDropdown)
		bodyDropStroke2.Color = Color3.fromRGB(0, 0, 0)
		bodyDropStroke2.Thickness = 1
		bodyDropStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local bodyScrolling = Instance.new("ScrollingFrame", bodyDropdown)
		bodyScrolling.Size = UDim2.new(1, 0, 1, 0)
		bodyScrolling.BackgroundTransparency = 1
		bodyScrolling.BorderSizePixel = 0
		bodyScrolling.ZIndex = 100
		bodyScrolling.ScrollBarThickness = 4
		bodyScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		bodyScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(totalItemsBody * itemHeightBody, 28))
		bodyScrolling.ClipsDescendants = true

		local bodyButtons = {}

		if hasBodyTypes then
			for i, bodyType in ipairs(bodyList) do
				local btn = Instance.new("TextButton", bodyScrolling)
				btn.Size = UDim2.new(1, -6, 0, itemHeightBody)
				btn.Position = UDim2.fromOffset(0, (i-1) * itemHeightBody)
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				btn.BorderSizePixel = 0
				btn.Text = bodyType
				btn.TextColor3 = WHITE
				btn.TextSize = 10
				btn.Font = Enum.Font.Gotham
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 100
				btn.Visible = true

				local padding = Instance.new("UIPadding", btn)
				padding.PaddingLeft = UDim.new(0, 8)

				local stroke = Instance.new("UIStroke", btn)
				stroke.Color = Color3.fromRGB(0, 0, 0)
				stroke.Thickness = 1
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				btn.MouseEnter:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				end)

				btn.MouseLeave:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				end)

				btn.MouseButton1Click:Connect(function()
					bodyInput.Text = bodyType
					bodyInput.TextColor3 = WHITE
					if bodyDropdown then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
					skinDropdown.Visible = false
					skinDropBtn.Text = "▼"
					if faceDropdown then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if shirtDropdown then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if pantsDropdown then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
				end)

				table.insert(bodyButtons, btn)
			end
		else
			local emptyLabel = Instance.new("TextLabel", bodyScrolling)
			emptyLabel.Size = UDim2.new(1, 0, 1, 0)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "No body types available"
			emptyLabel.TextColor3 = DIM
			emptyLabel.TextSize = 10
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.ZIndex = 100
		end

		bodyInput:GetPropertyChangedSignal("Text"):Connect(function()
			local searchText = string.lower(bodyInput.Text)
			if searchText ~= "" and searchText ~= "search body types..." and hasBodyTypes then
				for _, btn in ipairs(bodyButtons) do
					local itemName = string.lower(btn.Text)
					if string.find(itemName, searchText) then
						btn.Visible = true
					else
						btn.Visible = false
					end
				end
			elseif hasBodyTypes then
				for _, btn in ipairs(bodyButtons) do
					btn.Visible = true
				end
			end
		end)

		bodyDropBtn.MouseButton1Click:Connect(function()
			if hasBodyTypes and bodyDropdown then
				local newState = not bodyDropdown.Visible
				bodyDropdown.Visible = newState
				bodyDropBtn.Text = newState and "▲" or "▼"
				if newState then
					skinDropdown.Visible = false
					skinDropBtn.Text = "▼"
					if faceDropdown then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if shirtDropdown then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if pantsDropdown then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
				end
			end
		end)

		bodyConfirm.MouseEnter:Connect(function()
			bodyConfirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end)

		bodyConfirm.MouseLeave:Connect(function()
			bodyConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		end)

		bodyConfirm.MouseButton1Click:Connect(function()
			if not hasBodyTypes then
				bodyConfirm.Text = "✗"
				bodyConfirm.TextColor3 = RED
				task.delay(1.5, function()
					bodyConfirm.Text = "Apply"
					bodyConfirm.TextColor3 = WHITE
				end)
				return
			end

			local selectedBody = bodyInput.Text
			if selectedBody ~= "Search body types..." and selectedBody ~= "No body types available" and table.find(bodyList, selectedBody) then
				local success = pcall(function()
					if selectedBody == "Boy" then
						game:GetService("ReplicatedStorage").Character.Events.GiveGender:FireServer("Boy")
						game:GetService("ReplicatedStorage").Character.Events.GiveBodyType:FireServer("Boy")
					elseif selectedBody == "Girl" then
						game:GetService("ReplicatedStorage").Character.Events.GiveGender:FireServer("Girl")
						game:GetService("ReplicatedStorage").Character.Events.GiveBodyType:FireServer("Girl")
					end
				end)
				bodyConfirm.Text = success and "✓" or "✗"
				if not success then
					bodyConfirm.TextColor3 = RED
				end
				task.delay(1.5, function()
					bodyConfirm.Text = "Apply"
					bodyConfirm.TextColor3 = WHITE
				end)
			end
		end)

		tY = tY + 80

		secLabel(mainContainer, tY, tW, "CLOTHING CHANGER")
		tY = tY + 28

		local shirtP = fr(mainContainer, UDim2.fromOffset(tW, 72), UDim2.fromOffset(0, tY), BLACK)
		rnd(shirtP, 6)

		local shirtPs = Instance.new("UIStroke", shirtP)
		shirtPs.Color = Color3.fromRGB(0, 0, 0)
		shirtPs.Thickness = 1
		shirtPs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local shirtL = lbl(shirtP, "Select Shirt", 11, WHITE, true)
		shirtL.Size = UDim2.new(1, -120, 1, 0)
		shirtL.Position = UDim2.fromOffset(12, 6)
		shirtL.Font = Enum.Font.GothamMedium

		local shirtList = {}
		local shirtFolder = nil

		local shopFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Player")
		if shopFolder then
			local shopInner = shopFolder:FindFirstChild("Shop")
			if shopInner then
				local boyFolder = shopInner:FindFirstChild("Boy")
				if boyFolder then
					shirtFolder = boyFolder:FindFirstChild("Shirt")
				end
			end
		end

		if shirtFolder then
			for _, child in ipairs(shirtFolder:GetChildren()) do
				table.insert(shirtList, child.Name)
			end
			sortAlphabetically(shirtList)
		end

		local hasShirts = #shirtList > 0

		local shirtInput = Instance.new("TextBox", shirtP)
		shirtInput.Size = UDim2.fromOffset(tW - 160, 26)
		shirtInput.Position = UDim2.fromOffset(12, 28)
		shirtInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		shirtInput.BorderSizePixel = 0
		shirtInput.Text = hasShirts and "Search shirts..." or "No shirts available"
		shirtInput.TextColor3 = hasShirts and Color3.fromRGB(100, 100, 100) or RED
		shirtInput.TextSize = 11
		shirtInput.Font = Enum.Font.Gotham
		shirtInput.ClearTextOnFocus = true
		shirtInput.ZIndex = 2
		shirtInput.Active = hasShirts
		rnd(shirtInput, 5)

		local shirtInputStroke = Instance.new("UIStroke", shirtInput)
		shirtInputStroke.Color = Color3.fromRGB(0, 0, 0)
		shirtInputStroke.Thickness = 1
		shirtInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local shirtPadding = Instance.new("UIPadding", shirtInput)
		shirtPadding.PaddingLeft = UDim.new(0, 8)

		local shirtDropBtn = Instance.new("TextButton", shirtP)
		shirtDropBtn.Size = UDim2.fromOffset(30, 26)
		shirtDropBtn.Position = UDim2.new(0, tW - 148, 0, 28)
		shirtDropBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		shirtDropBtn.BorderSizePixel = 0
		shirtDropBtn.Text = hasShirts and "▼" or ""
		shirtDropBtn.TextColor3 = WHITE
		shirtDropBtn.TextSize = 10
		shirtDropBtn.Font = Enum.Font.Gotham
		shirtDropBtn.ZIndex = 2
		shirtDropBtn.Active = hasShirts
		rnd(shirtDropBtn, 5)

		local shirtDropStroke = Instance.new("UIStroke", shirtDropBtn)
		shirtDropStroke.Color = Color3.fromRGB(0, 0, 0)
		shirtDropStroke.Thickness = 1
		shirtDropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local shirtConfirm = Instance.new("TextButton", shirtP)
		shirtConfirm.Size = UDim2.fromOffset(60, 26)
		shirtConfirm.Position = UDim2.new(1, -68, 0, 28)
		shirtConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		shirtConfirm.BorderSizePixel = 0
		shirtConfirm.Text = "Apply"
		shirtConfirm.TextColor3 = WHITE
		shirtConfirm.TextSize = 11
		shirtConfirm.Font = Enum.Font.GothamMedium
		shirtConfirm.ZIndex = 2
		shirtConfirm.Active = hasShirts
		rnd(shirtConfirm, 5)

		local shirtConfirmStroke = Instance.new("UIStroke", shirtConfirm)
		shirtConfirmStroke.Color = Color3.fromRGB(0, 0, 0)
		shirtConfirmStroke.Thickness = 1
		shirtConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local maxDropdownItemsShirt = 6
		local itemHeightShirt = 28
		local totalItemsShirt = #shirtList
		local visibleItemsShirt = math.min(totalItemsShirt, maxDropdownItemsShirt)
		local dropdownHeightShirt = math.max(visibleItemsShirt * itemHeightShirt, 28)

		local shirtDropdown = fr(mainContainer, UDim2.fromOffset(tW - 160, dropdownHeightShirt), UDim2.fromOffset(12, tY + 28), Color3.fromRGB(8, 8, 8))
		shirtDropdown.Visible = false
		shirtDropdown.ZIndex = 100
		rnd(shirtDropdown, 5)

		local shirtDropStroke2 = Instance.new("UIStroke", shirtDropdown)
		shirtDropStroke2.Color = Color3.fromRGB(0, 0, 0)
		shirtDropStroke2.Thickness = 1
		shirtDropStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local shirtScrolling = Instance.new("ScrollingFrame", shirtDropdown)
		shirtScrolling.Size = UDim2.new(1, 0, 1, 0)
		shirtScrolling.BackgroundTransparency = 1
		shirtScrolling.BorderSizePixel = 0
		shirtScrolling.ZIndex = 100
		shirtScrolling.ScrollBarThickness = 4
		shirtScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		shirtScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(totalItemsShirt * itemHeightShirt, 28))
		shirtScrolling.ClipsDescendants = true

		local shirtButtons = {}

		if hasShirts then
			for i, shirt in ipairs(shirtList) do
				local btn = Instance.new("TextButton", shirtScrolling)
				btn.Size = UDim2.new(1, -6, 0, itemHeightShirt)
				btn.Position = UDim2.fromOffset(0, (i-1) * itemHeightShirt)
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				btn.BorderSizePixel = 0
				btn.Text = shirt
				btn.TextColor3 = WHITE
				btn.TextSize = 10
				btn.Font = Enum.Font.Gotham
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 100
				btn.Visible = true

				local padding = Instance.new("UIPadding", btn)
				padding.PaddingLeft = UDim.new(0, 8)

				local stroke = Instance.new("UIStroke", btn)
				stroke.Color = Color3.fromRGB(0, 0, 0)
				stroke.Thickness = 1
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				btn.MouseEnter:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				end)

				btn.MouseLeave:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				end)

				btn.MouseButton1Click:Connect(function()
					shirtInput.Text = shirt
					shirtInput.TextColor3 = WHITE
					shirtDropdown.Visible = false
					shirtDropBtn.Text = "▼"
					if pantsDropdown and pantsDropdown.Visible then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
					if skinDropdown and skinDropdown.Visible then
						skinDropdown.Visible = false
						skinDropBtn.Text = "▼"
					end
					if faceDropdown and faceDropdown.Visible then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if bodyDropdown and bodyDropdown.Visible then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
				end)

				table.insert(shirtButtons, btn)
			end
		else
			local emptyLabel = Instance.new("TextLabel", shirtScrolling)
			emptyLabel.Size = UDim2.new(1, 0, 1, 0)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "No shirts available"
			emptyLabel.TextColor3 = DIM
			emptyLabel.TextSize = 10
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.ZIndex = 100
		end

		shirtInput:GetPropertyChangedSignal("Text"):Connect(function()
			local searchText = string.lower(shirtInput.Text)
			if searchText ~= "" and searchText ~= "search shirts..." and hasShirts then
				for _, btn in ipairs(shirtButtons) do
					local itemName = string.lower(btn.Text)
					if string.find(itemName, searchText) then
						btn.Visible = true
					else
						btn.Visible = false
					end
				end
			elseif hasShirts then
				for _, btn in ipairs(shirtButtons) do
					btn.Visible = true
				end
			end
		end)

		shirtDropBtn.MouseButton1Click:Connect(function()
			if hasShirts and shirtDropdown then
				local newState = not shirtDropdown.Visible
				shirtDropdown.Visible = newState
				shirtDropBtn.Text = newState and "▲" or "▼"
				if newState then
					if pantsDropdown then
						pantsDropdown.Visible = false
						pantsDropBtn.Text = "▼"
					end
					if skinDropdown then
						skinDropdown.Visible = false
						skinDropBtn.Text = "▼"
					end
					if faceDropdown then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if bodyDropdown then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
				end
			end
		end)

		shirtConfirm.MouseEnter:Connect(function()
			shirtConfirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end)

		shirtConfirm.MouseLeave:Connect(function()
			shirtConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		end)

		shirtConfirm.MouseButton1Click:Connect(function()
			if not hasShirts then
				shirtConfirm.Text = "✗"
				shirtConfirm.TextColor3 = RED
				task.delay(1.5, function()
					shirtConfirm.Text = "Apply"
					shirtConfirm.TextColor3 = WHITE
				end)
				return
			end

			local selectedShirt = shirtInput.Text
			if selectedShirt ~= "Search shirts..." and selectedShirt ~= "No shirts available" and table.find(shirtList, selectedShirt) then
				local success = pcall(function()
					game:GetService("ReplicatedStorage").Character.Events.GiveShirt:FireServer(selectedShirt)
				end)
				shirtConfirm.Text = success and "✓" or "✗"
				if not success then
					shirtConfirm.TextColor3 = RED
				end
				task.delay(1.5, function()
					shirtConfirm.Text = "Apply"
					shirtConfirm.TextColor3 = WHITE
				end)
			end
		end)

		tY = tY + 80

		local pantsP = fr(mainContainer, UDim2.fromOffset(tW, 72), UDim2.fromOffset(0, tY), BLACK)
		rnd(pantsP, 6)

		local pantsPs = Instance.new("UIStroke", pantsP)
		pantsPs.Color = Color3.fromRGB(0, 0, 0)
		pantsPs.Thickness = 1
		pantsPs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local pantsL = lbl(pantsP, "Select Pants", 11, WHITE, true)
		pantsL.Size = UDim2.new(1, -120, 1, 0)
		pantsL.Position = UDim2.fromOffset(12, 6)
		pantsL.Font = Enum.Font.GothamMedium

		local pantsList = {}
		local pantsFolder = nil

		if shopFolder then
			local shopInner = shopFolder:FindFirstChild("Shop")
			if shopInner then
				local boyFolder = shopInner:FindFirstChild("Boy")
				if boyFolder then
					pantsFolder = boyFolder:FindFirstChild("Pants")
				end
			end
		end

		if pantsFolder then
			for _, child in ipairs(pantsFolder:GetChildren()) do
				table.insert(pantsList, child.Name)
			end
			sortAlphabetically(pantsList)
		end

		local hasPants = #pantsList > 0

		local pantsInput = Instance.new("TextBox", pantsP)
		pantsInput.Size = UDim2.fromOffset(tW - 160, 26)
		pantsInput.Position = UDim2.fromOffset(12, 28)
		pantsInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		pantsInput.BorderSizePixel = 0
		pantsInput.Text = hasPants and "Search pants..." or "No pants available"
		pantsInput.TextColor3 = hasPants and Color3.fromRGB(100, 100, 100) or RED
		pantsInput.TextSize = 11
		pantsInput.Font = Enum.Font.Gotham
		pantsInput.ClearTextOnFocus = true
		pantsInput.ZIndex = 2
		pantsInput.Active = hasPants
		rnd(pantsInput, 5)

		local pantsInputStroke = Instance.new("UIStroke", pantsInput)
		pantsInputStroke.Color = Color3.fromRGB(0, 0, 0)
		pantsInputStroke.Thickness = 1
		pantsInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local pantsPadding = Instance.new("UIPadding", pantsInput)
		pantsPadding.PaddingLeft = UDim.new(0, 8)

		local pantsDropBtn = Instance.new("TextButton", pantsP)
		pantsDropBtn.Size = UDim2.fromOffset(30, 26)
		pantsDropBtn.Position = UDim2.new(0, tW - 148, 0, 28)
		pantsDropBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		pantsDropBtn.BorderSizePixel = 0
		pantsDropBtn.Text = hasPants and "▼" or ""
		pantsDropBtn.TextColor3 = WHITE
		pantsDropBtn.TextSize = 10
		pantsDropBtn.Font = Enum.Font.Gotham
		pantsDropBtn.ZIndex = 2
		pantsDropBtn.Active = hasPants
		rnd(pantsDropBtn, 5)

		local pantsDropStroke = Instance.new("UIStroke", pantsDropBtn)
		pantsDropStroke.Color = Color3.fromRGB(0, 0, 0)
		pantsDropStroke.Thickness = 1
		pantsDropStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local pantsConfirm = Instance.new("TextButton", pantsP)
		pantsConfirm.Size = UDim2.fromOffset(60, 26)
		pantsConfirm.Position = UDim2.new(1, -68, 0, 28)
		pantsConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		pantsConfirm.BorderSizePixel = 0
		pantsConfirm.Text = "Apply"
		pantsConfirm.TextColor3 = WHITE
		pantsConfirm.TextSize = 11
		pantsConfirm.Font = Enum.Font.GothamMedium
		pantsConfirm.ZIndex = 2
		pantsConfirm.Active = hasPants
		rnd(pantsConfirm, 5)

		local pantsConfirmStroke = Instance.new("UIStroke", pantsConfirm)
		pantsConfirmStroke.Color = Color3.fromRGB(0, 0, 0)
		pantsConfirmStroke.Thickness = 1
		pantsConfirmStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local maxDropdownItemsPants = 6
		local itemHeightPants = 28
		local totalItemsPants = #pantsList
		local visibleItemsPants = math.min(totalItemsPants, maxDropdownItemsPants)
		local dropdownHeightPants = math.max(visibleItemsPants * itemHeightPants, 28)

		local pantsDropdown = fr(mainContainer, UDim2.fromOffset(tW - 160, dropdownHeightPants), UDim2.fromOffset(12, tY + 28), Color3.fromRGB(8, 8, 8))
		pantsDropdown.Visible = false
		pantsDropdown.ZIndex = 100
		rnd(pantsDropdown, 5)

		local pantsDropStroke2 = Instance.new("UIStroke", pantsDropdown)
		pantsDropStroke2.Color = Color3.fromRGB(0, 0, 0)
		pantsDropStroke2.Thickness = 1
		pantsDropStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		local pantsScrolling = Instance.new("ScrollingFrame", pantsDropdown)
		pantsScrolling.Size = UDim2.new(1, 0, 1, 0)
		pantsScrolling.BackgroundTransparency = 1
		pantsScrolling.BorderSizePixel = 0
		pantsScrolling.ZIndex = 100
		pantsScrolling.ScrollBarThickness = 4
		pantsScrolling.ScrollBarImageColor3 = Color3.fromRGB(40, 40, 40)
		pantsScrolling.CanvasSize = UDim2.new(0, 0, 0, math.max(totalItemsPants * itemHeightPants, 28))
		pantsScrolling.ClipsDescendants = true

		local pantsButtons = {}

		if hasPants then
			for i, pants in ipairs(pantsList) do
				local btn = Instance.new("TextButton", pantsScrolling)
				btn.Size = UDim2.new(1, -6, 0, itemHeightPants)
				btn.Position = UDim2.fromOffset(0, (i-1) * itemHeightPants)
				btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				btn.BorderSizePixel = 0
				btn.Text = pants
				btn.TextColor3 = WHITE
				btn.TextSize = 10
				btn.Font = Enum.Font.Gotham
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.ZIndex = 100
				btn.Visible = true

				local padding = Instance.new("UIPadding", btn)
				padding.PaddingLeft = UDim.new(0, 8)

				local stroke = Instance.new("UIStroke", btn)
				stroke.Color = Color3.fromRGB(0, 0, 0)
				stroke.Thickness = 1
				stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

				btn.MouseEnter:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
				end)

				btn.MouseLeave:Connect(function()
					btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				end)

				btn.MouseButton1Click:Connect(function()
					pantsInput.Text = pants
					pantsInput.TextColor3 = WHITE
					pantsDropdown.Visible = false
					pantsDropBtn.Text = "▼"
					if shirtDropdown and shirtDropdown.Visible then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if skinDropdown and skinDropdown.Visible then
						skinDropdown.Visible = false
						skinDropBtn.Text = "▼"
					end
					if faceDropdown and faceDropdown.Visible then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if bodyDropdown and bodyDropdown.Visible then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
				end)

				table.insert(pantsButtons, btn)
			end
		else
			local emptyLabel = Instance.new("TextLabel", pantsScrolling)
			emptyLabel.Size = UDim2.new(1, 0, 1, 0)
			emptyLabel.BackgroundTransparency = 1
			emptyLabel.Text = "No pants available"
			emptyLabel.TextColor3 = DIM
			emptyLabel.TextSize = 10
			emptyLabel.Font = Enum.Font.Gotham
			emptyLabel.ZIndex = 100
		end

		pantsInput:GetPropertyChangedSignal("Text"):Connect(function()
			local searchText = string.lower(pantsInput.Text)
			if searchText ~= "" and searchText ~= "search pants..." and hasPants then
				for _, btn in ipairs(pantsButtons) do
					local itemName = string.lower(btn.Text)
					if string.find(itemName, searchText) then
						btn.Visible = true
					else
						btn.Visible = false
					end
				end
			elseif hasPants then
				for _, btn in ipairs(pantsButtons) do
					btn.Visible = true
				end
			end
		end)

		pantsDropBtn.MouseButton1Click:Connect(function()
			if hasPants and pantsDropdown then
				local newState = not pantsDropdown.Visible
				pantsDropdown.Visible = newState
				pantsDropBtn.Text = newState and "▲" or "▼"
				if newState then
					if shirtDropdown then
						shirtDropdown.Visible = false
						shirtDropBtn.Text = "▼"
					end
					if skinDropdown then
						skinDropdown.Visible = false
						skinDropBtn.Text = "▼"
					end
					if faceDropdown then
						faceDropdown.Visible = false
						faceDropBtn.Text = "▼"
					end
					if bodyDropdown then
						bodyDropdown.Visible = false
						bodyDropBtn.Text = "▼"
					end
				end
			end
		end)

		pantsConfirm.MouseEnter:Connect(function()
			pantsConfirm.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		end)

		pantsConfirm.MouseLeave:Connect(function()
			pantsConfirm.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
		end)

		pantsConfirm.MouseButton1Click:Connect(function()
			if not hasPants then
				pantsConfirm.Text = "✗"
				pantsConfirm.TextColor3 = RED
				task.delay(1.5, function()
					pantsConfirm.Text = "Apply"
					pantsConfirm.TextColor3 = WHITE
				end)
				return
			end

			local selectedPants = pantsInput.Text
			if selectedPants ~= "Search pants..." and selectedPants ~= "No pants available" and table.find(pantsList, selectedPants) then
				local success = pcall(function()
					game:GetService("ReplicatedStorage").Character.Events.GivePants:FireServer(selectedPants)
				end)
				pantsConfirm.Text = success and "✓" or "✗"
				if not success then
					pantsConfirm.TextColor3 = RED
				end
				task.delay(1.5, function()
					pantsConfirm.Text = "Apply"
					pantsConfirm.TextColor3 = WHITE
				end)
			end
		end)

		tY = tY + 80

		mainContainer.Size = UDim2.new(1, 0, 0, tY + 8)
		mainScrolling.CanvasSize = UDim2.new(0, 0, 0, tY + 8)
	end
	
	do
		local SetTab = mkSubFrame("Settings")
		local L, R, colW = mkTwoCols(SetTab)
		local yL = 0
		secLabel(L, yL, colW, "UI")
		yL = yL + 26
		mkSlider(L, yL, colW, "UI Opacity", 10, 100, 100, function(v)
			Win.BackgroundTransparency = 1 - (v / 100)
		end)
		yL = yL + 49
		mkSlider(L, yL, colW, "UI Scale", 80, 120, 100, function(v)
			Win.Size = UDim2.fromOffset(math.floor(WIN_W * v / 100), math.floor(WIN_H * v / 100))
			Win.Position = UDim2.new(0.5, -math.floor(WIN_W * v / 100) / 2, 0.5, -math.floor(WIN_H * v / 100) / 2)
		end)
		yL = yL + 49

		local unlBtn = Instance.new("TextButton", L)
		unlBtn.Size = UDim2.fromOffset(colW, 28)
		unlBtn.Position = UDim2.fromOffset(0, yL)
		unlBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		unlBtn.BorderSizePixel = 0
		unlBtn.Text = "Unload Script"
		unlBtn.TextColor3 = WHITE
		unlBtn.TextSize = 11
		unlBtn.Font = Enum.Font.Gotham
		rnd(unlBtn, 6)

		local unlS = Instance.new("UIStroke", unlBtn)
		unlS.Color = Color3.fromRGB(0, 0, 0)
		unlS.Thickness = 1
		unlS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

		unlBtn.MouseEnter:Connect(function()
			unlBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
		end)

		unlBtn.MouseLeave:Connect(function()
			unlBtn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
		end)

		unlBtn.MouseButton1Click:Connect(function()
			for _, c in ipairs(_connections) do
				pcall(function()
					c:Disconnect()
				end)
			end

			for _, t in ipairs(_threads) do
				pcall(function()
					task.cancel(t)
				end)
			end

			for _, d in ipairs(_drawObjects) do
				pcall(function()
					d:Remove()
				end)
			end

			for _, line in pairs(activeTracers) do
				pcall(function()
					line:Remove()
				end)
			end

			activeTracers = {}
			S.AimbotEnabled = false
			S.ESPEnabled = false
			S.BoxEnabled = false
			S.NameEnabled = false
			S.HealthEnabled = false
			S.ShowFOV = false
			S.TriggerEnabled = false
			S.MagneticEnabled = false
			S.WalkEnabled = false
			S.JumpEnabled = false
			S.SpeedEnabled = false
			S.FlyEnabled = false
			S.FreecamEnabled = false
			S.TrackAllEnabled = false
			S.NoClip = false
			S.InfJump = false
			S.WhitelistEnabled = false

			pcall(function()
				local char = LP.Character

				if char then
					local hum = char:FindFirstChildOfClass("Humanoid")

					if hum then
						hum.WalkSpeed = 16
						hum.JumpPower = 50
						hum.PlatformStand = false
					end
				end
			end)

			pcall(function()
				workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
			end)

			pcall(function()
				if flyBody then
					flyBody:Destroy()
					flyBody = nil
				end
			end)

			for uid, obj in pairs(espObjects) do
				pcall(function()
					if obj.highlight then
						obj.highlight:Destroy()
					end
				end)

				pcall(function()
					if obj.billboard then
						obj.billboard:Destroy()
					end
				end)

				espObjects[uid] = nil
			end

			pcall(function()
				if clearTrack then
					clearTrack()
				end
			end)

			pcall(function()
				HamBtn:Destroy()
			end)

			mNXHub:Destroy()
		end)

		local yR = 0
		secLabel(R, yR, colW, "MENU KEY")
		yR = yR + 26

		local _, mkBadge = mkBadgeRow(R, yR, colW, "Toggle Key", S.MenuKey.Name, function(badge)
			if menuKeyCapturing then
				return
			end

			menuKeyCapturing = true
			badge.Text = "Press..."
			badge.TextColor3 = RED
			local conn
			conn = UIS.InputBegan:Connect(function(inp, gp)
				if gp then
					return
				end

				if inp.UserInputType == Enum.UserInputType.Keyboard then
					S.MenuKey = inp.KeyCode
					badge.Text = inp.KeyCode.Name
					badge.TextColor3 = WHITE
					menuKeyCapturing = false
					conn:Disconnect()
				end
			end)
		end)
		yR = yR + 31
		secLabel(R, yR, colW, "ABOUT")
		yR = yR + 26

		local ab = lbl(R, "WILD MENU | coded by @ https://porn.x", 10, DIM, false)
		ab.Size = UDim2.fromOffset(colW, 18)
		ab.Position = UDim2.fromOffset(0, yR)
	end

	local HamBtn = Instance.new("TextButton")
	HamBtn.Size = UDim2.fromOffset(32, 32)
	HamBtn.Position = UDim2.new(0, 8, 0.5, -16)
	HamBtn.BackgroundColor3 = BLACK
	HamBtn.BorderSizePixel = 0
	HamBtn.Text = "☰"
	HamBtn.TextColor3 = WHITE
	HamBtn.TextSize = 17
	HamBtn.Font = Enum.Font.Gotham
	HamBtn.ZIndex = 100
	HamBtn.Parent = mNXHub
	rnd(HamBtn, 6)

	local hamS = Instance.new("UIStroke", HamBtn)
	hamS.Color = Color3.fromRGB(0, 0, 0)
	hamS.Thickness = 1
	hamS.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	do
		local _hDrag, _hStart, _hOrigin = false, nil, nil

		HamBtn.InputBegan:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				_hDrag = true
				_hStart = i.Position
				_hOrigin = HamBtn.Position
			end
		end)

		HamBtn.InputEnded:Connect(function(i)
			if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
				_hDrag = false
			end
		end)

		trackConn(UIS.InputChanged:Connect(function(i)
			if _hDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
				local delta = i.Position - _hStart
				HamBtn.Position = UDim2.new(_hOrigin.X.Scale, _hOrigin.X.Offset + delta.X, _hOrigin.Y.Scale, _hOrigin.Y.Offset + delta.Y)
			end
		end))
	end

	HamBtn.MouseButton1Click:Connect(function()
		Win.Visible = not Win.Visible
	end)

	trackConn(UIS.InputBegan:Connect(function(inp, gp)
		if gp or menuKeyCapturing then
			return
		end

		if inp.KeyCode == S.MenuKey then
			Win.Visible = not Win.Visible
		end
	end))

	task.spawn(function()
		task.wait(0.05)
		Win.BackgroundTransparency = 1
		Win.Size = UDim2.fromOffset(math.floor(WIN_W * 0.94), math.floor(WIN_H * 0.94))
		Win.Position = UDim2.new(0.5, -math.floor(WIN_W * 0.94) / 2, 0.5, -math.floor(WIN_H * 0.94) / 2 + 8)
		TS:Create(Win, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(WIN_W, WIN_H),
			Position = UDim2.new(0.5, -WIN_W / 2, 0.5, -WIN_H / 2),
			BackgroundTransparency = 0,
		}):Play()
	end)

	switchMainTab("Combat")
	print(" WILD MENU — coded by @ https://porn.x — " .. LP.Name .. " (" .. LP.UserId .. ")")
