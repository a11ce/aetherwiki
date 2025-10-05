local c = require("common")

local pages = c.getAllPages()
local backlinks = c.readBacklinks()

for _, name in ipairs(pages) do
	if not name:match("^meta%-") then
		local count = backlinks[name] or 0
		if count < 2 then
			print(string.format("🔗 %d backlinks for page %s", count, name))
		end
	end
end
