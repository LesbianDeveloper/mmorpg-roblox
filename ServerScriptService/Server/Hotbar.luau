local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Items = require(ReplicatedStorage.Shared.Items)
local PlayerData = require(script.Parent.PlayerData)

local notify = ReplicatedStorage:WaitForChild("Notify")

local SLOTS = 6
local Hotbar = {}
local lastUse = {}

local function getBar(data)
	data.Hotbar = data.Hotbar or {} -- claves "1".."6" (texto, para que el DataStore las guarde bien)
	return data.Hotbar
end

-- Dibuja el objeto en la mano derecha
local function buildVisual(character, itemId)
	local old = character:FindFirstChild("HeldVisual")
	if old then old:Destroy() end

	local item = itemId and Items[itemId]
	local hand = character:FindFirstChild("RightHand") or character:FindFirstChild("Right Arm")
	if not item or not hand then return end

	local part = Instance.new("Part")
	part.Name = "HeldVisual"
	part.CanCollide = false
	part.CanQuery = false
	part.CanTouch = false
	part.Massless = true

	local offset
	if item.Type == "Weapon" then
		part.Size = Vector3.new(0.2, 0.4, 3.6)
		part.Material = Enum.Material.Metal
		part.Color = item.Color or Color3.fromRGB(170, 170, 175)
		offset = CFrame.new(0, -0.2, -1.6) -- hoja apuntando hacia adelante
	else
		part.Shape = Enum.PartType.Cylinder
		part.Size = Vector3.new(0.8, 0.55, 0.55)
		part.Material = Enum.Material.Glass
		part.Transparency = 0.2
		part.Color = Color3.fromRGB(220, 40, 50)
		offset = CFrame.new(0, -0.45, 0) * CFrame.Angles(0, 0, math.rad(90))
	end

	part.CFrame = hand.CFrame * offset
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = hand
	weld.Part1 = part
	weld.Parent = part
	part.Parent = character
end

-- Recalcula qué tenés en la mano (slot activo + que el objeto siga en el inventario)
function Hotbar.refresh(player)
	local data = PlayerData.get(player)
	if not data then return end
	local slot = player:GetAttribute("ActiveSlot") or 1
	local itemId = getBar(data)[tostring(slot)]
	if itemId and (data.Inventory[itemId] or 0) <= 0 then
		itemId = nil
	end
	if player:GetAttribute("HeldItem") ~= itemId then
		player:SetAttribute("HeldItem", itemId)
	end
	if player.Character then
		buildVisual(player.Character, itemId)
	end
end

function Hotbar.assign(player, itemId)
	local data = PlayerData.get(player)
	local item = Items[itemId]
	if not data or not item or (item.Type ~= "Weapon" and item.Type ~= "Consumable") then
		return false
	end
	if (data.Inventory[itemId] or 0) <= 0 then return false end

	local bar = getBar(data)
	for i = 1, SLOTS do
		if bar[tostring(i)] == itemId then
			notify:FireClient(player, "Ya está en la barra", "Common")
			return false
		end
	end
	for i = 1, SLOTS do
		if not bar[tostring(i)] then
			bar[tostring(i)] = itemId
			Hotbar.refresh(player)
			return true
		end
	end
	notify:FireClient(player, "La barra está llena (clic derecho en un slot para vaciarlo)", "Common")
	return false
end

function Hotbar.clear(player, slot)
	local data = PlayerData.get(player)
	if not data or typeof(slot) ~= "number" or slot < 1 or slot > SLOTS then return end
	getBar(data)[tostring(math.floor(slot))] = nil
	Hotbar.refresh(player)
end

function Hotbar.select(player, slot)
	if typeof(slot) ~= "number" or slot < 1 or slot > SLOTS then return end
	player:SetAttribute("ActiveSlot", math.floor(slot))
	Hotbar.refresh(player)
end

-- Usar el objeto en la mano (por ahora: beber pociones)
function Hotbar.use(player)
	local data = PlayerData.get(player)
	local itemId = player:GetAttribute("HeldItem")
	local item = itemId and Items[itemId]
	if not data or not item or item.Type ~= "Consumable" then return end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	if character:GetAttribute("Stunned") or character:GetAttribute("Drinking") then return end
	if lastUse[player] and os.clock() - lastUse[player] < (item.Cooldown or 1) then return end
	if (data.Inventory[itemId] or 0) <= 0 then return end

	lastUse[player] = os.clock()
	data.Inventory[itemId] -= 1 -- se consume al empezar a beber: no hay vuelta atrás
	if data.Inventory[itemId] <= 0 then
		data.Inventory[itemId] = nil
	end

	character:SetAttribute("Drinking", true)
	humanoid.WalkSpeed = 6

	task.delay(item.UseTime or 1, function()
		if character.Parent then
			character:SetAttribute("Drinking", nil)
			if not character:GetAttribute("Blocking") then
				humanoid.WalkSpeed = 16
			end
		end
		if humanoid.Health > 0 and item.Heal then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + humanoid.MaxHealth * item.Heal)
		end
		Hotbar.refresh(player)
		notify:FireClient(player, item.Name .. " (quedan " .. (data.Inventory[itemId] or 0) .. ")", item.Rarity)
	end)
end

function Hotbar.forget(player)
	lastUse[player] = nil
end

return Hotbar