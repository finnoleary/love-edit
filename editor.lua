-- convention: c stands for cursor, s stands for string

editor = {}

function editor:insert(c, s)
	if c.column < lines[c.line]:len() then
		lines[c.line] = lines[c.line]:sub(1, c.column-1)
						.. s
						.. lines[c.line]:sub(c.column)
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
	if c.column < lines[c.line]:len() then
		table.insert(lines, "")
		c.line = c.line + 1
		lines[c.line] = lines[c.line-1]:sub(c.column+1)
		lines[c.line-1] = lines[c.line-1]:sub(1, c.column)
		c.column = lines[c.line]:len()
	else
		table.insert(lines, "")
		c.line = c.line + 1
		c.column = 1
	end
	
end

function editor:delete_char(c)
	-- this whole thing is a kludge
	if c.column == 1 and #lines > 1 then
		c.line = c.line - 1
		table.remove(lines, c.line + 1)
		c.column = lines[c.line]:len()+1
		return
	end
	if c.column > lines[c.line]:len() then
		c.column = lines[c.line]:len()
	end
	if c.column < lines[c.line]:len() then
		lines[c.line] = lines[c.line]:sub(1, c.column-2)
						.. lines[c.line]:sub(c.column)
		c.column = c.column - 1

	elseif c.column == lines[c.line]:len() then
		lines[c.line] = lines[c.line]:sub(1, lines[c.line]:len()-1)
		c.column = lines[c.line]:len()+1
	end
end

function editor:move_right(c)
	if c.column <= lines[c.line]:len() and c.column >= 1 then
		c.column = c.column + 1
	else
		-- print("Unable to go right!")
		-- print("c.column :: " .. c.column)
		-- print("lines[c.line]:len() :: " .. lines[c.line]:len())
	end
end

function editor:move_left(c)
	if c.column > 1 then
		c.column = c.column - 1
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

function editor:open_file(f)
	if f == "" or f == nil then
		f = current_file
	else
		current_file = f
	end
	local b = {}
	for l in io.lines(f) do 
		table.insert(b, l)
		print(l)
	end
	lines = b
	cursor_uno.line = 1
	cursor_uno.column = 1
end

function editor:save_file(f)
	if f == "" or f == nil then
		f = current_file
	else
		current_file = f
	end
	local file = io.open(f, "w")
	for each, l in pairs(lines) do 
		file:write(l .. "\n")
	end
	file:close()
end

function editor:new_cursor(line, column)
	return {line = line, column = column}
end

function editor:switch_cursor(c)
	m.cursor = c
end

function editor:close()
	love.event.quit()
end