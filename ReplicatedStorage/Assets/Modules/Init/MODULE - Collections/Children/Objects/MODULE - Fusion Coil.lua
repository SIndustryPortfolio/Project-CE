local TagModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Info Modules
local CollectionsInfoModule = require(InfoModulesFolder["Collections"])
local ObjectsInfoModule = require(InfoModulesFolder["Objects"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local EffectsHandlerModule = require(ModulesFolder["EffectsHandler"])
local DebugModule = require(ModulesFolder["Debug"])
local SoundsModule = require(ModulesFolder["Sounds"])
local ParticlesModule = require(ModulesFolder["Particles"])
local ObjectsModule = require(ModulesFolder["Objects"])
local DebrisModule = require(ModulesFolder["Debris"])

-- CORE
local Connections = {}

-- Services
local DebrisService = game:GetService("Debris")

-- Functions
-- MECHANICS
local function AddToCache(Model, _Connections)
	-- Functions
	-- INIT
	if Connections[Model] == nil then
		Connections[Model] = {}
	end
	
	for i, Connection in pairs(_Connections) do
		table.insert(Connections[Model], Connection)
	end
end

local function RemoveFromCache(Model)
	-- Functions
	-- INIT
	if not Connections[Model] then
		return nil
	end
	
	UtilitiesModule:DisconnectConnections(Connections[Model])
	Connections[Model] = nil
end

local function Initialise(FusionCoil)
	-- CORE
	local ObjectInfoModule = CollectionsInfoModule:GetCollectionItemInfo(script.Name)
	local ObjectInfo = ObjectsInfoModule:GetObjectInfo(FusionCoil.Name)
	
	-- Elements
	-- PARTS
	local NeonTubes = UtilitiesModule:WaitForChildTimed(FusionCoil, "NeonTubes", nil, true)
	
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildOfClass(FusionCoil, "Humanoid")
	
	-- Functions
	-- MECHANICS
	local function Explode()
		-- Functions
		-- INIT
		
		--DebugModule:Print"Exploding Fusion Coil")
		
		task.wait(.3)
		
		local Attachment = EffectsHandlerModule:LoadParticleEmitter(NeonTubes, "Explosion")
		EffectsHandlerModule:ToggleParticleEmitters(Attachment, true, nil)
		ParticlesModule:ParticleEffect("Explosion", FusionCoil.PrimaryPart, ObjectInfoModule:GetInfo("ExplosionTrailColour"))
		ObjectsModule:ObjectProcess("Explosion", FusionCoil)
		
		--DebugModule:Print"Explosion Sound: ".. tostring(ObjectInfo["ExplosionSound"]))
		
		if not ObjectInfo["ExplosionSound"] or ObjectInfo["ExplosionSound"] == "" then
			SoundsModule:PlaySoundEffectByName("Objects", "Explosion", nil, Attachment, {["RollOffMaxDistance"] = 500--[[, ["Volume"] = 5]]})
		else
			SoundsModule:PlaySoundEffectById(ObjectInfo["ExplosionSound"], nil, Attachment, nil, {["RollOffMaxDistance"] = 500--[[, ["Volume"] = 5]]})
		end
		
		EffectsHandlerModule:ChangeTransparency(FusionCoil, 1)
		--DebrisService:AddItem(Attachment, 2)
		DebrisModule:AddItem(Attachment, 2)
		task.wait(.4)
		EffectsHandlerModule:ToggleParticleEmitters(Attachment, false, nil)
		
		End(FusionCoil)
	end
	
	local function UpdateHealthVisual()
		-- CORE
		local OriginalColour = UtilitiesModule:Color3ToVector3(ObjectInfoModule:GetInfo("OriginNeonColour"))
		local DestinationColour = UtilitiesModule:Color3ToVector3(ObjectInfoModule:GetInfo("EmergencyNeonColour"))
		
		-- Functions
		-- INIT
		--DebugModule:Print("Updating Fusion Coil Colour")
		
		local PercentageHealth = math.clamp(Humanoid.Health / Humanoid.MaxHealth, 0, 1)
		local DifferenceBetweenValues = DestinationColour - OriginalColour
		
		local VectorToAdd = OriginalColour + (DifferenceBetweenValues * (1 - PercentageHealth))
		
		if not NeonTubes then
			return nil
		end
		
		NeonTubes.Color = Color3.fromRGB(VectorToAdd.X, VectorToAdd.Y, VectorToAdd.Z)
		
		if Humanoid.Health <= 0 then
			return Explode()
		end
	end
	
	-- DIRECT
	local Connection1 = nil
	
	Connection1 = Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
		if Humanoid.Health <= 0 then
			Connection1:Disconnect()
		end
		
		return UpdateHealthVisual()
	end)
	
	-- INIT
	AddToCache(FusionCoil, {Connection1})
	UpdateHealthVisual()
end

function End(FusionCoil)
	-- Functions
	-- INIT
	RemoveFromCache(FusionCoil)
end

-- DIRECT
function TagModule.Initialise(NilParam, FusionCoil)
	return Initialise(FusionCoil)
end

function TagModule.End(NilParam, FusionCoil)
	return End(FusionCoil)
end

return TagModule