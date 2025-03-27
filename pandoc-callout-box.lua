-- lua filter for creating boxes around callout sections in Markdown.
-- Copyright (C) 2025 Onur Hayri Bakici, released under MIT license

local classColors = {
    info = '#E6F0FC',
    todo = '#E6F0FC',
    example = '#F1EEFD',
    -- warning
    warning = '#FDF1E5',
    caution = '#FDF1E5',
    attention = '#FDF1E5',

    -- danger
    danger = '#FDEAEC',
    error = '#FDEAEC',
    -- failure
    failure = '#FDEAEC',
    fail = '#FDEAEC',
    missing = '#FDEAEC',

    -- question
    question = '#FDF1E5',
    help = '#FDF1E5',
    faq = '#FDF1E5',
    -- tip
    tip = '#E4F8F8',
    hint = '#E4F8F8',
    important = '#E4F8F8',
    -- success
    check = '#E6F7ED',
    done = '#E6F7ED',
    success = '#E6F7ED',
    -- note
    note = '#E6F0FC',
    --
    plain = '#ffffff',
    -- summary
    abstract = '#E4F8F8',
    summary = '#E4F8F8',
    tdlr = '#E4F8F8',
    --
    quote = '#F5F5F5',
    cite = '#F5F5F5',
    bug = '#FDEAEC'
}

-- color_utils

local function darkenHexColor(hex, factor)
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



-- box-utils
local box_utils = {}

local function raw_tex(t)
    return pandoc.RawBlock('tex', t)
end

local function isempty(s)
    return s == nil or s == ''
end

-- checks whether string starts with a character c
local function startsWith(s, c)
    local pos = string.find(s, c)
    return pos ~= nil and pos == 1
end

local function sublist(list, startPos, endPos)
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

local function find_element_at(pandoc_list, pred)
    for i, el in ipairs(pandoc_list) do
        if pred(el) then
            return i
        end
    end
    return -1
end

local function getColorFromClass(class, classColors)
    if (classColors[class]) then
        return classColors[class]
    end
    print(string.format('[Warning] invalid admonition type %s. Setting to default', class))
    return classColors['default']
end

-- returns a tuple, the color defition
-- for latex and its name 'c_<htmlColor>'
local function getColorNameDefinitionTuple(htmlColor)
    local c = htmlColor:gsub('#', '')
    local latexCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', c, c:upper())
    local colorName = 'c_' .. c
    return latexCmd, colorName
end

-- Returns the stringified first line and the rest
-- of the BlockQuote
local function split_to_first_line_and_rest(elem)
    if #elem.content == 0 then
        return '', nil
    end
    local firstParagraph = elem.c:remove(1)
    if firstParagraph.t == "Para" then
        local paragraphContent = firstParagraph.c
        local indexSoftBreak = box_utils.find_element_at(paragraphContent, function(item)
            return item and item.tag == 'SoftBreak'
        end)
        if indexSoftBreak == -1 then
            -- Return the first line
            return pandoc.utils.stringify(paragraphContent), nil
        end
        local firstLine = pandoc.utils.stringify(box_utils.sublist(paragraphContent, 1, indexSoftBreak))
        local rest = pandoc.List:new({
            pandoc.Para(box_utils.sublist(paragraphContent, indexSoftBreak + 1))
        })
        rest:extend(elem.c)

        return firstLine, rest
    end
end

-- Returns the given admonition class and title, if applicable
local function split_admonition_class_and_title(input)
    local pattern = "(%[!(.-)%])"
    local full, textBetween = input:match(pattern)
    if textBetween then
        -- Adjusting for the length of '[!text]'
        return textBetween, input:sub(#full + 2)
    end
    return nil, nil
end

local function process(div)
    -- only proceed, if a BlockQuote is given
    if div.t ~= 'BlockQuote' then return nil end
    local firstLine, rest = split_to_first_line_and_rest(div)
    local class, title = split_admonition_class_and_title(firstLine)
    if box_utils.isempty(title) then
        title = class:gsub("^%l", string.upper)
    end
    local fillColor = box_utils.getColorFromClass(class, classColors)
    local borderColor = box_utils.getColorFromClass(class, classColors)
    local titleColor = darkenHexColor(fillColor, 0.5)
    -- print(titleColor)
    local options = {}
    local latexFillColorCmd = ''
    local latexBorderColorCmd = ''
    local latexTitleColorCmd = ''
    if not box_utils.isempty(fillColor) then
        local fcName = ''
        local tcName = ''
        if (box_utils.startsWith(fillColor, '#')) then
            latexFillColorCmd, fcName = box_utils.getColorNameDefinitionTuple(fillColor)
            latexTitleColorCmd, tcName = box_utils.getColorNameDefinitionTuple(titleColor)
        else
            fcName = fillColor
        end
        table.insert(options, 'colback=' .. fcName)
        table.insert(options, 'coltitle=' .. tcName)
    end
    if not box_utils.isempty(borderColor) then
        local bcName = ''
        if (box_utils.startsWith(borderColor, '#')) then
            latexBorderColorCmd, bcName = box_utils.getColorNameDefinitionTuple(borderColor)
        else
            bcName = borderColor
        end
        table.insert(options, 'colframe=' .. bcName)
    end
    if not box_utils.isempty(title) then
        table.insert(options, 'title=' .. pandoc.utils.stringify(title))
    end

    local result = {
        box_utils.raw_tex(latexTitleColorCmd),
        box_utils.raw_tex(latexFillColorCmd),
        box_utils.raw_tex(latexBorderColorCmd),
        box_utils.raw_tex(string.format('\\begin{tcolorbox}[%s]', table.concat(options, ','))),
    }

    local content = rest or ''
    for i = 1, #content do
        table.insert(result, content[i])
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
    { BlockQuote = process }
}
