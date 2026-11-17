local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Config = require(ReplicatedStorage.Shared.CombatConfig)
local Races = require(ReplicatedStorage.Shared.Races)

local remote = Instance.new("RemoteEvent")
remote.Name = "CombatAction"
remote.Parent = ReplicatedStorage

local COLORS = {
	Damage = Color3.fromRGB(255, 220, 80),
	Dodge = Color3.fromRGB(150, 200, 255),
	Block = Color3.fromRGB(190, 190, 190),
	Parry = Color3.fromRGB(255, 255, 255),
	Stun = Color3.fromRGB(255, 150, 50),
	Break = Color3.fromRGB(255, 70, 70),
}

local states = {}

local function getState(player)
	if not states[player] then
		states[player] = { cooldowns = {}, combo = 1, lastLight = 0, lastStaminaUse = 0, blockStart = 0 }
	end
	return states[player]
end

local function isReady(state, key, cooldown)
	local last = state.cooldowns[key]
	return not last or os.clock() - last >= cooldown
end

local function trySpendStamina(player, state, amount)
	local stamina = player:GetAttribute("Stamina") or 0
	if stamina < amount then return false end
	player:SetAttribute("Stamina", stamina - amount)
	state.lastStaminaUse = os.clock()
	return true
end

local function damageMultiplier(player)
	local strength = player:GetAttribute("Strength") or 10
	local race = Races.ById[player:GetAttribute("Race")]
	local bonus = race and race.Bonuses or {}
	local raceBonus = (bonus.MeleeDamage or 0) + (bonus.PhysicalDamage or 0) + (bonus.AllDamage or 0)
	return (1 + strength / 100) * (1 + raceBonus)
end

local function showText(model, text, color)
	local head = model:FindFirstChild("Head")
	if not head then return end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 140, 0, 40)
	gui.StudsOffset = Vector3.new(math.random(-10, 10) / 10, 2.5, 0)
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
	Debris:AddItem(gui, 0.8)
end

local function stun(model, duration)
	local token = os.clock()
	model:SetAttribute("Stunned", true)
	model:SetAttribute("StunToken", token)
	showText(model, "ATURDIDO", COLORS.Stun)
	task.delay(duration, function()
		-- solo lo libera si no lo volvieron a aturdir mientras tanto
		if model.Parent and model:GetAttribute("StunToken") == token then
			model:SetAttribute("Stunned", nil)
		end
	end)
end

local function setBlocking(player, blocking)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end
	local state = getState(player)
	if blocking then
		character:SetAttribute("Blocking", true)
		state.blockStart = os.clock()
		humanoid.WalkSpeed = Config.Block.WalkSpeed
	else
		if character:GetAttribute("Blocking") then
			state.cooldowns.Block = os.clock()
		end
		character:SetAttribute("Blocking", nil)
		humanoid.WalkSpeed = 16
	end
end

-- ¿El atacante está delante del defensor?
local function isFacing(defender, attacker)
	local dRoot = defender:FindFirstChild("HumanoidRootPart")
	local aRoot = attacker and attacker:FindFirstChild("HumanoidRootPart")
	if not dRoot or not aRoot then return false end
	local toAttacker = (aRoot.Position - dRoot.Position) * Vector3.new(1, 0, 1)
	if toAttacker.Magnitude < 0.01 then return true end
	return dRoot.CFrame.LookVector:Dot(toAttacker.Unit) > 0.3
end

local function dealDamage(attacker, target, amount)
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	amount = math.floor(amount)

	if target:GetAttribute("Invulnerable") then
		showText(target, "ESQUIVA", COLORS.Dodge)
		return
	end

	local defender = Players:GetPlayerFromCharacter(target)
	if defender and target:GetAttribute("Blocking") and isFacing(target, attacker) then
		local cfg = Config.Block
		local state = getState(defender)
		if os.clock() - state.blockStart <= cfg.ParryWindow then
			showText(target, "¡PARRY!", COLORS.Parry)
			if attacker then
				stun(attacker, cfg.ParryStun)
			end
			return
		end
		if trySpendStamina(defender, state, amount * cfg.StaminaPerDamage) then
			local reduced = math.floor(amount * (1 - cfg.DamageReduction))
			humanoid:TakeDamage(reduced)
			showText(target, "BLOQUEO " .. reduced, COLORS.Block)
			return
		end
		-- Sin estamina: guardia rota y daño completo
		setBlocking(defender, false)
		defender:SetAttribute("Stamina", 0)
		showText(target, "¡GUARDIA ROTA!", COLORS.Break)
		stun(target, cfg.GuardBreakStun)
	end

	if target:GetAttribute("TrainingDummy") and humanoid.Health - amount < 1 then
		humanoid.Health = humanoid.MaxHealth
	else
		humanoid:TakeDamage(amount)
	end
	showText(target, tostring(amount), COLORS.Damage)
end

local function getTargets(character, range, width)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return {} end
	local params = OverlapParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local boxCFrame = root.CFrame * CFrame.new(0, 0, -range / 2)
	local parts = workspace:GetPartBoundsInBox(boxCFrame, Vector3.new(width, 5, range), params)
	local targets, seen = {}, {}
	for _, part in parts do
		local model = part:FindFirstAncestorOfClass("Model")
		if model and not seen[model] and model:FindFirstChildOfClass("Humanoid") then
			seen[model] = true
			table.insert(targets, model)
		end
	end
	return targets
