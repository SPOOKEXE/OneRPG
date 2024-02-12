
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ShopDataModule = ReplicatedModules.Data.ShopData

local SystemsContainer = {}

local function SetProperties( Parent, Properties )
	for propName, propValue in pairs( Properties ) do
		Parent[propName] = propValue
	end
	return Parent
end

-- // Module // --
local Module = {}

function Module.AttemptShopPurchase( shopId, ItemId )

end

function Module.SetupShopNPC( ShopModel )

	local ShopConfig = ShopDataModule.Shops[ ShopModel.Name ]
	if not ShopConfig then
		warn('The target shop is invalid - no such shop from id: ' .. tostring(ShopModel:GetFullName()))
		return
	end

	SetProperties( ShopModel.BillboardGui.Title, ShopConfig.Display )

	local Debounce = false
	ShopModel.Counter.Touched:Connect(function( hit )
		if Debounce then
			return
		end

		local Humanoid = hit.Parent:FindFirstChildWhichIsA('Humanoid')
		if not Humanoid then
			return
		end

		if hit.Parent ~= LocalPlayer.Character then
			return
		end

		Debounce = true
		task.delay(3, function()
			Debounce = false
		end)

		print('Open Shop Widget: ', ShopModel.Name, ShopConfig.Display, ShopConfig.Items)
		-- Module.AttemptShopPurchase( ShopModel.Name, 'IronSword' )
	end)

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
