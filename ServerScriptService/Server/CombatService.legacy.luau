local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")
local Config = require(ReplicatedStorage.Shared.CombatConfig)
local Races = require(ReplicatedStorage.Shared.Races)

local remote = Instance.new("RemoteEvent")
remote.Name = "CombatAction"
remote.Parent = ReplicatedStorage

local states = {}

local function getState(player)
	if not states[player] then
		states[player] = { cooldowns = {}, combo = 1, lastLight = 0, lastStaminaUse = 0 }
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
	gui.Size = UDim2.new(0, 100, 0, 40)
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

local function dealDamage(target, amount)
	local humanoid = target:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if target:GetAttribute("Invulnerable") then
		showText(target, "ESQUIVA", Color3.fromRGB(150, 200, 255))
		return
	end
	amount = math.floor(amount)
	if target:GetAttribute("TrainingDummy") and humanoid.Health - amount < 1 then
		humanoid.Health = humanoid.MaxHealth -- el muñeco nunca muere
	else
		humanoid:TakeDamage(amount)
	end
	showText(target, tostring(amount), Color3.fromRGB(255, 220, 80))
end

-- Devuelve los modelos con Humanoid que están en una caja delante del personaje
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
		dealDamage(target, damage)
	end
end

function handlers.Heavy(player, state)
	local cfg = Config.Attacks.Heavy
	if not isReady(state, "Heavy", cfg.Cooldown) then return end
	if not trySpendStamina(player, state, cfg.Stamina) then return end
	state.cooldowns.Heavy = os.clock()

	task.wait(cfg.Windup)
	if not isAlive(player) then return end
	for _, target in getTargets(player.Character, cfg.Range, cfg.Width) do
		dealDamage(target, cfg.Damage * damageMultiplier(player))
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

remote.OnServerEvent:Connect(function(player, action)
	local handler = typeof(action) == "string" and handlers[action]
	if handler and isAlive(player) then
		handler(player, getState(player))
	end
end)

-- Aplica vida máxima y estamina al aparecer (o al cambiar de raza)
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

-- Regeneración de estamina (10 veces por segundo)
task.spawn(function()
	while true do
		local dt = task.wait(0.1)
		for _, player in Players:GetPlayers() do
			local stamina = player:GetAttribute("Stamina")
			local max = player:GetAttribute("MaxStamina")
			local state = getState(player)
			if stamina and max and stamina < max and os.clock() - state.lastStaminaUse > Config.RegenDelay then
				player:SetAttribute("Stamina", math.min(max, stamina + Config.StaminaRegen * dt))
			end
		end
	end
end)
