local NotificationsModule = {}

-- Dirs
local ClientServerRemotesFolder = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")["ClientServer"]["Remotes"]

-- Elements
-- REMOTES
local GameProcessRemote = ClientServerRemotesFolder["GameProcess"]

-- CORE

-- Functions
-- MECHANICS
local function SendAllNotification(Type, Text, Icon)
	-- Functions
	-- INIT
	return GameProcessRemote:FireAllClients("Game", "Notification", Type, Text, Icon)
end

-- DIRECT
function NotificationsModule.SendAllNotification(NilParam, Type, Text, Icon)
	return SendAllNotification(Type, Text, Icon)
end

return NotificationsModule