-- box-utils.lua
local box_utils = {}

function box_utils.raw_tex(t)
    return pandoc.RawBlock('tex', t)
end

function box_utils.isempty(s)
    return s == nil or s == ''
end

-- checks whether string starts with a character c
function box_utils.startsWith(s, c)
    local pos = string.find(s, c)
    return pos ~= nil and pos == 1
end

function box_utils.sublist(list, startPos, endPos)
    local sub = {}
    local len = #list
    -- Default to the length of the list if endPosition is nil
    endPos = endPos or len
    if startPos >= endPos then
        return sub
    end
    if startPos > len or endPos > len then
        return sub
    end
    for i = startPos, endPos do
        table.insert(sub, list[i])
    end
    return sub
end

function box_utils.find_element_at(pandoc_list, pred)
    for i, el in ipairs(pandoc_list) do
        if pred(el) then
            return i
        end
    end
    return -1
end

function box_utils.getColorFromClass(class, classColors)
    if (classColors[class]) then
        return classColors[class]
    end
    print(string.format('[Warning] invalid admonition type %s. Setting to default', class))
    return classColors['default']
end

-- returns a tuple, the color defition
-- for latex and its name 'c_<htmlColor>'
function box_utils.getColorNameDefinitionTuple(htmlColor)
    local c = htmlColor:gsub('#', '')
    local latexCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', c, c:upper())
    local colorName = 'c_' .. c
    return latexCmd, colorName
end

return box_utils
