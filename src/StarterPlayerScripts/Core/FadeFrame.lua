
local StarterGui = game:GetService("StarterGui")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Interface = LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('Interface')

local TweenService = game:GetService('TweenService')

local SystemsContainer = {}

local DEFAULT_FADE_DURATION = 2

-- // Module // --
local Module = {}

function Module.FadeIn( duration : number? )
	TweenService:Create(Interface.Fade, TweenInfo.new(duration or DEFAULT_FADE_DURATION), { BackgroundTransparency = 0 }):Play()
end

function Module.FadeOut( duration : number? )
	TweenService:Create(Interface.Fade, TweenInfo.new(duration or DEFAULT_FADE_DURATION), { BackgroundTransparency = 1 }):Play()
end

function Module.Start()

	StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.All, false )
	Interface.Fade.BackgroundTransparency = 0
	task.spawn(function()
		repeat task.wait(1)
		until LocalPlayer:GetAttribute('ServerReady')
		Module.FadeOut()
		task.wait(DEFAULT_FADE_DURATION / 2)
		StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.PlayerList, true )
		StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.Chat, true )
		StarterGui:SetCoreGuiEnabled( Enum.CoreGuiType.Health, true )
	end)

end

function Module.Init(otherSystems)
	SystemsContainer = otherSystems
end

return Module
