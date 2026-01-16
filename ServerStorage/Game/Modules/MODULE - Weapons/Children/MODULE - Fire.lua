local FireModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ServerInfoModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["InfoModules"]
local ServerModulesFolder = game:GetService("ServerStorage"):WaitForChild("Game")["Modules"]
local ServerRemotesFolder = game:GetService("ServerStorage"):WaitForChild("Remotes")["Server"]["Remotes"]
local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")

local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local EffectProcessRemote = ClientServerRemotesFolder["EffectProcess"]
local MainRemote = ServerRemotesFolder["Main"]

-- Info Modules
local ServerWeaponsInfoModule = require(ServerInfoModulesFolder["Weapons"])
local WeaponsInfoModule = require(InfoModulesFolder["Weapons"])
local RoundTypesInfoModule = require(InfoModulesFolder["RoundTypes"])
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local ServerDamageModule = require(ServerModulesFolder["Damage"])
local ServerLobbyModule = require(ServerModulesFolder["Lobby"])
local ServerObjectsModule = require(ServerModulesFolder["Objects"])
local ServerGameModule = require(ServerModulesFolder["Game"])
local DebugModule = require(ModulesFolder["Debug"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])

-- Services
local CollectionService = game:GetService("CollectionService")

-- Functions
-- MECHANICS
local function HandleFireRaycast(Player, WeaponModel, raycastResult, Origin, WeaponName, Charge)
	--print("RAYCAST RESULT")
	--print(raycastResult)
	
	local PackagedReturn = {}

	if raycastResult == nil or not raycastResult.Position  then
		DebugModule:Print("Fire | No raycast result! | Player: ".. tostring(Player))
		return PackagedReturn
	end
	
	if not WeaponModel or not WeaponModel.PrimaryPart then
		DebugModule:Print(script.Name.. " | No WeaponModel! | Player: ".. tostring(Player))
		return PackagedReturn
	end

	-- CORE
	local Type = "Graze"
	local BadgeOverwrite = ""
	local PlayerCharacter = UtilitiesModule:GetCharacter(Player, true)
	local PlayerDrinksFolder = nil
	
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or WeaponModel.Name)
	
	if PlayerCharacter then
		PlayerDrinksFolder = PlayerCharacter:FindFirstChild("Drinks")
	end
	
	if WeaponInfo["ExplosiveRounds"] ~= nil then
		ServerObjectsModule:ObjectProcess("Explosion", raycastResult.Position + (raycastResult.Normal or Vector3.new()), nil, Player, WeaponInfo["ExplosiveRounds"]["Type"], true)
		
		if not PackagedReturn["Explosions"] then
			PackagedReturn["Explosions"] = {}
		end
		
		table.insert(PackagedReturn["Explosions"], raycastResult.Position)
	end
	
	local HitPart = raycastResult.Instance
	
	if not HitPart then
		return PackagedReturn
	end
	
	local Distance = (WeaponModel.PrimaryPart.Position - raycastResult.Position).Magnitude
	local DropOffs = Distance / 30
	
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttribute("GameMode"))
	
	--local PlayerCharacter = UtilitiesModule:GetCharacter(Player, true)
	local PlayerCharacterProcessRemote = UtilitiesModule:GetPlayerCharacterRemote(Player, "CharacterProcess")
	
	-- Elements
	-- Humanoids
	local Humanoid = UtilitiesModule:GetHumanoidFromHit(HitPart)

	if not Humanoid or Humanoid.Health <= 0 then
		--BulletHoleModule:Initialise(raycastResult)
		if Humanoid and Humanoid.Health <= 0 then
			DebugModule:Print("Fire | Player died on registering shot")
		--else
			--DebugModule:Print("Fire | No humanoid!")
		end
		return PackagedReturn
	end

	local Damage = nil
	
	if Charge then
		Damage = WeaponInfo["ChargeDamage"]
	else
		Damage = WeaponInfo["Damage"]
	end
	
	if PlayerDrinksFolder and PlayerDrinksFolder:FindFirstChild("Full Metal Jacket") then
		Damage *= 2
	end
	
	local DropOffMultiplier = WeaponInfo["DamageDropOffMultiplier"] or 0.9
	
	for i = 1, DropOffs do
		Damage = Damage * DropOffMultiplier
	end
	
	--[[if DropOffs > 1 then
		Damage = math.floor(Damage * (0.75 * DropOffs))
	end]]
	
	local IsHeadShot = table.find(ServerWeaponsInfoModule:GetWeaponInfo("HeadshotParts"), HitPart.Name)
	
	if IsHeadShot ~= nil then
		Damage = Damage + (Damage * WeaponInfo["HeadshotDamageMultiplier"])
		Type = "HeadShot"
		
		if Humanoid:GetAttributes()["Shield"] <= 0 and table.find({"Semi Automatic", "Burst"}, WeaponInfo["Type"]) then
			Damage = Humanoid.Health
		end
		
		if WeaponModel.Name == "Sniper" then
			BadgeOverwrite = "SniperHeadshot"
		end
	end

	-- MODELS
	local Character = Humanoid.Parent

	-- Functions
	-- INIT
	local IsDead, DamagedHealth, TakenDamage = ServerDamageModule:TakeDamage(Humanoid, Damage, Player, nil, WeaponModel.PrimaryPart.Position)
	
	--[[local TargetPlayer = game.Players:GetPlayerFromCharacter(Character)
	
	if not TargetPlayer and Character.Parent == workspace["Temporary"]["AI"] then
		TargetPlayer = {["Character"] = Character, Name = Character.Name, Team = {Name = Character:GetAttributes()["Team"]}, ["AI"] = true}
	end]]
	
	local TargetPlayer = ShortcutsModule:GetPlayerFromCharacter(Character)
	
	if TargetPlayer and TakenDamage then
		MainRemote:Fire("PlayerShotRegistered", Player)
	end
	
	if TargetPlayer and ((GameModeInfo["Teams"] and TargetPlayer.Team ~= Player.Team) or not GameModeInfo["Teams"])  then
		--coroutine.wrap(function()
		
		if typeof(TargetPlayer) ~= "table" then
			local XPReturn = ServerGameModule:GameProcess("AddXp", Player, Type, {Target = Character}, true)
			
			if XPReturn then
				PackagedReturn["Feed"] = XPReturn
			end
		end
		--end)()

		--[[if Player.Settings.Game.VisualDamage.Value == "ON" or Player.Settings.Game.HitMarker.Value == "ON" then
 			PlayerCharacterProcessRemote:FireClient(Player, "Damage", Character, Damage, IsHeadShot, DamagedHealth, raycastResult.Position)
		end	]]
		
		PackagedReturn["Damage"] = 
		{
			["Character"] = Character,
			["Damage"] = Damage,
			["TakenDamage"] = TakenDamage,
			["IsHeadShot"] = IsHeadShot,
			["DamagedHealth"] = DamagedHealth,
			["Position"] = raycastResult.Position
		}
	end
	
	
	if TargetPlayer and TakenDamage then
		if DamagedHealth then
			--DebugModule:Print"Blood leak server | Character: ".. tostring(Character).. " | result: ".. tostring(raycastResult))
			--EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "BloodLeak", Character, {Position = raycastResult.Position, Normal = raycastResult.Normal, _Instance = raycastResult.Instance, _Origin = Origin})
			--
			
			PackagedReturn["Damage"]["Effect"] = {["Name"] = "BloodLeak", ["Character"] = Character, ["Result"] = {Position = raycastResult.Position, Normal = raycastResult.Normal, _Instance = raycastResult.Instance, _Origin = Origin}}
			
				--[[if PlayerCharacterProcessRemote then
					local StringToSend = "Grazed ".. tostring(Humanoid.Parent.Name)
					local Type = "Graze"
					
					if IsHeadShot then
						StringToSend = "Head shotted ".. tostring(Humanoid.Parent.Name)
					end
					
					PlayerCharacterProcessRemote:FireClient(Player, "Feed", )
				end]]
		else
			PackagedReturn["Damage"]["Effect"] = {["Name"] = "ShieldHit", ["Character"] = Character, ["Result"] = {Position = raycastResult.Position, Normal = raycastResult.Normal, _Instance = raycastResult.Instance, _Origin = Origin}}
			--EffectProcessRemote:FireAllClients("EffectProcess", "FPSEffects", "ShieldHit", Character, {Position = raycastResult.Position, Normal = raycastResult.Normal, _Instance = raycastResult.Instance, _Origin = Origin})
		end
	end
	
	coroutine.wrap(function()
		if IsDead then
			local DeadPlayer = game.Players:FindFirstChild(Character.Name) --game.Players:GetPlayerFromCharacter(Character)
			
			if not DeadPlayer and typeof(TargetPlayer) == "table" then
				DeadPlayer = TargetPlayer
				ServerGameModule:GameProcess("Kill", Player, WeaponModel.Name, DeadPlayer, IsHeadShot, BadgeOverwrite, true, Distance)
				return PackagedReturn
			end
			
			if DeadPlayer --[[and DeadPlayer.Team ~= Player.Team]] then
				ServerGameModule:GameProcess("Kill", Player, WeaponModel.Name, DeadPlayer, IsHeadShot, BadgeOverwrite, nil, Distance) --ServerLobbyModule:IncrementValue(Player, "Kills")
			end
		end
	end)()
	
	return PackagedReturn
