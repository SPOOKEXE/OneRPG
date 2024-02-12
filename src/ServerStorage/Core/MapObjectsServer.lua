
local CollectionService = game:GetService("CollectionService")

local SystemsContainer = {}

-- // Module // --
local Module = {}

function Module.SetupHealingFountain( Model )
	if Model:GetAttribute('FountainIsSetup') then
		return
	end
	Model:SetAttribute('FountainIsSetup', true)

	local Debounce = false
	Model.Heal.Touched:Connect(function( hit )
		if Debounce then
			return
		end
		local Humanoid = hit.Parent:FindFirstChildWhichIsA('Humanoid')
		if Humanoid then
			Debounce = true
			Humanoid.Health = Humanoid.MaxHealth
			Model.WaterColor.Color = Color3.fromRGB(255, 0, 0)
			task.wait(2)
			Debounce = false
			Model.WaterColor.Color = Color3.fromRGB(74, 129, 161)
		end
	end)
end

function Module.Start()

	for _, Model in ipairs( CollectionService:GetTagged('HealingFountain') ) do
		task.spawn( Module.SetupHealingFountain, Model )
	end
	CollectionService:GetInstanceAddedSignal('HealingFountain'):Connect(Module.SetupHealingFountain)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
