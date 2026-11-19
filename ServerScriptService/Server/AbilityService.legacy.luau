local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Abilities = require(ReplicatedStorage.Shared.Abilities)
local Races = require(ReplicatedStorage.Shared.Races)
local PlayerData = require(script.Parent.PlayerData)
local Resources = require(script.Parent.Resources)
local damageEvent = ServerStorage:WaitForChild("DealDamage")

local request = Instance.new("RemoteFunction")
request.Name = "AbilityRequest"
request.Parent = ReplicatedStorage

local cooldowns = {}

---------------------------------------------------------------- Helpers
local function isHostile(model)
	local humanoid = model and model:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return false end
	return model:GetAttribute("IsEnemy") or model:GetAttribute("TrainingDummy") or model:GetAttribute("AttacksPlayers")
end

local function hostilesInRadius(position, radius)
	local found = {}
	for _, model in workspace:GetChildren() do
		if model:IsA("Model") and isHostile(model) then
			local root = model:FindFirstChild("HumanoidRootPart")
			if root and (root.Position - position).Magnitude <= radius then
				table.insert(found, model)
			end
		end
	end
	return found
end

local function raceBonus(player, keys)
	local race = Races.ById[player:GetAttribute("Race")]
	local bonus = race and race.Bonuses or {}
	local total = 0
	for _, key in keys do
		total += bonus[key] or 0
	end
	return total
end

local function physicalPower(player)
	return (1 + (player:GetAttribute("Strength") or 10) / 100)
		* (1 + raceBonus(player, { "MeleeDamage", "PhysicalDamage", "AllDamage" }))
end

local function magicPower(player, extraKey)
	return (1 + (player:GetAttribute("Intellect") or 10) / 100)
		* (1 + raceBonus(player, { "MagicDamage", "AllDamage", extraKey }))
end

local function showText(model, text, color)
	local head = model:FindFirstChild("Head")
	if not head then return end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 140, 0, 40)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 3.2, 0)
	gui.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
	gui.Parent = head
	Debris:AddItem(gui, 0.9)
end

-- Mismo sistema de aturdimiento que CombatService (atributo Stunned)
local function stun(model, duration, text, color)
	local token = os.clock()
	model:SetAttribute("Stunned", true)
	model:SetAttribute("StunToken", token)
	showText(model, text or "ATURDIDO", color or Color3.fromRGB(255, 150, 50))
	task.delay(duration, function()
		if model.Parent and model:GetAttribute("StunToken") == token then
			model:SetAttribute("Stunned", nil)
		end
	end)
end

local function burn(attacker, target, tickDamage, ticks)
	task.spawn(function()
		for _ = 1, ticks do
			task.wait(1)
			local humanoid = target:FindFirstChildOfClass("Humanoid")
			if not target.Parent or not humanoid or humanoid.Health <= 0 then return end
			damageEvent:Fire(attacker, target, tickDamage)
		end
	end)
end

local function effectPart(props)
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Material = Enum.Material.Neon
	for key, value in props do
		part[key] = value
	end
	part.Parent = workspace
	return part
end

---------------------------------------------------------------- Habilidades
local impl = {}

-- GUERRERO
impl.BrutalStrike = function(player, character, root)
	local damage = (20 + (player:GetAttribute("WeaponDamage") or 0) * 1.5) * physicalPower(player)
	for _, target in hostilesInRadius(root.Position + root.CFrame.LookVector * 4, 4.5) do
		damageEvent:Fire(character, target, damage)
	end
	Resources.gain(player, 15)
	return true
end

impl.Charge = function(player, character, root)
	local best, bestDistance = nil, math.huge
	for _, target in hostilesInRadius(root.Position, 30) do
		local offset = target.HumanoidRootPart.Position - root.Position
		if offset.Magnitude > 0.1 and root.CFrame.LookVector:Dot(offset.Unit) > 0.5 and offset.Magnitude < bestDistance then
			best, bestDistance = target, offset.Magnitude
		end
	end
	if not best then
		return false, "No hay enemigos adelante"
	end
	local targetPos = best.HumanoidRootPart.Position
	local flat = Vector3.new(targetPos.X - root.Position.X, 0, targetPos.Z - root.Position.Z)
	local direction = flat.Magnitude > 0.1 and flat.Unit or root.CFrame.LookVector
	local landing = Vector3.new(targetPos.X, root.Position.Y, targetPos.Z) - direction * 3.5
	root.CFrame = CFrame.lookAt(landing, Vector3.new(targetPos.X, root.Position.Y, targetPos.Z))
	damageEvent:Fire(character, best, 10 * physicalPower(player))
	stun(best, 1)
	return true
end

-- MAGO
impl.Fireball = function(player, character, root, aim)
	local origin = root.Position + root.CFrame.LookVector * 2 + Vector3.new(0, 1.5, 0)
	local direction = aim and (aim - origin) or root.CFrame.LookVector
	if direction.Magnitude < 1 then direction = root.CFrame.LookVector end
	direction = direction.Unit

	local ball = effectPart({
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(1.3, 1.3, 1.3),
		Color = Color3.fromRGB(255, 120, 30),
		Position = origin,
	})
	local light = Instance.new("PointLight")
	light.Color = ball.Color
	light.Range = 10
	light.Parent = ball

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character, ball }

	local damage = 18 * magicPower(player, "FireDamage")
	local burnDamage = 4 * magicPower(player, "FireDamage")
	local speed, maxDistance, travelled = 70, 120, 0
	local connection
	connection = RunService.Heartbeat:Connect(function(dt)
		local step = direction * speed * dt
		local result = workspace:Raycast(ball.Position, step, params)
		if result then
			connection:Disconnect()
			local model = result.Instance:FindFirstAncestorOfClass("Model")
			if isHostile(model) then
				damageEvent:Fire(character, model, damage)
				burn(character, model, burnDamage, 3)
			end
			ball:Destroy()
			return
		end
		ball.Position += step
		travelled += step.Magnitude
		if travelled >= maxDistance then
			connection:Disconnect()
			ball:Destroy()
		end
	end)
	return true
