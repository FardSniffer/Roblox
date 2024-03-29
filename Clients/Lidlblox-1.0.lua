-- Made for Survive The Killer game in Roblox.
-- You can use this in other "Hide and Seek" type games if you wish.

-- Services
local runService = game:GetService("RunService")
local contextActionService = game:GetService("ContextActionService")
local workspaceService = game:GetService("Workspace")
local lightingService = game:GetService("Lighting")

-- Variables
local player = game:GetService("Players").LocalPlayer

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

getgenv()[tag.."Light"] = {

	AntiFog = {
		Toggled = false,
		Enabled = false,

		Server = game:GetService("Lighting").FogEnd
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

-- FogEnd Listener
local fogEnd = 274917

game:GetService("Lighting"):GetPropertyChangedSignal("FogEnd"):Connect(function()
	if game:GetService("Lighting").FogEnd ~= fogEnd and getgenv()[tag.."Light"].AntiFog.Server ~= game:GetService("Lighting").FogEnd then
		getgenv()[tag.."Light"].AntiFog.Server = game:GetService("Lighting").FogEnd

		if getgenv()[tag.."Light"].AntiFog.Toggled and getgenv()[tag.."Light"].AntiFog.Enabled then
			game:GetService("Lighting").FogEnd = fogEnd
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
local clipSection = movementTab:NewSection("Clip")
local teleportSection = movementTab:NewSection("Teleport")

-- For Render Tab
local antiFogSection = renderTab:NewSection("AntiFog")

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
		game:GetService("Lighting").FogEnd = fogEnd

	else
		game:GetService("Lighting").FogEnd = getgenv()[tag.."Light"].AntiFog.Server
	end
end)

antiFogSection:NewKeybind("Anti Fog Keybind", "Keybind for Anti Fog. Default is F", Enum.KeyCode.F, function()
	getgenv()[tag.."Light"].AntiFog.Enabled = not getgenv()[tag.."Light"].AntiFog.Enabled

	if getgenv()[tag.."Light"].AntiFog.Toggled and getgenv()[tag.."Light"].AntiFog.Enabled then
		game:GetService("Lighting").FogEnd = fogEnd

	else
		game:GetService("Lighting").FogEnd = getgenv()[tag.."Light"].AntiFog.Server
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

	getgenv()[tag.."Light"] = {
	
		AntiFog = {
			Toggled = false,
			Enabled = false,
	
			Server = serverFog
		}
	
	}

	getgenv()[tag.."enabled"] = false
	guiLibrary:DestructUI()
end)

-- Checks if getgenv() is enabled.
while getgenv()[tag.."enabled"] do

	HighlightPlayers()
	task.wait(1)
end
