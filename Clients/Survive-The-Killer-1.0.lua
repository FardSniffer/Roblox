-- Made for Survive The Killer game in Roblox.
-- You can use this in other "Hide and Seek" type games if you wish.

-- Services
local runService = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local workspaceService = game:GetService("Workspace")
local lightingService = game:GetService("Lighting")

-- Variables
local player = game:GetService("Players").LocalPlayer
repeat 
	wait(1)
	print("Waiting on Humanoid...")
until player.Character.Humanoid

local animator = player.Character.Humanoid:FindFirstChildOfClass("Animator")
local animate = player.Character:WaitForChild("Animate")

-- Animation Instance
local animation = Instance.new("Animation")
animation.AnimationId = "rbxassetid://616006778" -- Idle

local idleAnim = animator:LoadAnimation(animation)
animation.AnimationId = "rbxassetid://616010382" -- Movement

local moveAnim = animator:LoadAnimation(animation)
local lastAnim = idleAnim

local camera = workspaceService.CurrentCamera
local movement = {forward = 0, backward = 0, right = 0, left = 0}

-- For environmental tags, so other clients won't conflict with it.
local random = Random.new()
local tag = tostring(random:NextNumber(10, 99)) .. tostring(random:NextNumber(10, 99)) .. tostring(random:NextNumber(10, 99))

getgenv()[tag.."enabled"] = true

getgenv()[tag.."PlayerESP"] = {
	Toggled = false,
	Enabled = false,

	Color = Color3.fromRGB(255, 0, 0)
}

getgenv()[tag.."Flight"] = {
	Toggled = false,
	Enabled = false,

	Speed = 0.5
}

getgenv()[tag.."Light"] = {

	AntiFog = {
		Toggled = false,
		Enabled = false,

		Server = game:GetService("Lighting").FogEnd
	},

	Brightness = {
		Toggled = false,
		Enabled = false,

		Brightness = 3
	}

}

-- Libraries
local guiLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/FardSniffer/Roblox/main/Changed-Kavo.lua"))()

-- Local Variables/Functions (For Code Below, not General)

-- Highlight Instance to clone for Player ESP
local highlight = Instance.new("Highlight")
highlight.Name = "ESP"
highlight.FillColor = getgenv()[tag.."PlayerESP"].Color
highlight.FillTransparency = 0.3
highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

-- BodyPosition & BodyGyro Instances for Flight
local bodyPosition = Instance.new("BodyPosition")
bodyPosition.Name = "FlightPosition"
bodyPosition.MaxForce = Vector3.new()

bodyPosition.D = 10
bodyPosition.P = 10000

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.Name = "FlightGyro"

bodyGyro.MaxTorque = Vector3.new()
bodyGyro.D = 10

-- Client Functions/Events (Basically only used if it's going to be used more than once)

-- Toggles ESP
local function HighlightPlayers()
	for i, v in pairs(game:GetService("Players"):GetChildren()) do
		if getgenv()[tag.."PlayerESP"].Toggled and getgenv()[tag.."PlayerESP"].Enabled then
			if v.Character and not v.Character:FindFirstChild("ESP") then highlight:Clone().Parent = v.Character end
		else
			if v.Character and v.Character:FindFirstChild("ESP") then v.Character:FindFirstChild("ESP"):Destroy() end
		end
	end
end

game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
	if game:GetService("Lighting").FogEnd ~= 69425 and getgenv()[tag.."Light"].AntiFog.Server ~= game:GetService("Lighting").FogEnd then
		getgenv()[tag.."Light"].AntiFog.Server = game:GetService("Lighting").FogEnd

		if getgenv()[tag.."Light"].AntiFog.Toggled and getgenv()[tag.."Light"].AntiFog.Enabled then
			game:GetService("Lighting").FogEnd = 69425
		end
	end
end)

game:GetService("Lighting"):GetPropertyChangedSignal("Brightness"):Connect(function()
	if game:GetService("Lighting").Brightness ~= getgenv()[tag.."Light"].Brightness.Brightness and getgenv()[tag.."Light"].Brightness.Server ~= game:GetService("Lighting").Brightness then
		getgenv()[tag.."Light"].AntiFog.Server = game:GetService("Lighting").FogEnd

		if getgenv()[tag.."Light"].Brightness.Toggled and getgenv()[tag.."Light"].Brightness.Enabled then
			game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Brightness
		end
	end
end)

-- UI (Window, Tab, & Section)
local duckClient = guiLibrary.CreateLib("Duck Client v0.1-dev1")

local playerTab = duckClient:NewTab("Player")
local renderTab = duckClient:NewTab("Render")
local movementTab = duckClient:NewTab("Movement")
local otherTab = duckClient:NewTab("Other")

