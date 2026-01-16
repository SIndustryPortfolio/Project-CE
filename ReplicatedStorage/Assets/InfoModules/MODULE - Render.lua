local RenderInfoModule = {}

-- CORE
local RenderInfo = 
{
	["LoopDelay"] = 0.5 -- Seconds
		
}

-- Functions
-- DIRECT
function RenderInfoModule.GetRenderInfo(NilParam, SettingName)
	return RenderInfo[SettingName]
end

function RenderInfoModule.GetAllRenderInfo()
	return RenderInfo
end

return RenderInfoModule