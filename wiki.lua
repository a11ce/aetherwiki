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
	if linksCount < 2 then
		print(
			string.format(
				"🔗 %d outgoing links from page %s",
				linksCount,
				PANDOC_STATE.input_files[1]
			)
		)
	end
	if PANDOC_STATE.input_files[1]:match("index") then
		return doc
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

local attributions -- loaded lazily

-- minimal HTML escape
local function esc(s)
	if not s then
		return ""
	end
	return (
		tostring(s)
			:gsub("&", "&amp;")
			:gsub("<", "&lt;")
			:gsub(">", "&gt;")
			:gsub('"', "&quot;")
	)
end

local function loadAttributions()
	local path = "attribution.txt"
	local map = {}
	local f = io.open(path, "r")
	for line in f:lines() do
		line = (line:gsub("\r", ""))
		local s = line:match("^%s*(.-)%s*$") or ""
		if s ~= "" and not s:match("^#") then
			local key, val = s:match("^([^:]+):%s*(.+)$")
			if key and val then
				key = key:match("^%s*(.-)%s*$")
				val = val:match("^%s*(.-)%s*$")
				map[key] = val
			else
				print(
					string.format(
						"⛔ Bad line in attribution.txt: %s",
						line,
						PANDOC_STATE.input_files[1] or "?"
					)
				)
			end
		end
	end
	f:close()
	return map
end

local function getAttributionFor(src)
	if not attributions then
		attributions = loadAttributions()
	end
	local norm = src:gsub("[?#].*$", "")
	local filename = norm:match("([^/\\]+)$") or norm
	local attr = attributions[filename]
	if not attr or attr == "" then
		print(
			string.format(
				"⛔ %s is missing attribution info in %s",
				filename,
				PANDOC_STATE.input_files[1] or "?"
			)
		)
		return "Missing attribution info. Please contact a11ce to report this."
	end
	if attr == "a11ce" then
		return ""
	end
	return attr
end

function Image(el)
	if not el.classes:includes("fig-right") then
		return el
	end

	local caption_text = pandoc.utils.stringify(el.caption)
	local classes = table.concat(el.classes, " ")
	local title_attr = (el.title and el.title ~= "")
			and (' title="' .. esc(el.title) .. '"')
		or ""
	local attribution = getAttributionFor(el.src)

	local html = string.format(
		'<details class="zoom"><summary>'
			.. '<div class="zoom-img-block">'
			.. '<img src="%s" alt="%s" class="%s"%s />'
			.. "</div>"
			.. '<div class="zoom-info">'
			.. "<figcaption>%s</figcaption>"
			.. "<small>%s</small>"
			.. "</div>"
			.. "</summary></details>",
		esc(el.src),
		esc(caption_text),
		esc(classes),
		title_attr,
		esc(caption_text),
		attribution
	)

	return pandoc.RawInline("html", html)
end
