local MOTDInfoModule = {}

-- CORE
local MOTDInfo = 
{
	["Tips"] = 
	{
		[1] = {SenderName = "MOTD", Text = "This game is in pre alpha expect bugs! When encountering a bug report it to the devs!"},
		[2] = {SenderName = "MOTD", Text = "This is a HALO fangame. We aren't affiliated with neither Microsoft, 343 or Bungie!"},
		[3] = {SenderName = "MOTD", Text = "Keybinds can be changed in the Settings panel"},
		[4] = {SenderName = "MOTD", Text = "Lagging? Head to settings and change the 'RenderQuality' and make sure the server region is close!"},
		[5] = {SenderName = "MOTD", Text = "Project CE is best played in Fullscreen mode! (Press F11)"},
		[6] = {SenderName = "MOTD", Text = "Remember to like, follow and favourite Project CE!"},
		[7] = {SenderName = "MOTD", Text = "All shop items are cosmetic based. This game IS NOT pay to win!"}
	}	
}

-- Functions
-- DIRECT
function MOTDInfoModule.GetMOTDInfo(NilParam, SettingName)
	return MOTDInfo[SettingName]
end

return MOTDInfoModule