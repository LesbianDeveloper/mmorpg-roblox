local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Classes = require(ReplicatedStorage.Shared.Classes)
local Races = require(ReplicatedStorage.Shared.Races)
local PlayerData = require(script.Parent.PlayerData)
local RaceService = require(script.Parent.RaceService)

local request = Instance.new("RemoteFunction")
request.Name = "CreationRequest"
request.Parent = ReplicatedStorage

local function waitForData(player)
	while player.Parent and not PlayerData.get(player) do
		task.wait(0.2)
	end
	return PlayerData.get(player)
end

local function setFrozen(player, frozen)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if root then
		root.Anchored = frozen
	end
end

request.OnServerInvoke = function(player, action, value)
	local data = PlayerData.get(player)
	if not data then return false, "Datos no cargados" end
	if data.CharacterCreated then return false, "Tu personaje ya fue creado" end

	if action == "chooseClass" then
		local class = typeof(value) == "string" and Classes.ById[value]
		if not class or not class.Enabled or class.Access ~= "Base" then
			return false, "Clase no disponible"
		end
		PlayerData.set(player, "Class", class.Id)
		return true, class.Name

	elseif action == "roll" then
		if data.FreeRollUsed then
			return false, "Ya usaste tu tirada gratis"
		end
		PlayerData.set(player, "FreeRollUsed", true) -- se marca ANTES de tirar: no se puede repetir
		RaceService.roll(player, true)
		PlayerData.save(player)
		return true, data.Race

	elseif action == "finish" then
		if not data.FreeRollUsed then
			return false, "Primero tirá tu raza"
		end
		PlayerData.set(player, "CharacterCreated", true)
		setFrozen(player, false)
		PlayerData.save(player)
		return true, "¡Bienvenido!"
	end

	return false, "Acción inválida"
end

-- Mientras no termine la creación, el personaje queda quieto
local function onCharacter(player, character)
	local data = waitForData(player)
	if data and not data.CharacterCreated then
		local root = character:WaitForChild("HumanoidRootPart")
		root.Anchored = true
	end
end

local function onPlayer(player)
	player.CharacterAdded:Connect(function(character)
		onCharacter(player, character)
	end)
	if player.Character then
		task.spawn(onCharacter, player, player.Character)
	end
end

Players.PlayerAdded:Connect(onPlayer)
for _, player in Players:GetPlayers() do
	task.spawn(onPlayer, player)
end