end


local function ToggleEffect(Attachment, ToggleValue, PlayerToIgnore)
	-- Functions
	-- INIT
	--[[for i, Emitter in pairs(Attachment:GetChildren()) do
		pcall(function()
			Emitter.Enabled = ToggleValue
		end)
	end]]
	--EffectProcessRemote:FireAllClients("ToggleParticleEmitters", Attachment, ToggleValue, PlayerToIgnore)
	
	if PlayerToIgnore then
		Attachment:SetAttribute("PlayerToIgnore", PlayerToIgnore.Name)
	end
	
	if ToggleValue then
		CollectionService:AddTag(Attachment, "ToggleParticleEmitters")
	else
		CollectionService:RemoveTag(Attachment, "ToggleParticleEmitters")
	end
end


local function HandleFireEffect(Player, WeaponModel, raycastResult, WeaponName, Charge, Result)
	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player, true)
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or WeaponModel.Name)
	
	-- Elements
	-- PARTS
	local BarrelPart = WeaponModel:FindFirstChild("Barrel") --WeaponModel.PrimaryPart
	
	if not BarrelPart then
		return nil
	end
	
	-- Attachments
	local Attachment = UtilitiesModule:WaitForChildOfClass(BarrelPart, "Attachment")
	
	-- PARTICLE EMITTERS
	local MuzzleFlashParticleEmitter = Attachment:FindFirstChild("MuzzleFlash")

	-- Functions
	-- INIT
	ToggleEffect(Attachment, true, Player)
	EffectProcessRemote:FireAllClients("Fire", Player, WeaponModel, raycastResult, WeaponName, Charge, Result)
	--GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "Fire")
	
	local WeaponNames = {Character:GetAttribute("Primary"), Character:GetAttribute("Secondary")}
	
	if table.find(WeaponNames, WeaponModel.Name) ~= nil then
		UtilitiesModule:GetPlayerCharacterSignal(Player, "GunRequest"):InvokeClient(Player, "Fire")
	end
	
	--task.wait(1 / WeaponModel:GetAttribute("FireRate"))
	--task.wait(0.1)
	task.wait(MuzzleFlashParticleEmitter.Lifetime.Min)
	ToggleEffect(Attachment, false, Player)
