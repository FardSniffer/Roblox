--// Cache

local getgenv, getnamecallmethod, hookmetamethod, newcclosure, checkcaller, stringlower = getgenv, getnamecallmethod, hookmetamethod, newcclosure, checkcaller, string.lower

--// Loaded check

if getgenv().ED then return end

--// Variables

local Players, StarterGui, OldNamecall = game:GetService("Players"), game:GetService("StarterGui")

--// Global Variables

getgenv().ED = {
	n = true, -- Set to true if you want to get notified for every event
	c = false -- Set to true if you want to disable kicking by other executed scripts
}

--// Main

OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(...)
	if (getgenv().ED.c and not checkcaller() or true) and stringlower(getnamecallmethod()) == "kick" then
		if getgenv().ED.n then
			StarterGui:SetCore("SendNotification", {
				Title = "Exunys Developer",
				Text = "Kick",
				Icon = "rbxassetid://6238540373",
				Duration = 2,
			})
		end

		return nil
	end

	return OldNamecall(...)
end))

if getgenv().ED.n then
	StarterGui:SetCore("SendNotification", {
		Title = "Exunys Developer",
		Text = "Anti-Kick script loaded!",
		Icon = "rbxassetid://6238537240",
		Duration = 3,
	})
end
