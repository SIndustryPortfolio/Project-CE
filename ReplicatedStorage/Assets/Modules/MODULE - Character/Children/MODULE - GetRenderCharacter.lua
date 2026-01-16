local GetRenderCharacterModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local SpartansPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Spartans"]

-- InfoModules
local VisorColoursInfoModule = require(InfoModulesFolder["VisorColours"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- Functions
-- MECHANICS
local function GetRenderCharacter(CharacterModule, Player)
	-- Elements
	-- VALUES
	local ArmourVariantValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Variant")
	local ArmourColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour")
	local ArmourSecondaryColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour")
	
	-- FOLDERS
	local VisorColourFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, "VisorColours")
	local ArmourEffectsFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, "ArmourEffects")
	local HelmetsFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, "Helmets")
	
	-- CORE
	local SpartanClone = UtilitiesModule:WaitForChildTimed(SpartansPartsFolder, ArmourVariantValue.Value):FindFirstChildOfClass("Model"):Clone()
	
	local TableToReturn = {Character = SpartanClone}
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- CORE
		local EquippedVisorColour = nil
		
		-- Functions
		-- INIT
		if VisorColourFolder:GetAttributes()["Equipped"] and VisorColourFolder:GetAttributes()["Equipped"] ~= "" then
			--EquippedVisorColour = VisorColoursInfoModule:GetVisorColourInfo(VisorColourFolder:GetAttribute("Equipped"))["Colour"]
			EquippedVisorColour = VisorColoursInfoModule:GetInfo(VisorColourFolder:GetAttribute("Equipped"))["Colour"]	
		else
			EquippedVisorColour = BrickColor.new("Bright yellow")
			--EquippedVisorColour = VisorColoursInfoModule:GetVisorColourInfo(VisorColourFolder:GetAttributes()["Equipped"])["Colour"]
		--[[else
			EquippedVisorColour = BrickColor.new("Bright yellow")]]
		end
		
		CharacterModule:CharacterProcess("ApplyHelmet", SpartanClone, HelmetsFolder:GetAttributes()["Equipped"])
		CharacterModule:SetCharacterAppearance(SpartanClone, ArmourColourValue.Value, ArmourSecondaryColourValue.Value, EquippedVisorColour)
		CharacterModule:CharacterProcess("RemoveArmourEffect", SpartanClone)
		CharacterModule:CharacterProcess("ApplyArmourEffect", SpartanClone, ArmourEffectsFolder:GetAttributes()["Equipped"])		
	end
	
	-- DIRECT
	local Connection1 = ArmourColourValue:GetPropertyChangedSignal("Value"):Connect(function()
		Update()
	end)
	
	local Connection2 = ArmourSecondaryColourValue:GetPropertyChangedSignal("Value"):Connect(function()
		Update()
	end)
	
	local Connection3 = VisorColourFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
		Update()
	end)
	
	local Connection4 = ArmourEffectsFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
		Update()
	end)
	
	local Connection5 = HelmetsFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
		Update()
	end)
	
	-- INIT
	Update()
	
	TableToReturn["Connections"] = {Connection1, Connection2, Connection3, Connection4, Connection5}
	
	return TableToReturn
end

-- DIRECT
function GetRenderCharacterModule.Initialise(NilParam, CharacterModule, Player)
	return GetRenderCharacter(CharacterModule, Player)
end

return GetRenderCharacterModule