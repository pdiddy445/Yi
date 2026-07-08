-- Roblox Remove Hitbox Executor Script
-- Paste this into your executor (Synapse X, Script-Ware, etc.)

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

-- Function to remove hitbox from a part
local function removeHitbox(part)
	if part:IsA("BasePart") then
		part.CanCollide = false
		part.CanTouch = false
		part.CanQuery = false
	end
end

-- Remove hitbox from all parts in character
for _, part in pairs(character:GetDescendants()) do
	removeHitbox(part)
end

-- Remove hitbox when new parts are added
local descendantConnection
descendantConnection = character.DescendantAdded:Connect(function(descendant)
	removeHitbox(descendant)
end)

-- Handle character respawn
local respawnConnection
respawnConnection = player.CharacterAdded:Connect(function(newCharacter)
	character = newCharacter
	
	-- Remove hitbox from new character's parts
	for _, part in pairs(character:GetDescendants()) do
		removeHitbox(part)
	end
	
	-- Reconnect descendant listener
	descendantConnection:Disconnect()
	descendantConnection = character.DescendantAdded:Connect(function(descendant)
		removeHitbox(descendant)
	end)
end)

print("✅ Hitbox Removed! You are now invisible to collisions.")
