-- lua filter for creating boxes around text in Markdown.
-- Copyright (C) 2023 Onur Hayri Bakici, released under MIT license

local box_utils = require("box_utils")

local classColors = {
    warning = '#E3C414',
    info = '#7289DA',
    danger = '#ce2029',
    important = '#00a86b',
    -- note = '',
    plain = '#ffffff',
    default = ''
}

local function popAndStripBlockQuoteElementFromDiv(div, index)
    local elem = ''
    if (#div.content == 0) then
        return elem
    end
    if div.content[index].t == "BlockQuote" then
        -- return the contents of the BlockQuote
        elem = table.remove(div.content, index).c[1]
    end
    return elem
end

local function popAttrFromDiv(div, name)
    -- can be nil
    local attr = div.attr.attributes[name] or nil
    div.attr.attributes[name] = nil
    return attr
end

-- returns two values, if it is in the class and its name
local function isInAdmonitionMode(div)
    for i = 0, #div.attr.classes do
        if (not box_utils.isempty(div.attr.classes[i])) then
            return true, div.attr.classes[i]
        end
    end
    return false, ''
end

local function process(div)
    if div.attr.classes[1] ~= "box" then return nil end
    table.remove(div.attr.classes, 1)

    local title = popAndStripBlockQuoteElementFromDiv(div, 1)
    local bottom = popAndStripBlockQuoteElementFromDiv(div, #div.content)

    local fillColor = ''
    local borderColor = ''
    local admonitionMode, class = isInAdmonitionMode(div)

    if (admonitionMode) then
        borderColor = box_utils.getColorFromClass(class, classColors)
    else
        fillColor = popAttrFromDiv(div, 'fillcolor')
        borderColor = popAttrFromDiv(div, 'bordercolor')
    end

    local options = {}
    local latexFillColorCmd = ''
    local latexBorderColorCmd = ''
    if (not box_utils.isempty(fillColor)) then
        local fcName = ''
        if (box_utils.startsWith(fillColor, '#')) then
            latexFillColorCmd, fcName = box_utils.getColorNameDefinitionTuple(fillColor, classColors)
        else
            fcName = fillColor
        end
        table.insert(options, 'colback=' .. fcName)
    end
    if (not box_utils.isempty(borderColor)) then
        local bcName = ''
        if (box_utils.startsWith(borderColor, '#')) then
            latexBorderColorCmd, bcName = box_utils.getColorNameDefinitionTuple(borderColor, classColors)
        else
            bcName = borderColor
        end
        table.insert(options, 'colframe=' .. bcName)
    end
    if (not box_utils.isempty(title)) then
        table.insert(options, 'title=' .. pandoc.utils.stringify(title))
    end

    local result = {
        box_utils.raw_tex(latexFillColorCmd),
        box_utils.raw_tex(latexBorderColorCmd),
        box_utils.raw_tex(string.format('\\begin{tcolorbox}[%s]', table.concat(options, ','))),
    }

    local content = div.content or ''
    for i = 1, #content do
        table.insert(result, content[i])
    end
    if (not box_utils.isempty(bottom)) then
        table.insert(result, box_utils.raw_tex('\\tcblower'))
        table.insert(result, bottom)
    end
    table.insert(result, box_utils.raw_tex('\\end{tcolorbox}'))
    return result
end

--- Ensure that the longfbox package is loaded.
function Meta(m)
    m['header-includes'] = { box_utils.raw_tex('\\usepackage{tcolorbox}') }
    return m
end

return {
    { Meta = Meta },
    { Div = process }
}
