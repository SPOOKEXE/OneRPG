
local CollectionService = game:GetService("CollectionService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ShopDataModule = ReplicatedModules.Data.ShopData

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.IsPlayerNearbyShopsOfId( LocalPlayer, shopId )
	return false
end

function Module.PlayerAttemptPurchase( LocalPlayer, shopId, weaponId )

	if not Module.IsPlayerNearbyShopsOfId( LocalPlayer, shopId ) then
		return false, 'You are not nearby a related shop.'
	end

	local ItemData = ShopDataModule.Shops[ shopId ]

end

function Module.SetupShopNPC( ShopModel )

end

function Module.CleanupShopNPC( ShopModel )

end

function Module.Start()

	local CollectionTagShop = ShopDataModule.CollectionTagShops
	for _, Model in ipairs( CollectionService:GetTagged( CollectionTagShop ) ) do
		task.spawn(Module.SetupShopNPC, Model )
	end
	CollectionService:GetInstanceAddedSignal( CollectionTagShop ):Connect( Module.SetupShopNPC )
	CollectionService:GetInstanceRemovedSignal( CollectionTagShop ):Connect( Module.CleanupShopNPC )

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