-- For Player Tab
local playerESPSection = playerTab:NewSection("ESP")
local flightSection = movementTab:NewSection("Flight")
local clipSection = movementTab:NewSection("Clip")
local teleportSection = movementTab:NewSection("Teleport")

-- For Render Tab
local antiFogSection = renderTab:NewSection("AntiFog")
local lightingSection = renderTab:NewSection("Lighting")

-- For Other Tab
local UISection = otherTab:NewSection("UI")

-- UI (Buttons, Toggle, Keybind, & More)

-- Player Tab
-- Player ESP Section
playerESPSection:NewToggle("Player ESP", "Highlights players through parts", function()
	getgenv()[tag.."PlayerESP"].Toggled = not getgenv()[tag.."PlayerESP"].Toggled
	HighlightPlayers()
end)

playerESPSection:NewKeybind("Player ESP Keybind", "Keybind for Player ESP. Default is G", Enum.KeyCode.G, function()
	getgenv()[tag.."PlayerESP"].Enabled = not getgenv()[tag.."PlayerESP"].Enabled
	HighlightPlayers()
end)

playerESPSection:NewColorPicker("Player ESP Color", "The highlighted ESP Color for players", getgenv()[tag.."PlayerESP"].Color, function(color)
    if color then 
		getgenv()[tag.."PlayerESP"].Color = color
		highlight.FillColor = color
	end
end)

-- Movement Tab
-- Flight Section
flightSection:NewToggle("Flight", "Grants you the ability to fly", function()
	getgenv()[tag.."Flight"].Toggled = not getgenv()[tag.."Flight"].Toggled
	if not getgenv()[tag.."Flight"].Toggled then getgenv()[tag.."Flight"].Enabled = false end
end)

flightSection:NewKeybind("Flight Keybind", "Keybind for Flight. Default is H", Enum.KeyCode.H, function()
	getgenv()[tag.."Flight"].Enabled = not getgenv()[tag.."Flight"].Enabled

	if not player.Character.HumanoidRootPart:FindFirstChild("FlightPosition") or not player.Character.HumanoidRootPart:FindFirstChild("FlightGyro") then
		bodyPosition:Clone().Parent = player.Character.HumanoidRootPart
		bodyGyro:Clone().Parent = player.Character.HumanoidRootPart
	end

	local flightPosition = player.Character.HumanoidRootPart:FindFirstChild("FlightPosition")
	local flightGyro = player.Character.HumanoidRootPart:FindFirstChild("FlightGyro")

	if getgenv()[tag.."Flight"].Toggled and getgenv()[tag.."Flight"].Enabled then

		flightPosition.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
		flightGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)

		while getgenv()[tag.."Flight"].Toggled and getgenv()[tag.."Flight"].Enabled do
			
			if player.Character and player.Character.HumanoidRootPart then

				if not flightPosition then
					bodyPosition:Clone().Parent = player.Character.HumanoidRootPart
				end

				if not flightGyro then
					bodyGyro:Clone().Parent = player.Character.HumanoidRootPart
				end

				flightPosition.Position = player.Character.HumanoidRootPart.Position + ((player.Character.HumanoidRootPart.Position - camera.CFrame.p).unit * getgenv()[tag.."Flight"].Speed)
				flightGyro.CFrame = CFrame.new(camera.CFrame.p, player.Character.HumanoidRootPart.Position)
			end

			runService.RenderStepped:Wait()
		end

		flightPosition.MaxForce = Vector3.new()
		flightGyro.MaxTorque = Vector3.new()

	else
		flightPosition.MaxForce = Vector3.new()
		flightGyro.MaxTorque = Vector3.new()
	end
end)

flightSection:NewSlider("Flight Speed", "Sets your flight speed. Default is 0.5", 5, 0.1, function(speed)
	if tonumber(speed) then
		getgenv()[tag.."Flight"].Speed = tonumber(speed)

	else
		warn("Specified value for Flight Speed may be incorrect.")
	end
end)

-- Clip Section
clipSection:NewTextBox("Clip Amount", "Adds your Root's CFrame to the value you specified", function(position)
	local values = string.split(position, ", ") and string.split(position, ",")

	for i = 1, 3, 1 do

		if not values[i] then 
			values[i] = 0
			
		else
			values[i] = string.gsub(values[i], " ", "")
			if not tonumber(values[i]) then values[i] = 0 end
		end
	end

	local newPosition = CFrame.new(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))

	if newPosition then
		player.Character.HumanoidRootPart.CFrame = player.Character.HumanoidRootPart.CFrame * newPosition

	else
		warn("Specified value for Clip may be incorrect. Could not change the HumanoidRootPart's Position. (Specified Position: "..tostring(position).." | New Position: Possibly nil)")
	end
end)

