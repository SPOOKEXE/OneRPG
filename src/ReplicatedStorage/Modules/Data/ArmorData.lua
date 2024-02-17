
local function CreateDisplayData( Text, Color )
	return { Text = Text, TextColor3 = Color, }
end

-- // Module // --
local Module = {}

Module.CollectionTagArmorMorph = 'ArmorMorph'
Module.Armors = {
	BronzeArmor = {
		RequiredLevel = 3,
		BonusMaxHealth = 10,
		BonusWalkSpeed = 1,

		Display = CreateDisplayData( 'Bronze Armor', Color3.fromRGB(128, 73, 22) ),
	},

	IronArmor = {
		RequiredLevel = 5,
		BonusMaxHealth = 25,
		BonusWalkSpeed = 2,

		Display = CreateDisplayData( 'Iron Armor', Color3.fromRGB(86, 86, 86) ),
	},

	SilverArmor = {
		RequiredLevel = 7,
		BonusMaxHealth = 50,
		BonusWalkSpeed = 4,

		Display = CreateDisplayData( 'Silver Armor', Color3.fromRGB(255, 255, 255) ),
	},

	GoldArmor = {
		RequiredLevel = 10,
		BonusMaxHealth = 100,
		BonusWalkSpeed = 5,

		Display = CreateDisplayData( 'Gold Armor', Color3.fromRGB(217, 224, 7) ),
	},

	PlatinumArmor = {
		RequiredLevel = 15,
		BonusMaxHealth = 200,
		BonusWalkSpeed = 6,

		Display = CreateDisplayData( 'Platinum Armor', Color3.fromRGB(255, 255, 255) ),
	},
}

return Module
