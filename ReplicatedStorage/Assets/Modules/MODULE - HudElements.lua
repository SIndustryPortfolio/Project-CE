local HudElementsModule = {}

-- Dirs
local InfoModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["InfoModules"]
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]
local HudElementsPartsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Parts"]["HudElements"]
local GameScoresFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["Scores"]
local GameFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")
local GlobalLeaderboardFolder = game:GetService("ReplicatedStorage"):WaitForChild("Game")["GlobalLeaderboard"]

-- Elements
-- FOLDERS
local DonatedFolder = GlobalLeaderboardFolder["Donated"]

-- Client
local LocalPlayer = game.Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Info Modules
local KillStreaksInfoModule = require(InfoModulesFolder["KillStreaks"])
local PowerUpsInfoModule = require(InfoModulesFolder["PowerUps"])
local ButtonToActionInfoModule = require(InfoModulesFolder["ButtonToAction"])
local RanksInfoModule = require(InfoModulesFolder["Ranks"])
local DevicesInfoModule = require(InfoModulesFolder["Devices"])
local EmblemsInfoModule = require(InfoModulesFolder["Emblems"])
local GameModesInfoModule = require(InfoModulesFolder["GameModes"])
local SpecialRanksInfoModule = require(InfoModulesFolder["SpecialRanks"])
local CoversInfoModule = require(InfoModulesFolder["Covers"])
local PerkDrinksInfoModule = require(InfoModulesFolder["PerkDrinks"])

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local ShortcutsModule = require(ModulesFolder["Shortcuts"])
local GameModule = require(ModulesFolder["Game"])
local UtilitiesModule = require(ModulesFolder["Utilities"])
local PurchaseableModule = require(ModulesFolder["Purchaseable"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Services
local UserInputService = game:GetService("UserInputService")

-- Functions
-- MECHANICS
local function GetHudElement(Name)
	return UtilitiesModule:WaitForChildTimed(HudElementsPartsFolder, Name):Clone()
end

-- DIRECT
function HudElementsModule.HandleSpartanDragFrame(NilParam, DragAreaFrame, SpartanClone)
	-- CORE
	local MouseDown = false
	local Connections = {}
	
	-- Functions
	-- MECHANICS
	local function MouseMoved()
		-- Functions
		-- INIT
		local Delta = UserInputService:GetMouseDelta()

		if MouseDown then
			if not SpartanClone then
				return UtilitiesModule:DisconnectConnections(Connections)
			end
			
			SpartanClone.PrimaryPart.CFrame = SpartanClone.PrimaryPart.CFrame:Lerp(SpartanClone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(Delta.X), 0), 0.4)

			--SpartanClone:SetPrimaryPartCFrame(SpartanClone.PrimaryPart.CFrame * CFrame.Angles(0, math.rad(Delta.X), 0))
		end
	end

	-- DIRECT
	local Connection1 = Mouse.Button1Down:Connect(function()
		if Mouse.X > DragAreaFrame.AbsolutePosition.X and Mouse.X < (DragAreaFrame.AbsolutePosition.X + DragAreaFrame.AbsoluteSize.X) then
			if Mouse.Y > DragAreaFrame.AbsolutePosition.Y and Mouse.Y < (DragAreaFrame.AbsolutePosition.Y + DragAreaFrame.AbsoluteSize.Y) then
				DebugModule:Print(script.Name.. " | Initialise | Mouse Down!")

				UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition				
				MouseDown = true
			end
		end
	end)

	local Connection2 = Mouse.Button1Up:Connect(function()
		UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		MouseDown = false
	end)

	local Connection3 = Mouse.Move:Connect(function()
		return MouseMoved()
	end)
	
	-- CONNECTIONS
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	table.insert(Connections, Connection3)
	
	return Connections
end

function HudElementsModule.HandlePlayerEmblemFrame(NilParam, Player, EmblemFrame)
	-- CORE
	local Connections = {}
	
	local EmblemIcon1Value = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "EmblemIcon1")
	local EmblemIcon2Value = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "EmblemIcon2")
	--
	local ArmourColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour")
	local ArmourSecondaryColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "SecondaryColour")
	
	local Loopable = {EmblemIcon1Value, EmblemIcon2Value, ArmourColourValue, ArmourSecondaryColourValue}
	
	-- Elements
	-- IMAGES
	local Emblem1Image = UtilitiesModule:WaitForChildTimed(EmblemFrame, "Emblem1")
	local Emblem2Image = UtilitiesModule:WaitForChildTimed(EmblemFrame, "Emblem2")
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- Functions
		-- INIT
		pcall(function()
			Emblem1Image.Image = EmblemsInfoModule:GetEmblemInfo(EmblemIcon1Value.Value)["Wrap"]["Id"]
			Emblem1Image.ImageColor3 = UtilitiesModule:TypeToColor3(ArmourColourValue.Value)
		end)
		pcall(function()
			Emblem2Image.Image = EmblemsInfoModule:GetEmblemInfo(EmblemIcon2Value.Value)["Wrap"]["Id"]
			Emblem2Image.ImageColor3 = UtilitiesModule:TypeToColor3(ArmourSecondaryColourValue.Value)
		end)
	end
	
	-- DIRECT
	for i, Value in pairs(Loopable) do
		local Connection1 = Value:GetPropertyChangedSignal("Value"):Connect(function()
			Update()
		end)
		
		-- CONNECTIONS
		table.insert(Connections, Connection1)
	end
	
	-- INIT
	Update()
	
	return Connections
