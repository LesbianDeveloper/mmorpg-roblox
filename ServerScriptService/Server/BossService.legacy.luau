local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")

local Bosses = require(ReplicatedStorage.Shared.Bosses)
local Animations = require(ReplicatedStorage.Shared.Animations)
local PlayerData = require(script.Parent.PlayerData)
local Rewards = require(script.Parent.Rewards)
local damageEvent = ServerStorage:WaitForChild("DealDamage")
local bossTemplates = ServerStorage:WaitForChild("BossTemplates")
local enemyTemplates = ServerStorage:WaitForChild("EnemyTemplates")
local arenasFolder = workspace:WaitForChild("BossArenas")
local notify = ReplicatedStorage:WaitForChild("Notify")

local MAX_GROUP = 4
local GROUP_RADIUS = 20 -- los jugadores a esta distancia de la niebla entran juntos
local TICK = 0.15
local rng = Random.new()

---------------------------------------------------------------- Helpers
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

local function showText(model, text, color)
	local head = model:FindFirstChild("Head")
	if not head then return end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 220, 0, 50)
	gui.StudsOffset = Vector3.new(0, 4, 0)
	gui.AlwaysOnTop = true
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color
	label.TextStrokeTransparency = 0
	label.TextScaled = true
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
	gui.Parent = head
	Debris:AddItem(gui, 1.5)
end

-- Círculo rojo en el piso que avisa dónde va a pegar
local function telegraph(position, radius, duration)
	local result = workspace:Raycast(position + Vector3.new(0, 5, 0), Vector3.new(0, -60, 0))
	local groundY = result and result.Position.Y or position.Y - 3
	local disc = Instance.new("Part")
	disc.Shape = Enum.PartType.Cylinder
	disc.Anchored = true
	disc.CanCollide = false
	disc.CanQuery = false
	disc.CanTouch = false
	disc.Material = Enum.Material.Neon
	disc.Color = Color3.fromRGB(255, 40, 40)
	disc.Transparency = 0.75
	disc.Size = Vector3.new(0.2, radius * 2, radius * 2)
	disc.CFrame = CFrame.new(position.X, groundY + 0.15, position.Z) * CFrame.Angles(0, 0, math.rad(90))
	disc.Parent = workspace
	TweenService:Create(disc, TweenInfo.new(duration), { Transparency = 0.25 }):Play()
	Debris:AddItem(disc, duration + 0.1)
end

local function flatDistance(a, b)
	return Vector3.new(a.X - b.X, 0, a.Z - b.Z).Magnitude
end

local function faceTowards(root, position)
	root.CFrame = CFrame.lookAt(root.Position, Vector3.new(position.X, root.Position.Y, position.Z))
end

---------------------------------------------------------------- Recompensas
local function grantVictory(player, fight, bossId, data)
	local d = PlayerData.get(player)
	if not d then return end
	d.BossCooldowns = d.BossCooldowns or {}
	d.BossCooldowns[bossId] = os.time() + data.Cooldown

	notify:FireClient(player, "¡" .. string.upper(data.Name) .. " HA CAÍDO!", "Legendary")
	Rewards.addEssence(player, data.Essence)
	Rewards.addGold(player, rng:NextInteger(data.Gold[1], data.Gold[2]))
	for _, drop in data.Loot do
		if rng:NextNumber() <= drop.Chance then
			Rewards.addItem(player, drop.Item, rng:NextInteger(drop.Min, drop.Max))
		end
	end

	-- El Alma: más difícil de obtener si el grupo supera el nivel recomendado
	local soul = data.Soul
	local excess = math.max(0, fight.maxLevel - data.RecommendedLevel)
	local chance = math.max(soul.MinChance, soul.BaseChance * soul.LevelPenalty ^ excess)
	if rng:NextNumber() <= chance then
		d.Souls = d.Souls or {}
		if #d.Souls < (d.SoulFlasks or 0) then
			table.insert(d.Souls, { Boss = bossId, Essence = 0 })
			notify:FireClient(player, "Obtuviste: " .. soul.Name, "Mythic")
		else
			notify:FireClient(player, "El alma escapó… (no tenías un frasco vacío)", "Mythic")
		end
	end
	PlayerData.save(player)
end

