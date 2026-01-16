local KeybindsInfoModule = {}

-- CORE
local KeybindsInfo = 
{
	["SwitchWeapon"] = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.ButtonY, Enum.KeyCode.Tab},
	["SwitchGrenade"] = {Enum.KeyCode.X, Enum.KeyCode.ButtonX},
	["Ads"] = {Enum.UserInputType.MouseButton2, Enum.KeyCode.ButtonR3},
	["Melee"] = {Enum.KeyCode.Q, Enum.KeyCode.ButtonB},
	["Reload"] = {Enum.KeyCode.R, Enum.KeyCode.ButtonR1},
	["Fire"] = {Enum.UserInputType.MouseButton1},
	["Grenade"] = {Enum.KeyCode.G, Enum.KeyCode.ButtonL2},
	["ScoreBoard"] = {Enum.KeyCode.F1, Enum.KeyCode.DPadUp},
	["InGameSettings"] = {Enum.KeyCode.F2, Enum.KeyCode.DPadDown},
	["Crouch"] = {Enum.KeyCode.C, Enum.KeyCode.ButtonL3},
	["ChangeTeam"] = {Enum.KeyCode.K, Enum.KeyCode.DPadLeft},
	["Menu"] = {Enum.KeyCode.M},
	["Interact"] = {Enum.KeyCode.E, Enum.KeyCode.ButtonL1},
	["Keybinds"] = {Enum.KeyCode.H},
	["DebugConsole"] = {Enum.KeyCode.J}
}

local TouchKeybinds = 
{
	["Fire"] = {Icon = {Id = "rbxassetid://10544801304"}, Position = UDim2.fromScale(--[[0.3]] 0.25, -0.15), SizeMultiplier = 1.5},
	["SwitchWeapon"] = {Icon = {Id = "rbxassetid://10544843598"}, Position = UDim2.fromScale(0.5, 0.25)},
	["Reload"] = {Icon = {Id = "rbxassetid://10544800419"}, Position = UDim2.fromScale(0.75, 0.25)},
	["Grenade"] = {Icon = {Id = "rbxassetid://10544879156"}, Position = UDim2.fromScale(0.825, 0)},
	["Crouch"] = {Icon = {Id = "rbxassetid://10544801583"}, Position = UDim2.fromScale(0.25, 0.3)},
	["Melee"] = {Icon = {Id = "rbxassetid://10544801014"}, Position = UDim2.fromScale(0.4, 0.5)},
	["Ads"] = {Icon = {Id = "rbxassetid://10553996488"}, Position = UDim2.fromScale(0.6125, 0)}
}

-- Services
local RunService = game:GetService("RunService")

-- Functions
-- MECHANICS
local function ChangeKeybind(KeybindName, KeyCode)
	-- Functions
	-- INIT
	if table.find(KeybindsInfo[KeybindName], KeyCode) ~= nil then
		return nil
	end
	
	table.insert(KeybindsInfo[KeybindName], KeyCode)
	
	for Keybind, KeyCodes in pairs(KeybindsInfo) do
		if Keybind == KeybindName then
			continue
		end
		
		local FoundIndex = table.find(KeyCodes, KeyCode)
		
		if FoundIndex then
			table.remove(KeybindsInfo[Keybind], FoundIndex)
		end
	end
end

local function ClearKeybind(KeybindName)
	-- Functions
	-- INIT
	for i = 1, #KeybindsInfo[KeybindName] do
		table.remove(KeybindsInfo[KeybindName], 1)
	end
	
	return KeybindsInfo[KeybindName]
end

-- DIRECT
function KeybindsInfoModule.GetTouchKeybinds()
	return TouchKeybinds
end

function KeybindsInfoModule.ClearKeybind(NilParam, KeybindName)
	return ClearKeybind(KeybindName)
end

function KeybindsInfoModule.ChangeKeybind(NilParam, KeybindName, KeyCode)
	return ChangeKeybind(KeybindName, KeyCode)
end

function KeybindsInfoModule.GetKeybindInfo(NilParam, SettingName)
	return KeybindsInfo[SettingName]
end

function KeybindsInfoModule.GetAllKeybindInfo()
	return KeybindsInfo
end

-- INIT
if RunService:IsStudio() then
	table.insert(KeybindsInfo["ScoreBoard"], Enum.KeyCode.T)
	table.insert(KeybindsInfo["InGameSettings"], Enum.KeyCode.Y)
end

return KeybindsInfoModule