end

local function isAlive(player)
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	return humanoid ~= nil and humanoid.Health > 0
end

local handlers = {}

function handlers.Light(player, state)
	local cfg = Config.Attacks.Light
	if not isReady(state, "Light", cfg.Cooldown) then return end
	if not trySpendStamina(player, state, cfg.Stamina) then return end
	state.cooldowns.Light = os.clock()

	if os.clock() - state.lastLight > cfg.ComboReset then
		state.combo = 1
	end
	state.lastLight = os.clock()
	local damage = cfg.Damage[state.combo] * damageMultiplier(player)
	state.combo = state.combo % #cfg.Damage + 1

	for _, target in getTargets(player.Character, cfg.Range, cfg.Width) do
		dealDamage(player.Character, target, damage)
	end
end

function handlers.Heavy(player, state)
	local cfg = Config.Attacks.Heavy
	if not isReady(state, "Heavy", cfg.Cooldown) then return end
	if not trySpendStamina(player, state, cfg.Stamina) then return end
	state.cooldowns.Heavy = os.clock()

	task.wait(cfg.Windup)
	if not isAlive(player) or player.Character:GetAttribute("Stunned") then return end
	for _, target in getTargets(player.Character, cfg.Range, cfg.Width) do
		dealDamage(player.Character, target, cfg.Damage * damageMultiplier(player))
	end
end

function handlers.Dodge(player, state)
	local cfg = Config.Dodge
	if not isReady(state, "Dodge", cfg.Cooldown) then return end
	if not trySpendStamina(player, state, cfg.Stamina) then return end
	state.cooldowns.Dodge = os.clock()

	local character = player.Character
	character:SetAttribute("Invulnerable", true)
	task.delay(cfg.IFrames, function()
		if character.Parent then
			character:SetAttribute("Invulnerable", nil)
		end
	end)
end

function handlers.BlockStart(player, state)
	if not isReady(state, "Block", Config.Block.Cooldown) then return end
	setBlocking(player, true)
end

function handlers.BlockEnd(player)
	setBlocking(player, false)
end

remote.OnServerEvent:Connect(function(player, action)
	local handler = typeof(action) == "string" and handlers[action]
	if not handler or not isAlive(player) then return end
	local character = player.Character

	if action == "BlockEnd" then
		handler(player, getState(player))
		return
	end
	if character:GetAttribute("Stunned") then return end
	if action ~= "BlockStart" and character:GetAttribute("Blocking") then
		setBlocking(player, false) -- atacar o esquivar cancela el bloqueo
	end
	handler(player, getState(player))
end)

local function setupCharacter(player)
	local character = player.Character
	if not character then return end
	local humanoid = character:WaitForChild("Humanoid")
	local maxHealth = player:GetAttribute("MaxHealth")
	if maxHealth then
		humanoid.MaxHealth = maxHealth
		humanoid.Health = maxHealth
	end
	player:SetAttribute("Stamina", player:GetAttribute("MaxStamina") or 100)
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function()
		setupCharacter(player)
	end)
	player:GetAttributeChangedSignal("MaxHealth"):Connect(function()
		setupCharacter(player)
	end)
	setupCharacter(player)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end
Players.PlayerRemoving:Connect(function(player)
	states[player] = nil
end)

-- Regeneración de estamina (no regenera mientras bloqueás)
task.spawn(function()
	while true do
		local dt = task.wait(0.1)
		for _, player in Players:GetPlayers() do
			local stamina = player:GetAttribute("Stamina")
			local max = player:GetAttribute("MaxStamina")
			local state = getState(player)
			local blocking = player.Character and player.Character:GetAttribute("Blocking")
			if stamina and max and stamina < max and not blocking
				and os.clock() - state.lastStaminaUse > Config.RegenDelay then
				player:SetAttribute("Stamina", math.min(max, stamina + Config.StaminaRegen * dt))
			end
		end
	end
end)

-- Muñecos que atacan (atributo AttacksPlayers = true) para practicar bloqueo y parry
local function dummyAttack(dummy)
	local cfg = Config.DummyAttack
	local root = dummy:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- Aviso: se pone rojo antes de pegar. Esa es tu señal para el parry.
	local originals = {}
	for _, part in dummy:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			originals[part] = part.Color
			part.Color = Color3.fromRGB(255, 60, 60)
		end
	end
	task.wait(cfg.Windup)
	for part, color in originals do
		part.Color = color
	end

	for _, player in Players:GetPlayers() do
		local character = player.Character
		local playerRoot = character and character:FindFirstChild("HumanoidRootPart")
		if playerRoot and (playerRoot.Position - root.Position).Magnitude <= cfg.Range then
			dealDamage(dummy, character, cfg.Damage)
		end
	end
end

task.spawn(function()
	while true do
		task.wait(Config.DummyAttack.Interval)
		for _, model in workspace:GetChildren() do
			if model:GetAttribute("AttacksPlayers") and not model:GetAttribute("Stunned") then
				task.spawn(dummyAttack, model)
			end
		end
	end
end)