end

local function HandleFireWeaponLogic(Player, WeaponModel, raycastResult, WeaponName, Charge) --> The actual damage -> Connects the functions
	-- Functions
	-- INIT
	local BarrelPart = WeaponModel:FindFirstChild("Barrel") --WeaponModel.PrimaryPart
	
	if not BarrelPart then
		DebugModule:Print(script.Name.. " | HandleFireWeaponLogic | No barrel part!")
		return nil
	end
	
	local ToReturn = {}
	
	if typeof(raycastResult) == "table" and raycastResult[1] ~= nil then
		--DebugModule:Print("Scattering")
		
		local Done = 0
		
		for i, _raycastResult in pairs(raycastResult) do
			coroutine.wrap(function()
				if not BarrelPart then
					DebugModule:Print("Barrel part not found! V")
					DebugModule:Print("Fire | WeaponModel: ".. tostring(WeaponModel))
					DebugModule:Print("Fire | Raycast Result: ".. tostring(_raycastResult))
					
					Done += 1
					return nil
				end

				local Success, Error = pcall(function()				
					return HandleFireRaycast(Player, WeaponModel, _raycastResult, BarrelPart.Position, WeaponName, Charge)
				end)

				if not Success then
					DebugModule:Print("Error: ".. tostring(Error))
				else
					--[[if Error then
						Error["Result"] = raycastResult
					end]]
					
					table.insert(ToReturn, Error)
				end
				Done += 1
			end)()
		end
		
		repeat
			task.wait()
		until Done >= #raycastResult
	else
		local Result = HandleFireRaycast(Player, WeaponModel, raycastResult, BarrelPart.Position, WeaponName, Charge)
		
		--[[if Result then
			Result["Result"] = raycastResult
		end]]
		
		table.insert(ToReturn, Result)
	end
	
	return ToReturn
end