end

function HudElementsModule.HandlePlayerProgressBarFrame(NilParam, Player, ProgressBarBackingFrame)
	-- CORE
	local PlayerRankValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Rank")
	local PlayerXpValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Xp")
	
	-- Functions
	-- INIT
	local BarBackingFrame = ProgressBarBackingFrame["BarBacking"]
	local BarFrame = BarBackingFrame["Bar"]

	-- TEXT
	local BarProgressText = BarBackingFrame["Progress"]

	-- IMAGES
	local CurrentRankImage = ProgressBarBackingFrame["CurrentRank"]
	local NextRankImage = ProgressBarBackingFrame["NextRank"]

	-- Functions
	-- MECHANICS
	local function Update()
		-- CORE
		local CurrentRankInfo = RanksInfoModule:GetRankInfo(PlayerRankValue.Value)
		local NextRankInfo = RanksInfoModule:GetRankInfo(PlayerRankValue.Value + 1)		

		-- Functions
		-- INIT
		if CurrentRankInfo then
			CurrentRankImage.Image = CurrentRankInfo["Icon"]["Id"]
			
			if CurrentRankInfo["Icon"]["Colour"] then
				CurrentRankImage.ImageColor3 = CurrentRankInfo["Icon"]["Colour"].Color
			end
		end
		
		if NextRankInfo then
			NextRankImage.Image = NextRankInfo["Icon"]["Id"]
			if NextRankInfo["Icon"]["Colour"] then
				NextRankImage.ImageColor3 = NextRankInfo["Icon"]["Colour"].Color		
			end
			BarProgressText.Text = tostring(PlayerXpValue.Value - CurrentRankInfo["RequiredXp"]).. " / ".. tostring(NextRankInfo["RequiredXp"] - CurrentRankInfo["RequiredXp"]).. " | NEXT RANK: ".. tostring(NextRankInfo["Name"])
			BarFrame.Size = UDim2.new(math.clamp((PlayerXpValue.Value - CurrentRankInfo["RequiredXp"]) / (NextRankInfo["RequiredXp"] - CurrentRankInfo["RequiredXp"]), 0, 1), 0, 1, 0)
		else
			pcall(function()
				NextRankImage.Image = ""
			end)
			
			BarProgressText.Text = "MAX RANK"
			BarFrame.Size = UDim2.fromScale(1, 1)
		end
	end

	-- DIRECT
	local Connection1 = PlayerRankValue:GetPropertyChangedSignal("Value"):Connect(function()
		return Update()
	end)

	local Connection2 = PlayerXpValue:GetPropertyChangedSignal("Value"):Connect(function()
		return Update()
	end)

	-- INIT
	Update()
	
	return {Connection1, Connection2}
end

