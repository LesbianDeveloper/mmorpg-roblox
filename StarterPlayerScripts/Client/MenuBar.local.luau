local UserInputService = game:GetService("UserInputService")

local UIKit = require(script.Parent:WaitForChild("UIKit"))

-- Para agregar una ventana nueva al menú, sumá una línea acá
local MENU = {
	{ Window = "Inventory", Icon = "🎒", Key = Enum.KeyCode.B, Tooltip = "Inventario (B)" },
	{ Window = "Equipment", Icon = "⚔️", Key = Enum.KeyCode.C, Tooltip = "Equipo (C)" },
	{ Window = "Spellbook", Icon = "📖", Key = Enum.KeyCode.K, Tooltip = "Habilidades (K)" },
	{ Window = "Souls", Icon = "🔮", Key = Enum.KeyCode.J, Tooltip = "Almas (J)" },
}

local BUTTON_SIZE = 52

local bar = Instance.new("Frame")
bar.Size = UDim2.new(0, #MENU * (BUTTON_SIZE + 8), 0, BUTTON_SIZE)
bar.Position = UDim2.new(1, -(#MENU * (BUTTON_SIZE + 8)) - 12, 1, -BUTTON_SIZE - 40)
bar.BackgroundTransparency = 1
bar.Parent = UIKit.Gui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.Padding = UDim.new(0, 8)
layout.Parent = bar

local tooltip = UIKit.label(UIKit.Gui, "", UDim2.new(0, 200, 0, 20), UDim2.new(1, -212, 1, -BUTTON_SIZE - 64), 14)
tooltip.TextXAlignment = Enum.TextXAlignment.Right

for _, item in MENU do
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(0, BUTTON_SIZE, 0, BUTTON_SIZE)
	button.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	button.BackgroundTransparency = 0.15
	button.Text = item.Icon
	button.TextSize = 28
	button.Parent = bar
	UIKit.corner(button, 10)
	UIKit.stroke(button, Color3.fromRGB(120, 100, 60), 2)

	button.MouseButton1Click:Connect(function()
		UIKit.toggle(item.Window)
	end)
	button.MouseEnter:Connect(function()
		tooltip.Text = item.Tooltip
	end)
	button.MouseLeave:Connect(function()
		tooltip.Text = ""
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	for _, item in MENU do
		if input.KeyCode == item.Key then
			UIKit.toggle(item.Window)
		end
	end
end)