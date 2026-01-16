local SoundsInfoModule = {}

-- CORE
local EffectClassNames = {"FlangeSoundEffect", "EqualizerSoundEffect", "ReverbSoundEffect", "EchoSoundEffect", "CompressorSoundEffect", "TremoloSoundEffect"}

local Music = 
{
	["Menu"] = {Id = "rbxassetid://11997421454"},  --{Id = "rbxassetid://1844859347"}, --{Id = "rbxassetid://9582602872"}, --{Id = "rbxassetid://170917770"},
	--	
	["Gravemind"] = {Id = "rbxassetid://8592341295"},
	["Abandoned"] = {Id = "rbxassetid://8592341295"},
	["Two Window"] = {Id = "rbxassetid://8592341295"},
	["Nacht Der Untoten"] = {Id = "rbxassetid://8592341295"},
	["Zen"] = {Id = "rbxassetid://8592341295"},
	["Construction"] = {Id = "rbxassetid://8592341295"},
	["Unstable"] = {Id = "rbxassetid://8592341295"},
	["Shaky Heights"] = {Id = "rbxassetid://8592341295"},
	["Run From Barney"] = {Id = "rbxassetid://8592341295"},	
	["Train"] = {Id = "rbxassetid://8592341295"},
	["Battle Creek"] = {Id = "rbxassetid://9112841159"},
	["Wizard"] = {Id = "rbxassetid://5554912458"},
	["Robox"] = {Id = "rbxassetid://364927601"},
	["Gephyrophobia"] = {Id = "rbxassetid://9111868149"}
	--["Labroratory"] = {Ambience = "rbxassetid://6648108981", --[[Id = "rbxassetid://142370399"]] Id = "rbxassetid://6889254319"},
	--["Acolade"] = {Ambience = "rbxassetid://6648108981", --[[Id = "rbxassetid://142370399"]] Id = "rbxassetid://6673164898"},
	--["Gravemind"] = {Ambience = "rbxassetid://6648108981", --[[Id = "rbxassetid://142370399"]] Id = "rbxassetid://95096715961"},
	--["Battle Creek"] = {Ambience = "rbxassetid://6648108981", --[[Id = "rbxassetid://7399443751"]] Id = "rbxassetid://1843030751"},
	--["Gephyrophobia"] = {Ambience = "rbxassetid://6648108981", Id = "rbxassetid://9046421438"},
	--["Robox"] = {Ambience = "rbxassetid://364927601", Id = "rbxassetid://1837758041"}, --rbxassetid://1837758041
	--["Wizard"] = {Ambience = "rbxassetid://6648108981",Id = "rbxassetid://1836163532"},
	--["Titan Alpine"] = {Ambience = "rbxassetid://6648108981", Id = "rbxassetid://6049310402"},
	--["Titan Canyon"] = {Ambience = "rbxassetid://6648108981", Id = "rbxassetid://1995643189"},
	--["Titan Frost"] = {Ambience = "rbxassetid://6648108981", Id = "rbxassetid://1987628941"},
	--["Titan Lunar"] = {Ambience = "rbxassetid://6648108981", Id = "rbxassetid://542308971"}
}

