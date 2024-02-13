
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local LocalModules = require(LocalPlayer:WaitForChild("PlayerScripts"):WaitForChild("Modules"))

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')
local CharacterDataFrame = Interface.CharacterData

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local LevelingDataModule = ReplicatedModules.Data.Leveling

local SystemsContainer = {}

local function TweenSize( frame : Frame, endSize : UDim2, duration : number? )
	frame:TweenSize( endSize, Enum.EasingDirection.InOut, Enum.EasingStyle.Sine, duration or 1, true )
end

-- // Module // --
local Module = {}

function Module.OnCharacterAdded( NewCharacter )
	local Humanoid = NewCharacter:WaitForChild('Humanoid', 5)
	if not Humanoid then
		return
	end

	local delta = (Humanoid.WalkSpeed - 16)
	CharacterDataFrame.StatsFrame.SubStatsFrame.WalkSpeedFrame.WalkSpeed.Text = (delta > 0 and '+' or '')..tostring(delta)
	Humanoid:GetPropertyChangedSignal('WalkSpeed'):Connect(function()
		delta = (Humanoid.WalkSpeed - 16)
		CharacterDataFrame.StatsFrame.SubStatsFrame.WalkSpeedFrame.WalkSpeed.Text = (delta > 0 and '+' or '')..tostring(delta)
	end)
end

function Module.ToggleAttributesFrame( forced : boolean? )
	if typeof(forced) == nil then
		Interface.StatsFrame.Visible = not Interface.StatsFrame.Visible
	else
		Interface.StatsFrame.Visible = forced
	end
end

function Module.SetupCharacterData()

	local leaderstatsFolder = LocalPlayer:WaitForChild('leaderstats')
	-- local HiddenStatsFolder = LocalPlayer:WaitForChild('HiddenStats')

	CharacterDataFrame.Character.Icon.Image = Players:GetUserThumbnailAsync( LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size180x180 )
	CharacterDataFrame.StatsFrame.NameFrame.Label.Text = string.upper( LocalPlayer.Name )

	CharacterDataFrame.Character.Level.Text = 'Lvl: '..tostring(leaderstatsFolder.Level.Value)
	leaderstatsFolder.Level.Changed:Connect(function()
		CharacterDataFrame.Character.Level.Text = 'Lvl: '..tostring(leaderstatsFolder.Level.Value)
	end)

	CharacterDataFrame.StatsFrame.SubStatsFrame.GoldFrame.Gold.Text = leaderstatsFolder.Money.Value
	leaderstatsFolder.Money.Changed:Connect(function()
		CharacterDataFrame.StatsFrame.SubStatsFrame.GoldFrame.Gold.Text = leaderstatsFolder.Money.Value
	end)

	local requiredExperience = LevelingDataModule.GetRequiredExperience(leaderstatsFolder.Level.Value)
	local roundedPercent = math.round( (leaderstatsFolder.Experience.Value / requiredExperience) * 100 )
	CharacterDataFrame.ExperienceFrame.ExpLabel.Text = string.format('XP: %s / %s (%s%s)', tostring(leaderstatsFolder.Experience.Value), tostring(requiredExperience), tostring(roundedPercent), '%')
	CharacterDataFrame.ExperienceFrame.Bar.Size = UDim2.fromScale( leaderstatsFolder.Experience.Value / requiredExperience )
	leaderstatsFolder.Experience.Changed:Connect(function()
		requiredExperience = LevelingDataModule.GetRequiredExperience(leaderstatsFolder.Level.Value)
		roundedPercent = math.round( (leaderstatsFolder.Experience.Value / requiredExperience) * 100 )
		CharacterDataFrame.ExperienceFrame.ExpLabel.Text = string.format('XP: %s / %s (%s%s)', tostring(leaderstatsFolder.Experience.Value), tostring(requiredExperience), tostring(roundedPercent), '%')
		TweenSize( CharacterDataFrame.ExperienceFrame.Bar, UDim2.fromScale( leaderstatsFolder.Experience.Value / LevelingDataModule.GetRequiredExperience(leaderstatsFolder.Level.Value) ), 1 )
	end)

	if LocalPlayer.Character then
		task.spawn(Module.OnCharacterAdded, LocalPlayer.Character)
	end
	LocalPlayer.CharacterAdded:Connect(Module.OnCharacterAdded)

	Module.ToggleAttributesFrame(false)
	CharacterDataFrame.StatsFrame.AttributesButton.AttributeButton.Activated:Connect(function()
		Module.ToggleAttributesFrame(true)
	end)
	Interface.StatsFrame.CloseButton.Activated:Connect(function()
		Module.ToggleAttributesFrame(false)
	end)
end

function Module.Start()

	task.spawn(Module.SetupCharacterData)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
