local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))
local player = Players.LocalPlayer

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.5, 0, 0, 48)
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.new(0.5, 0, 0, 56)
frame.BackgroundTransparency = 1
frame.Visible = false
frame.Parent = UIKit.Gui

local nameLabel = UIKit.label(frame, "", UDim2.new(1, 0, 0, 24), UDim2.new(), 20, Color3.fromRGB(235, 210, 150))
nameLabel.Font = Enum.Font.GothamBlack

local back = Instance.new("Frame")
back.Size = UDim2.new(1, 0, 0, 14)
back.Position = UDim2.new(0, 0, 0, 28)
back.BackgroundColor3 = Color3.fromRGB(25, 20, 20)
back.BorderSizePixel = 0
back.Parent = frame
UIKit.stroke(back, Color3.fromRGB(120, 100, 60), 1.5)

local fill = Instance.new("Frame")
fill.Size = UDim2.fromScale(1, 1)
fill.BorderSizePixel = 0
fill.Parent = back

local boss = nil

local function findBoss(arenaName)
	for _, model in workspace:GetChildren() do
		if model:IsA("Model") and model:GetAttribute("BossArena") == arenaName then
			return model
		end
	end
	return nil
end

RunService.RenderStepped:Connect(function()
	local arenaName = player:GetAttribute("InBossFight")
	if not arenaName then
		frame.Visible = false
		boss = nil
		return
	end
	if not boss or not boss.Parent then
		boss = findBoss(arenaName)
	end
	local humanoid = boss and boss:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		frame.Visible = false
		return
	end
	local ratio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
	frame.Visible = true
	nameLabel.Text = boss.Name
	fill.Size = UDim2.fromScale(ratio, 1)
	fill.BackgroundColor3 = ratio > 0.5 and Color3.fromRGB(170, 30, 30) or Color3.fromRGB(230, 90, 20) -- fase 2
end)