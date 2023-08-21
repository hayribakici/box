-- lua filter for creating boxes around text in Markdown.
-- Copyright (C) 2023 Onur Hayri Bakici, released under MIT license


local classColors = {
  warning = '#E3C414',
  info = '#7289DA',
  danger = '#ce2029',
  important = '#00a86b',
  -- note = '',
  plain = '#ffffff',
  default = ''
}

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

local function getColorFromClass(class)
  if (classColors[class]) then
    return classColors[class]
  end
  print(string.format('[Warning] invalid admonition type %s. Setting to default', class))
  return classColors['default']
end

-- returns two values, if it is in the class and its name
local function isInAdmonitionMode(div)
  for i = 0, #div.attr.classes do
    if (not isempty(div.attr.classes[i])) then
      return true, div.attr.classes[i]
    end
  end
  return false, ''
end

-- returns a tuple, the color defition
-- for latex and its name 'c_<htmlColor>'
local function getColorNameDefinitionTuple(htmlColor)
  local c = htmlColor:gsub('#', '')
  local latexCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', c, c:upper())
  local colorName = 'c_' .. c
  return latexCmd, colorName
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
    borderColor = getColorFromClass(class)
  else
    fillColor = popAttrFromDiv(div, 'fillcolor')
    borderColor = popAttrFromDiv(div, 'bordercolor')
  end

  local options = {}
  local latexFillColorCmd = ''
  local latexBorderColorCmd = ''
  if (not isempty(fillColor)) then
    local fcName = ''
    if (startsWith(fillColor, '#')) then
      latexFillColorCmd, fcName = getColorNameDefinitionTuple(fillColor)
    else
      fcName = fillColor
    end
    table.insert(options, 'colback=' .. fcName)
  end
  if (not isempty(borderColor)) then
    local bcName = ''
    if (startsWith(borderColor, '#')) then
      latexBorderColorCmd, bcName = getColorNameDefinitionTuple(borderColor)
    else
      bcName = borderColor
    end
    table.insert(options, 'colframe=' .. bcName)
  end
  if (not isempty(title)) then
    table.insert(options, 'title=' .. pandoc.utils.stringify(title))
  end

  local result = {
    raw_tex(latexFillColorCmd),
    raw_tex(latexBorderColorCmd),
    raw_tex(string.format('\\begin{tcolorbox}[%s]', table.concat(options, ','))),
  }

  local content = div.content or ''
  for i = 1, #content do
    table.insert(result, content[i])
  end
  if (not isempty(bottom)) then
    table.insert(result, raw_tex('\\tcblower'))
    table.insert(result, bottom)
  end
  table.insert(result, raw_tex('\\end{tcolorbox}'))
  return result
end

--- Ensure that the longfbox package is loaded.
function Meta(m)
  m['header-includes'] = { raw_tex('\\usepackage{tcolorbox}') }
  return m
end

return {
  { Meta = Meta },
  { Div = process }
}
