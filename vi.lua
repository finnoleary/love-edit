vi = {
	modename = "Vi",

	COMMAND = 0,
	COMMAND_GET = 1,
	INSERT = 2,
	VISUAL = 3,
	VISUAL_LINE = 4,
	command_line = "-- COMMAND --",
	cursor = cursor_uno,
	maxlines = 25,
	offset = 1,
	col = {
		back = {r=255, g=255, b=255},
		num = {r=1, g=1, b=1},
		text = {r=1, g=1, b=1},
		stat = {r=1, g=1, b=1},
		comd = {r=1, g=1, b=1}
	},
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
				editor:open_file(s:sub(3))
				return nil
			elseif s:sub(1, 5) == "edit " then
				editor:open_file(s:sub(6))
				return nil
			end
		end
	elseif s:sub(1, 1) == "q" then
		editor:close()
		return nil
	elseif s:sub(1, 2) == "cd" then
		if s:sub(3) == "" or s:sub(3, 4) == " " then
			editor:change_dir("~")
			return nil
		else
			editor:change_dir(s:sub(4))
			return nil
		end
	elseif s == "pwd" then
		editor:current_dir()
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
		elseif key == m.keys.right then
			editor:move_right(c)
		elseif key == m.keys.down then
			editor:move_down(c)
		elseif key == m.keys.up then
			editor:move_up(c)
		elseif key == m.keys.left then
			editor:move_left(c)
		end

	elseif vi.mode == vi.INSERT then
		editor:insert(vi.cursor, key)
	end
end

function vi:draw()
	local c = vi.cursor
	local col = norm.col
	local i = 10
	local inc = 20
	local lineno = 1
	local x

	love.graphics.setBackgroundColor(col.back.r, col.back.g, col.back.b)
	if m.show_line_num == true then
		x = 70
		love.graphics.setColor(0, 0, 0)
		love.graphics.line(x-15, 0, x-15, 540)
	else
		x = 20
	end
	for j = m.offset, m.offset+m.maxlines do
		if j <= #lines then
			if m.show_line_num == true then
				love.graphics.setColor(col.num.r, col.num.g, col.num.b)
				love.graphics.print(lineno .. "  ", 10, i)
			end

			if j == c.line then
				love.graphics.setColor(col.text.r, col.text.g, col.text.b)
				love.graphics.print(lines[c.line]:sub(1, c.column-1) 
									.. "|"
									..lines[c.line]:sub(c.column),
									x, i)
			else
				love.graphics.setColor(col.text.r, col.text.g, col.text.b)
				love.graphics.print(lines[j], x, i)
			end
			
			i = i + inc
			lineno = lineno + 1
		end
	end
	love.graphics.setColor(col.stat.r, col.stat.g, col.stat.b)
	love.graphics.print(vi.command_line, 10, screen_height-50)
	love.graphics.print("Line: " .. c.line, 140, screen_height-50)
	love.graphics.print("Column: " .. c.column, 240, screen_height-50)
	love.graphics.print("Max lines: " .. #lines, 360, screen_height-50)
	if command_mode == true then
		love.graphics.setColor(col.comd.r, col.comd.g, col.comd.b)
		love.graphics.print(":" .. command_input .. "|", 10, screen_height-30)
	else 
		love.graphics.setColor(col.comd.r, col.comd.g, col.comd.b)
		love.graphics.print(command_input, 10, screen_height-30)
	end
end