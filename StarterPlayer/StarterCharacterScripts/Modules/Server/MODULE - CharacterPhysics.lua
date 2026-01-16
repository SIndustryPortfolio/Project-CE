local CharacterPhysicsModule = {}

-- Dirs
local Character = script.Parent.Parent.Parent

-- EXT
local SharedModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Modules
local UtilitiesModule = require(SharedModulesFolder["Utilities"])

-- CORE
local LocalPlayer = game.Players:GetPlayerFromCharacter(Character)
local WAIST_MAX_TURN_ANGLE_BOUNDS = 100
local NECK_MAX_ANGLE_BOUNDS = 40
local MIN_MAX_Y_VECTOR_BOUND = 0.5

-- Elements
-- REMOTES
local TiltReplicateRemote = ClientServerRemotesFolder["TiltReplicateRemote"]

-- Attachments
local Neck = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("UpperTorso"), "Neck")
local Waist = UtilitiesModule:WaitForChildTimed(Character:WaitForChild("LowerTorso"), "Waist")

-- Functions
-- MECHANICS
local function UpdateTilt4(NeckAngle, WaistAngle)
	-- Functions
	-- INIT
	--[[Character:SetAttribute("NeckAngleRightVector", NeckAngle.RightVector)
	Character:SetAttribute("NeckAngleUpVector", NeckAngle.UpVector)
	
	Character:SetAttribute("WaistAngleRightVector", WaistAngle.RightVector)
	Character:SetAttribute("WaistAngleUpVector", WaistAngle.UpVector)]]
	
	Character:SetAttribute("NeckAngle", NeckAngle)
	Character:SetAttribute("WaistAngle", WaistAngle)
end

local function UpdateTilt3(NeckAngle, WaistAngle)
	-- Functions
	-- INIT
	Character:SetAttribute("WaistAngle", WaistAngle)
	Character:SetAttribute("NeckAngle", NeckAngle)
end

local function UpdateTilt2(DeltaY)
	-- Functions
	-- INIT
	local waistAngle = UtilitiesModule:MapValue(DeltaY, -MIN_MAX_Y_VECTOR_BOUND, MIN_MAX_Y_VECTOR_BOUND, -WAIST_MAX_TURN_ANGLE_BOUNDS, WAIST_MAX_TURN_ANGLE_BOUNDS)
	Character:SetAttribute('WaistAngle', math.floor(waistAngle))
	
	-- neck angle
	local neckAngle =  UtilitiesModule:MapValue(DeltaY, -MIN_MAX_Y_VECTOR_BOUND, MIN_MAX_Y_VECTOR_BOUND, -NECK_MAX_ANGLE_BOUNDS, NECK_MAX_ANGLE_BOUNDS)
	Character:SetAttribute('NeckAngle', math.floor(neckAngle))
end

local function UpdateTilt(NeckC0, WaistC0)
	-- Functions
	-- INIT
	
	for i, PlayerValue in pairs(game.ReplicatedStorage.Game.Deployed:GetChildren()) do
		pcall(function()
			local FoundPlayer = game.Players[PlayerValue.Name]
			
			if FoundPlayer then
				TiltReplicateRemote:FireClient(FoundPlayer, LocalPlayer, Neck, {["C0"] = NeckC0})
				TiltReplicateRemote:FireClient(FoundPlayer, LocalPlayer, Waist, {["C0"] = WaistC0})
			end
		end)
	end
	
	--TiltReplicateRemote:FireAllClients(LocalPlayer, Neck, {["C0"] = NeckC0})
	--TiltReplicateRemote:FireAllClients(LocalPlayer, Waist, {["C0"] = WaistC0})
	
	--Neck.C0 = NeckC0
	--Waist.C0 = WaistC0
end

local function GarbageCollect()
	-- Functions
	-- INIT
	Character = nil
	--
	SharedModulesFolder = nil
	--
	UtilitiesModule = nil
	--
	LocalPlayer = nil
	--
	Neck = nil
	Waist = nil
	
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["UpdateTilt"] = function(Player, ...)
		return UpdateTilt(...)
	end,
	["UpdateTilt2"] = function(Player, ...)
		return UpdateTilt2(...)	
	end,
	["UpdateTilt3"] = function(Player, ...)
		return UpdateTilt3(...)
	end,
	["UpdateTilt4"] = function(Player, ...)
		return UpdateTilt4(...)
	end,
}

-- DIRECT
function CharacterPhysicsModule.ClientRequest(NilParam, Player, FunctionName, ...)
	-- Functions
	-- INIT
	if Player == LocalPlayer then
		return ClientRequests[FunctionName](Player, ...)
	end
end

function CharacterPhysicsModule.GarbageCollect()
	GarbageCollect()
end

return CharacterPhysicsModule