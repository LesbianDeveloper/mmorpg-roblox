local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.Items)
local Stats = require(ReplicatedStorage.Shared.Stats)
local PlayerData = require(script.Parent.PlayerData)

local notify = ReplicatedStorage:WaitForChild("Notify")
local shrinesFolder = workspace:WaitForChild("Shrines")

local PICKUP_RANGE = 6   -- distancia para recoger el Remanente
local SHRINE_RANGE = 14  -- distancia para usar un santuario
local MAX_LEVEL = 60

local shrineRequest = Instance.new("RemoteFunction")
shrineRequest.Name = "ShrineRequest"
shrineRequest.Parent = ReplicatedStorage

---------------------------------------------------------------- Helpers
local function waitForData(player)
	while player.Parent and not PlayerData.get(player) do
		task.wait(0.2)
	end
	return PlayerData.get(player)
end

local function getShrine(shrineId)
	for _, shrine in shrinesFolder:GetChildren() do
		if shrine:GetAttribute("ShrineId") == shrineId then
			return shrine
		end
	end
	return nil
end

local function isNearShrine(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then return false end
	for _, shrine in shrinesFolder:GetChildren() do
		if (shrine:GetPivot().Position - root.Position).Magnitude <= SHRINE_RANGE then
			return true
		end
	end
	return false
end

-- Copia la posición del Remanente a atributos, para que el cliente lo dibuje
local function mirrorRemnant(player)
	local data = PlayerData.get(player)
	local remnant = data and data.Remnant
	if remnant then
		local p = remnant.Position
		player:SetAttribute("RemnantPos", Vector3.new(p[1], p[2], p[3]))
		player:SetAttribute("RemnantEssence", remnant.Essence)
	else
		player:SetAttribute("RemnantPos", nil)
		player:SetAttribute("RemnantEssence", nil)
	end
end

---------------------------------------------------------------- Muerte
local function onDied(player, character)
	local data = PlayerData.get(player)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not data or not root then return end

	if data.Remnant then
		notify:FireClient(player, "Tu Remanente anterior se perdió para siempre", "Mythic")
	end

	-- Juntar lo que se pierde: Esencia, oro y materiales
	local lostItems = {}
	local hasSomething = (data.Essence or 0) > 0 or data.Gold > 0
	for itemId, quantity in data.Inventory do
		local item = Items[itemId]
		if item and item.Type == "Material" then
			lostItems[itemId] = quantity
			data.Inventory[itemId] = nil
			hasSomething = true
		end
	end

	if hasSomething then
		local pos = root.Position
		data.Remnant = {
			Essence = data.Essence or 0,
			Gold = data.Gold,
			Items = lostItems,
			Position = { pos.X, pos.Y, pos.Z },
		}
		PlayerData.set(player, "Essence", 0)
		PlayerData.set(player, "Gold", 0)
		notify:FireClient(player, "Moriste. Tu Remanente quedó donde caíste", "Legendary")
	else
		data.Remnant = nil
	end

	mirrorRemnant(player)
	PlayerData.save(player) -- se guarda al instante, por si se desconecta
end

---------------------------------------------------------------- Recuperar el Remanente
local function recover(player)
	local data = PlayerData.get(player)
	local remnant = data and data.Remnant
	if not remnant then return end
	data.Remnant = nil

	PlayerData.set(player, "Essence", (data.Essence or 0) + remnant.Essence)
	PlayerData.set(player, "Gold", data.Gold + remnant.Gold)
	for itemId, quantity in remnant.Items do
		data.Inventory[itemId] = (data.Inventory[itemId] or 0) + quantity
	end

	mirrorRemnant(player)
	notify:FireClient(player, "Recuperaste tu Remanente (+" .. remnant.Essence .. " Esencia)", "Legendary")
end

task.spawn(function()
	while true do
		task.wait(0.25)
		for _, player in Players:GetPlayers() do
			local remnantPos = player:GetAttribute("RemnantPos")
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if remnantPos and humanoid and humanoid.Health > 0 and root
				and (root.Position - remnantPos).Magnitude <= PICKUP_RANGE then
				recover(player)
			end
		end
	end
end)

---------------------------------------------------------------- Santuarios
local function rest(player, shrine)
	local data = PlayerData.get(player)
	if not data then return end
	local shrineId = shrine:GetAttribute("ShrineId")

	if not data.Shrines[shrineId] then
		data.Shrines[shrineId] = true
		notify:FireClient(player, "Santuario activado: " .. (shrine:GetAttribute("DisplayName") or shrine.Name), "Epic")
	end
	PlayerData.set(player, "LastShrine", shrineId)

	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.Health > 0 then
		humanoid.Health = humanoid.MaxHealth
	end
	player:SetAttribute("Stamina", player:GetAttribute("MaxStamina") or 100)
end

local function setupShrine(shrine)
	local prompt = shrine:FindFirstChildWhichIsA("ProximityPrompt", true)
	if prompt then
		prompt.Triggered:Connect(function(player)
			rest(player, shrine)
		end)
	end
end

for _, shrine in shrinesFolder:GetChildren() do
	setupShrine(shrine)
end
shrinesFolder.ChildAdded:Connect(setupShrine)

shrineRequest.OnServerInvoke = function(player, action)
	local data = PlayerData.get(player)
	if not data then return false, "Datos no cargados" end

	if action == "levelup" then
		if not isNearShrine(player) then return false, "Tenés que estar en un santuario" end
		if data.Level >= MAX_LEVEL then return false, "Ya estás en el nivel máximo" end
		local cost = Stats.XPForLevel(data.Level)
		if (data.Essence or 0) < cost then return false, "Esencia insuficiente" end
		PlayerData.set(player, "Essence", data.Essence - cost)
		PlayerData.set(player, "Level", data.Level + 1)
		return true, "¡Subiste a nivel " .. data.Level .. "!"
	end
	return false, "Acción inválida"
end

---------------------------------------------------------------- Personaje: muerte y reaparición
local function onCharacter(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()
		onDied(player, character)
	end)

	-- Reaparecer en el último santuario
	local data = waitForData(player)
	local shrine = data and data.LastShrine and getShrine(data.LastShrine)
	if shrine then
		character:WaitForChild("HumanoidRootPart")
		task.wait() -- deja que Roblox termine de ubicar al personaje
		character:PivotTo(shrine:GetPivot() * CFrame.new(0, 3, -6))
	end
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end
	task.spawn(function()
		if waitForData(player) then
			mirrorRemnant(player) -- por si quedó un Remanente de otra sesión
		end
	end)
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end