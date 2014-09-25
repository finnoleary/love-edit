-- convention: c stands for cursor, s stands for string

editor = {}

function editor:insert(c, s)
	if c.column < lines[c.line]:len() then
		lines[c.line] = lines[c.line]:sub(1, c.column)
						.. s
						.. lines[c.line]:sub(c.column+1)
		c.column = c.column + s:len()
	else
		lines[c.line] = lines[c.line] .. s
		c.column = c.column + s:len()
	end
end

function editor:append(c, s)
	lines[c.line] = lines[c.line] .. s
end

function editor:newline(c)
	table.insert(lines, "")
	c.line = c.line + 1
	c.column = 1
end

function editor:delete_char(c)
	if c.column == 1 and #lines > 1 then
		c.line = c.line - 1
		table.remove(lines, c.line + 1)
		c.column = lines[c.line]:len()

	elseif c.column < lines[c.line]:len() then
		lines[c.line] = lines[c.line]:sub(1, c.column-1)
						.. lines[c.line]:sub(c.column+1)
		c.column = c.column - 1

	elseif lines[c.line]:len() > 0 then
		lines[c.line] = lines[c.line]:sub(1, lines[c.line]:len()-1)
		c.column = c.column - 1
	end
end

function editor:move_right(c)
	if c.column <= lines[c.line]:len() then
		c.column = c.column - 1
	end
end

function editor:move_left(c)
	if c.column > 1 then
		c.column = c.column + 1
	end
end

function editor:move_down(c)
	if c.line < #lines then
		c.line = c.line + 1
		if lines[c.line]:len() < c.column then
			c.column = lines[c.line]:len()+1
		end
	end
end

function editor:move_up(c)
	if c.line > 1 then
		c.line = c.line - 1
		if lines[c.line]:len() < c.column then
			c.column = lines[c.line]:len()+1
		end
	end
end

function editor:new_file(filename)
	local file = io.open(filename, "r+")
	local buffer = {}
	local l
	for l in file:lines() do 
		table.insert(buffer, line)
	end
	cursor_uno.line = 1
	cursor_uno.column = 1
	file:close()
	return buffer
end

function editor:save_file(t)
	-- if io.type(t.f) == nil then -- We could use `if not` but I'd rather !risk it
	-- 	file = io.open(t.f, "w+")
	-- else
	local file = io.open(t.f, "w")
--	end
	
	local l
	for l in t.b do 
		file:write(l)
	end
	file:close()
end