
local function CreateDisplayData( Text, TextColor )
	return { Text = Text, TextColor3 = TextColor }
end

-- // Module // --
local Module = {}

Module.Types = {
	Sword = 1,
	Staff = 2,
	Consumable = 3,
}

Module.Animations = {
	Melee1 = 'rbxassetid://-1',
	Staff1 = 'rbxassetid://-1',
	Consume1 = 'rbxassetid://-1',
}

Module.Items = {

	BronzeSword = { -- STARTER ITEM
		Type = Module.Types.Sword,
		-- shop
		BuyPrice = 100,
		SellPrice = 25,
		Display = CreateDisplayData( 'Iron Staff', Color3.new(1, 1, 1) ),
		-- combat
		MinDamage = 1,
		MaxDamage = 3,
		Animation = Module.Animations.Melee1,
	},

	IronSword = {
		Type = Module.Types.Sword,
		-- shop
		BuyPrice = 250,
		SellPrice = 100,
		Display = CreateDisplayData( 'Iron Staff', Color3.new(1, 1, 1) ),
		-- combat
		MinDamage = 5,
		MaxDamage = 10,
		Animation = Module.Animations.Melee1,
	},


	IronStaff = {
		Type = Module.Types.Sword,
		-- shop
		BuyPrice = 1250,
		SellPrice = 300,
		Display = CreateDisplayData( 'Iron Staff', Color3.new(1, 1, 1) ),
		-- combat
		MinDamage = 25,
		MaxDamage = 50,
		Animation = Module.Animations.Staff1,
	},

}

Module.CollectionTagShops = 'ShopModel'

Module.ShopTypes = {
	Buy = 1,
	Sell = 2,
}

Module.Shops = {

	SpawnSwordShop = {
		ShopType = Module.ShopTypes.Buy,
		Display = { Text = 'Sword Shop', TextColor3 = Color3.fromRGB(255,255,255) },
		Items = { 'IronSword' },
	},

	SpawnStaffShop = {
		ShopType = Module.ShopTypes.Buy,
		Display = { Text = 'Staff Shop', TextColor3 = Color3.fromRGB(255,255,255) },
		Items = { 'IronStaff' },
	},

	SpawnPawnShop = {
		ShopType = Module.ShopTypes.Sell,
		Display = { Text = 'Pawn Shop', TextColor3 = Color3.fromRGB(255,255,255) },
		Items = { 'IronSword', 'IronStaff' },
	},

}

return Module
