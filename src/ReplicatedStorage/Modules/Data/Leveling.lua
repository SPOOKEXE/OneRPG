
local Module = {}

function Module.GetRequiredExperience( level )
	-- ROUND(100 + (($A1 * 50) * POWER( 1.05, MIN($A1, 40) ) ), 0)
	return math.round(100 + (level * 50) * math.pow( 1.05, math.min(level, 40) ))
end

return Module
