
local CollectionService = game:GetService('CollectionService')
local Players = game:GetService('Players')

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ArmorConfigModule = ReplicatedModules.Data.ArmorData

local SystemsContainer = {}

local ArmorMorphConnections = {}

local function WeldConstraint( WeldThis, ToThis )
	local Constraint = Instance.new('WeldConstraint')
	Constraint.Part0 = WeldThis
	Constraint.Part1 = ToThis
	Constraint.Parent = WeldThis
	return Constraint
end

local function PrepareArmorModel( Model )
	for _, item in ipairs( Model:GetDescendants() ) do
		if item:IsA('BasePart') then
			item.Anchored = false
			item.CanCollide = false
			item.CanTouch = false
			item.CanQuery = false
			item.Massless = true
		end
	end
end

-- // Module // --
local Module = {}

function Module.GetCurrentArmor( Character )
	return Character:GetAttribute('ArmorTag')
end

function Module.AddArmorBonuses( Humanoid, ArmorConfig )
	if ArmorConfig.BonusMaxHealth then
		Humanoid.MaxHealth += ArmorConfig.BonusMaxHealth
		if Humanoid.Health > Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end
	if ArmorConfig.BonusWalkSpeed then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed + ArmorConfig.BonusWalkSpeed
	end
end

function Module.RemoveArmorBonuses( Humanoid, ArmorConfig )
	if ArmorConfig.BonusMaxHealth then
		Humanoid.MaxHealth -= ArmorConfig.BonusMaxHealth
		if Humanoid.Health > Humanoid.MaxHealth then
			Humanoid.Health = Humanoid.MaxHealth
		end
	end
	if ArmorConfig.BonusWalkSpeed then
		Humanoid.WalkSpeed = Humanoid.WalkSpeed - ArmorConfig.BonusWalkSpeed
	end
end

function Module.ClearCurrentArmor( Character, Humanoid )
	local ArmorId = Module.GetCurrentArmor( Character )
	local OldArmorConfig = ArmorId and ArmorConfigModule.Armors[ArmorId]
	if OldArmorConfig then
		Module.RemoveArmorBonuses( Humanoid, OldArmorConfig )
	end
	Character:SetAttribute('ArmorTag', nil)
	for _, item in ipairs( Character:GetChildren() ) do
		if item:GetAttribute('ArmorAccessory') then
			item:Destroy()

			local bodyPart = Character:FindFirstChild(item.Name)
			if bodyPart and bodyPart.Transparency == 1 and bodyPart:IsA('BasePart') then
				bodyPart.Transparency = 0
			end

		end
	end
end

function Module.ApplyTargetArmor( Character, Humanoid, ArmorId : string, ArmorConfig : {}, MorphBodyParts : Instance )
	Character:SetAttribute('ArmorTag', ArmorId)
	Module.AddArmorBonuses( Humanoid, ArmorConfig )
	for _, Model in ipairs( MorphBodyParts:GetChildren() ) do
		if Model:IsA('Model') then
			local TargetBodyPart = Character:FindFirstChild( Model.Name )
			if not TargetBodyPart then
				warn(string.format("Unable to find the target bodypart %s in %s's character.", Model.Name, Character:GetFullName()))
				continue
			end

			TargetBodyPart.Transparency = 1

			Model = Model:Clone()
			if not Model.PrimaryPart then
				Model.PrimaryPart = Model:FindFirstChildWhichIsA('BasePart')
			end
			Model:SetAttribute('ArmorAccessory', true)
			PrepareArmorModel( Model )
			Model:PivotTo( TargetBodyPart:GetPivot() )
			WeldConstraint( Model.PrimaryPart, TargetBodyPart )
			Model.Parent = Character
		end
	end
end

function Module.AttemptArmorApplication( Character, Humanoid, ArmorId, ArmorConfig, MorphBodyParts )
	local currentArmor = Module.GetCurrentArmor( Character )
	if currentArmor and currentArmor == ArmorId then
		return
	end
	if currentArmor then
		Module.ClearCurrentArmor( Character, Humanoid )
	end
	Module.ApplyTargetArmor( Character, Humanoid, ArmorId, ArmorConfig, MorphBodyParts )
end

function Module.SetupArmorMorph( ArmorMorph )
	local ArmorId = ArmorMorph:GetAttribute('ArmorId')
	local ArmorConfig = ArmorId and ArmorConfigModule.Armors[ArmorId]
	if (not ArmorId) or (not ArmorConfig) then
		warn(string.format('%s has no (valid) armor id.', ArmorMorph:GetFullName()))
		return
	end

	local MorphBodyParts = ArmorMorph:FindFirstChild('Armor')
	if not MorphBodyParts then
		warn(string.format('%s has no armor morph to apply to the character.', ArmorMorph:GetFullName()))
		return
	end

	local MorphPad = ArmorMorph:FindFirstChild('Pad')
	if (not MorphPad) or (not MorphPad:IsA('BasePart')) then
		warn(string.format('%s has no morph pad for touched events.', ArmorMorph:GetFullName()))
		return
	end

	local Debounce = false
	MorphPad.Touched:Connect(function( hit )
		if Debounce then
			return
		end
		local Character = hit.Parent
		local Humanoid = Character:FindFirstChildWhichIsA('Humanoid')
		local TargetPlayer = Players:GetPlayerFromCharacter( Character )
		if Humanoid and Humanoid.Health > 0 and TargetPlayer then
			Debounce = true
			task.delay(0.2, function()
				Debounce = false
			end)
			local LevelValue = TargetPlayer.leaderstats.Level
			if LevelValue.Value < ArmorConfig.RequiredLevel then
				return
			end
			Module.AttemptArmorApplication( Character, Humanoid, ArmorId, ArmorConfig, MorphBodyParts )
		end
	end)
end

function Module.CleanupArmorMorph( ArmorMorph )
	if ArmorMorphConnections[ ArmorMorph ] then
		ArmorMorphConnections[ ArmorMorph ]:Disconnect()
	end
	ArmorMorphConnections[ ArmorMorph ] = nil
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
