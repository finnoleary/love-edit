norm = {
	modename = "Normal",

	cursor = cursor_uno,
	show_line_num = false,
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
		up = "up",
		down = "down",
		left = "left",
		right = "right",
		delete = "backspace",
		newline = "return",
		command_enter = "return",
		command_get = "escape"
	}
}

function norm:onload()
end

function norm:keypress(key, is_repeat)
	local c = norm.cursor
	if key == m.keys.command_get then
		command_input = ""
		command_mode = true
	elseif key == m.keys.delete and #lines >= 1 then
		editor:delete_char(c)
	elseif key == m.keys.newline then
		editor:newline(c)
	elseif key == m.keys.right then
		editor:move_right(c)
	elseif key == m.keys.down then
		editor:move_down(c)
	elseif key == m.keys.up then
		editor:move_up(c)
	elseif key == m.keys.left then
		editor:move_left(c)
	end
end

function norm:command_mode(key, is_repeat)
end

function norm:command_enter(s)
	if s:sub(1, 5) == "write" then
		editor:save_file(s:sub(7))
		return nil
	elseif s:sub(1, 4) == "edit" or s:sub(1, 4) == "open" then
		if s:sub(5, 5) == " " then
			editor:open_file(s:sub(6))
			return nil
		end
	elseif s:sub(1, 4) == "quit" then
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

function norm:textin(key)
	local c = norm.cursor
	if command_mode == false then
		editor:insert(c, key)
	end
end

function norm:draw()
	local c = norm.cursor
	local col = norm.col
	local i = 10
	local inc = 20
	local lineno = m.offset
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
				love.graphics.print(lineno .. "  ", 20, i)
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
	love.graphics.print("Line: " .. c.line, 20, screen_height-50)
	love.graphics.print("Column: " .. c.column, 120, screen_height-50)
	love.graphics.print("Max lines: " .. #lines, 260, screen_height-50)
	if command_mode == true then
		love.graphics.setColor(col.comd.r, col.comd.g, col.comd.b)
		love.graphics.print(">> " .. command_input .. "|", 10, screen_height-30)
	else 
		love.graphics.setColor(col.comd.r, col.comd.g, col.comd.b)
		love.graphics.print(command_input, 10, screen_height-30)
	end
end