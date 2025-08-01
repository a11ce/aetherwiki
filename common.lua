local C = {}

function C.normalize(str)
	return str:gsub("^md%-src/", "")
		:gsub("%s+", "-")
		:gsub("%.md$", "")
		:gsub("_", "-")
		:gsub("[^%w%-]", "")
		:lower()
end

function C.exists(name)
	local f = io.open(name, "r")
	return f ~= nil and io.close(f)
end

function C.readBacklinks()
	local backlinks = {}
	local f = io.open("backlinks.csv", "r")
	if not f then
		return backlinks
	end
	for line in f:lines() do
		local dst, count = line:match("^(%S+), (%d+)$")
		if dst and count then
			backlinks[dst] = tonumber(count)
		end
	end
	f:close()
	return backlinks
end

function C.writeBacklinks(backlinks)
	local f = io.open("backlinks.csv", "w")
	for dst, count in pairs(backlinks) do
		f:write(string.format("%s, %d\n", dst, count))
	end
	f:close()
end

function C.getAllPages()
	local pages = {}
	local ls = io.popen("ls -1 md-src/")
	if ls then
		for name in ls:lines() do
			table.insert(pages, C.normalize(name))
		end
	end
	return pages
end

return C
