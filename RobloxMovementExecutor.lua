-- Roblox 24 FPS Movement Executor Script
-- Paste this into your executor (Synapse X, Script-Ware, etc.)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

-- Configuration
local MOVE_SPEED = 50 -- Speed in studs per second
local TARGET_FPS = 24
local FRAME_TIME = 1 / TARGET_FPS

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

-- Movement state
local moveDirection = Vector3.new(0, 0, 0)
local lastUpdateTime = 0

-- Input handling
local inputConnections = {}

inputConnections.inputBegan = UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.W then
		moveDirection = moveDirection + Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection + Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection + Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection + Vector3.new(1, 0, 0)
	end
end)

inputConnections.inputEnded = UserInputService.InputEnded:Connect(function(input, gameProcessed)
	if input.KeyCode == Enum.KeyCode.W then
		moveDirection = moveDirection - Vector3.new(0, 0, -1)
	elseif input.KeyCode == Enum.KeyCode.A then
		moveDirection = moveDirection - Vector3.new(-1, 0, 0)
	elseif input.KeyCode == Enum.KeyCode.S then
		moveDirection = moveDirection - Vector3.new(0, 0, 1)
	elseif input.KeyCode == Enum.KeyCode.D then
		moveDirection = moveDirection - Vector3.new(1, 0, 0)
	end
end)

-- 24 FPS movement loop
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function(deltaTime)
	if not character or not humanoidRootPart or humanoid.Health <= 0 then
		renderConnection:Disconnect()
		inputConnections.inputBegan:Disconnect()
		inputConnections.inputEnded:Disconnect()
		return
	end
	
	lastUpdateTime = lastUpdateTime + deltaTime
	
	if lastUpdateTime >= FRAME_TIME then
		-- Normalize direction
		local normalizedDirection = moveDirection.Magnitude > 0 and moveDirection.Unit or Vector3.new(0, 0, 0)
		
		-- Calculate movement
		local moveAmount = normalizedDirection * MOVE_SPEED * FRAME_TIME
		
		-- Apply movement
		if normalizedDirection.Magnitude > 0 then
			humanoidRootPart.CFrame = humanoidRootPart.CFrame + moveAmount
			humanoid:MoveTo(humanoidRootPart.Position)
		end
		
		lastUpdateTime = lastUpdateTime - FRAME_TIME
	end
end)

-- Handle character respawn
local respawnConnection
respawnConnection = player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	humanoidRootPart = character:WaitForChild("HumanoidRootPart")
	humanoid = character:WaitForChild("Humanoid")
	moveDirection = Vector3.new(0, 0, 0)
	lastUpdateTime = 0
end)

print("✅ 24 FPS Movement Executor Loaded! Use WASD to move.")
