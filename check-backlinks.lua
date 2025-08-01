local c = require("common")

function getAllPages()
	local pages = {}
	local ls = io.popen("ls -1 md-src/")
	if ls then
		for name in ls:lines() do
			table.insert(pages, c.normalize(name))
		end
	end
	return pages
end

local pages = getAllPages()
local backlinks = c.readBacklinks()

for _, name in ipairs(pages) do
	local count = backlinks[name] or 0
	if count < 1 then
		print(string.format("🔗 %d backlinks for page %s", count, name))
	end
end
