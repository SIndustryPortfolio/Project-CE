local FixModule = {}

-- Functions
-- MECHANICS
local function Initialise()
	--  CORE
	local MapFolder = workspace:FindFirstChild("Map")
	
	-- Functions
	-- Init
	if not MapFolder then
		MapFolder = Instance.new("Folder", workspace)
		MapFolder.Name = "Map"
		
		local ServerMapFolder = Instance.new("Folder")
		ServerMapFolder.Name = "Server"
		ServerMapFolder.Parent = MapFolder
		
		local ClientMapFolder = Instance.new("Folder")
		ClientMapFolder.Name = "Client"
		ClientMapFolder.Parent = MapFolder
	end
end

-- INIT
Initialise()

return FixModule