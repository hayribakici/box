-- lua filter for creating boxes around text in Markdown.
-- Copyright (C) 2023 Onur Hayri Bakici, released under MIT license


function raw_tex(t)
  return pandoc.RawBlock('tex', t)
end

local function isempty(s)
  return s == nil or s == ''
end

local function popAttrFromDiv(div, name)
  -- can be nil
  local color = div.attr.attributes[name] or nil
  div.attr.attributes[name] = nil
  return color
end

local function randomString()
  local r = ""
  for i = 1, 5 do
    r = r .. string.char(math.random(65, 65 + 25)):lower()
  end
  return r
end

local function process(div)
  if div.attr.classes[1] ~= "box" then return nil end
  table.remove(div.attr.classes, 1)

  local title = ""
  if div.content[1].t == "BlockQuote" then
    title = pandoc.utils.stringify(table.remove(div.content, 1))
  end

  local content = div.content

  local fillColor = popAttrFromDiv(div, 'fillcolor')
  local borderColor = popAttrFromDiv(div, 'bordercolor')

  local options = { }
  local latexFillColorCmd = ''
  local latexBorderColorCmd = ''
  if (fillColor ~= nil) then
    local fc = fillColor:gsub('#', '')
    latexFillColorCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', fc, fc:upper())
    table.insert(options, 'colback=c_'..fc)
  end
  if (borderColor ~= nil) then
    local bc = borderColor:gsub('#', '')
    latexBorderColorCmd = string.format('\\definecolor{c_%s}{HTML}{%s}', bc, bc:upper())
    table.insert(options, 'colframe=c_'..bc)
  end
  if (not isempty(title)) then
    table.insert(options, string.format("title=%s", title))
  end

  local result = {
    raw_tex(latexFillColorCmd),
    raw_tex(latexBorderColorCmd),
    raw_tex(string.format('\\begin{tcolorbox}[%s]', table.concat(options, ','))),
  }
  for i = 1, #content do
    table.insert(result, content[i])
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
