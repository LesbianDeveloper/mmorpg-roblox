local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Enemies = require(ReplicatedStorage.Shared.Enemies)
local Animations = require(ReplicatedStorage.Shared.Animations)
local damageEvent = ServerStorage:WaitForChild("DealDamage")
local templates = ServerStorage:WaitForChild("EnemyTemplates")
local spawnsFolder = workspace:WaitForChild("EnemySpawns")

local TICK = 0.2 -- cada cuánto "piensa" el enemigo

local function loadTrack(humanoid, animName)
	local id = Animations[animName]
	if not id or id == "" then return nil end
	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. id
	return animator:LoadAnimation(animation)
end

local function flash(model, duration)
	local originals = {}
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Transparency < 1 then
			originals[part] = part.Color
			part.Color = Color3.fromRGB(255, 60, 60)
		end
	end
	task.delay(duration, function()
		for part, color in originals do
			if part.Parent then part.Color = color end
		end
	end)
end

local function hasLineOfSight(enemy, fromPart, toPart)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { enemy }
	local result = workspace:Raycast(fromPart.Position, toPart.Position - fromPart.Position, params)
	return result == nil or result.Instance:IsDescendantOf(toPart.Parent)
end

local function findTarget(enemy, root, range)
	local best, bestDistance = nil, range
	for _, player in Players:GetPlayers() do
		local character = player.Character
		local humanoid = character and character:FindFirstChildOfClass("Humanoid")
		local targetRoot = character and character:FindFirstChild("HumanoidRootPart")
		if humanoid and humanoid.Health > 0 and targetRoot then
			local distance = (targetRoot.Position - root.Position).Magnitude
			if distance < bestDistance and hasLineOfSight(enemy, root, targetRoot) then
				best, bestDistance = character, distance
			end
		end
	end
	return best
end

local function chooseAttack(data, cooldowns, distance)
	local options = {}
	for _, attack in data.Attacks do
		local ready = not cooldowns[attack.Name] or os.clock() - cooldowns[attack.Name] >= attack.Cooldown
		if ready and distance <= attack.Range then
			table.insert(options, attack)
		end
	end
	if #options == 0 then return nil end
	return options[math.random(#options)]
end

local function faceTowards(root, position)
	root.CFrame = CFrame.lookAt(root.Position, Vector3.new(position.X, root.Position.Y, position.Z))
end

local function runSpawn(spawnPart)
	local enemyType = spawnPart:GetAttribute("EnemyType")
	local data = Enemies[enemyType]
	local template = templates:FindFirstChild(enemyType)
	if not data or not template then
		warn("Spawn sin enemigo válido: " .. spawnPart:GetFullName())
		return
	end

	while true do
		-- Aparecer
		local enemy = template:Clone()
		enemy.Name = data.Name
		local humanoid = enemy:FindFirstChildOfClass("Humanoid")
		local root = enemy:FindFirstChild("HumanoidRootPart")
		humanoid.MaxHealth = data.MaxHealth
		humanoid.Health = data.MaxHealth
		humanoid.WalkSpeed = data.WalkSpeed
		enemy:PivotTo(spawnPart.CFrame + Vector3.new(0, 1, 0))
		enemy.Parent = workspace
		root:SetNetworkOwner(nil) -- el servidor controla su movimiento

		local tracks = {}
		for _, attack in data.Attacks do
			tracks[attack.Name] = loadTrack(humanoid, attack.Animation)
		end
		local stunTrack = loadTrack(humanoid, "Stunned")
		enemy:GetAttributeChangedSignal("Stunned"):Connect(function()
			if not stunTrack then return end
			if enemy:GetAttribute("Stunned") then stunTrack:Play() else stunTrack:Stop() end
		end)

		local home = spawnPart.Position
		local cooldowns = {}
		local target = nil
		local returning = false

		-- Cerebro
		while humanoid.Health > 0 and enemy.Parent do
			task.wait(TICK)
			if humanoid.Health <= 0 then break end
			if enemy:GetAttribute("Stunned") then continue end

			local distanceFromHome = (root.Position - home).Magnitude

			if returning then
				-- Volviendo a casa: inmune e ignora jugadores
				if distanceFromHome < 5 then
					returning = false
					enemy:SetAttribute("Invulnerable", nil)
				else
					humanoid:MoveTo(home)
				end

			elseif target then
				local targetHumanoid = target:FindFirstChildOfClass("Humanoid")
				local targetRoot = target:FindFirstChild("HumanoidRootPart")
				local lost = not target.Parent or not targetHumanoid or targetHumanoid.Health <= 0 or not targetRoot

				if lost or distanceFromHome > data.LeashRange then
					-- Perdió al objetivo o se alejó demasiado: vuelve y se cura
					target = nil
					returning = true
					enemy:SetAttribute("Invulnerable", true)
					humanoid.Health = humanoid.MaxHealth
					humanoid:MoveTo(home)
				else
					local distance = (targetRoot.Position - root.Position).Magnitude
					local attack = chooseAttack(data, cooldowns, distance)
					if attack then
						-- Atacar: frena, mira al objetivo, avisa en rojo y golpea
						cooldowns[attack.Name] = os.clock()
						humanoid:MoveTo(root.Position)
						faceTowards(root, targetRoot.Position)
						flash(enemy, attack.Windup)
						if tracks[attack.Name] then tracks[attack.Name]:Play() end
						task.wait(attack.Windup)

						if humanoid.Health > 0 and not enemy:GetAttribute("Stunned") and targetRoot.Parent then
							if (targetRoot.Position - root.Position).Magnitude <= attack.Range + 1.5 then
								damageEvent:Fire(enemy, target, attack.Damage)
							end
						end
						task.wait(0.3) -- recuperación tras atacar
					else
						humanoid:MoveTo(targetRoot.Position)
					end
				end

			else
				target = findTarget(enemy, root, data.AggroRange)
			end
		end

		-- Muerte y reaparición
		task.wait(3)
		enemy:Destroy()
		task.wait(data.RespawnTime)
	end
end

for _, spawnPart in spawnsFolder:GetChildren() do
	task.spawn(runSpawn, spawnPart)
end
spawnsFolder.ChildAdded:Connect(function(spawnPart)
	task.spawn(runSpawn, spawnPart)
end)