-- Teleport Section
teleportSection:NewTextBox("Teleport Player", "Teleports to the player you specified", function(target)
	if game:GetService("Players")[target] and game:GetService("Players")[target].Character and game:GetService("Players")[target].Character.HumanoidRootPart then
		player.Character.HumanoidRootPart.CFrame = game:GetService("Players")[target].Character.HumanoidRootPart.CFrame
	end
end)

-- Render Tab
-- AntiFog Section
antiFogSection:NewToggle("Anti Fog", "Change Fog render in your game", function()
	getgenv()[tag.."Light"].AntiFog.Toggled = not getgenv()[tag.."Light"].AntiFog.Toggled

	if getgenv()[tag.."Light"].AntiFog.Toggled and getgenv()[tag.."Light"].AntiFog.Enabled then
		if game:GetService("Lighting").FogEnd < 500 then
			getgenv()[tag.."Light"].AntiFog.Server = game:GetService("Lighting").FogEnd
		end
		game:GetService("Lighting").FogEnd = 99999

	else
		game:GetService("Lighting").FogEnd = getgenv()[tag.."Light"].AntiFog.Server
	end
end)

antiFogSection:NewKeybind("Anti Fog Keybind", "Keybind for Anti Fog. Default is F", Enum.KeyCode.F, function()
	getgenv()[tag.."Light"].AntiFog.Enabled = not getgenv()[tag.."Light"].AntiFog.Enabled

	if getgenv()[tag.."Light"].AntiFog.Toggled and getgenv()[tag.."Light"].AntiFog.Enabled then
		if game:GetService("Lighting").FogEnd < 500 then
			getgenv()[tag.."Light"].AntiFog.Server = game:GetService("Lighting").FogEnd
		end
		game:GetService("Lighting").FogEnd = 69425

	else
		game:GetService("Lighting").FogEnd = getgenv()[tag.."Light"].AntiFog.Server
	end
end)

lightingSection:NewToggle("Brightness", "Change brightness in your game", function()
	getgenv()[tag.."Light"].Brightness.Toggled = not getgenv()[tag.."Light"].Brightness.Toggled

	if getgenv()[tag.."Light"].Brightness.Toggled and getgenv()[tag.."Light"].Brightness.Enabled then
		game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Brightness
	else
		game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Server
	end
end)

lightingSection:NewSlider("Brightness Value", "Change the value of the brightness", 10, -10, function(value)
	getgenv()[tag.."Light"].Brightness.Brightness = value

	if getgenv()[tag.."Light"].Brightness.Toggled and getgenv()[tag.."Light"].Brightness.Enabled then
		game:GetService("Lighting").Brightness = value
	else
		game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Server
	end
end)

lightingSection:NewKeybind("Brightness Keybind", "Keybind for Brightness. Default is B", Enum.KeyCode.B, function()
	getgenv()[tag.."Light"].Brightness.Enabled = not getgenv()[tag.."Light"].Brightness.Enabled

	if getgenv()[tag.."Light"].Brightness.Toggled and getgenv()[tag.."Light"].Brightness.Enabled then
		game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Brightness
	else
		game:GetService("Lighting").Brightness = getgenv()[tag.."Light"].Brightness.Server
	end	
end)

-- Other Tab
-- UI Section
UISection:NewKeybind("Toggle UI", "Toggles the UI on or off", Enum.KeyCode.RightShift, function()
	guiLibrary:ToggleUI()
end)

UISection:NewButton("Destruct UI", "Destructs the client", function()
	local serverFog = getgenv()[tag.."Light"].AntiFog.Server

	getgenv()[tag.."PlayerESP"] = {
		Toggled = false,
		Enabled = false,

		Color = Color3.fromRGB(255, 0, 0)
	}

	getgenv()[tag.."Flight"] = {
		Toggled = false,
		Enabled = false,

		Speed = 0.5
	}

	getgenv()[tag.."Light"] = {
	
		AntiFog = {
			Toggled = false,
			Enabled = false,
	
			Server = 124124
		},

		Brightness = {
			Toggled = false,
			Enabled = false,
	
			Server = 1
		}
	
	}

	getgenv()[tag.."enabled"] = false
	guiLibrary:DestructUI()
end)

-- Checks if getgenv() is enabled.
while getgenv()[tag.."enabled"] do

	if player.Character and player.Character.HumanoidRootPart and not player.Character.HumanoidRootPart:FindFirstChild("FlightPosition") then
		bodyPosition:Clone().Parent = player.Character.HumanoidRootPart
	end

	if player.Character and player.Character.HumanoidRootPart and not player.Character.HumanoidRootPart:FindFirstChild("FlightGyro") then
		bodyGyro:Clone().Parent = player.Character.HumanoidRootPart
	end

	HighlightPlayers()
	task.wait(1)
end
