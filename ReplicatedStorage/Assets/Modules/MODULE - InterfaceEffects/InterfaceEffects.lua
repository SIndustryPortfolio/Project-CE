local InterfaceEffectsModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Client
--local Player = game.Players.LocalPlayer
--local Mouse = Player:GetMouse()

-- Modules
local UtilitiesModule = require(ModulesFolder["Utilities"])
local SoundsModule = require(ModulesFolder["Sounds"])
local DebugModule = require(ModulesFolder["Debug"])

-- CORE
local RequiredModules = {}

local AllEffectInfo = 
{
	["InventoryButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut	
	},
	["ShopButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
			
	},
	["CrewButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["MenuButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut,
		
		["IconSizeMultiplier"] = 1.4,
		["ButtonBackgroundTransparency"] = 0.75,
		["BlockTransparency"] = 0.5,

		["SwipeDuration"] = 0.5,
		["SwipeStyle"] = Enum.EasingStyle.Linear,
		["SwipeDirection"] = Enum.EasingDirection.InOut
	},
	["MainButton"] = 
	{
		["Duration"] = 0.3,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut,
			
		["HoverSizeMultiplier"] = 0.25,
		["RGBAmplifier"] = 30
	},
	["Fade"] = 
	{
		["Duration"] = 1,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["ExpandElement"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["ShrinkElement"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut	
	},
	["YTransitionIn"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	},
	["YTransitionOut"] = 
	{
		["Duration"] = 0.5,
		["Style"] = Enum.EasingStyle.Cubic,
		["Direction"] = Enum.EasingDirection.InOut
	}
}

local ElementCache = {}
local TweenDict = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Functions
-- MECHANICS
local function RunSubModules()
	-- Functions
	-- INIT
	RequiredModules = UtilitiesModule:RunSubModules(script, true)
end


local function TweenWait(TweenElement)
	if TweenElement.PlaybackState == Enum.PlaybackState.Playing then
		TweenElement.Completed:Wait()
	end
end

local function IsUiAdditionalElement(Element)
	-- CORE
	local ClassNames = {"UIListLayout", "UIGradient", "UIGridLayout", "UIStroke" , "UIPadding", "Frame", "TextLabel", "Configuration"}
	
	-- Functions
	-- INIT
	for i, ClassName in pairs(ClassNames) do
		if Element:IsA(ClassName) then
			return true
		end
	end
	
	return false
end

local function MultiplyUDim2(UDim2Value, Multiplier)
	return UDim2.new(UDim2Value.X.Scale * Multiplier, UDim2Value.X.Offset * Multiplier, UDim2Value.Y.Scale * Multiplier, UDim2Value.Y.Offset * Multiplier)
end

local function Color3FromRGB(RGBValue)
	return Color3.fromRGB(RGBValue.R, RGBValue.G, RGBValue.B)
end

local function AddToColor3(RGBValue, Amplifier)
	return {R = RGBValue.R + Amplifier, G = RGBValue.G + Amplifier, B = RGBValue.B + Amplifier}
end

local function Color3ToRGB(Color3Value)
	return {R = Color3Value.r * 255, G = Color3Value.g * 255, B = Color3Value.b * 255}
end

local function CancelTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		TweenDict[TweenElement]:Cancel()
		TweenDict[TweenElement]:Destroy()
	end
end

local function CompleteTween(TweenElement)
	if TweenDict[TweenElement] ~= nil then
		local Connection
		
		Connection = TweenDict[TweenElement].Completed:Connect(function(PlaybackStatus)
			if PlaybackStatus == Enum.PlaybackState.Completed then
				TweenDict[TweenElement]:Destroy()
			end
			
			Connection:Disconnect()
		end)
	end
end

local function CreateElementCache(Element, Properties)
	if not Element then
		return nil
	end
	
	if ElementCache[Element] == nil then
		ElementCache[Element] = {}
	end
	
	if not Properties then
		return nil
	end
	
	for i, PropertyName in pairs(Properties) do
		if ElementCache[Element][PropertyName] == nil then
			local Success, Error = pcall(function()
				ElementCache[Element][PropertyName] = Element[PropertyName]
			end)
			
			if not Success then
				ElementCache[Element][PropertyName] = Element:GetAttributes()[PropertyName]
			end
		end
	end
	
	return ElementCache[Element]
end

-- DIRECT
-- SINGLE LOADERS
function InterfaceEffectsModule.Fade(NilParam, Element, Type, _Wait, CustomEffectInfo, IgnoreProperties, ForceTweenTo, StartTransparency)
	if not Element then
		return nil
	end
	
	-- CORE
	local EffectInfo = CustomEffectInfo or AllEffectInfo["Fade"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local ClassToBackgroundProperties = 
	{
		["ImageLabel"] = {"ImageTransparency", "BackgroundTransparency"},
		["TextLabel"] = {"TextTransparency", "BackgroundTransparency", "TextStrokeTransparency"},
		["Frame"] = {"BackgroundTransparency"}	
	}
	
	local ChosenArrayOfProperties = ClassToBackgroundProperties[Element.ClassName]
	
	-- Functions
	-- INIT
	if IgnoreProperties then
		for i, PropertyName in pairs(IgnoreProperties) do
			local FoundIndex = table.find(ChosenArrayOfProperties, PropertyName)
			
			if FoundIndex then
				table.remove(ChosenArrayOfProperties, FoundIndex)
			end
		end
	end
	
	CreateElementCache(Element, ChosenArrayOfProperties)
	
	if StartTransparency then
		for i, PropertyName in pairs(ChosenArrayOfProperties) do
			Element[PropertyName] = StartTransparency
		end
	end
	
	-- Tween
	local tweeningInfo = {}
	
	for i, PropertyName in pairs(ChosenArrayOfProperties) do
		if Type == "In" then
			Element[PropertyName] = 1
			
			local ToTweenTo = ElementCache[Element][PropertyName] or 0
			
			if ForceTweenTo then
				ToTweenTo = ForceTweenTo
			end
			
			--[[if ToTweenTo == 1 then
				ToTweenTo = 0
			end]]
			
			tweeningInfo[PropertyName] = ToTweenTo
		elseif Type == "Out" then
			tweeningInfo[PropertyName] = 1
		end
	end

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenDict[Element].Completed:Wait()
	end
end

function InterfaceEffectsModule.YTransitionOut(NilParam, Element, _Wait)
	-- CORE
	local EffectInfo = AllEffectInfo["YTransitionOut"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})
	
	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]
	
	-- Tween
	local tweeningInfo = {}
	tweeningInfo.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, -ElementOldSize.Y.Scale, -ElementOldSize.Y.Offset - 36)
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.YTransitionIn(NilParam, Element, _Wait)
	-- CORE
	local EffectInfo = AllEffectInfo["YTransitionIn"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Functions
	-- INIT
	CreateElementCache(Element, {"Position", "Size"})
	
	local ElementOldPosition = ElementCache[Element]["Position"]
	local ElementOldSize = ElementCache[Element]["Size"]
	
	-- Properties
	Element.Position = UDim2.new(ElementOldPosition.X.Scale, ElementOldPosition.X.Offset, -ElementOldSize.Y.Scale, -ElementOldSize.Y.Offset - 36)
	
	-- TWEEN
	local tweeningInfo = {}
	tweeningInfo.Position = ElementOldPosition
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
		
	if _Wait then
		TweenWait(TweenDict[Element])
	end
end

function InterfaceEffectsModule.ExpandElement(NilParam, Element, _Wait, Axis)
	-- CORE
	local EffectInfo = AllEffectInfo["ExpandElement"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Size"})
	
	-- Properties
	if Axis then
		if string.lower(Axis) == "x" then
			Element.Size = UDim2.new(0, 0, Element.Size.Y.Scale, Element.Size.Y.Offset)
		elseif string.lower(Axis) == "y" then
			Element.Size = UDim2.new(Element.Size.X.Scale, Element.Size.X.Offset, 0, 0)
		end
	else
		Element.Size = UDim2.new()
	end
	
	-- TWEEN
	local tweeningInfo = {}
	tweeningInfo.Size = ElementCache[Element]["Size"]
	
	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end
	
	return TweenDict[Element]
end

function InterfaceEffectsModule.ShrinkElement(NilParam, Element, _Wait, Axis)
	-- CORE
	local EffectInfo = AllEffectInfo["ShrinkElement"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Functions
	-- INIT
	CreateElementCache(Element, {"Size"})

	-- TWEEN
	local tweeningInfo = {}
	
	if Axis then
		if string.lower(Axis) == "x" then
			tweeningInfo.Size = UDim2.new(0, 0, Element.Size.Y.Scale, Element.Size.Y.Offset)
		elseif string.lower(Axis) == "y" then
			tweeningInfo.Size = UDim2.new(Element.Size.X.Scale, Element.Size.X.Offset, 0, 0)
		end		
	else
		tweeningInfo.Size = UDim2.new()
	end

	CancelTween(Element)
	TweenDict[Element] = TweenService:Create(Element, tweenInfo, tweeningInfo)
	TweenDict[Element]:Play()
	CompleteTween(Element)
	
	if _Wait then
		TweenWait(TweenDict[Element])
	end

	return TweenDict[Element]
end

function InterfaceEffectsModule.CreateElementCache(NilParam, Element, Properties)
	-- Functions
	-- INIT
	return CreateElementCache(Element, Properties)
end

function InterfaceEffectsModule.InitialiseMenuButton(NilParam, Button, IgnoreClipsDescendants)
	if not Button then
		return nil
	end
	
	-- Elements
	-- FRAMES
	local BlockBehind = Button:FindFirstChild("BlockBehind") --UtilitiesModule:WaitForChildTimed(Button, "BlockBehind")
	local BlockInfront = Button:FindFirstChild("BlockInfront") --UtilitiesModule:WaitForChildTimed(Button, "BlockInfront")
	
	-- IMAGES
	local Icons = {}
	
	for i, ImageLabel in pairs(Button:GetChildren()) do
		if ImageLabel:IsA("ImageLabel") and ImageLabel.Name == "Icon" then
			table.insert(Icons, ImageLabel)
		end
	end
	
	--local IconImage = Button:FindFirstChild("Icon")
	
	-- CORE
	local EffectInfo = AllEffectInfo["MenuButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	local Hovering = false
	
	local Blocks = {}
	
	if BlockBehind then
		table.insert(Blocks, BlockBehind)
	end
	
	if BlockInfront then
		table.insert(Blocks, BlockInfront)
	end
	
	--if IconImage then
	--	CreateElementCache(IconImage, {"Size"})
	--end
	
	for i, IconImage in pairs(Icons) do
		CreateElementCache(IconImage, {"Size"})
	end
	
	-- Functions
	-- INIT
	CreateElementCache(Button, {"BackgroundTransparency"})
	
	if not IgnoreClipsDescendants then
		Button.ClipsDescendants = true
	end
		
	local Connection1 = Button.MouseEnter:Connect(function()		
		Hovering = true
		
		local ButtonTweeningInfo = {}
		ButtonTweeningInfo.BackgroundTransparency = ElementCache[Button]["BackgroundTransparency"] * EffectInfo["ButtonBackgroundTransparency"]
		
		local BlockTweeningInfo = {}
		BlockTweeningInfo.BackgroundTransparency = EffectInfo["BlockTransparency"]
		
		SoundsModule:PlaySoundEffectByName("Button", "Hover")
		
		
		for i, IconImage in pairs(Icons) do
			local IconImageTweeningInfo = {}
			IconImageTweeningInfo.Size = UDim2.fromScale(ElementCache[IconImage]["Size"].X.Scale * EffectInfo["IconSizeMultiplier"], ElementCache[IconImage]["Size"].Y.Scale * EffectInfo["IconSizeMultiplier"])

			CancelTween(IconImage)
			TweenDict[IconImage] = TweenService:Create(IconImage, tweenInfo, IconImageTweeningInfo)
			TweenDict[IconImage]:Play()
			CompleteTween(IconImage)
		end
		
		--if IconImage then
		--	local IconImageTweeningInfo = {}
		--	IconImageTweeningInfo.Size = UDim2.fromScale(ElementCache[IconImage]["Size"].X.Scale * EffectInfo["IconSizeMultiplier"], ElementCache[IconImage]["Size"].Y.Scale * EffectInfo["IconSizeMultiplier"])
			
		--	CancelTween(IconImage)
		--	TweenDict[IconImage] = TweenService:Create(IconImage, tweenInfo, IconImageTweeningInfo)
		--	TweenDict[IconImage]:Play()
		--	CompleteTween(IconImage)
		--end
		
		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, ButtonTweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
		
		for i, Block in pairs(Blocks) do
			CancelTween(Block)
			TweenDict[Block] = TweenService:Create(Block, tweenInfo, BlockTweeningInfo)
			TweenDict[Block]:Play()
			CompleteTween(Block)
		end
	end)
	
	local Connection2 = Button.MouseLeave:Connect(function()
		Hovering = false
		
		local ButtonTweeningInfo = {}
		ButtonTweeningInfo.BackgroundTransparency = ElementCache[Button]["BackgroundTransparency"] --1

		local BlockTweeningInfo = {}
		BlockTweeningInfo.BackgroundTransparency = 1
		
		for i, IconImage in pairs(Icons) do
			local IconImageTweeningInfo = {}
			IconImageTweeningInfo.Size = ElementCache[IconImage]["Size"]
			
			CancelTween(IconImage)
			TweenDict[IconImage] = TweenService:Create(IconImage, tweenInfo, IconImageTweeningInfo)
			TweenDict[IconImage]:Play()
			CompleteTween(IconImage)
		end

		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, ButtonTweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)

		for i, Block in pairs(Blocks) do
			CancelTween(Block)
			TweenDict[Block] = TweenService:Create(Block, tweenInfo, BlockTweeningInfo)
			TweenDict[Block]:Play()
			CompleteTween(Block)
		end
	end)
	
	local Connection3 = Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Click")
	end)
	
	
	if Button:GetAttributes()["Special"] then
		coroutine.wrap(function()			
			local ReferenceImage = Instance.new("ImageLabel")
			ReferenceImage.Size = UDim2.new(0.2, 0, 1, 0)
			ReferenceImage.BackgroundTransparency = 1
			ReferenceImage.BorderSizePixel = 0
			ReferenceImage.Image = "rbxassetid://11995296336"
			ReferenceImage.Name = "SwipeEffect"
			ReferenceImage.ImageTransparency = 1
			ReferenceImage.Position = UDim2.new(0, 0, 0, 0)
			
			
			local tweens = 
			{
				{Position = UDim2.new(0.3, 0, 0, 0), ImageTransparency = 0.5},
				{Position = UDim2.new(0.6, 0, 0, 0), ImageTransparency = 0.5},
				{Position = UDim2.new(1, 0, 0, 0), ImageTransparency = 1}
			}
			
			local tweenInfo = TweenInfo.new(EffectInfo["SwipeDuration"] / UtilitiesModule:GetSizeOfDict(tweens), EffectInfo["SwipeStyle"], EffectInfo["SwipeDirection"])
			
			while Button and task.wait(math.random(100, 300) / 100) and Connection1 and Connection1.Connected do
				local Clone = ReferenceImage:Clone()
				Clone.Parent = Button
				
				if Hovering then
					SoundsModule:PlaySoundEffectById("rbxassetid://1837834188", nil, nil, nil, {["Volume"] = 0.1})
				end
				
				for i, tweeningInfo in pairs(tweens) do
					UtilitiesModule:CancelTween(Clone, TweenDict)
					TweenDict[Clone] = TweenService:Create(Clone, tweenInfo, tweeningInfo)
					TweenDict[Clone]:Play()
					UtilitiesModule:CompleteTween(Clone, TweenDict)
					TweenDict[Clone].Completed:Wait()
				end
				Clone:Destroy()
			end
			
			if ReferenceImage then
				ReferenceImage:Destroy()
			end
		end)()
	end
	
	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseShopButton(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- CORE
	local EffectInfo = AllEffectInfo["ShopButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Elements
	-- IMAGES
	local IconImage = UtilitiesModule:WaitForChildTimed(Button, "Icon")
	
	-- BUTTONS
	local TextButton = UtilitiesModule:WaitForChildTimed(IconImage, "Button")
	
	-- Functions
	-- INIT
	CreateElementCache(IconImage, {"Size", "ImageColor3"})
	
	-- DIRECT
	local Connection1 = TextButton.MouseEnter:Connect(function()
		local tweeningInfo = {}
		tweeningInfo.Size = UDim2.new(0.95, 0, 0.95, 0)
		tweeningInfo.ImageColor3 = Color3.fromRGB(125, 125, 125)
		
		UtilitiesModule:CancelTween(IconImage, TweenDict)
		TweenDict[IconImage] = TweenService:Create(IconImage, tweenInfo, tweeningInfo)
		TweenDict[IconImage]:Play()
		UtilitiesModule:CompleteTween(IconImage, TweenDict)
		
		SoundsModule:PlaySoundEffectByName("ShopButton", "Hover")
	end)
	
	local Connection2 = TextButton.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo.Size = ElementCache[IconImage]["Size"]
		tweeningInfo.ImageColor3 = ElementCache[IconImage]["ImageColor3"]

		UtilitiesModule:CancelTween(IconImage, TweenDict)
		TweenDict[IconImage] = TweenService:Create(IconImage, tweenInfo, tweeningInfo)
		TweenDict[IconImage]:Play()
		UtilitiesModule:CompleteTween(IconImage, TweenDict)
	end)
	
	local Connection3 = TextButton.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Click")
	end)
	
	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseCrewButton(NilParam, Button)
	if not Button or not Button:IsA("Frame") then
		return nil
	end
	
	-- CORE
	local EffectInfo = AllEffectInfo["CrewButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	-- Elements
	-- FRAMES
	local ContainerFrame = UtilitiesModule:WaitForChildTimed(Button, "Container")
	
	-- Functions
	-- INIT
	CreateElementCache(ContainerFrame, {"Size"})
	
	-- DIRECT
	local Connection1 = Button.MouseEnter:Connect(function()
		local tweeningInfo = {}
		tweeningInfo.Size = UDim2.new(1, 0, 1, 0)
		
		UtilitiesModule:CancelTween(ContainerFrame, TweenDict)
		TweenDict[ContainerFrame] = TweenService:Create(ContainerFrame, tweenInfo, tweeningInfo)
		TweenDict[ContainerFrame]:Play()
		
		SoundsModule:PlaySoundEffectByName("Button", "Hover")
		
		UtilitiesModule:CompleteTween(ContainerFrame, TweenDict)
	end)
	
	local Connection2 = Button.MouseLeave:Connect(function()
		if not ContainerFrame then
			return nil
		end
		
		local tweeningInfo = {}
		tweeningInfo.Size = ElementCache[ContainerFrame]["Size"]

		UtilitiesModule:CancelTween(ContainerFrame, TweenDict)
		TweenDict[ContainerFrame] = TweenService:Create(ContainerFrame, tweenInfo, tweeningInfo)
		TweenDict[ContainerFrame]:Play()
		UtilitiesModule:CompleteTween(ContainerFrame, TweenDict)
	end)
	
	return {Connection1, Connection2}
end

function InterfaceEffectsModule.InitialiseInventoryButton(NilParam, Button)
	if not Button then
		return nil
	end
	
	if not Button then
		return nil
	end

	-- CORE
	local EffectInfo = AllEffectInfo["InventoryButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])

	-- Elements
	-- BUTTONS
	local ImageButton = UtilitiesModule:WaitForChildTimed(Button, "Button")
	
	-- FRAMES
	local BehindFrame = UtilitiesModule:WaitForChildTimed(Button, "Behind")

	-- Functions
	-- INIT
	CreateElementCache(ImageButton, {"Size"})

	-- DIRECT
	local Connection1 = ImageButton.MouseEnter:Connect(function()
		local tweeningInfo = {}
		tweeningInfo.Size = UDim2.new(.9, 0, .9, 0)
		
		local tweeningInfo1 = {}
		tweeningInfo1.Size = UDim2.new(1, 0, 1, 0)
		
		UtilitiesModule:CancelTween(BehindFrame, TweenDict)
		TweenDict[BehindFrame] = TweenService:Create(BehindFrame, tweenInfo, tweeningInfo1)
		TweenDict[BehindFrame]:Play()
		UtilitiesModule:CompleteTween(BehindFrame, TweenDict)
		
		UtilitiesModule:CancelTween(ImageButton, TweenDict)
		TweenDict[ImageButton] = TweenService:Create(ImageButton, tweenInfo, tweeningInfo)
		TweenDict[ImageButton]:Play()
		
		SoundsModule:PlaySoundEffectByName("Button", "Hover")
		
		UtilitiesModule:CompleteTween(ImageButton, TweenDict)
	end)

	local Connection2 = ImageButton.MouseLeave:Connect(function()
		local tweeningInfo = {}
		tweeningInfo.Size = ElementCache[ImageButton]["Size"]
		
		local tweeningInfo1 = {}
		tweeningInfo1.Size = ElementCache[ImageButton]["Size"]

		UtilitiesModule:CancelTween(BehindFrame, TweenDict)
		TweenDict[BehindFrame] = TweenService:Create(BehindFrame, tweenInfo, tweeningInfo1)
		TweenDict[BehindFrame]:Play()
		UtilitiesModule:CompleteTween(BehindFrame, TweenDict)
		
		UtilitiesModule:CancelTween(ImageButton, TweenDict)
		TweenDict[ImageButton] = TweenService:Create(ImageButton, tweenInfo, tweeningInfo)
		TweenDict[ImageButton]:Play()
		UtilitiesModule:CompleteTween(ImageButton, TweenDict)
	end)
	
	local Connection3 = ImageButton.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Click")
	end)

	return {Connection1, Connection2, Connection3}
end

function InterfaceEffectsModule.InitialiseMainButton(NilParam, Button)
	if not Button then
		return nil
	end
	
	-- Core
	local EffectInfo = AllEffectInfo["MainButton"]
	local tweenInfo = TweenInfo.new(EffectInfo["Duration"], EffectInfo["Style"], EffectInfo["Direction"])
	
	local ClassToColourProperty = 
	{
		["ImageButton"] = "ImageColor3",
		["TextButton"] = "BackgroundColor3"	
	}	
	
	local ColourProperty = ClassToColourProperty[Button.ClassName]
	
	-- Functions
	-- INIT
	CreateElementCache(Button, {"Size", ColourProperty})
	
	-- DIRECT
	local Connection1 = Button.MouseEnter:Connect(function()
		-- CORE
		local NewSize = ElementCache[Button]["Size"] +  MultiplyUDim2(ElementCache[Button]["Size"], EffectInfo["HoverSizeMultiplier"])
		local NewColour = Color3FromRGB(AddToColor3(ElementCache[Button][ColourProperty], EffectInfo["RGBAmplifier"]))
		
		-- TWEEN
		local tweeningInfo = {}
		tweeningInfo.Size = NewSize
		tweeningInfo[ColourProperty] = NewColour
		
		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
		
		SoundsModule:PlaySoundEffectByName("Button", "Hover")
	end)
	
	local Connection2 = Button.MouseLeave:Connect(function()
		-- TWEEN
		local tweeningInfo = {}
		tweeningInfo.Size = ElementCache[Button]["Size"]
		tweeningInfo[ColourProperty] = ElementCache[Button][ColourProperty]
		
		CancelTween(Button)
		TweenDict[Button] = TweenService:Create(Button, tweenInfo, tweeningInfo)
		TweenDict[Button]:Play()
		CompleteTween(Button)
	end)
	
	local Connection3 = Button.MouseButton1Down:Connect(function()
		SoundsModule:PlaySoundEffectByName("Button", "Click")
	end)
	
	return {Connection1, Connection2, Connection3}
end

-- CONVERSION
local ButtonTypes = 
{
	["Main"] = {Function = InterfaceEffectsModule.InitialiseMainButton},
	["Menu"] = {Function = InterfaceEffectsModule.InitialiseMenuButton},
	["Shop"] = {Function = InterfaceEffectsModule.InitialiseShopButton, ClassName = "Frame"},
	["Crew"] = {Function = InterfaceEffectsModule.InitialiseCrewButton, ClassName = "Frame"},
	["Inventory"] = {Function = InterfaceEffectsModule.InitialiseInventoryButton, ClassName = "Frame"}
}

-- GROUP LOADERS
function InterfaceEffectsModule.InitialiseButtons(NilParam, ButtonsFolder, ButtonType, ...)
	-- CORE
	local ButtonConnections = {}
	
	-- Functions
	-- INIT
	local InitialiseFunction = ButtonTypes[ButtonType]["Function"]
	local ClassNameExceptance = ButtonTypes[ButtonType]["ClassName"]
	
	for i, Button in pairs(ButtonsFolder:GetChildren()) do
		-- INIT
		if IsUiAdditionalElement(Button) then
			if not ClassNameExceptance then
				continue
			else
				if ClassNameExceptance ~= Button.ClassName then
					continue
				end
			end
		end
		
		-- DIRECT
		local _ButtonConnections = InitialiseFunction(nil, Button, ...)
			
		-- Connections
		for x, Connection in pairs(_ButtonConnections) do
			table.insert(ButtonConnections, Connection)
		end		
	end
	
	return ButtonConnections
end

--
function InterfaceEffectsModule.InterfaceEffectProcess(NilParam, FunctionName, ...)
	-- Functions
	-- INIT
	local Success, RequiredModule = pcall(function()
		return RequiredModules[FunctionName] --require(UtilitiesModule:WaitForChildTimed(script, FunctionName))
	end)
	
	if Success then
		if RequiredModule and RequiredModule.Initialise ~= nil then
			return RequiredModule:Initialise(...)
		end
	else
		--DebugModule:PrintRequiredModule, "Error")
	end
end

-- INIT
RunSubModules()

return InterfaceEffectsModule