--[[
  Show a page's featured image at the top of its body, as Hugo Academic did.

  Front matter:
    image: featured.jpg          # also used by listings and social cards
    image-caption: "Photo by …"  # optional, Markdown/HTML allowed
    image-banner: false          # optional, to not show the image on the page

  Enabled for post/, project/ and publication/ by their _metadata.yml.
]]

function Pandoc(doc)
  local meta = doc.meta
  if not meta.image or meta["image-banner"] == false then
    return doc
  end
  if not quarto.doc.is_format("html") then
    return doc
  end

  local src = pandoc.utils.stringify(meta.image)
  local caption = ""
  if meta["image-caption"] then
    caption = pandoc.write(pandoc.Pandoc({ pandoc.Plain(meta["image-caption"]) }), "markdown")
    caption = caption:gsub("%s+$", ""):gsub("\n", " ")
  end

  -- Parse as Markdown so it becomes exactly the figure an author would write
  local figure = pandoc.read(
    string.format('![%s](%s){fig-alt=""}', caption, src),
    "markdown"
  ).blocks
  for i = #figure, 1, -1 do
    table.insert(doc.blocks, 1, figure[i])
  end
  return doc
end
