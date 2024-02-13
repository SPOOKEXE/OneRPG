
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalMouse = LocalPlayer:GetMouse()
local LocalAssets = LocalPlayer:WaitForChild('PlayerScripts'):WaitForChild('Assets')

local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))
local UserInterfaceUtility = LocalModules.Utility.UserInterface

local Interface = LocalPlayer.PlayerGui:WaitForChild('Interface')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ShopDataModule = ReplicatedModules.Data.ShopData
local MaidClassModule = ReplicatedModules.Modules.Maid

local SystemsContainer = {}

local function SetProperties( Parent, Properties )
	for propName, propValue in pairs( Properties ) do
		Parent[propName] = propValue
	end
	return Parent
end

local function CreateCounterSelectionBox( Counter )
	local SelectionBox = Instance.new('SelectionBox')
	SelectionBox.Adornee = Counter
	SelectionBox.Color3 = Color3.fromRGB(172, 172, 172)
	SelectionBox.LineThickness = 0.005
	SelectionBox.Transparency = 0.5
	SelectionBox.SurfaceTransparency = 1
	SelectionBox.Parent = Counter
end

-- // Module // --
local Module = {}

Module.CurrentShopId = false
Module.CurrentShopConfig = false

function Module.AttemptShopPurchase( shopId : string, itemId : string )
	print( 'Purchase: ', shopId, itemId )
end

function Module.AttemptShopSell( shopId, itemId )
	print( 'Sell: ', shopId, itemId )
end

function Module.ClearShopFrame()
	for _, Frame in ipairs( Interface.ShopFrame.Scroll:GetChildren() ) do
		if Frame:IsA('Frame') then
			Frame:Destroy()
		end
	end
end

function Module.GetShopWidgetFrame( itemId )
	local itemData = ShopDataModule.Items[ itemId ]
	local Frame = Interface.ShopFrame.Scroll:FindFirstChild(itemId)
	if not Frame then
		Frame = LocalAssets.UI.TemplateShopItem:Clone()
		Frame.Name = itemId
		Frame.LayoutOrder = itemData.BuyPrice
		SetProperties( Frame.TitleLabel, itemData.Display )
		Frame.Parent = Interface.ShopFrame.Scroll
	end
	return Frame
end

function Module.CloseShopWidget()
	Module.CurrentShopId = false
	Module.CurrentShopConfig = false
	Module.ClearShopFrame()
	Interface.ShopFrame.Visible = false
end

function Module.OpenShopWidget( shopId )
	if Module.CurrentShopId == shopId then
		return
	end

	local ShopConfig = ShopDataModule.Shops[ shopId ]
	if not ShopConfig then
		warn(string.format('Shop of id %s does not exist.', tostring(shopId)))
		return
	end

	Module.CurrentShopId = shopId
	Module.CurrentShopConfig = ShopConfig
	SetProperties(Interface.ShopFrame.Title, ShopConfig.Display)

	local IsBuyMode = (ShopConfig.ShopType == ShopDataModule.ShopTypes.Buy)

	Module.ClearShopFrame()

	for _, itemId in ipairs( ShopConfig.Items ) do
		local itemData = ShopDataModule.Items[ itemId ]
		if not itemData then
			warn(string.format('Item of id %s does not exist.', tostring(itemId)))
			continue
		end

		local Frame = Module.GetShopWidgetFrame( itemId ) :: Frame
		if not Frame then
			continue
		end

		if IsBuyMode and (not itemData.BuyPrice) then
			warn(string.format('Item of id %s does not have a buy price and shop %s is trying to make it a shop item.', itemId, shopId))
			continue
		elseif (not IsBuyMode) and (not itemData.SellPrice) then
			warn(string.format('Item of id %s does not have a sell price and shop %s is trying to make it a shop item.', itemId, shopId))
			continue
		end

		if IsBuyMode then
			Frame.ValueLabel.Text = 'Buy: '..tostring(itemData.BuyPrice)
		else
			Frame.ValueLabel.Text = 'Sell: '..tostring(itemData.SellPrice)
		end

		UserInterfaceUtility.CreateActionButton({Parent = Frame}).Activated:Connect(function()
			if IsBuyMode then
				Module.AttemptShopPurchase( shopId, itemId )
			else
				Module.AttemptShopSell( shopId, itemId )
			end
		end)
	end

	Interface.ShopFrame.Visible = true
end

function Module.SetupShopNPC( ShopModel )
	local ShopConfig = ShopDataModule.Shops[ ShopModel.Name ]
	if not ShopConfig then
		warn('The target shop is invalid - no such shop from id: ' .. tostring(ShopModel:GetFullName()))
		return
	end

	SetProperties( ShopModel.BillboardGui.Title, ShopConfig.Display )
	CreateCounterSelectionBox( ShopModel.Counter )

	local Debounce = false
	ShopModel.Counter.Touched:Connect(function( hit )
		if Debounce then
			return
		end

		local Humanoid = hit.Parent:FindFirstChildWhichIsA('Humanoid')
		if not Humanoid then
			return
		end

		if not hit:IsDescendantOf(LocalPlayer.Character) then
			return
		end

		Debounce = true
		task.delay(3, function()
			Debounce = false
		end)

		Module.OpenShopWidget( ShopModel.Name )
	end)

end

-- function Module.CleanupShopNPC( ShopModel )

-- end

function Module.Start()

	local CollectionTagShop = ShopDataModule.CollectionTagShops
	for _, Model in ipairs( CollectionService:GetTagged( CollectionTagShop ) ) do
		task.spawn(Module.SetupShopNPC, Model )
	end
	CollectionService:GetInstanceAddedSignal( CollectionTagShop ):Connect( Module.SetupShopNPC )
	-- CollectionService:GetInstanceRemovedSignal( CollectionTagShop ):Connect( Module.CleanupShopNPC )

	Interface.ShopFrame.CloseButton.Activated:Connect(function()
		Module.CloseShopWidget()
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
