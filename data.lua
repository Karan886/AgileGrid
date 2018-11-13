local data = {}

local rawSizeCombinations = {
	{rows = 3, cols = 2},
	{rows = 3, cols = 3},
    {rows = 3, cols = 4},
    {rows = 3, cols = 5},
    {rows = 3, cols = 6},
    {rows = 4, cols = 6},
    {rows = 2, cols = 6}
}

data.sizeCombinations = {}
function getSizeCombinations()
	for i=1, #rawSizeCombinations do
		data.sizeCombinations[#data.sizeCombinations + 1] = rawSizeCombinations[i]
		data.sizeCombinations[#data.sizeCombinations + 1] = {rows = rawSizeCombinations[i].rows, cols = rawSizeCombinations[i].cols}
	end
end

getSizeCombinations()
return data