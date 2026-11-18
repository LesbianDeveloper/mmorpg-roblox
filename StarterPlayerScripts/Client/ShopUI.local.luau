local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Shared = ReplicatedStorage:WaitForChild("Shared")
local Items = require(Shared:WaitForChild("Items"))
local Shops = require(Shared:WaitForChild("Shops"))
local shopRequest = ReplicatedStorage:WaitForChild("ShopRequest")
local player = Players.LocalPlayer

local RARITY = UIKit.RARITY
local GREEN = Color3.fromRGB(90, 220, 90)
local RED = Color3.fromRGB(240, 80, 80)
local GOLD = Color3.fromRGB(255, 210, 60)

local window, content, entry = UIKit.createWindow("Shop", "Mercader", UDim2.new(0, 540, 0, 460))

local currentShopId, currentShopModel = nil, nil
local mode = "buy"
local lastSnapshot = nil

---------------------------------------------------------------- Pestañas
local function tabButton(text, x)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 120, 0, 30)
	b.Position = UDim2.new(0, x, 0, 0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 15
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Parent = content
	UIKit.corner(b, 6)
	return b
end
local buyTab = tabButton("Comprar", 0)
local sellTab = tabButton("Vender", 128)

local goldLabel = UIKit.label(content, "", UDim2.new(0, 200, 0, 30), UDim2.new(1, -200, 0, 0), 16, GOLD)
goldLabel.TextXAlignment = Enum.TextXAlignment.Right

local list = Instance.new("ScrollingFrame")
list.Size = UDim2.new(1, 0, 1, -72)
list.Position = UDim2.new(0, 0, 0, 38)
list.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
list.BorderSizePixel = 0
list.ScrollBarThickness = 6
list.CanvasSize = UDim2.new()
list.AutomaticCanvasSize = Enum.AutomaticSize.Y
list.Parent = content
UIKit.corner(list, 6)

local listPadding = Instance.new("UIPadding")
listPadding.PaddingTop = UDim.new(0, 6)
listPadding.PaddingLeft = UDim.new(0, 6)
listPadding.PaddingRight = UDim.new(0, 12)
listPadding.Parent = list

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = list

local status = UIKit.label(content, "", UDim2.new(1, 0, 0, 26), UDim2.new(0, 0, 1, -28), 14)

---------------------------------------------------------------- Filas
local function clearList()
	for _, child in list:GetChildren() do
		if child:IsA("Frame") then child:Destroy() end
	end
end

local function makeRow(order, title, titleColor, detail, buttons)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 58)
	row.LayoutOrder = order
	row.BackgroundColor3 = Color3.fromRGB(35, 35, 44)
	row.Parent = list
	UIKit.corner(row, 6)

	local name = UIKit.label(row, title, UDim2.new(1, -200, 0, 22), UDim2.new(0, 10, 0, 6), 15, titleColor)
	name.TextXAlignment = Enum.TextXAlignment.Left
	local info = UIKit.label(row, detail, UDim2.new(1, -200, 0, 24), UDim2.new(0, 10, 0, 28), 12, Color3.fromRGB(180, 180, 180))
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextWrapped = true
	info.Font = Enum.Font.Gotham

	for i, spec in buttons do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0, 88, 0, 34)
		b.Position = UDim2.new(1, -96 * (#buttons - i + 1), 0, 12)
		b.BackgroundColor3 = spec.Color
		b.Text = spec.Text
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Parent = row
		UIKit.corner(b, 6)
		b.MouseButton1Click:Connect(spec.OnClick)
	end
end

local function showResult(ok, message)
	status.Text = message or ""
	status.TextColor3 = ok and GREEN or RED
	UIKit.request("get") -- actualiza oro, inventario y barra rápida
end

local refresh -- se define abajo

local function buildBuy()
	local shop = Shops[currentShopId]
	if not shop then return end
	for index, item in shop.Buy do
		if item.Special == "SoulFlask" then
			local owned = player:GetAttribute("SoulFlasks") or 0
			makeRow(index, item.Name, RARITY[item.Rarity].Color,
				string.format("%s  ·  Tenés %d/3", item.Description, owned),
				{ { Text = item.Price .. " oro", Color = Color3.fromRGB(110, 60, 150), OnClick = function()
					showResult(shopRequest:InvokeServer("buy", index, 1))
				end } })
		else
			local data = Items[item.Item]
			local buttons = { { Text = item.Price .. " oro", Color = Color3.fromRGB(40, 90, 60), OnClick = function()
				showResult(shopRequest:InvokeServer("buy", index, 1))
			end } }
			if item.Bulk then
				table.insert(buttons, { Text = "x5 · " .. item.Price * 5, Color = Color3.fromRGB(40, 90, 60), OnClick = function()
					showResult(shopRequest:InvokeServer("buy", index, 5))
				end })
			end
			makeRow(index, data.Name, RARITY[data.Rarity].Color, item.Description or "", buttons)
		end
	end
end

local function buildSell()
	if not lastSnapshot then return end
	local order = 0
	for itemId, quantity in lastSnapshot.Items do
		local item = Items[itemId]
		if item and item.Value and quantity > 0 then
			order += 1
			makeRow(order, item.Name .. "  x" .. quantity, RARITY[item.Rarity].Color,
				string.format("Vale %d de oro c/u  ·  Total: %d", item.Value, item.Value * quantity),
				{
					{ Text = "Vender 1", Color = Color3.fromRGB(120, 80, 30), OnClick = function()
						showResult(shopRequest:InvokeServer("sell", itemId, 1))
					end },
					{ Text = "Todo", Color = Color3.fromRGB(150, 90, 30), OnClick = function()
						showResult(shopRequest:InvokeServer("sell", itemId, "all"))
					end },
				})
		end
	end
	if order == 0 then
		makeRow(1, "Nada para vender", Color3.fromRGB(150, 150, 150),
			"Las pociones, Runas, frascos y almas no se venden. El equipo puesto tampoco.", {})
	end
end

refresh = function()
	clearList()
	buyTab.BackgroundColor3 = mode == "buy" and Color3.fromRGB(150, 90, 30) or Color3.fromRGB(50, 50, 60)
	sellTab.BackgroundColor3 = mode == "sell" and Color3.fromRGB(150, 90, 30) or Color3.fromRGB(50, 50, 60)
	goldLabel.Text = "Oro: " .. (player:GetAttribute("Gold") or 0)
	if mode == "buy" then buildBuy() else buildSell() end
end

buyTab.MouseButton1Click:Connect(function()
	mode = "buy"
	status.Text = ""
	refresh()
end)
sellTab.MouseButton1Click:Connect(function()
	mode = "sell"
	status.Text = ""
	refresh()
end)

UIKit.DataChanged:Connect(function(snapshot)
	lastSnapshot = snapshot
	if window.Visible then refresh() end
end)
player:GetAttributeChangedSignal("Gold"):Connect(function()
	if window.Visible then refresh() end
end)

entry.onOpen = function()
	mode = "buy"
	status.Text = ""
	refresh()
	UIKit.request("get")
end

---------------------------------------------------------------- Abrir desde el mercader
ProximityPromptService.PromptTriggered:Connect(function(prompt)
	local shop = prompt:FindFirstAncestorOfClass("Model")
	local shopId = shop and shop:GetAttribute("ShopId")
	if not shopId then return end
	currentShopId = shopId
	currentShopModel = shop
	if not window.Visible then
		UIKit.toggle("Shop")
	else
		entry.onOpen()
	end
end)

RunService.Heartbeat:Connect(function()
	if not window.Visible or not currentShopModel then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (currentShopModel:GetPivot().Position - root.Position).Magnitude > 16 then
		UIKit.toggle("Shop")
	end
end)