---------------------------------------------------------------- Arena
local function runArena(arena)
	local bossId = arena:GetAttribute("BossId")
	local data = Bosses[bossId]
	local template = bossTemplates:FindFirstChild(bossId)
	if not data or not template then
		warn("Arena sin jefe válido: " .. arena:GetFullName())
		return
	end

	local gate = arena:WaitForChild("FogGate")
	local prompt = gate:FindFirstChildWhichIsA("ProximityPrompt")
	local bossSpawn = arena:WaitForChild("BossSpawn")
	local playerSpawn = arena:WaitForChild("PlayerSpawn")
	local attacks = data.Attacks
	local fight = nil

	local function setGate(locked)
		prompt.Enabled = not locked
		gate.CanCollide = locked -- sólida solo durante la pelea
		gate.Transparency = locked and 0.25 or 0.6
		gate.Color = locked and Color3.fromRGB(170, 170, 255) or Color3.fromRGB(240, 240, 240)
	end

	local function aliveTargets(f)
		local list = {}
		for player in f.alive do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root then
				table.insert(list, { character = character, root = root })
			end
		end
		return list
	end

	local function nearestTarget(f)
		local best, bestDistance = nil, math.huge
		for _, t in aliveTargets(f) do
			local distance = (t.root.Position - f.root.Position).Magnitude
			if distance < bestDistance then
				best, bestDistance = t, distance
			end
		end
		return best, bestDistance
	end

	local function hitArea(f, center, radius, damage)
		for _, t in aliveTargets(f) do
			if flatDistance(t.root.Position, center) <= radius then
				damageEvent:Fire(f.boss, t.character, damage)
			end
		end
	end

	local endFight -- se define abajo

	local function checkFail(f)
		if fight == f and next(f.alive) == nil then
			endFight(f, false)
		end
	end

	---------------------------------------------------------------- Esbirros
	local function minionBrain(f, minion)
		local humanoid = minion:FindFirstChildOfClass("Humanoid")
		local root = minion:FindFirstChild("HumanoidRootPart")
		local lastAttack = 0
		while fight == f and humanoid.Health > 0 and minion.Parent do
			task.wait(0.3)
			if minion:GetAttribute("Stunned") then continue end
			local best, bestDistance = nil, math.huge
			for _, t in aliveTargets(f) do
				local distance = (t.root.Position - root.Position).Magnitude
				if distance < bestDistance then best, bestDistance = t, distance end
			end
			if not best then continue end
			if bestDistance <= 5.5 and os.clock() - lastAttack > 1.6 then
				lastAttack = os.clock()
				humanoid:MoveTo(root.Position)
				faceTowards(root, best.root.Position)
				flash(minion, 0.5)
				task.wait(0.5)
				if humanoid.Health > 0 and not minion:GetAttribute("Stunned")
					and (best.root.Position - root.Position).Magnitude <= 7 then
					damageEvent:Fire(minion, best.character, data.Minions.Damage * f.damageMult)
				end
			else
				humanoid:MoveTo(best.root.Position)
			end
		end
		if minion.Parent then
			task.wait(2)
			minion:Destroy()
		end
	end

	local function spawnMinions(f)
		local skeleton = enemyTemplates:FindFirstChild("Skeleton")
		if not skeleton then return end
		for i = 1, data.Minions.Count do
			local minion = skeleton:Clone()
			minion.Name = "Esbirro"
			minion:SetAttribute("IsEnemy", true)
			local humanoid = minion:FindFirstChildOfClass("Humanoid")
			humanoid.MaxHealth = data.Minions.Health
			humanoid.Health = data.Minions.Health
			humanoid.WalkSpeed = 13
			minion:PivotTo(f.root.CFrame * CFrame.new(i % 2 == 0 and 7 or -7, 0, 0))
			minion.Parent = workspace
			minion.HumanoidRootPart:SetNetworkOwner(nil)
			table.insert(f.minions, minion)
			task.spawn(minionBrain, f, minion)
		end
	end

	---------------------------------------------------------------- Ataques del jefe
	local function isReady(f, name, cooldown)
		local last = f.cooldowns[name]
		return not last or os.clock() - last >= cooldown
	end

	local function interrupted(f)
		return fight ~= f or f.humanoid.Health <= 0 or f.boss:GetAttribute("Stunned")
	end

	local function doCombo(f, target)
		local speed = f.phase == 2 and 0.75 or 1
		f.humanoid:MoveTo(f.root.Position)
		for i, windup in { attacks.Combo.Windup, attacks.Combo.SecondWindup } do
			faceTowards(f.root, target.root.Position)
			windup *= speed
			flash(f.boss, windup)
			local track = f.tracks[i == 1 and "Light1" or "Light2"]
			if track then track:Play() end
			task.wait(windup)
			if interrupted(f) then return end
			-- Golpea a todos los que estén adelante y a rango
			for _, t in aliveTargets(f) do
				local offset = t.root.Position - f.root.Position
				if offset.Magnitude <= attacks.Combo.Range + 1.5 and f.root.CFrame.LookVector:Dot(offset.Unit) > 0.2 then
					damageEvent:Fire(f.boss, t.character, attacks.Combo.Damage * f.damageMult)
				end
			end
		end
		task.wait(0.6 * speed)
	end

	local function doSlam(f)
		local speed = f.phase == 2 and 0.75 or 1
		local windup = attacks.Slam.Windup * speed
		f.cooldowns.Slam = os.clock()
		f.humanoid:MoveTo(f.root.Position)
		telegraph(f.root.Position, attacks.Slam.Radius, windup)
		flash(f.boss, windup)
		if f.tracks.Light3 then f.tracks.Light3:Play() end
		task.wait(windup)
		if interrupted(f) then return end
		hitArea(f, f.root.Position, attacks.Slam.Radius, attacks.Slam.Damage * f.damageMult)
		task.wait(1 * speed)
	end

	local function doLeap(f, target)
		local windup = attacks.Leap.Windup
		f.cooldowns.Leap = os.clock()
		f.humanoid:MoveTo(f.root.Position)
		local landing = target.root.Position
		telegraph(landing, attacks.Leap.Radius, windup)
		flash(f.boss, windup)
		if f.tracks.Heavy then f.tracks.Heavy:Play() end
		task.wait(windup)
		if interrupted(f) then return end

		-- Salto en arco hasta el punto marcado
		local start = f.root.Position
		local finish = Vector3.new(landing.X, start.Y, landing.Z)
		for step = 1, 10 do
			local alpha = step / 10
			local position = start:Lerp(finish, alpha) + Vector3.new(0, math.sin(alpha * math.pi) * 10, 0)
			f.root.CFrame = CFrame.lookAt(position, Vector3.new(finish.X, position.Y, finish.Z) + (finish - start).Unit)
			task.wait(0.04)
		end
		hitArea(f, finish, attacks.Leap.Radius, attacks.Leap.Damage * f.damageMult)
		task.wait(1.2)
	end

	local function bossBrain(f)
		while fight == f and f.humanoid.Health > 0 do
			task.wait(TICK)
			if interrupted(f) then continue end

			-- Fase 2
			if f.phase == 1 and f.humanoid.Health <= f.humanoid.MaxHealth * 0.5 then
				f.phase = 2
				f.humanoid.WalkSpeed = data.EnragedWalkSpeed
				showText(f.boss, "¡FURIA!", Color3.fromRGB(255, 60, 60))
				for player in f.participants do
					notify:FireClient(player, "¡El " .. data.Name .. " se enfurece!", "Legendary")
				end
				spawnMinions(f)
			end

			local target, distance = nearestTarget(f)
			if not target then continue end

			if f.phase == 2 and distance >= attacks.Leap.MinDistance and isReady(f, "Leap", attacks.Leap.Cooldown) then
				doLeap(f, target)
			elseif distance <= attacks.Combo.Range + 2 then
				if isReady(f, "Slam", attacks.Slam.Cooldown) and rng:NextNumber() < 0.35 then
					doSlam(f)
				else
					doCombo(f, target)
				end
			else
				f.humanoid:MoveTo(target.root.Position)
			end
		end
	end

	---------------------------------------------------------------- Empezar y terminar
	endFight = function(f, victory)
		if fight ~= f or f.ending then return end
		f.ending = true
		for _, connection in f.connections do
			connection:Disconnect()
		end
		for _, minion in f.minions do
			if minion.Parent then minion:Destroy() end
		end

		if victory then
			for player in f.participants do
				if player.Parent then
					grantVictory(player, f, bossId, data)
				end
			end
			task.wait(4) -- el cuerpo del jefe queda tirado un momento
		end

		if f.boss.Parent then f.boss:Destroy() end
		for player in f.participants do
			if player.Parent then player:SetAttribute("InBossFight", nil) end
		end
		fight = nil
		setGate(false)
	end

	local function startFight(group)
		local maxLevel = 1
		for _, player in group do
			maxLevel = math.max(maxLevel, PlayerData.get(player).Level)
		end
		local healthMult = (1 + data.HealthPerLevel * (maxLevel - 1)) * (1 + data.HealthPerExtraPlayer * (#group - 1))

		local boss = template:Clone()
		boss.Name = data.Name
		boss:SetAttribute("IsEnemy", true)
		boss:SetAttribute("IsBoss", true)
		boss:SetAttribute("BossArena", arena.Name)
		local humanoid = boss:FindFirstChildOfClass("Humanoid")
		local root = boss:FindFirstChild("HumanoidRootPart")
		humanoid.MaxHealth = math.floor(data.BaseHealth * healthMult)
		humanoid.Health = humanoid.MaxHealth
		humanoid.WalkSpeed = data.WalkSpeed
		boss:PivotTo(bossSpawn.CFrame + Vector3.new(0, 5, 0))
		boss.Parent = workspace
		root:SetNetworkOwner(nil)

		local f = {
			boss = boss, humanoid = humanoid, root = root,
			participants = {}, alive = {}, minions = {}, cooldowns = {}, connections = {},
			damageMult = 1 + data.DamagePerLevel * (maxLevel - 1),
			maxLevel = maxLevel, phase = 1,
			tracks = {
				Light1 = loadTrack(humanoid, "Light1"),
				Light2 = loadTrack(humanoid, "Light2"),
				Light3 = loadTrack(humanoid, "Light3"),
				Heavy = loadTrack(humanoid, "Heavy"),
			},
		}
		fight = f
		setGate(true)

		for i, player in group do
			f.participants[player] = true
			f.alive[player] = true
			player:SetAttribute("InBossFight", arena.Name)
			player.Character:PivotTo(playerSpawn.CFrame * CFrame.new((i - 2.5) * 4, 3, 0))
			notify:FireClient(player, "El " .. data.Name .. " te desafía", "Legendary")

			local playerHumanoid = player.Character:FindFirstChildOfClass("Humanoid")
			table.insert(f.connections, playerHumanoid.Died:Connect(function()
				f.alive[player] = nil
				player:SetAttribute("InBossFight", nil)
				checkFail(f)
			end))
		end
		table.insert(f.connections, Players.PlayerRemoving:Connect(function(player)
			if f.alive[player] then
				f.alive[player] = nil
				checkFail(f)
			end
		end))
		table.insert(f.connections, humanoid.Died:Connect(function()
			endFight(f, true)
		end))

		task.spawn(bossBrain, f)
	end

	---------------------------------------------------------------- Entrar por la niebla
	prompt.Triggered:Connect(function(triggeringPlayer)
		if fight then
			notify:FireClient(triggeringPlayer, "Hay una pelea en curso", "Common")
			return
		end

		-- El que activó la niebla va primero; después, los que estén cerca
		local candidates = { triggeringPlayer }
		for _, player in Players:GetPlayers() do
			if player ~= triggeringPlayer then
				table.insert(candidates, player)
			end
		end

		local group = {}
		for _, player in candidates do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local d = PlayerData.get(player)
			if #group < MAX_GROUP and d and humanoid and humanoid.Health > 0 and root
				and (root.Position - gate.Position).Magnitude <= GROUP_RADIUS then
				local unlock = d.BossCooldowns and d.BossCooldowns[bossId]
				if unlock and os.time() < unlock then
					notify:FireClient(player, string.format("Podés volver a enfrentar al %s en %d min",
						data.Name, math.ceil((unlock - os.time()) / 60)), "Common")
				else
					table.insert(group, player)
				end
			end
		end

		if #group > 0 then
			startFight(group)
		end
	end)

	setGate(false)
end

for _, arena in arenasFolder:GetChildren() do
	task.spawn(runArena, arena)
end
arenasFolder.ChildAdded:Connect(function(arena)
	task.spawn(runArena, arena)
end)