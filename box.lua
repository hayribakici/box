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
  local color = div.attr.attributes[name] or nil
  div.attr.attributes[name] = nil
  return color
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

local function process(div)
  if div.attr.classes[1] ~= "box" then return nil end
  table.remove(div.attr.classes, 1)

  local title = popAndStripBlockQuoteElementFromDiv(div, 1)
  local bottom = popAndStripBlockQuoteElementFromDiv(div, #div.content)

  local fillColor
  local borderColor
  local admonitionMode, class = isInAdmonitionMode(div)

  if (admonitionMode) then
    print('mode: '..class)
    borderColor = getColorFromClass(class)
  else
    fillColor = popAttrFromDiv(div, 'fillcolor')
    borderColor = popAttrFromDiv(div, 'bordercolor')
  end

  local options = { }
  local latexFillColorCmd = ''
  local latexBorderColorCmd = ''
  if (not isempty(fillColor)) then
    local fc = fillColor:gsub('#', '')
    latexFillColorCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', fc, fc:upper())
    table.insert(options, 'colback=c_'..fc)
  end
  if (not isempty(borderColor)) then
    local bc = borderColor:gsub('#', '')
    latexBorderColorCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', bc, bc:upper())
    table.insert(options, 'colframe=c_'..bc)
  end
  if (not isempty(title)) then
    table.insert(options, 'title='..pandoc.utils.stringify(title))
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
