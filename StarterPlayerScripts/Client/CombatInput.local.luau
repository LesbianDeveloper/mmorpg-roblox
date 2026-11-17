local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Config = require(Shared:WaitForChild("CombatConfig"))
local Animations = require(Shared:WaitForChild("Animations"))
local remote = ReplicatedStorage:WaitForChild("CombatAction")
local player = Players.LocalPlayer

---------------------------------------------------------------- Animaciones
local tracks = {}

local function getTrack(name)
	local id = Animations[name]
	if not id or id == "" then return nil end
	if tracks[name] then return tracks[name] end
	local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if not animator then return nil end
	local animation = Instance.new("Animation")
	animation.AnimationId = "rbxassetid://" .. id
	tracks[name] = animator:LoadAnimation(animation)
	return tracks[name]
end

local function play(name)
	local track = getTrack(name)
	if track then track:Play(0.05) end
end

local function stop(name)
	local track = tracks[name]
	if track then track:Stop(0.15) end
end

---------------------------------------------------------------- Helpers
local function getCharacter()
	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return nil end
	if character:GetAttribute("Stunned") then return nil end
	return character, humanoid
end

local function hasStamina(amount)
	return (player:GetAttribute("Stamina") or 0) >= amount
end

---------------------------------------------------------------- Acciones
local lastLight, lastLightCombo, combo = 0, 0, 1
local function lightAttack()
	local cfg = Config.Attacks.Light
	if not getCharacter() then return end
	if os.clock() - lastLight < cfg.Cooldown or not hasStamina(cfg.Stamina) then return end
	lastLight = os.clock()

	if os.clock() - lastLightCombo > cfg.ComboReset then combo = 1 end
	lastLightCombo = os.clock()
	stop("Block")
	play("Light" .. combo)
	combo = combo % #cfg.Damage + 1
	remote:FireServer("Light")
end

local lastHeavy = 0
local function heavyAttack()
	local cfg = Config.Attacks.Heavy
	if not getCharacter() then return end
	if os.clock() - lastHeavy < cfg.Cooldown or not hasStamina(cfg.Stamina) then return end
	lastHeavy = os.clock()
	stop("Block")
	play("Heavy")
	remote:FireServer("Heavy")
end

local lastDodge = 0
local function dodge()
	local character, humanoid = getCharacter()
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if os.clock() - lastDodge < Config.Dodge.Cooldown or not hasStamina(Config.Dodge.Stamina) then return end
	lastDodge = os.clock()
	stop("Block")
	play("Dodge")
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

local function blockStart()
	if not getCharacter() then return end
	play("Block")
	remote:FireServer("BlockStart")
end

local function blockEnd()
	stop("Block")
	remote:FireServer("BlockEnd")
end

---------------------------------------------------------------- Input
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		lightAttack()
	elseif input.KeyCode == Enum.KeyCode.E then
		heavyAttack()
	elseif input.KeyCode == Enum.KeyCode.Q then
		dodge()
	elseif input.KeyCode == Enum.KeyCode.F then
		blockStart()
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.F then
		blockEnd()
	end
end)

---------------------------------------------------------------- Personaje
local function onCharacter(character)
	table.clear(tracks) -- las animaciones se recargan en cada personaje nuevo
	character:GetAttributeChangedSignal("Stunned"):Connect(function()
		if character:GetAttribute("Stunned") then
			stop("Block")
			play("Stunned")
		else
			stop("Stunned")
		end
	end)
	character:GetAttributeChangedSignal("Blocking"):Connect(function()
		if not character:GetAttribute("Blocking") then
			stop("Block") -- por si el servidor te rompe la guardia
		end
	end)
end

player.CharacterAdded:Connect(onCharacter)
if player.Character then onCharacter(player.Character) end

---------------------------------------------------------------- HUD
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