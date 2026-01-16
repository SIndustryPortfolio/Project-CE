local AdminCommunicationModule = {}

-- Dirs
local ModulesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Assets")["Modules"]

-- Modules
local DebugModule = require(ModulesFolder["Debug"])
local InterfacesModule = require(ModulesFolder["Interfaces"])

-- Functions
-- MECHANICS
local function Announcement(Admin, Announcement)
	-- Functions
	-- INIT
	-- CORE
	local NotificationsUiModule = InterfacesModule:GetUiModuleFromType("Custom", "Notifications")

	-- Functions
	-- INIT
	if NotificationsUiModule then
		return NotificationsUiModule:Add("Important", Admin.Name.. " | ".. tostring(Announcement), nil)
	end
end

local function Debug()
	-- Functions
	-- INIT
	ModulesFolder["Debug"]:SetAttribute("Enabled", not ModulesFolder["Debug"]:GetAttribute("Enabled"))
end

-- CORE FUNCTIONS
local ServerRequests = 
{
	["Announcement"] = Announcement,
	["Debug"] = Debug
}

-- DIRECT
function AdminCommunicationModule.Initialise(NilParam, FunctionName, ...)
	return ServerRequests[FunctionName](...)
end

return AdminCommunicationModule