function HudElementsModule.HandlePlayerConnectionFrame(NilParam, Player, ConnectionFrame)
	-- Elements
	-- BUTTONS
	--[[local Button = ConnectionFrame:FindFirstChildOfClass("Button")
	
	if not Button then
		Button = Instance.new("TextLabel")
		Button.BackgroundTransparency = 1
		Button.Text = ""
		Button.Size = UDim2.fromScale(1, 1)
		Button.Parent = ConnectionFrame
	end]]
	
	-- CORE
	local Colours = 
	{
		["Off"] = Color3.fromRGB(16, 16, 16),
		["Low"] = {Ping = 500, Colour = Color3.fromRGB(170, 0, 0), Visible = {"Low"}, Invisible = {"Mid", "High"}},
		["Mid"] = {Ping = 150, Colour = Color3.fromRGB(255, 255, 0), Visible = {"Low", "Mid"}, Invisible = {"High"}},
		["High"] = {Ping = 0, Colour = Color3.fromRGB(0, 255, 0), Visible = {"Low", "Mid", "High"}, Invisible = {}}	
	}
	
	-- Functions
	-- MECHANICS
	local function UpdateVisual(Type)
		-- CORE
		local TypeInfo = Colours[Type]
		
		-- Functions
		-- INIT
		if not ConnectionFrame then
			return nil
		end
		
		for i, FrameName in pairs(TypeInfo["Invisible"]) do
			local Frame = UtilitiesModule:WaitForChildTimed(ConnectionFrame, FrameName)
			
			if not Frame then
				continue
			end
			
			Frame.BackgroundColor3 = Colours["Off"]
		end
		
		for i, FrameName in pairs(TypeInfo["Visible"]) do
			local Frame = UtilitiesModule:WaitForChildTimed(ConnectionFrame, FrameName)
			
			if not Frame then
				continue
			end
			
			Frame.BackgroundColor3 = TypeInfo["Colour"]
		end
	end
	
	local function GetPingType(Ping)
		-- Functions
		-- INIT
		if Ping then
			Ping = tonumber(Ping)
		end
		
		local SelectedPingType = "High"
		
		local Order = {"High", "Mid", "Low"}
		
		for i, Type in pairs(Order) do
			local Info = Colours[Type]
			
			if not Ping or not Info then
				SelectedPingType = "Low"
				break
			end
			
			if Ping > Info["Ping"] then
				SelectedPingType = Type
			end
		end
		
		return SelectedPingType
	end
	
	local function UpdatePing()
		if not Player then
			return nil
		end
		
		-- CORE
		local PlayerPing = math.floor(Player:GetAttribute("Ping") or 0)
		
		local SelectedPingType = GetPingType(PlayerPing)
		
		-- Functions
		-- INIT
		return UpdateVisual(SelectedPingType)
	end
	
	local function ShowConnectionHint()
		-- Functions
		-- INIT
		local MenuHudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")
		
		if MenuHudUiModule then
			MenuHudUiModule:UpdateHint(GetPingType(Player:GetAttributes()["Ping"]).. " connection")
			MenuHudUiModule:Show("Hint")
		end
	end
	
	local function HideConnectionHint()
		-- Functions
		-- INIT
		local MenuHudUiModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudUiModule then
			MenuHudUiModule:Hide("Hint")
		end
	end
	
	-- DIRECT
	local Connection1 = nil
	
	if Player then
		Connection1 = Player:GetAttributeChangedSignal("Ping"):Connect(function()
			return UpdatePing()
		end)
	end
	
	local Connection2 = ConnectionFrame.MouseEnter:Connect(function()
		return ShowConnectionHint()
	end)
	
	local Connection3 = ConnectionFrame.MouseLeave:Connect(function()
		return HideConnectionHint()
	end)
	
	-- INIT
	UpdatePing()
	
	return {Connection1, Connection2, Connection3}
end

function HudElementsModule.CreatePowerUp(NilParam, PowerUpName)
	-- CORE
	local PowerUpInfo = PowerUpsInfoModule:GetPowerUpInfo(PowerUpName)

	-- Instancing
	local PowerUpImage = GetHudElement("PowerUp")

	-- Properties
	PowerUpImage.Image = PowerUpInfo["Icon"]["Id"]
	PowerUpImage.Name = PowerUpName

	return PowerUpImage
end

function HudElementsModule.CreateDrinkPerk(NilParam, PerkName)
	-- CORE
	local PerkDrinkInfo = PerkDrinksInfoModule:GetPerkDrinkInfo(PerkName)
	
	-- Instancing
	local BadgeImage = GetHudElement("Badge")
	
	-- Properties
	BadgeImage.Image = PerkDrinkInfo["Image"]["Id"]
	
	return BadgeImage
end

