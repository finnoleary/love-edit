vi = {
	modename = "Vi",

	COMMAND = 0,
	COMMAND_GET = 1,
	INSERT = 2,
	VISUAL = 3,
	VISUAL_LINE = 4,
	command_line = "-- COMMAND --",
	cursor = cursor_uno,

	keys = {
		insert = "i",
		command = "escape",
		command_get = ":",
		up = "k",
		down = "j",
		left = "h",
		right = "l",
		delete = "backspace",
		newline = "return",
		command_enter = "return"
	}
}
function vi:onload()
	vi.mode = vi.COMMAND
end

function vi:keypress(key, is_repeat)
	local c = vi.cursor
	if vi.mode == vi.INSERT then
		if key == m.keys.delete and #lines >= 1 then
			editor:delete_char(c)
		elseif key == m.keys.newline then
			editor:newline(c)
		elseif key == m.keys.command then
			vi.mode = vi.COMMAND
			vi.command_line = "-- COMMAND --"
		end
	end
end

function vi:command_mode(key, is_repeat)
	if key == m.keys.command then
	 	command_input = ""
	 	command_mode = false
	 	vi.mode = vi.COMMAND
		vi.command_line = "-- COMMAND --"
	elseif key == m.keys.command_enter then
		vi.mode = vi.COMMAND
		vi.command_line = "-- COMMAND --"
	end
end

function vi:command_enter(s)
	if s:sub(1, 1) == "w" then
		if s:sub(1, 2) == "wq" then
			editor:save_file(s:sub(4))
			editor:close()
		else
			editor:save_file(s:sub(3))
		end
		return nil
	elseif s:sub(1, 1) == "e" then
		if s:len() > 1 then
			if s:sub(1, 2) == "e " then 
				print(s:sub(3))
				editor:open_file(s:sub(3))
				return nil
			elseif s:sub(1, 5) == "edit " then
				print(s:sub(6))
				editor:open_file(s:sub(6))
				return nil
			end
		end
	elseif s:sub(1, 1) == "q" then
		editor:close()
		return nil
	end
	return true
end

function vi:textin(key)
	local c = vi.cursor
	if vi.mode == vi.COMMAND then
		if key == m.keys.insert then
			vi.mode = vi.INSERT
			vi.command_line = "-- INSERT --"
		elseif key == m.keys.command_get then
			vi.mode = vi.COMMAND_GET
			command_input = ""
			vi.command_line = "-- COMMAND GET --"
			command_mode = true
			-- command_input = command_input .. key
		elseif key == m.keys.right then --and h >= 1 thhen
			-- print("right")
			editor:move_right(c)
		elseif key == m.keys.down then
			-- print("down")
			editor:move_down(c)
		elseif key == m.keys.up then
			-- print("up")
			editor:move_up(c)
		elseif key == m.keys.left then
			-- print("left")
			editor:move_left(c)
		end

	elseif vi.mode == vi.INSERT then
		editor:insert(vi.cursor, key)
	end
end

function vi:draw()
	local c = vi.cursor
	local i = 10
	local inc = 20
	local lineno = 1
	local x
	if m.show_line_num == true then
		x = 40
	else
		x = 10
	end
	for each, l in pairs(lines) do
		if m.show_line_num == true then
			love.graphics.print(lineno .. "  ", 10, i)
		end

		if each == c.line then
			love.graphics.print(l:sub(1, c.column-1) 
								.. "|"
								..lines[c.line]:sub(c.column), 
								x, i)
		else
			love.graphics.print(l, x, i)	
		end
		
		i = i + inc
		lineno = lineno + 1
	end
	love.graphics.print(vi.command_line, 10, screen_height-50)
	love.graphics.print("L: " .. c.line, 140, screen_height-50)
	love.graphics.print("C: " .. c.column, 200, screen_height-50)
	love.graphics.print("LL: " .. #lines, 260, screen_height-50)
	if command_mode == true then
		love.graphics.print(":" .. command_input .. "|", 10, screen_height-30)
	else 
		love.graphics.print(command_input, 10, screen_height-30)
	end
end