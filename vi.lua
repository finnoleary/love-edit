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
	for each, l in pairs(lines) do
		if each == c.line then
			love.graphics.print(l:sub(1, c.column-1) 
								.. "|"
								..lines[c.line]:sub(c.column)
								, 10, i)
		else
			love.graphics.print(l, 10, i)	
		end
		
		i = i + inc
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