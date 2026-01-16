local TexturesModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local TextureCache = {}

local TextureClassesToProperty = 
{
	["SurfaceGui"] = {PropertyName = "PixelsPerStud", MultiplierPropertyNames = {"PixelsPerStud"}, ValueMultiplier = {["ULTRA LOW"] = 0.25, ["LOW"] = 0.5, ["MEDIUM"] = 0.75, ["HIGH"] = 1, ["ULTRA HIGH"] = 1}},
	["Texture"] = {PropertyName = "Texture", MultiplierPropertyNames = {"StudsPerTileU", "StudsPerTileV"}, Value = {["ULTRA LOW"] = ""}, ValueMultiplier = {["LOW"] = 4, ["MEDIUM"] = 2, ["HIGH"] = 1, ["ULTRA HIGH"] = 1}},
	["Decal"] = {PropertyName = "Texture", Value = {["ULTRA LOW"] = ""}},
	["Part"] = {PropertyName = "Material", Value = {["ULTRA LOW"] = Enum.Material.SmoothPlastic}},
	["MeshPart"] = {PropertyName = "Material", Value = {["ULTRA LOW"] = Enum.Material.SmoothPlastic}},
	["UnionOperation"] = {PropertyName = "Material", Value = {["ULTRA LOW"] = Enum.Material.SmoothPlastic}}
}

local Toggle = 
{
	["ULTRA LOW"] = true,
	["LOW"] = true,
	["MEDIUM"] = true,
	["HIGH"] = false
}

-- Functions
-- MECHANICS
local function ToggleTextures(Child, RenderMode)
	-- CORE
	local PropertyInfo = TextureClassesToProperty[Child.ClassName]
	
	-- Functions
	-- INIT
	----DebugModule:Print"Pre texture toggle")
		
	if not Child or not PropertyInfo then
		return nil
	end
	----DebugModule:Print"Toggling textures | Child: ".. tostring(Child).. " | Mode: ".. tostring(RenderMode))
	
	local _Toggle = Toggle[RenderMode]
	
	--[[if not TextureCache[Child] then
		TextureCache[Child] = {}
	end]]
	
	local TableToCache = {PropertyInfo["PropertyName"]}

	if PropertyInfo["MultiplierPropertyNames"] then
		TableToCache = UtilitiesModule:CombineTables(TableToCache, PropertyInfo["MultiplierPropertyNames"]) --[[{unpack(TableToCache), unpack(PropertyInfo["MultiplierPropertyNames"])}]]
	end	
	
	if not _Toggle then
		if not TextureCache[Child] then
			return nil
		end
		
		Child[PropertyInfo["PropertyName"]] = TextureCache[Child][PropertyInfo["PropertyName"]]
		
		if PropertyInfo["MultiplierPropertyNames"] then
			for i, MultiplierPropertyName in pairs(PropertyInfo["MultiplierPropertyNames"]) do
				if PropertyInfo["ValueMultiplier"] ~= nil and PropertyInfo["ValueMultiplier"][RenderMode] ~= nil then
					Child[MultiplierPropertyName] = TextureCache[Child][MultiplierPropertyName]
				end
			end
		end
		
		UtilitiesModule:RemoveElementCache(Child, TableToCache, TextureCache)
	else
		UtilitiesModule:CreateElementCache(Child, TableToCache, TextureCache)
				
		if PropertyInfo["Value"] ~= nil and PropertyInfo["Value"][RenderMode] ~= nil then
			Child[PropertyInfo["PropertyName"]] = PropertyInfo["Value"][RenderMode]
		end
		
		if PropertyInfo["MultiplierPropertyNames"] then
			for i, MultiplierPropertyName in pairs(PropertyInfo["MultiplierPropertyNames"]) do
				if PropertyInfo["ValueMultiplier"] ~= nil and PropertyInfo["ValueMultiplier"][RenderMode] ~= nil then
					Child[MultiplierPropertyName] = TextureCache[Child][MultiplierPropertyName] * PropertyInfo["ValueMultiplier"][RenderMode]
				end
			end
		end
	end
end

-- DIRECT
function TexturesModule.Update(NilParam, Child, RenderMode)
	return ToggleTextures(Child, RenderMode)
end

return TexturesModule