function HudElementsModule.CreateBadge(NilParam, Type, BadgeName)
	-- CORE
	local KillStreakInfo = KillStreaksInfoModule:GetKillStreakInfo(Type, BadgeName)
	
	-- Instancing
	local BadgeImage = GetHudElement("Badge")
	
	-- Properties
	BadgeImage.Image = KillStreakInfo["Image"]["Id"]
	
	return BadgeImage
end

function HudElementsModule.CreateUiHints(NilParam, ParentFrame, Device)
	-- Functions
	-- MECHANICS
	local function Update()
		-- Functions
		-- INIT
		local _Device = LocalPlayer:GetAttributes()["Device"]
		
		--DebugModule:Print("HudElements | Updating UI hints | Device: ".. tostring(_Device).. " | Match against Param: ".. tostring(Device))
		
		if _Device == Device then
			ParentFrame.Visible = true
		else
			ParentFrame.Visible = false
		end
	end
	
	if not LocalPlayer:GetAttributes()["Device"] then
		repeat
			task.wait()
		until LocalPlayer and LocalPlayer:GetAttributes()["Device"]
	end
	
	-- DIRECT
	local Connection1 = LocalPlayer:GetAttributeChangedSignal("Device"):Connect(function()
		return Update()		
	end)
	
	-- INIT
	for ButtonEnum, ActionInfo in pairs(ButtonToActionInfoModule:GetButtonToActionInfo("Ui", Device)) do
		if ParentFrame:FindFirstChild(ActionInfo["ActionName"]) then
			continue
		end
		
		-- Instancing
		local ButtonContainer = GetHudElement("ButtonContainer")
		
		-- Elements
		-- IMAGES
		local ButtonIconImage = UtilitiesModule:WaitForChildTimed(ButtonContainer, "ButtonIcon")
		
		-- TEXTS
		local ButtonActionText = UtilitiesModule:WaitForChildTimed(ButtonContainer, "ButtonAction")
		
		-- Propertties
		ButtonIconImage.Image = ActionInfo["Image"]["Id"]
		ButtonActionText.Text = ActionInfo["ActionName"]
		ButtonContainer.Name = ActionInfo["ActionName"]
		
		ButtonContainer.Parent = ParentFrame
	end
	
	Update()
	
	return {Connection1}
end

function HudElementsModule.CreateTeamNameplate(NilParam, Team)
	-- Elements
	-- VALUES
	local FoundTeamScoreValue = UtilitiesModule:WaitForChildTimed(GameScoresFolder, Team.Name)
	
	-- Instancing
	local Nameplate = GetHudElement("TeamCard")
	
	-- Elements
	-- TEXTS
	local TeamNameText = UtilitiesModule:WaitForChildTimed(Nameplate, "TeamName")
	local TeamPositionText = UtilitiesModule:WaitForChildTimed(Nameplate, "TeamPosition")
	local TeamScoreText = UtilitiesModule:WaitForChildTimed(Nameplate, "TeamScore")
	
	-- Properties
	TeamNameText.Text = Team.Name
	
	-- Functions
	-- MECHANICS
	local function UpdateTeamNameplate()
		if not Team then
			return nil
		end
		
		-- CORE
		local PackagedTeamScores = GameModule:GameProcess("GetOrderedTeamScore")
		
		-- Properties
		if not table.find(PackagedTeamScores["OrderedTeamScores"], Team) then
			return nil
		end
				
		Nameplate.BackgroundColor3 = Team.TeamColor.Color
		TeamPositionText.Text = table.find(PackagedTeamScores["OrderedTeamScores"], Team)
		TeamScoreText.Text = PackagedTeamScores["AllTeamScores"][Team]
	end
	
	-- DIRECT
	local Connection1 = FoundTeamScoreValue:GetPropertyChangedSignal("Value"):Connect(function()
		return UpdateTeamNameplate()
	end)
	
	-- INIT
	UpdateTeamNameplate()
	
	return Nameplate, {Connection1}
end

