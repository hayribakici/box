-- color_utils.lua

local color_utils = {}

function color_utils.darkenHexColor(hex, factor)
    -- Ensure the factor is between 0 and 1
    factor = math.max(0, math.min(1, factor))

    -- Remove the hash at the start if it's there
    hex = hex:gsub("#", "")

    -- Convert hex to RGB
    local r = tonumber(hex:sub(1, 2), 16)
    local g = tonumber(hex:sub(3, 4), 16)
    local b = tonumber(hex:sub(5, 6), 16)

    -- Darken the RGB values
    r = math.floor(r * (1 - factor))
    g = math.floor(g * (1 - factor))
    b = math.floor(b * (1 - factor))

    -- Convert back to hex
    return string.format("#%02X%02X%02X", r, g, b)
end

return color_utils
