
-- DEMONLTT FLY'S
-- UN SEUL LOCALSCRIPT
-- StarterPlayer > StarterPlayerScripts

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local speed = 40
local flying = false
local connections = {}

-- INTERFACE
local gui = Instance.new("ScreenGui")
gui.Name = "DEMONLTT_FLY"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(310, 125)
frame.Position = UDim2.new(0.5, -155, 0.3, 0)
frame.BackgroundColor3 = Color3.new(0,0,0)
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0,25)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.new(1,1,1)
stroke.Thickness = 4
stroke.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,48)
title.BackgroundTransparency = 1
title.Text = "DEMONLTT FLY'S"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextScaled = true
title.Parent = frame

local function createButton(text, position, size)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = position
    b.BackgroundColor3 = Color3.new(0,0,0)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0,10)
    c.Parent = b

    local s = Instance.new("UIStroke")
    s.Color = Color3.new(1,1,1)
    s.Thickness = 2
    s.Parent = b

    return b
end

local minus = createButton("-", UDim2.fromOffset(10,58),
    UDim2.fromOffset(60,55))

local plus = createButton("+", UDim2.fromOffset(80,58),
    UDim2.fromOffset(60,55))

local fly = createButton("FLY OFF", UDim2.fromOffset(150,58),
    UDim2.fromOffset(150,55))

-- VITESSE
plus.Activated:Connect(function()
    speed = math.min(speed + 10,300)
end)

minus.Activated:Connect(function()
    speed = math.max(speed - 10,10)
end)

-- ARRET DU VOL
local function stopFly()
    flying = false
    fly.Text = "FLY OFF"

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if root then
        for _, name in ipairs({
            "DemonAttachment",
            "DemonVelocity",
            "DemonOrientation"
        }) do
            local object = root:FindFirstChild(name)
            if object then object:Destroy() end
        end
    end

    if humanoid then
        humanoid.AutoRotate = true
    end
end

-- ACTIVATION DU VOL
fly.Activated:Connect(function()
    if flying then
        stopFly()
        return
    end

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    local attachment = Instance.new("Attachment")
    attachment.Name = "DemonAttachment"
    attachment.Parent = root

    local velocity = Instance.new("LinearVelocity")
    velocity.Name = "DemonVelocity"
    velocity.Attachment0 = attachment
    velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    velocity.MaxForce = math.huge
    velocity.VectorVelocity = Vector3.zero
    velocity.Parent = root

    local orientation = Instance.new("AlignOrientation")
    orientation.Name = "DemonOrientation"
    orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
    orientation.Attachment0 = attachment
    orientation.RigidityEnabled = false
    orientation.Responsiveness = 30
    orientation.MaxTorque = math.huge
    orientation.Parent = root

    humanoid.AutoRotate = false

    flying = true
    fly.Text = "FLY ON"
end)

-- VOL DANS LA DIRECTION DE LA CAMERA
connections.render = RunService.RenderStepped:Connect(function()
    if not flying then return end

    local character = player.Character
    if not character then return end

    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChildOfClass("Humanoid")

    if not root or not humanoid then return end

    local velocity = root:FindFirstChild("DemonVelocity")
    local orientation = root:FindFirstChild("DemonOrientation")

    if not velocity or not orientation then return end

    local cam = workspace.CurrentCamera
    local look = cam.CFrame.LookVector
    local right = cam.CFrame.RightVector

    -- Direction du joystick par rapport à la caméra
    local flatLook = Vector3.new(look.X,0,look.Z)
    local flatRight = Vector3.new(right.X,0,right.Z)

    if flatLook.Magnitude > 0 then
        flatLook = flatLook.Unit
    end

    if flatRight.Magnitude > 0 then
        flatRight = flatRight.Unit
    end

    local move = humanoid.MoveDirection

    local forwardAmount = move:Dot(flatLook)
    local rightAmount = move:Dot(flatRight)

    -- Le regard vers le haut ou le bas contrôle l'altitude
    local direction =
        look * forwardAmount +
        right * rightAmount

    if direction.Magnitude > 1 then
        direction = direction.Unit
    end

    velocity.VectorVelocity = direction * speed

    -- LockCam : le personnage suit la caméra
    orientation.CFrame = cam.CFrame.Rotation
end)

-- DEPLACER LE MENU AVEC LE DOIGT
local dragging = false
local dragStart
local startPosition

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPosition = frame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (
        input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement
    ) then
        local delta = input.Position - dragStart

        frame.Position = UDim2.new(
            startPosition.X.Scale,
            startPosition.X.Offset + delta.X,
            startPosition.Y.Scale,
            startPosition.Y.Offset + delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- RESPAWN
player.CharacterAdded:Connect(function()
    flying = false
    fly.Text = "FLY OFF"
end)
