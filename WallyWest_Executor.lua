--[[
    WALLY WEST SPEEDSTER EFFECT - EXECUTOR SCRIPT
    Paste this into your executor (Synapse X, Script-Ware, etc.)
    Press E to activate super speed
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- CONFIGURATION
local CONFIG = {
    SPEED_MULTIPLIER = 0.2,           -- How fast you move (0.2 = 5x faster)
    SLOW_MOTION_SPEED = 0.3,          -- How slow world becomes (0.3 = 70% slower)
    EFFECT_DURATION = 5,              -- Duration in seconds
    COOLDOWN = 8,                     -- Cooldown in seconds
    ACTIVATION_KEY = Enum.KeyCode.E,  -- Press E to activate
    ENABLE_TRAIL = true,              -- Speed trail particles
    ENABLE_BLUR = true,               -- Camera blur effect
    ENABLE_SOUND = true,              -- Activation sound
}

-- STATE VARIABLES
local isActive = false
local canUse = true
local originalSpeed = humanoid.WalkSpeed
local speedTrails = {}
local originalSpeeds = {}
local blurEffect = nil

-- Function: Create speed trail effect
local function createSpeedTrail()
    if not CONFIG.ENABLE_TRAIL then return end
    
    local trailConnection
    trailConnection = RunService.RenderStepped:Connect(function()
        if not isActive then
            trailConnection:Disconnect()
            return
        end
        
        local trail = Instance.new("Part")
        trail.Shape = Enum.PartType.Ball
        trail.Material = Enum.Material.Neon
        trail.Color = Color3.fromRGB(255, 100, 0)
        trail.CanCollide = false
        trail.CFrame = humanoidRootPart.CFrame
        trail.Size = Vector3.new(0.5, 0.5, 0.5)
        trail.TopSurface = Enum.SurfaceType.Smooth
        trail.BottomSurface = Enum.SurfaceType.Smooth
        trail.Parent = workspace
        
        table.insert(speedTrails, trail)
        
        local fadeTween = TweenService:Create(
            trail,
            TweenInfo.new(0.5, Enum.EasingStyle.Linear),
            {Transparency = 1}
        )
        fadeTween:Play()
        
        game:GetService("Debris"):AddItem(trail, 0.5)
    end)
end

-- Function: Create blur effect
local function createBlurEffect()
    if not CONFIG.ENABLE_BLUR then return end
    
    local camera = workspace.CurrentCamera
    blurEffect = Instance.new("BlurEffect")
    blurEffect.Size = 0
    blurEffect.Parent = camera
    
    local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(blurEffect, tweenInfo, {Size = 15})
    tween:Play()
end

-- Function: Remove blur effect
local function removeBlurEffect()
    if blurEffect then
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local tween = TweenService:Create(blurEffect, tweenInfo, {Size = 0})
        tween:Play()
        
        tween.Completed:Connect(function()
            if blurEffect then
                blurEffect:Destroy()
                blurEffect = nil
            end
        end)
    end
end

-- Function: Play sound effect
local function playSpeedSound()
    if not CONFIG.ENABLE_SOUND then return end
    
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://3570695787"
    sound.Volume = 0.5
    sound.Parent = humanoidRootPart
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- Function: Slow down world
local function slowDownWorld()
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            local otherChar = otherPlayer.Character
            if otherChar then
                local otherHumanoid = otherChar:FindFirstChildOfClass("Humanoid")
                if otherHumanoid then
                    originalSpeeds[otherHumanoid] = otherHumanoid.WalkSpeed
                    otherHumanoid.WalkSpeed = otherHumanoid.WalkSpeed * CONFIG.SLOW_MOTION_SPEED
                end
            end
        end
    end
end

-- Function: Reset world speed
local function resetWorldSpeed()
    for humanoidObj, originalSpd in pairs(originalSpeeds) do
        if humanoidObj and humanoidObj.Parent then
            humanoidObj.WalkSpeed = originalSpd
        end
    end
    originalSpeeds = {}
end

-- Function: Activate speedster effect
local function activateEffect()
    if not canUse or isActive then
        return
    end
    
    isActive = true
    canUse = false
    
    -- Increase player speed
    humanoid.WalkSpeed = originalSpeed * (1 / CONFIG.SPEED_MULTIPLIER)
    
    -- Create effects
    createSpeedTrail()
    createBlurEffect()
    playSpeedSound()
    
    -- Slow down world
    slowDownWorld()
    
    print("⚡ SPEEDSTER ACTIVATED! ⚡")
    
    -- Duration timer
    local startTime = tick()
    while isActive and (tick() - startTime) < CONFIG.EFFECT_DURATION do
        wait(0.01)
    end
    
    -- Deactivate
    deactivateEffect()
end

-- Function: Deactivate speedster effect
function deactivateEffect()
    if not isActive then return end
    
    isActive = false
    
    -- Reset player speed
    humanoid.WalkSpeed = originalSpeed
    
    -- Remove effects
    removeBlurEffect()
    
    -- Reset world speed
    resetWorldSpeed()
    
    print("⚡ Speedster deactivated. Cooldown: " .. CONFIG.COOLDOWN .. "s")
    
    -- Cooldown
    wait(CONFIG.COOLDOWN)
    canUse = true
    print("⚡ Speedster ready!")
end

-- Input detection
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.ACTIVATION_KEY then
        activateEffect()
    end
end)

-- Cleanup on respawn
player.CharacterAdded:Connect(function()
    deactivateEffect()
end)

print("⚡ Wally West Speedster Loaded! Press " .. tostring(CONFIG.ACTIVATION_KEY) .. " to activate")
print("Duration: " .. CONFIG.EFFECT_DURATION .. "s | Cooldown: " .. CONFIG.COOLDOWN .. "s")