end

impl.FrostNova = function(player, character, root)
	local ring = effectPart({
		Shape = Enum.PartType.Ball,
		Size = Vector3.new(2, 2, 2),
		Color = Color3.fromRGB(150, 220, 255),
		Transparency = 0.5,
		Position = root.Position,
	})
	TweenService:Create(ring, TweenInfo.new(0.3), { Size = Vector3.new(24, 24, 24), Transparency = 1 }):Play()
	Debris:AddItem(ring, 0.35)

	for _, target in hostilesInRadius(root.Position, 12) do
		damageEvent:Fire(character, target, 10 * magicPower(player, "FrostDamage"))
		stun(target, 2, "CONGELADO", Color3.fromRGB(150, 220, 255))
	end
	return true
end

-- SACERDOTE
impl.Heal = function(player, character, root, aim, targetModel)
	local healTarget = character
	if typeof(targetModel) == "Instance" and targetModel:IsA("Model") then
		local other = Players:GetPlayerFromCharacter(targetModel)
		local otherRoot = targetModel:FindFirstChild("HumanoidRootPart")
		if other and otherRoot and (otherRoot.Position - root.Position).Magnitude <= 40 then
			healTarget = targetModel
		end
	end
	local humanoid = healTarget:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false, "Objetivo inválido"
	end
	if humanoid.Health >= humanoid.MaxHealth then
		return false, "Ya tiene la vida llena"
	end

	local amount = math.floor((25 + (player:GetAttribute("Intellect") or 10) * 1.5)
		* (1 + raceBonus(player, { "HealingDone" })))
	humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + amount)
	showText(healTarget, "+" .. amount, Color3.fromRGB(90, 230, 120))

	local targetRoot = healTarget:FindFirstChild("HumanoidRootPart")
	if targetRoot then
		local sparkles = Instance.new("Sparkles")
		sparkles.SparkleColor = Color3.fromRGB(120, 255, 150)
		sparkles.Parent = targetRoot
		Debris:AddItem(sparkles, 1)
	end
	return true
end

impl.Smite = function(player, character, root, aim)
	local head = character:FindFirstChild("Head") or root
	local origin = head.Position
	local direction = aim and (aim - origin) or root.CFrame.LookVector
	if direction.Magnitude < 1 then direction = root.CFrame.LookVector end
	direction = direction.Unit * 40

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local result = workspace:Raycast(origin, direction, params)
	local endPoint = result and result.Position or origin + direction

	local length = (endPoint - origin).Magnitude
	local beam = effectPart({
		Size = Vector3.new(0.3, 0.3, length),
		Color = Color3.fromRGB(255, 240, 150),
		CFrame = CFrame.lookAt(origin, endPoint) * CFrame.new(0, 0, -length / 2),
	})
	Debris:AddItem(beam, 0.15)

	if result then
		local model = result.Instance:FindFirstAncestorOfClass("Model")
		if isHostile(model) then
			damageEvent:Fire(character, model, 16 * magicPower(player, "HolyDamage"))
		end
	end
	return true
end

---------------------------------------------------------------- Lanzar
request.OnServerInvoke = function(player, index, aim, targetModel)
	local data = PlayerData.get(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not data or not humanoid or humanoid.Health <= 0 or not root then
		return false, "No podés ahora"
	end
	if character:GetAttribute("Stunned") or character:GetAttribute("Drinking") then
		return false, "No podés ahora"
	end
	if character:GetAttribute("Blocking") then
		return false, "No podés mientras bloqueás"
	end

	local list = Abilities[data.Class]
	local ability = typeof(index) == "number" and list and list[index]
	if not ability then return false, "Sin habilidad" end
	if not ability.Implemented then return false, "Próximamente" end
	if data.Level < ability.Level then return false, "Requiere nivel " .. ability.Level end

	cooldowns[player] = cooldowns[player] or {}
	local last = cooldowns[player][ability.Id]
	if last and os.clock() - last < ability.Cooldown then
		return false, "En espera"
	end
	if Resources.get(player) < ability.Cost then
		return false, player:GetAttribute("ResourceType") == "Rage" and "No tenés suficiente Furia" or "No tenés suficiente Maná"
	end

	local ok, message = impl[ability.Id](player, character, root, typeof(aim) == "Vector3" and aim or nil, targetModel)
	if not ok then
		return false, message
	end
	Resources.spend(player, ability.Cost)
	cooldowns[player][ability.Id] = os.clock()
	return true, ability.Cooldown
end

---------------------------------------------------------------- Jugadores
local function waitForData(player)
	while player.Parent and not PlayerData.get(player) do
		task.wait(0.2)
	end
	return PlayerData.get(player)
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		Resources.reset(player)
		Resources.watch(player, character)
	end)
	if player.Character then
		task.spawn(Resources.watch, player, player.Character)
	end

	task.spawn(function()
		if not waitForData(player) then return end
		Resources.setup(player)
		player:GetAttributeChangedSignal("Class"):Connect(function()
			Resources.setup(player)
			Resources.reset(player)
		end)
		player:GetAttributeChangedSignal("Intellect"):Connect(function()
			Resources.setup(player)
		end)
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
Players.PlayerRemoving:Connect(function(player)
	cooldowns[player] = nil
end)