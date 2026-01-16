local ShadowsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local DebugModule = require(ModulesFolder["Debug"])
local SettingsModule = require(ModulesFolder["Settings"])

-- CORE
local ShadowCache = {}

local ClassesToProperty = 
{
	["Part"] = {PropertyName = "CastShadow", Value = {["OFF"] = false, ["ON"] = true}},
	["MeshPart"] = {PropertyName = "CastShadow", Value = {["OFF"] = false, ["ON"] = true}},
	["UnionOperation"] = {PropertyName = "CastShadow", Value = {["OFF"] = false, ["ON"] = true}}
}

-- Functions
-- MECHANICS
local function ToggleShadows(Child, RenderMode)
	-- CORE
	local PropertyInfo = ClassesToProperty[Child.ClassName]
	
	-- Functions
	-- INIT
	
	----DebugModule:Print"Pre texture toggle")
		
	if not Child or not PropertyInfo then
		return nil
	end
	
	local SettingValue = SettingsModule:GetSettingValue("Video", "CastShadows", true)

	----DebugModule:Print"Toggling textures | Child: ".. tostring(Child).. " | Mode: ".. tostring(RenderMode))
		
	--[[if not TextureCache[Child] then
		TextureCache[Child] = {}
	end]]
	
	if not SettingValue then
		UtilitiesModule:CreateElementCache(Child, {PropertyInfo["PropertyName"]}, ShadowCache)
		
		if PropertyInfo["Value"] ~= nil and PropertyInfo["Value"][SettingValue] ~= nil then
			Child[PropertyInfo["PropertyName"]] = PropertyInfo["Value"][SettingValue]
		end
	else
		if not ShadowCache[Child] then
			return nil
		end
		
		----DebugModule:Print"Enabling shadow")
		Child[PropertyInfo["PropertyName"]] = ShadowCache[Child][PropertyInfo["PropertyName"]]
		UtilitiesModule:RemoveElementCache(Child, {PropertyInfo["PropertyName"]}, ShadowCache)
	end
end

-- DIRECT
function ShadowsModule.Update(NilParam, Child, RenderMode)
	return ToggleShadows(Child, RenderMode)
end

return ShadowsModule