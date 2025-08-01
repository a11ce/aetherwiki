local c = require("common")

local pageLinks = {}

function Link(el)
	if el.classes:includes("wikilink") then
		normalName = c.normalize(el.target:gsub("%.html$", ""))
		pageLinks[normalName] = true
		el.target = normalName .. ".html"
		mdName = "md-src/" .. normalName .. ".md"
		if not c.exists(mdName) then
			print(
				string.format(
					"⛔ %s is a broken link in %s",
					normalName,
					PANDOC_STATE.input_files[1]
				)
			)
		end
	end
	return el
end

function Pandoc(doc)
	local linksCount = 0
	for _ in pairs(pageLinks) do
		linksCount = linksCount + 1
	end
	if linksCount < 1 then
		print(
			string.format(
				"🔗 %d outgoing links from page %s",
				linksCount,
				PANDOC_STATE.input_files[1]
			)
		)
	end
	backlinks = c.readBacklinks()
	for dest, _ in pairs(pageLinks) do
		backlinks[dest] = (backlinks[dest] or 0) + 1
	end
	c.writeBacklinks(backlinks)
	return doc
end

function Meta(meta)
	if meta.title then
		local t = pandoc.utils.stringify(meta.title)
		meta.pagetitle = pandoc.MetaString(t .. " - AetherWiki")
	end
	return meta
end
