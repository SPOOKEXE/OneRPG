
local CollectionService = game:GetService("CollectionService")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedModules = require(ReplicatedStorage:WaitForChild("Modules"))

local ProgressionsModule = ReplicatedModules.Data.Progressions

local SystemsContainer = {}

local function SetProperties( Parent, Properties )
	for propName, propValue in pairs( Properties ) do
		Parent[propName] = propValue
	end
end

-- // Module // --
local Module = {}

function Module.SetupLevelPortal( Model )

	local PortalConfig = ProgressionsModule.LevelRestrictors[ Model.Name ]
	if not PortalConfig then
		warn('Invalid Level Portal : ' .. tostring(Model:GetFullName()))
		return
	end

	Model.BillboardUI.LevelLabel.Text = 'Level '..tostring( PortalConfig.Level )
	SetProperties( Model.BillboardUI.NameLabel, PortalConfig.Display )

	local Debounce = false
	Model.Door.Touched:Connect(function( hit )
		if Debounce then
			return
		end

		local Character = hit.Parent
		local Humanoid = Character:FindFirstChildWhichIsA('Humanoid')
		if not Humanoid then
			return
		end

		if LocalPlayer.Character ~= Character then
			return
		end

		Debounce = true
		task.delay(1, function()
			Debounce = false
		end)

		Character:PivotTo( Model.TeleportTo:GetPivot() )
	end)

end

function Module.SetupLevelDoor( Model )
	local DoorConfig = ProgressionsModule.LevelRestrictors[ Model.Name ]
	if not DoorConfig then
		warn('Invalid Level Door : ' .. tostring(Model:GetFullName()))
		return
	end

	Model.BillboardUI.LevelLabel.Text = 'Level '..tostring( DoorConfig.Level )
	SetProperties( Model.BillboardUI.NameLabel, DoorConfig.Display )

	local Debounce = false
	Model.Door.Touched:Connect(function( hit )
		if Debounce then
			return
		end

		local Humanoid = hit.Parent:FindFirstChildWhichIsA('Humanoid')
		if not Humanoid then
			return
		end

		if LocalPlayer.Character ~= hit.Parent then
			return
		end

		Debounce = true
		task.delay(1, function()
			Debounce = false
		end)

		Model.Door.Transparency = 0.7
		Model.Door.CanCollide = false
		task.wait(2)
		Model.Door.Transparency = 0.25
		Model.Door.CanCollide = true
	end)
end

function Module.Start()

	for _, Model in ipairs( CollectionService:GetTagged('LevelPortal') ) do
		task.spawn( Module.SetupLevelPortal, Model )
	end
	CollectionService:GetInstanceAddedSignal('LevelPortal'):Connect(Module.SetupLevelPortal)

	for _, Model in ipairs( CollectionService:GetTagged('LevelDoor') ) do
		task.spawn( Module.SetupLevelDoor, Model )
	end
	CollectionService:GetInstanceAddedSignal('LevelDoor'):Connect(Module.SetupLevelDoor)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
