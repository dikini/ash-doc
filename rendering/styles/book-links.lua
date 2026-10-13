-- Run before Quarto's filters from the staged book directory.
-- sources.json is the builder's existing record of selected pages: chapter is
-- the staged filename, anchor is its original H1 identifier, and introduction
-- records are the file-backed book parts. No source anchor is renamed.
local epub = quarto.doc.is_format("epub")
local typst = quarto.doc.is_format("typst")
if not epub and not typst then
  return {}
end

local file = assert(io.open("sources.json", "r"))
local sources = quarto.json.decode(file:read("*a"))
file:close()

local anchors, parts = {}, {}
for _, source in ipairs(sources) do
  anchors[source.chapter] = source.anchor
  if source.role == "introduction" then
    parts[source.anchor] = true
  end
end

return {
  Div = function(el)
    -- Quarto's single-file cleanup drops the whole native part Div in EPUB.
    -- Keep its ordinary heading and reader guidance in the reading flow.
    if epub and el.classes:includes("quarto-book-part") then
      return el.content
    end
  end,

  Link = function(el)
    -- The builder stages selected page links as flat filenames. Resolve them
    -- in either direction before Quarto's traversal-dependent book lookup.
    local path, fragment = el.target:match("^([^#]+)#?(.*)$")
    if anchors[path] ~= nil then
      el.target = "#" .. (fragment ~= "" and fragment or anchors[path])
      return el
    end
  end,

  Header = function(el)
    if typst and el.level == 1 and parts[el.identifier] then
      -- The bundled Orange Book filter discards a part H1's identifier.
      -- Render its inlines with Pandoc so formatting and escaping survive,
      -- then attach the original label to our part function's heading.
      local body = pandoc.write(pandoc.Pandoc({pandoc.Plain(el.content)}), "typst")
      body = body:gsub("%s+$", "")
      return pandoc.RawBlock("typst", "#part[" .. body .. "] <" .. el.identifier .. ">")
    end
  end,
}
