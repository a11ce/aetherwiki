local c = require("common")

local events = {}
for _, name in ipairs(c.getAllPages()) do
	if not name:match("^meta%-") then
		local path = "md-src/" .. name .. ".md"
		for line in io.lines(path) do
			for year in line:gmatch("(%d%d%d)") do
				table.insert(events, {
					year = year,
					name = name,
					line = line,
				})
			end
		end
	end
end

table.sort(events, function(a, b)
	local ay, by = tonumber(a.year), tonumber(b.year)
	if ay ~= by then
		return ay < by
	elseif a.file ~= b.file then
		return a.file < b.file
	else
		return a.line < b.line
	end
end)

local f = io.open("auto-timeline.txt", "w")
for _, e in ipairs(events) do
	f:write(string.format("[[%s]]: %s\n", e.name, e.line))
end
f:close()
