
local CollectionService = game:GetService('CollectionService')
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedAssets = ReplicatedStorage:WaitForChild('Assets')
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ArmorConfigModule = ReplicatedModules.Data.ArmorData

local SystemsContainer = {}

local ArmorMorphBillboards = {}

local function SetProperties( Parent, Properties )
	for propName, propValue in pairs( Properties ) do
		Parent[propName] = propValue
	end
	return Parent
end

-- // Module // --
local Module = {}

function Module.SetupArmorMorph( ArmorMorph )
	local ArmorId = ArmorMorph:GetAttribute('ArmorId')
	local ArmorConfig = ArmorId and ArmorConfigModule.Armors[ArmorId]
	if (not ArmorId) or (not ArmorConfig) then
		warn(string.format('%s has no (valid) armor id.', ArmorMorph:GetFullName()))
		return
	end

	local MorphPad = ArmorMorph:FindFirstChild('Pad')
	if (not MorphPad) or (not MorphPad:IsA('BasePart')) then
		warn(string.format('%s has no morph pad for touched events.', ArmorMorph:GetFullName()))
		return
	end

	local TemplateBillboard = ReplicatedAssets.UI.ArmorMorphInfo:Clone()
	TemplateBillboard.Adornee = MorphPad
	SetProperties(TemplateBillboard.Frame.TitleLabel, ArmorConfig.Display)
	TemplateBillboard.Frame.InfoLabel.Text = string.format('Level %s | +%s HP | +%s WS', tostring(ArmorConfig.RequiredLevel), tostring(ArmorConfig.BonusMaxHealth), tostring(ArmorConfig.BonusWalkSpeed))
	TemplateBillboard.Parent = ArmorMorph

	ArmorMorphBillboards[ ArmorMorph ] = TemplateBillboard

end

function Module.CleanupArmorMorph( ArmorMorph )
	if ArmorMorphBillboards[ ArmorMorph ] then
		ArmorMorphBillboards[ ArmorMorph ]:Destroy()
	end
	ArmorMorphBillboards[ ArmorMorph ] = nil
end

function Module.Start()

	local CollectionArmorMorphTag = ArmorConfigModule.CollectionTagArmorMorph
	for _, Model in ipairs( CollectionService:GetTagged( CollectionArmorMorphTag ) ) do
		task.spawn(Module.SetupArmorMorph, Model)
	end
	CollectionService:GetInstanceAddedSignal( CollectionArmorMorphTag ):Connect( Module.SetupArmorMorph )
	CollectionService:GetInstanceRemovedSignal( CollectionArmorMorphTag ):Connect( Module.CleanupArmorMorph )

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
