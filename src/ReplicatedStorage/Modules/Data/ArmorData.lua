
local function CreateDisplayData( Text, Color )
	return { Text = Text, TextColor3 = Color, }
end

-- // Module // --
local Module = {}

Module.CollectionTagArmorMorph = 'ArmorMorph'
Module.Armors = {
	BronzeArmor = {
		RequiredLevel = 3,
		BonusMaxHealth = 20,
		BonusWalkSpeed = 2,

		Display = CreateDisplayData( 'Bronze Armor', Color3.fromRGB(128, 73, 22) ),
	},

	IronArmor = {
		RequiredLevel = 5,
		BonusMaxHealth = 40,
		BonusWalkSpeed = 3,

		Display = CreateDisplayData( 'Iron Armor', Color3.fromRGB(86, 86, 86) ),
	},
}

return Module