local SoundEffects = 
{
	["Misc"] = 
	{
		["IntroLogo"] = {Id = "rbxassetid://464067838"},
		["Swoosh"] = {Id = "rbxassetid://246930031"}
	},
	["Crew"] = 
	{
		["Joined"] = {Id = "rbxassetid://225824796"}	
	},
	["RoundReload"] = 
	{
		["Shell"] = {Id = "rbxassetid://5677987779"}
	},
	["Keyframes"] = 
	{
		["Pump"] = {Id = "rbxassetid://200289834"}	
	},
	["BulletImpacts"] = 
	{
		["Glass"] = {Id = "rbxassetid://9113631914"},
		["Grass"] = {Id = "rbxassetid://4757265395"},
		["Wood"] = {Id = "rbxassetid://1055287191"},
		["WoodPlanks"] = {Id = "rbxassetid://1055287191"},
		["Concrete"] = {Id = "rbxassetid://9120644082"},
		["Cobblestone"] = {Id = "rbxassetid://9120644082"},
		["Slate"] = {Id = "rbxassetid://9120644082"},
		["Default"] = {Id = "rbxassetid://9116685948"},
		["Default1"] = {Id = "rbxassetid://1055287191"},
		["Default2"] = {Id = "rbxassetid://8011833963"},
		["Default3"] = {Id = "rbxassetid://9113632523"}
			
	},
	["Guns"] = 
	{
		["BulletFly"] = {--[[Id = "rbxassetid://7428797338" Id = "rbxassetid://5361946320"]] Id = "rbxassetid://9120988183"}, 
		["ScopeIn"] = {Id = "rbxassetid://2862871544"},
		["ScopeOut"] = {Id = "rbxassetid://2862871544"},
		["TurretSpinning"] = {Id = "rbxassetid://6288685832"}
	},
	["Objects"] = 
	{
		["Explosion"] = {Id = "rbxassetid://5318802024"} --{Id = "rbxassetid://4810729508"}	
	},
	["Button"] = 
	{
		["Hover"] = {Id = "rbxassetid://140909770"},
		["Click"] = {Id = "rbxassetid://6042053626"}	
	},
	["ShopButton"] = 
	{
		["Hover"] = {Id = "rbxassetid://4612384434"}	
	},
	["Ui"] = 
	{
		["Transition"] = {Id = "rbxassetid://1544048962"},
		["Loading"] = {Id = "rbxassetid://5628246271"},
		["Badge"] = {Id = "rbxassetid://9125675064"}
	},
	["Narrator"] = 
	{
		["30MinutesRemaining"] = {Id = "rbxassetid://11887417001"},
		["15MinutesRemaining"] = {Id = "rbxassetid://11887416934"},
		["5MinutesRemaining"] = {Id = "rbxassetid://11887417157"},
		["1MinuteRemaining"] = {Id = "rbxassetid://945454423"},
		["30SecondsRemaining"] = {Id = "rbxassetid://11887416843"},	
		["10SecondsRemaining"] = {Id = "rbxassetid://11887417234"}, -- FromTime = 34, EndTime = 35.5},
		["GameOver"] = {Id = "rbxassetid://11887416166"},
		["RoundOver"] = {Id = "rbxassetid://11887416007"},
		["Betrayal"] = {Id = "rbxassetid://11887416753"}, --{Id = "rbxassetid://5404338660", FromTime = 9, EndTime = 10.3},
		["Betrayed"] = {Id = "rbxassetid://11887416617"}, --FromTime = 10.5, EndTime = 12},
		["GainedTheLead"] = {Id = "rbxassetid://11887416467"}, --FromTime = 21.5, EndTime = 22.3},
		["LostTheLead"] = {Id = "rbxassetid://11887416096"}, --FromTime = 26.5, EndTime = 28.1}
		["TiedTheLeader"] = {Id = "rbxassetid://11887415707"},
		["SuddenDeath"] = {Id = "rbxassetid://11887416352"},
		["TeamMateGained"] = {Id = "rbxassetid://11887416266"},
		["TeamChange"] = {Id = "rbxassetid://11887415903"},
		["Suicide"] = {Id = "rbxassetid://11887415808"}
	},
	["Hud"] = 
	{
		["DamageFlash"] = {Id = "rbxassetid://6915638113"},
		["Damage"] = {Id = "rbxassetid://3378132335"},
		["ShieldRegen"] = {Id = "rbxassetid://187933025"},
		["Beep"] = {Id = "rbxassetid://300473653"},
		["LowHealth"] = {Id = "rbxassetid://5603204209"},
		["HealRefresh"] = {Id = "rbxassetid://2174940777"},
		["FeedAdd"] = {Id = "rbxassetid://257422322"},
		["HitMarker1"] = {Id = "rbxassetid://3748776946"},
		["HitMarker2"] = {Id = "rbxassetid://3748777642"},
		["HitMarker3"] = {Id = "rbxassetid://3748780065"}
	},
	["CharacterActions"] = 
	{
		["SpawnShield"] = {Id = "rbxassetid://8754565103"},
		["Drink"] = {Id = "rbxassetid://1481574895"},
		["BloodSplat"] = {Id = "rbxassetid://1043479862"},
		["MeleeDamage"] = {Id = "rbxassetid://7441099555"},
		["MeleeSwing"] = {Id = "rbxassetid://5972744228"},
		["MeleeThud"] = {Id = "rbxassetid://3626698892"},
		["Death"] = {Id = "rbxassetid://180479971"},
		["Death2"] = {Id = "rbxassetid://132594821"},
		["Death3"] = {Id = "rbxassetid://256077446"},		
		["EliteDeath"] = {Id = "rbxassetid://8387207404"},
		["EliteDeath2"] = {Id = "rbxassetid://8387204900"},
		["PickupGrenade"] = {Id = "rbxassetid://291256829"},
		["PickupWeapon"] = {Id = "rbxassetid://293565330"},
		["SwitchGrenade"] = {Id = "rbxassetid://9120099891"},
		["DropWeapon"] = {Id = "rbxassetid://131436144"},
		["DropGrenade"] = {Id = "rbxassetid://131436144"},
		["ShieldDamage"] = {Id = "rbxassetid://2508764331"},
		["ShieldBroken"] = {Id = "rbxassetid://8565898966"},
		["HealthDamage"] = {Id = "rbxassetid://5592868905"},
		["HealthDamage2"] = {Id = "rbxassetid://175272131"},
		["HealthDamage3"] = {Id = "rbxassetid://597154815"}
	},
	["Game"] = 
	{
		["RoundStarting"] = {Id = "rbxassetid://5315095173"}	
	},
	["GameModes"] = 
	{
		["Team Slayer"] = {Id = "rbxassetid://8926086666"}, --{Id = "rbxassetid://187317456"}
		["Precision Slayer"] = {Id = "rbxassetid://8926086666"},
		["Slayer"] = {Id = "rbxassetid://8926086666"},
		["Shotty Snipers"] = {Id = "rbxassetid://8926086666"},
		["Swat"] = {Id = "rbxassetid://11887409303"},
		["Swat (Magnums)"] = {Id = "rbxassetid://11887409303"},
		["Infection"] = {Id = "rbxassetid://11887148612"},
		["Barney"] = {Id = "rbxassetid://11887148612"},
		["Spleef"] = {Id = "rbxassetid://11887148612"},
		["Horde"] = {Id = "rbxassetid://11887479966"}
	},
	["Shop"] = 
	{
		["PurchaseComplete"] = {Id = "rbxassetid://2609873966"}	
	}
}


local MusicEffectLists = 
{
	["InterfaceOverlay"] = {Equalizer = {HighGain = -80, MidGain = -80, LowGain = 0}}
}

--
local SoundTypes = 
{
	["Effects"] = SoundEffects,
	["Music"] = Music
}

-- Functions

function SoundsInfoModule.GetSounds(NilParam, SoundType)
	return SoundTypes[SoundType]
end

function SoundsInfoModule.GetMusicEffects()
	return MusicEffectLists
end

function SoundsInfoModule.GetSoundEffectClasses()
	return EffectClassNames
end

return SoundsInfoModule