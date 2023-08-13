-- lua filter for creating boxes around text in Markdown.
-- Copyright (C) 2023 Onur Hayri Bakici, released under MIT license


function raw_tex(t)
  return pandoc.RawBlock('tex', t)
end

local function isempty(s)
  return s == nil or s == ''
end

local function popStringifiedBlockQuoteElementFromDiv(div, index)
  local elem = ''
  if div.content[index].t == "BlockQuote" then
    elem = pandoc.utils.stringify(table.remove(div.content, index))
  end
  return elem
end

local function popAttrFromDiv(div, name)
  -- can be nil
  local color = div.attr.attributes[name] or nil
  div.attr.attributes[name] = nil
  return color
end

local function containsAttribute(div, name)
  return div.attr.attributes[name] ~= nil
end

-- returns a color based on the box type or an empty string
-- from https://stackoverflow.com/questions/37447704/what-is-the-alternative-for-switch-statement-in-lua-language
local function getColorFromType(type)
  case = {
    ['warning'] = function () 
                    return "#E3C414"
                  end,
    ['info'] = function ()
                    return "#7289DA"
                end,
    ['danger'] = function ()
                    return "#ce2029"
                  end,
    ['important'] = function () 
                    return "#00a86b"
                  end,
    ['plain'] = function ()
                    return "#ffffff"
                end,
    default = function ()
                    return ''
              end,
  }
  if (case[type]) then
    return case[type]()
  end
  return case['default']()
end

local function process(div)
  if div.attr.classes[1] ~= "box" then return nil end
  table.remove(div.attr.classes, 1)

  local title = popStringifiedBlockQuoteElementFromDiv(div, 1)
  local bottom = popStringifiedBlockQuoteElementFromDiv(div, #div.content)
    
  local content = div.content
  
  local fillColor = popAttrFromDiv(div, 'fillcolor')
  local borderColor = popAttrFromDiv(div, 'bordercolor')
  if (containsAttribute(div, 'type')) then
    local value = popAttrFromDiv(div, 'type')
    local color = getColorFromType(value)
    if (isempty(color)) then
      print(string.format('[Warning] type %s is not valid. Trying to use the \'bordercolor\' value', value))
    else
      -- overriding the bordercolor attribute
      borderColor = color
    end
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
    table.insert(options, 'title='..title)
  end

  local result = {
    raw_tex(latexFillColorCmd),
    raw_tex(latexBorderColorCmd),
    raw_tex(string.format('\\begin{tcolorbox}[%s]', table.concat(options, ','))),
  }
  for i = 1, #content do
    table.insert(result, content[i])
  end
  if (not isempty(bottom)) then
    table.insert(result, raw_tex('\\tcblower'))
    table.insert(result, pandoc.Para(bottom))
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
