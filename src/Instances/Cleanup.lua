local Cleanup = {}
Cleanup.type = "SpecialKey"
Cleanup.stage = "observer"

function Cleanup:apply(value, instance, toClean)
	table.insert(toClean, value)
end

return Cleanup