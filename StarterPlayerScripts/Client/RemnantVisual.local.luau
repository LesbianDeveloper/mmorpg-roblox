local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

local remnant = nil

local function clear()
	if remnant then
		remnant:Destroy()
		remnant = nil
	end
end

local function build(position)
	clear()
	local orb = Instance.new("Part")
	orb.Name = "MiRemanente"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.6, 1.6, 1.6)
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.Material = Enum.Material.Neon
	orb.Color = Color3.fromRGB(90, 255, 200)
	orb.Transparency = 0.2
	orb.Position = position

	local light = Instance.new("PointLight")
	light.Color = orb.Color
	light.Range = 12
	light.Brightness = 3
	light.Parent = orb

	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.new(0, 220, 0, 40)
	billboard.StudsOffset = Vector3.new(0, 2.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 300
	billboard.Parent = orb
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "Tu Remanente (" .. (player:GetAttribute("RemnantEssence") or 0) .. " Esencia)"
	label.TextColor3 = orb.Color
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.Parent = billboard

	orb.Parent = workspace
	remnant = orb
end

local function update()
	local position = player:GetAttribute("RemnantPos")
	if position then build(position) else clear() end
end

player:GetAttributeChangedSignal("RemnantPos"):Connect(update)
update()

-- Flota y late suavemente
RunService.RenderStepped:Connect(function()
	if remnant then
		local base = player:GetAttribute("RemnantPos")
		if base then
			local t = os.clock()
			remnant.Position = base + Vector3.new(0, 1.5 + math.sin(t * 2) * 0.4, 0)
			remnant.Transparency = 0.2 + (math.sin(t * 4) + 1) * 0.15
		end
	end
end)