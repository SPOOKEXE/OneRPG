
local Debris = game:GetService('Debris')
local Players = game:GetService("Players")

local DataStoreService = game:GetService("DataStoreService")
local PlayerDataStore = DataStoreService:GetDataStore('PlayerData1')

local SystemsContainer = {}

local function CreateStatValue( statName, statValue, parent )
	local valueObject = Instance.new('IntValue')
	valueObject.Name = statName
	valueObject.Value = statValue
	valueObject.Parent = parent
	return valueObject
end

local function GetRequiredExperience( levelValue )
	return 100 + (levelValue.Value * 50) * math.pow( 1.1, math.min(levelValue, 1000) )
end

local function DisplayLevelUpMessage( LocalPlayer, levelValue, customDuration : number? )
	local levelUpHint = Instance.new('Hint')
	levelUpHint.Name = 'LevelUpMessage'
	levelUpHint.Text = string.format('%s has leveled up to %s', LocalPlayer.Name, tostring(levelValue.Value))
	levelUpHint.Parent = workspace
	Debris:AddItem(levelUpHint, customDuration or 3)
end

local function OnExperienceChanged( LocalPlayer, experienceValue, levelValue, attributesValue )

	local doneLeveledUpMessage = false

	local requiredExperience = GetRequiredExperience( levelValue )
	while experienceValue.Value >= requiredExperience do
		experienceValue.Value -= requiredExperience
		levelValue.Value += 1
		attributesValue.Value += 2
		if not doneLeveledUpMessage then
			doneLeveledUpMessage = true
			DisplayLevelUpMessage( LocalPlayer, levelValue, nil )
		end
		requiredExperience = GetRequiredExperience( levelValue )
	end

end

-- // Module // --
local Module = {}

function Module.OnPlayerAdded( LocalPlayer : Player )

	local leaderstats = Instance.new('Folder')
	leaderstats.Name = 'leaderstats'
	leaderstats.Parent = LocalPlayer

	local levelValue = CreateStatValue( 'Level', 9e9, leaderstats )
	local experienceValue = CreateStatValue( 'Experience', 0, leaderstats )
	local currencyValue = CreateStatValue( 'Money', 9e99, leaderstats )

	local hiddenStats = Instance.new('Folder')
	hiddenStats.Name = 'HiddenStats'
	hiddenStats.Parent = LocalPlayer

	local attributePointsValue = CreateStatValue( 'AttributePoints', 0, hiddenStats ) -- mana + bonus mana damage
	local strengthValue = CreateStatValue( 'Strength', 0, hiddenStats ) -- base melee damage + crit dmg
	local vitalityValue = CreateStatValue( 'Vitality', 0, hiddenStats ) -- health + damage red. %
	local dexterityValue = CreateStatValue( 'Dexterity', 0, hiddenStats ) -- accuracy + crit chance
	local intelligencevalue = CreateStatValue( 'Intelligence', 0, hiddenStats ) -- mana + bonus mana damage

	local weaponsFolder = Instance.new('Folder')
	weaponsFolder.Name = 'Weapons'
	weaponsFolder.Parent = LocalPlayer

	local savedData = PlayerDataStore:GetAsync( tostring(LocalPlayer.UserId) )
	if savedData then
		-- leaderstats
		levelValue.Value = savedData.leaderstats.Level
		experienceValue.Value = savedData.leaderstats.Experience
		currencyValue.Value = savedData.leaderstats.Currency
		-- hidden stats
		attributePointsValue.Value = savedData.HiddenStats.AttributePoints
		strengthValue.Value = savedData.HiddenStats.Strength
		vitalityValue.Value = savedData.HiddenStats.Vitality
		dexterityValue.Value = savedData.HiddenStats.Dexterity
		intelligencevalue.Value = savedData.HiddenStats.Intelligence
		-- weapons
		for _, itemName in ipairs( savedData.Weapons ) do
			Instance.new('Folder', weaponsFolder).Name = itemName
		end
	end

	local isBusy = false
	experienceValue.Changed:Connect(function()
		if isBusy then
			return
		end
		isBusy = true
		OnExperienceChanged( LocalPlayer, experienceValue, levelValue, attributePointsValue )
		isBusy = false
	end)

	LocalPlayer:SetAttribute('ServerReady', true) -- let player load in now
end

function Module.OnPlayerRemoving( LocalPlayer )
	local leaderstats = LocalPlayer.leaderstats
	local hiddenStats = LocalPlayer.HiddenStats
	local weaponsFolder = LocalPlayer.Weapons

	local Weapons = {}
	for _, item in ipairs( weaponsFolder:GetChildren() ) do
		table.insert(Weapons, item.Name)
	end

	local SaveData = {
		leaderstats = {
			Level = leaderstats.Level.Value,
			Experience = leaderstats.Experience.Value,
			Currency=  leaderstats.Money.Value,
		},
		HiddenStats = {
			AttributePoints = hiddenStats.AttributePoints.Value,
			Strength = hiddenStats.Strength.Value,
			Vitality = hiddenStats.Vitality.Value,
			Dexterity = hiddenStats.Dexterity.Value,
			Intelligence = hiddenStats.Intelligence.Value,
		},
		Weapons = Weapons,
	}
	warn('Saving is not currently enabled.')
	-- PlayerDataStore:SetAsync( tostring(LocalPlayer.UserId), SaveData )
end

function Module.Start()

	for _, LocalPlayer in ipairs( Players:GetChildren() ) do
		task.spawn(Module.OnPlayerAdded, LocalPlayer)
	end
	Players.PlayerAdded:Connect(Module.OnPlayerAdded)
	Players.PlayerRemoving:Connect(Module.OnPlayerRemoving)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module

