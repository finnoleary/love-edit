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

function editor:hello()
	print("Hello world")
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
	if c.column < lines[c.line]:len() and c.column > 1 then
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
	-- else
	-- 	print("Unable to go right!")
	-- 	print("c.column :: " .. c.column)
	-- 	print("lines[c.line]:len() :: " .. lines[c.line]:len())
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
		if c.line > m.offset+m.maxlines then
			m.offset = m.offset + 1
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
	-- CHECK TO SEE IF IT'S ALIVE FIRST!
	if f == "" or f == nil then
		f = current_file
	else
		current_file = f
	end
	if f:sub(1, 1) == "~" then
		f = editor:get_homedir() .. f:sub(2)
	elseif not (f:sub(1, 1) == "/") and -- UNIX or NT?
		   not (f:sub(2, 2) == ":" and (f:sub(3, 3) == "\\" or 
		   								f:sub(3, 3) == "/")) then
		f = editor:current_dir() .. "/" .. f
	end
	local b = {}
	for l in io.lines(f) do 
		table.insert(b, l)
	end
	lines = b
	m.cursor.line = 1
	m.cursor.column = 1

end

function editor:save_file(f)
	if f == "" or f == nil then
		f = current_file
	else
		current_file = f
	end
	if f:sub(1, 1) == "~" then
		f = editor:get_homedir() .. f:sub(2)
	elseif not (f:sub(1, 1) == "/") and -- UNIX or NT?
		   not (f:sub(2, 2) == ":" and (f:sub(3, 3) == "\\" or 
		   								f:sub(3, 3) == "/")) then
		f = editor:current_dir() .. "/" .. f
	end
	local file = io.open(f, "w")
	for each, l in pairs(lines) do 
		file:write(l .. "\n")
	end
	file:close()
	if command_mode == true then
		command_input = "Wrote to file: " .. f
	end
end

function editor:new_cursor(line, column)
	return {line = line, column = column}
end

function editor:switch_cursor(c)
	m.cursor = c
end

function editor:switch_mode(mode)
	m = mode
	if m.onload then
		m:onload()
	else
		command_line = "Unable to load mode! onload() missing!"
	end
end

function editor:close()
	love.event.quit()
end

function editor:toggle_lines()
	if m.show_line_num then
		m.show_line_num = false
	end
	if not m.show_line_num then
		m.show_line_num = true
	end
end

function editor:background_colour(r, g, b)
	m.col.back = {r=r, g=g, b=b}
end

-- editor:background_color = editor:background_colour

function editor:text_colour(r, g, b)
	m.col.text = {r=r, g=g, b=b}
end

function editor:linenum_colour(r, g, b)
	m.col.num = {r=r, g=g, b=b}
end

function editor:status_colour(r, g, b)
	m.col.stat = {r=r, g=g, b=b}
end

function editor:command_colour(r, g, b)
	m.col.comd = {r=r, g=g, b=b}
end

function editor:get_os()
	return love.system.getOS()
end

function editor:get_homedir()
	local t = editor:get_os()
	if t == "Linux" or t == "OS X" then
		return os.getenv("HOME")
	elseif t == "Windows" then
		return os.getenv("USERPROFILE")
	end
end

function editor:change_dir(s)
	if s:sub(1, 1) == "~" then
		current_dir = editor:get_homedir() .. s:sub(2)
	else
		current_dir = s
	end
end

function editor:current_dir()
	if command_mode == true then
		command_input = "Current dir: " .. current_dir
	end
	return current_dir
end

function editor:load_init_file()
	local f = editor:get_homedir() .. "/.leinit"
	commands = ""
	for l in io.lines(f) do 
		commands = commands .. l .. "\n"
	end
	editor:execute(commands)
end

function editor:execute(s)
	if loadstring(s) == nil then
		return false
	else
		loadstring(s)()
		return true
	end
end

function editor:interpret(s)
	m:command_enter(s)
end