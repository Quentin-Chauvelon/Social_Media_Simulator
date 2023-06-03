local TableUtilities = {}

export type TableUtilities = {
    clone : ({}) -> {}
}

function TableUtilities.clone(tbl)
	local clone = {}

	for i, v in pairs(tbl) do
		if typeof(v) == "table" then
			clone[i] = TableUtilities.clone(v)
		else
			clone[i] = v
		end
	end

	return clone
end

return TableUtilities