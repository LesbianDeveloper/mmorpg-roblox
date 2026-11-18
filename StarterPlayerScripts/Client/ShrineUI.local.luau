local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local Stats = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Stats"))
local shrineRequest = ReplicatedStorage:WaitForChild("ShrineRequest")
local player = Players.LocalPlayer

local GREEN = Color3.fromRGB(90, 220, 90)
local RED = Color3.fromRGB(240, 80, 80)
local GOLD = Color3.fromRGB(255, 200, 90)

local window, content, entry = UIKit.createWindow("Shrine", "Santuario", UDim2.new(0, 380, 0, 300))
local currentShrine = nil

local shrineName = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 0), 16, GOLD)
local levelLabel = UIKit.label(content, "", UDim2.new(1, 0, 0, 24), UDim2.new(0, 0, 0, 36), 20)
local essenceLabel = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 70), 16, Color3.fromRGB(170, 120, 255))
local costLabel = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 96), 15)

local levelButton = Instance.new("TextButton")
levelButton.Size = UDim2.new(1, -40, 0, 44)
levelButton.Position = UDim2.new(0, 20, 0, 140)
levelButton.Text = "Subir de nivel"
levelButton.Font = Enum.Font.GothamBold
levelButton.TextSize = 18
levelButton.TextColor3 = Color3.new(1, 1, 1)
levelButton.Parent = content
UIKit.corner(levelButton, 6)

local status = UIKit.label(content, "", UDim2.new(1, 0, 0, 22), UDim2.new(0, 0, 0, 196), 14)

local function refresh()
	local level = player:GetAttribute("Level") or 1
	local essence = player:GetAttribute("Essence") or 0
	local cost = Stats.XPForLevel(level)
	shrineName.Text = currentShrine and (currentShrine:GetAttribute("DisplayName") or currentShrine.Name) or ""
	levelLabel.Text = "Nivel " .. level
	essenceLabel.Text = "Esencia: " .. essence
	costLabel.Text = "Costo del siguiente nivel: " .. cost
	costLabel.TextColor3 = essence >= cost and GREEN or RED
	levelButton.BackgroundColor3 = essence >= cost and Color3.fromRGB(150, 90, 30) or Color3.fromRGB(60, 60, 60)
end

levelButton.MouseButton1Click:Connect(function()
	local ok, message = shrineRequest:InvokeServer("levelup")
	status.Text = message or ""
	status.TextColor3 = ok and GREEN or RED
	refresh()
end)

player:GetAttributeChangedSignal("Essence"):Connect(function()
	if window.Visible then refresh() end
end)
player:GetAttributeChangedSignal("Level"):Connect(function()
	if window.Visible then refresh() end
end)

entry.onOpen = function()
	status.Text = ""
	refresh()
end

ProximityPromptService.PromptTriggered:Connect(function(prompt)
	local shrine = prompt:FindFirstAncestorOfClass("Model")
	if not shrine or not shrine:GetAttribute("ShrineId") then return end
	currentShrine = shrine
	if not window.Visible then
		UIKit.toggle("Shrine")
	else
		entry.onOpen()
	end
end)

RunService.Heartbeat:Connect(function()
	if not window.Visible or not currentShrine then return end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (currentShrine:GetPivot().Position - root.Position).Magnitude > 16 then
		UIKit.toggle("Shrine")
	end
end)