function HudElementsModule.CreatePlayerNameplate(NilParam, Player)
	-- CORE
	local Connections = {}
	local GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttribute("GameMode"))
	
	-- Instancing
	local Nameplate = GetHudElement("PlayerCard")
	
	-- Elements
	-- FOLDERS
	local PlayerCoverFolder = ShortcutsModule:GetPlayerInventoryFolder(Player, "Covers")
	
	-- VALUES
	local PlayerArmourColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour")
	local PlayerRankValue = ShortcutsModule:GetPlayerStatisticValue(Player, "General", "Rank")
	
	-- FRAMES
	local ConnectionFrame = Nameplate:WaitForChild("Connection")
	local CrewFrame = Nameplate:WaitForChild("Crew")
	
	-- IMAGES
	local CoverImage = Nameplate:WaitForChild("Cover")
	local RankImage = Nameplate:WaitForChild("PlayerRank")
	local SpecialRankImage = Nameplate:WaitForChild("SpecialRank")
	local DeviceImage = Nameplate:WaitForChild("PlayerDevice")
	
	-- TEXTS
	local PlayerNameText = Nameplate:WaitForChild("PlayerName")
	
	-- Properties
	Nameplate.Name = Player.Name
	PlayerNameText.Text = Player.Name
	
	if Player:GetAttributes()["Crew"] == true then
		CrewFrame.Visible = true
	else
		CrewFrame.Visible = false
	end
	
	--[[if PurchaseableModule:DoesUserHavePass(Player, "CECrew") then
		CrewFrame.Visible = true
	end]]
	
	--[[if GameModeInfo and GameModeInfo["Teams"] and (UtilitiesModule:HasProperty(Player, "Team") and Player.Team) then
		Nameplate.BackgroundColor3 = Player.Team.TeamColor.Color
	else
		local ColourValue = ShortcutsModule:GetPlayerStatisticValue(Player, "Armour", "Colour")
		
		if ColourValue then
			Nameplate.BackgroundColor3 = ColourValue.Value.Color
		end
	end]]
	
	-- Functions
	-- MECHANICS
	local function Update()
		-- CORE
		local RankInfo = ShortcutsModule:GetPlayerRankInfo(Player)
		local DeviceInfo = DevicesInfoModule:GetDeviceInfo(Player:GetAttribute("Device"))
		local GameModeInfo = nil 
		
		if GameFolder:GetAttribute("GameMode") and GameFolder:GetAttribute("GameMode") ~= "" then
			GameModeInfo = GameModesInfoModule:GetGameModeInfo(GameFolder:GetAttribute("GameMode"))
		end
		
		-- Functions
		-- INIT
		if ShortcutsModule:IsPlayerInLeaderboard(Player, DonatedFolder) then
			SpecialRankImage.Image = SpecialRanksInfoModule:GetSpecialRankInfo("Top Donator")["Id"]
			SpecialRankImage.Visible = true
		else
			DebugModule:Print(script.Name.. " | Player is not in Donation leaderboard | Player: ".. tostring(Player))
		end
		
		if RankInfo then
			RankImage.Image = RankInfo["Icon"]["Id"]
			
			if RankInfo["Icon"]["Colour"] then
				RankImage.ImageColor3 = RankInfo["Icon"]["Colour"].Color
			end
			
			if DeviceInfo then
				DeviceImage.Visible = true
				DeviceImage.Image = DeviceInfo["Icon"]["Id"]
			else
				DeviceImage.Visible = false
				--return nil
			end
		end
		
		if PlayerCoverFolder then
			local CoverName = PlayerCoverFolder:GetAttributes()["Equipped"]
			
			if CoverName ~= "" and CoverName ~= nil then
				CoverImage.Image = CoversInfoModule:GetInfo(CoverName)["Wrap"]["Id"] --CoversInfoModule:GetCoverInfo(CoverName)["Wrap"]["Id"]
				CoverImage.Visible = true
			else
				CoverImage.Visible = false
			end
		end
		
		if GameModeInfo and GameModeInfo["Teams"] and (UtilitiesModule:HasProperty(Player, "Team") and Player.Team and not Player.Neutral) then
			Nameplate.BackgroundColor3 = Player.Team.TeamColor.Color
			return nil
		end
		
		if PlayerArmourColourValue then
			if --[[(]]PlayerArmourColourValue.Value --[[and GameModeInfo and not GameModeInfo["Teams") or (PlayerArmourColourValue.Value and not GameModeInfo)]] then
				Nameplate.BackgroundColor3 = PlayerArmourColourValue.Value.Color
			elseif Player.Team then
				Nameplate.BackgroundColor3 = Player.Team.TeamColor.Color
			elseif not GameFolder:GetAttributes()["GameTime"] or GameFolder:GetAttributes()["GameTime"] == 0 then
				Nameplate.BackgroundColor3 = PlayerArmourColourValue.Value.Color
			end
		end
	end
	
	local function ShowRankHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")
		
		if MenuHudModule and ShortcutsModule:GetPlayerRankInfo(Player) then
			MenuHudModule:UpdateHint(ShortcutsModule:GetPlayerRankInfo(Player)["Name"])
			MenuHudModule:Show("Hint")
		end
	end
	
	local function HideRankHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:Hide("Hint")
		end
	end
	
	local function ShowSpecialRankHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:UpdateHint(SpecialRanksInfoModule:UnpackId(SpecialRankImage.Image))
			MenuHudModule:Show("Hint")
		end
	end
	
	local function HideSpecialRankHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:Hide("Hint")
		end
	end
	
	local function ShowNameplateHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:UpdateNameplate(Player)
			MenuHudModule:Show("Nameplate")
		end
	end
	
	local function HideNameplateHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:Hide("Nameplate")
		end
	end
	
	local function ShowDeviceHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")
		
		if MenuHudModule then
			MenuHudModule:UpdateHint(Player:GetAttributes()["Device"])
			MenuHudModule:Show("Hint")
		end
	end
	
	local function HideDeviceHint()
		-- Functions
		-- INIT
		local MenuHudModule = InterfacesModule:GetUiModuleFromType("Custom", "MenuHud")

		if MenuHudModule then
			MenuHudModule:Hide("Hint")
		end
	end
	
	-- INIT
	local PingConnections = HudElementsModule:HandlePlayerConnectionFrame(Player, ConnectionFrame)
	
	for i, Connection in pairs(PingConnections) do
		table.insert(Connections, Connection)
	end
	
	Update()
	
	-- DIRECT
	local Connection1 = nil
	
	if PlayerRankValue then
		Connection1 = PlayerRankValue:GetPropertyChangedSignal("Value"):Connect(function()
			Update()
		end)
	end
		
	local Connection2 = nil
	
	if Player:GetAttributes()["Device"] then
		Connection2 = Player:GetAttributeChangedSignal("Device"):Connect(function()
			Update()
		end)
	end
	
	local Connection3 = nil
	
	if PlayerArmourColourValue then
		Connection3 = PlayerArmourColourValue:GetPropertyChangedSignal("Value"):Connect(function()
			Update()
		end)
	end
	
	local Connection4 = nil
	
	if UtilitiesModule:HasProperty(Player, "Team") then
		Connection4 = Player:GetPropertyChangedSignal("Team"):Connect(function()
			Update()
		end)
	end
	
	local Connection5 = Player:GetPropertyChangedSignal("Neutral"):Connect(function()
		Update()
	end)
	
	local Connection6 = DeviceImage.MouseEnter:Connect(function()
		return ShowDeviceHint()
	end)
	
	local Connection7 = DeviceImage.MouseLeave:Connect(function()
		return HideDeviceHint()
	end)
	
	local Connection8 = RankImage.MouseEnter:Connect(function()
		return ShowRankHint()
	end)
	
	local Connection9 = RankImage.MouseLeave:Connect(function()
		return HideRankHint()
	end)
	
	--[[local Connection10 = Nameplate.MouseEnter:Connect(function()
		return ShowNameplateHint()
	end)
	
	local Connection11 = Nameplate.MouseLeave:Connect(function()
		return HideNameplateHint()
	end)]]
	
	local Connection12 = nil
	
	if PlayerCoverFolder then
		Connection12 = PlayerCoverFolder:GetAttributeChangedSignal("Equipped"):Connect(function()
			return Update()
		end)
	end
	
	local Connection13 = SpecialRankImage.MouseEnter:Connect(function()
		return ShowSpecialRankHint()
	end)
	
	local Connection14 = SpecialRankImage.MouseLeave:Connect(function()
		return HideSpecialRankHint()
	end)
	
	-- Connections
	table.insert(Connections, Connection1)
	table.insert(Connections, Connection2)
	table.insert(Connections, Connection3)
	table.insert(Connections, Connection4)
	table.insert(Connections, Connection5)
	table.insert(Connections, Connection6)
	table.insert(Connections, Connection7)
	table.insert(Connections, Connection8)
	table.insert(Connections, Connection9)
	--[[table.insert(Connections, Connection10)
	table.insert(Connections, Connection11)]]
	table.insert(Connections, Connection12)
	table.insert(Connections, Connection13)
	table.insert(Connections, Connection14)
	
	return Nameplate, Connections --{unpack(PingConnections), Connection1, Connection2}
end

return HudElementsModule