
local function CreateDisplayData( Text, Color )
	return { Text = Text, TextColor3 = Color }
end

-- // Module // --
local Module = {}

Module.LevelRestrictors = {

	OrcDoor = {
		Level = 3,
		Display = CreateDisplayData( 'Orc Swamp', Color3.fromRGB(172, 244, 105) )
	},

	KingdomPortal = {
		Level = 100,
		Display = CreateDisplayData( 'Kingdom', Color3.fromRGB(115, 115, 115) )
	}

}

return Module
