local TagModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
local Player = game.Players.LocalPlayer

-- Modules
local SettingsModule = require(SharedModulesFolder["Settings"])
local UtilitiesModule = require(SharedModulesFolder["Utilities"])
local DebugModule = require(SharedModulesFolder["Debug"])
local InterfacesModule = require(SharedModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Intialise(CharacterModel)
	-- Functions
	-- INIT
	if not CharacterModel then
		DebugModule:Print(script.Name.. " | No character model!")
		return nil
	end
	
	local _Player = game.Players:GetPlayerFromCharacter(CharacterModel)
	
	local HeadPart = UtilitiesModule:WaitForChildTimed(CharacterModel, "Head")
	
	if Player == _Player then
		InterfacesModule:LoadPage("Custom", "Role", true, "rbxassetid://11328827586", "LAST MAN STANDING", "rbxassetid://11887148792")
	end
	
	local Ui = InterfacesModule:LoadBillboard(HeadPart, "Marker", "rbxassetid://11328827586")
	
	if Ui and _Player then
		Ui.PlayerToHideFrom = _Player
	end
end

local function End(Character)
	-- Functions
	-- INIT
	--RemoveFromCache(WeaponModel)
	
end

-- DIRECT
function TagModule.Initialise(NilParam, Character)
	return Intialise(Character)
end

function TagModule.End(NilParam, Character)
	return End(Character)
end

-- 

return TagModule