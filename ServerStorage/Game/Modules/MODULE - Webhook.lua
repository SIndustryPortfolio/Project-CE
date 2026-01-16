local WebhookLogModule = {}

-- CORE
local WebhookURL = "https://ptb.discord.com/api/webhooks/1234534828234248363/Ah5ygHUMkHxcMZk3z2OU2qFBNNaQ7YA_umYMKP7a3CLqobcIFmK2Fc3B48UCDHrUgVAv"
local LogCache = {}

-- Services
local HttpService = game:GetService("HttpService")

-- Functions
-- MECHANICS
local function LogAll()
	if #LogCache <= 0 then
		return nil
	end
	
	-- Functions
	-- INIT
	local PackagedData = 
	{
		["embeds"] = 
		{
			--{
			--	["username"] = "Error Logger",
			--	["title"] = String,
			--	["type"] = "rich",
			--	["color"] = tonumber(0xff0000)
			--}
		}
	}
	
	for i, _Log in pairs(LogCache) do
		local Embed = {["username"] = "Error Logger", ["type"] = "rich", ["color"] = tonumber(0xff0000)}
		
		Embed["title"] = _Log
		
		table.insert(PackagedData["embeds"], Embed)
	end
	
	
	coroutine.wrap(function()
		local Success, Error = pcall(function()
			return HttpService:PostAsync(WebhookURL, HttpService:JSONEncode(PackagedData))
		end)
		
		LogCache = {}
	end)()
	
end

local function Log(Player, String)
	-- Functions
	-- INIT
	table.insert(LogCache, String)
end

-- CORE FUNCTIONS
local ClientRequests = 
{
	["Log"] = Log		
}

-- MECHANICS
local function ClientRequest(Player, FunctionName, ...)
	-- Functions
	-- INIT
	return ClientRequests[FunctionName](Player, ...)
end

-- DIRECT
function WebhookLogModule.ClientRequest(NilParam, ...)
	return ClientRequest(...)
end

function WebhookLogModule.ServerRequest(NilParam, ...)
	return ClientRequest(nil, ...)
end

function WebhookLogModule.Log(NilParam, ...)
	return Log(nil, ...)
end

function WebhookLogModule.LogAll()
	return LogAll()
end

return WebhookLogModule