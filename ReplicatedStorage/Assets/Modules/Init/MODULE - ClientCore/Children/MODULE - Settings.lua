local ClientCoreSettingsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]

-- Client
local Player = game.Players.LocalPlayer

-- Info Modules
local CamosInfoModule = require(InfoModulesFolder["Camos"])

-- Modules
local SettingsModule = require(ModulesFolder["Settings"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local AnimatedWeaponCamoCollectionModule = require(ModulesFolder["Init"]["Collections"]["Handlers"]["AnimatedWeaponCamo"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Services
local CollectionService = game:GetService("CollectionService")
local LightingService = game:GetService("Lighting")

-- Functions
-- MECHANICS
local function GetWeapons()
	-- Functions
	-- INIT
	local Weapons = {}
	
	for i, WeaponModel in pairs(workspace:WaitForChild("Dump")["Weapons"]:GetChildren()) do
		table.insert(Weapons, WeaponModel)
	end
	
	for i, Player in pairs(game.Players:GetPlayers()) do
		local FoundWeaponModel = Player:WaitForChild("Backpack"):FindFirstChildOfClass("Model")
		
		if FoundWeaponModel then
			table.insert(Weapons, FoundWeaponModel)
		end
		
		local Character = UtilitiesModule:GetCharacter(Player, true)
		
		if Character then
			local FoundSecondWeaponModel = Character:FindFirstChildOfClass("Model")
			
			if FoundSecondWeaponModel then
				table.insert(Weapons, FoundSecondWeaponModel)
			end
			
			for x, ViewmodelGun in pairs(Character["ViewModels"]:GetDescendants()) do
				if ViewmodelGun:IsA("Model") then
					table.insert(Weapons, ViewmodelGun:FindFirstChild("Gun"))
				end
			end
		end
	end
	
	return Weapons
end

local function ToggleWeaponCamos(ToggleValue)
	-- Functions
	-- INIT
	if ToggleValue == "OFF" then
		for i, Tagged in pairs(CollectionService:GetTagged("AnimatedWeaponCamo")) do
			AnimatedWeaponCamoCollectionModule:End(Tagged)
		end
	else
		local Weapons = GetWeapons()
		
		for i, WeaponModel in pairs(Weapons) do
			local WeaponCamoName = WeaponModel:GetAttributes()["Camo"]
			
			if not WeaponCamoName or WeaponCamoName == "" then
				continue
			end
			
			local CamoInfo = CamosInfoModule:GetInfo(WeaponCamoName) --CamosInfoModule:GetCamoInfo(WeaponCamoName)
			
			if CamoInfo and CamoInfo["Animated"] then
				AnimatedWeaponCamoCollectionModule:Initialise(WeaponModel)
			end
		end
	end
end

local function ChangeBrightness(BrightnessValue)
	-- Functions
	-- INIT
	LightingService.Brightness = BrightnessValue
end

local function ToggleHitMarker(ToggleValue)
	-- Functions
	-- INIT
	local HudGuiModule = InterfacesModule:GetUiModuleFromType("Custom", "Hud")
	
	if HudGuiModule then
		HudGuiModule:HudProcess("Cursor", "ToggleHitMarker", ToggleValue)
	end
end

local function Initialise()
	-- CORE
	local AnimatedCamosValue = SettingsModule:GetSettingValueInstance("Video", "AnimatedCamos")
	local BrightnessValue = SettingsModule:GetSettingValueInstance("Video", "Brightness")
	local HitMarkerValue = SettingsModule:GetSettingValueInstance("Game", "HitMarker")
	
	-- Functions
	-- DIRECT
	local Connection1 = AnimatedCamosValue:GetPropertyChangedSignal("Value"):Connect(function()
		return ToggleWeaponCamos(AnimatedCamosValue.Value)
	end)
	
	local Connection2 = BrightnessValue:GetPropertyChangedSignal("Value"):Connect(function()
		return ChangeBrightness(BrightnessValue.Value)
	end)
	
	local Connection3 = HitMarkerValue:GetPropertyChangedSignal("Value"):Connect(function()
		return ToggleHitMarker(HitMarkerValue.Value)
	end)
end

-- DIRECT
function ClientCoreSettingsModule.Initialise()
	return Initialise()
end


return ClientCoreSettingsModule