local function FireWeapon(Player, WeaponModel, raycastResult, Force, WeaponName, Charge)
	if not WeaponModel then
		return nil
	end
	
	local Result = nil

	-- CORE
	local Character = UtilitiesModule:GetCharacter(Player) --GetCharacter(Player)

	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponName or WeaponModel.Name)

	if not Character then
		DebugModule:Print("Fire | FireWeapon | Character not found!")
		return nil
	end

	-- Elements
	-- HUMANOIDS
	local Humanoid = UtilitiesModule:WaitForChildTimed(Character, "Humanoid")

	-- PARTS
	local BarrelPart = WeaponModel:FindFirstChild("Barrel") --WeaponModel.PrimaryPart
	
	if not BarrelPart then
		DebugModule:Print("Fire | FireWeapon | Barrel Part not found!")
		return nil
	end
	
	-- Functions
	-- INIT
	if not Humanoid then
		DebugModule:Print("Fire | FireWeapon | No Humanoid")
		return nil
	end
	
	if Humanoid.Health <= 0 then
		DebugModule:Print("Fire | FireWeapon | Humanoid Health is dead")
		return nil
	end

	if --[[Humanoid:GetAttribute("Reload") or]] Humanoid:GetAttribute("Melee") then
		DebugModule:Print("Fire | FireWeapon | Humanoid is Reloading or Meleeing!")
		return nil
	end
	
	if Humanoid:GetAttribute("Reload") then
		Humanoid:SetAttribute("Reload", false)
	end

	if not WeaponModel then
		return nil
	end

	if not Force and (WeaponInfo["Technology"] == "UNSC" and WeaponModel:GetAttribute("RoundsInMag") <= 0) or (WeaponInfo["Technology"] == "Covenant" and WeaponModel:GetAttribute("Energy") <= 0) then
		SoundsModule:PlaySoundEffectById(WeaponInfo["EmptyMagSound"], nil, BarrelPart, nil, nil)
		return nil
	end
	
	if WeaponInfo["ProjectileType"] ~= "Projectile" then
		Result = HandleFireWeaponLogic(Player, WeaponModel, raycastResult, WeaponName, Charge)
	end
	
	coroutine.wrap(function()
		return HandleFireEffect(Player, WeaponModel, raycastResult, WeaponName, Charge, Result)		
	end)()
	
	--[[if WeaponInfo["ProjectileType"] ~= "Projectile" then
		if typeof(raycastResult) == "table" and raycastResult[1] ~= nil then
			--DebugModule:Print("Scattering")
			for i, _raycastResult in pairs(raycastResult) do
				coroutine.wrap(function()
					if not BarrelPart then
						DebugModule:Print("Barrel part not found! V")
						DebugModule:Print("Fire | WeaponModel: ".. tostring(WeaponModel))
						DebugModule:Print("Fire | Raycast Result: ".. tostring(_raycastResult))
						return nil
					end
					
					local Success, Error = pcall(function()				
						return HandleFireRaycast(Player, WeaponModel, _raycastResult, BarrelPart.Position, WeaponName)
					end)

					if not Success then
						DebugModule:Print("Error: ".. tostring(Error))
					end
				end)()
			end
		else
			HandleFireRaycast(Player, WeaponModel, raycastResult, BarrelPart.Position, WeaponName)
		end
	end]]
	
	--SoundsModule:PlaySoundEffectById(WeaponInfo["FireSound"], nil, BarrelPart, nil, nil)
	if not Force then
		if WeaponInfo["Technology"] == "UNSC" then
			WeaponModel:SetAttribute("RoundsInMag", math.clamp(WeaponModel:GetAttribute("RoundsInMag") - 1, 0, math.huge))
		elseif WeaponInfo["Technology"] == "Covenant" then
			if Charge then
				WeaponModel:SetAttribute("Energy", math.clamp(WeaponModel:GetAttribute("Energy") - WeaponModel:GetAttribute("MaxCharge"), 0, math.huge))
			else
				WeaponModel:SetAttribute("Energy", math.clamp(WeaponModel:GetAttribute("Energy") - --[[1]] WeaponInfo["MinimumEnergyConsumption"], 0, math.huge))
			end
			--WeaponModel:SetAttribute("CurrentEnergyUsage", math.clamp(WeaponModel:GetAttribute("CurrentEnergyUsage") + WeaponInfo["MinimumEnergyConsumption"], 0, WeaponModel:GetAttribute("MaxCharge")))
		end
	end
	
	return Result
end

local function ProjectileRegistered(Player, Part, WeaponModel, Charge)
	-- CORE
	local WeaponInfo = WeaponsInfoModule:GetWeaponInfo(WeaponModel.Name)
	
	-- Functions
	-- INIT
	if WeaponInfo["ProjectileType"] ~= "Projectile" or not Part then
		DebugModule:Print(script.Name.. " | ProjectileRegistered | ProjectileType is: ".. tostring(WeaponInfo["ProjectileType"]).. " | WeaponModel: ".. tostring(WeaponModel).. " | Part: ".. tostring(Part))
		return nil
	end
	
	local Result = HandleFireWeaponLogic(Player, WeaponModel, {["Instance"] = Part, ["Position"] = Part.Position}, WeaponModel.Name, Charge)
	HandleFireEffect(Player, WeaponModel, {["Instance"] = Part, ["Position"] = Part.Position}, WeaponModel.Name, Charge, Result)
	
	return Result
end

-- Functions
-- DIRECT
function FireModule.Fire(NilParam, ...)
	return FireWeapon(...)
end

function FireModule.ProjectileRegistered(NilParam, ...)
	return ProjectileRegistered(...)
end

return FireModule