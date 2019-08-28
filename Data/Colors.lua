local colors = {}
colors.colors = {
    {r = 0.45, g = 0.35, b = 0.5},
    {r = 0.45, g = 0.24, b = 0.10},
    {r = 0.38, g = 0.69, b = 0.10},
    {r = 0.38, g = 0.69, b = 1.0},
    {r = 0.60, g = 0.09, b = 0.17},
    {r = 0.73, g = 0.69, b = 0.03},
    {r = 0.74, g = 0.82, b = 0.93},
    {r = 0.89, g = 0.47, b = 0.82},
    {r = 0.96, g = 0.97, b = 0.46},
    {r = 0.94, g = 0.94, b = 0.94},
    {r = 0.99, g = 0.82, b = 0.09},
    {r = 1.0, g = 0.68, b = 0.73},
    {r = 1.0, g = 1.0, b = 0.80},
    {r = 0.93, g = 0.68, b = 0.05},
    {r = 0.89, g = 0.87, b = 0.71}
}



math.randomseed(os.time())
function colors.shuffle(table)
    for i = #table, 2, -1 do
        j = math.random(i)
        table[i], table[j] = table[j], table[i]
    end
end

function colors.populateDimensions(x, y)
    local result = {}
    local size = x * y

    colors.shuffle(colors.colors)
    local colorsTable = colors.colors

    for i = 1, (size / 3) do
        colorsTable[i].id = i
        result[#result + 1] = colorsTable[i]
        result[#result + 1] = colorsTable[i]
        result[#result + 1] = colorsTable[i]
    end
    colors.shuffle(result)
    return result
end



return colors