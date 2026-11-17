local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("CombatConfig"))
local remote = ReplicatedStorage:WaitForChild("CombatAction")
local player = Players.LocalPlayer

-- Esquiva: el impulso se hace en el cliente para que se sienta instantáneo;
-- la invulnerabilidad la da el servidor
local lastDodge = 0
local function dodge()
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then return end
	if character:GetAttribute("Stunned") then return end
	if os.clock() - lastDodge < Config.Dodge.Cooldown then return end
	if (player:GetAttribute("Stamina") or 0) < Config.Dodge.Stamina then return end
	lastDodge = os.clock()
	remote:FireServer("Dodge")

	-- Si te movés, esquiva en esa dirección; si estás quieto, salta hacia atrás
	local direction = humanoid.MoveDirection.Magnitude > 0
		and humanoid.MoveDirection
		or -root.CFrame.LookVector
	local attachment = Instance.new("Attachment")
	attachment.Parent = root
	local velocity = Instance.new("LinearVelocity")
	velocity.Attachment0 = attachment
	velocity.MaxForce = math.huge
	velocity.VectorVelocity = Vector3.new(direction.X, 0, direction.Z).Unit * Config.Dodge.Speed
	velocity.Parent = root
	task.delay(Config.Dodge.Duration, function()
		velocity:Destroy()
		attachment:Destroy()
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		remote:FireServer("Light")
	elseif input.KeyCode == Enum.KeyCode.E then
		remote:FireServer("Heavy")
	elseif input.KeyCode == Enum.KeyCode.Q then
		dodge()
	elseif input.KeyCode == Enum.KeyCode.F then
		remote:FireServer("BlockStart")
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		remote:FireServer("BlockEnd")
	end
end)

-- HUD: barras de vida y estamina
local gui = Instance.new("ScreenGui")
gui.Name = "HUD"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local function makeBar(offsetY, color)
	local back = Instance.new("Frame")
	back.Size = UDim2.new(0, 260, 0, 16)
	back.Position = UDim2.new(0, 20, 1, offsetY)
	back.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	back.BorderSizePixel = 0
	back.Parent = gui
	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(1, 1)
	fill.BackgroundColor3 = color
	fill.BorderSizePixel = 0
	fill.Parent = back
	return fill
end

local healthFill = makeBar(-60, Color3.fromRGB(200, 50, 50))
local staminaFill = makeBar(-38, Color3.fromRGB(80, 200, 80))

RunService.RenderStepped:Connect(function()
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if humanoid and humanoid.MaxHealth > 0 then
		healthFill.Size = UDim2.fromScale(math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1), 1)
	end
	local stamina, max = player:GetAttribute("Stamina"), player:GetAttribute("MaxStamina")
	if stamina and max then
		staminaFill.Size = UDim2.fromScale(math.clamp(stamina / max, 0, 1), 1)
	end
end)