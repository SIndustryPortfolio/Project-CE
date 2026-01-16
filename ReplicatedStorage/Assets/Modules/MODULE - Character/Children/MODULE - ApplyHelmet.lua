local ApplyHelmetModule = {}

-- Dirs
local PartsArmoursFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["Armours"]

-- Functions
-- MECHANICS
local function DeletePreviousHelmet(Character)
	-- Functions
	-- INIT
	for i, Model in pairs(Character:GetChildren()) do
		if Model:GetAttributes()["Helmet"] then
			Model:Destroy()
		end
	end
end

local function GetHelmet(HelmetName)
	-- Functions
	-- INIT
	return PartsArmoursFolder["Helmets"]:FindFirstChild(HelmetName):Clone()
end

local function GetPreviousHelmetName(Character)
	-- Functioons
	-- INIT
	for i, Model in pairs(Character:GetChildren()) do
		if Model:GetAttributes()["Helmet"] then
			return Model.Name
		end
	end
end

local function Initialise(CharacterModule, Character, HelmetName)
	-- Functions
	-- INIT
	--[[if HelmetName == "" then
		return nil
	end]]
	
	local PreviousHelmetName = GetPreviousHelmetName(Character)
	
	if PreviousHelmetName == HelmetName then
		return nil
	else
		DeletePreviousHelmet(Character)
	end
		
	local VisorPart = Character:FindFirstChild("Visor")
	
	if VisorPart then
		if HelmetName ~= "" then
			VisorPart.Transparency = 1
		else
			VisorPart.Transparency = 0
		end
		--VisorPart:Destroy()
	end
	
	local HeadPart = Character:FindFirstChild("Head")

	if HeadPart then
		local FoundDecal = HeadPart:FindFirstChildOfClass("Decal")

		if HelmetName ~= "" then
			HeadPart.Transparency = 1
			FoundDecal.Transparency = 1
		else
			HeadPart.Transparency = 0
			FoundDecal.Transparency = 0
		end
	end
	
	if HelmetName ~= "" then
		local HelmetModel = GetHelmet(HelmetName)
		HelmetModel:SetAttribute("Helmet", true)
		HelmetModel.Parent = Character
		local HelmWeld = HelmetModel:FindFirstChild("HelmWeld")
		HelmWeld.Part1 = HeadPart		
		HelmetModel:SetPrimaryPartCFrame(HeadPart.CFrame * HelmWeld.C0)
	end
end

-- INIT
function ApplyHelmetModule.Initialise(NilParam, ...)
	return Initialise(...)
end

return ApplyHelmetModule