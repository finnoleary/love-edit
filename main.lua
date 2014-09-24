function love.load()
	file = io.tmpfile()
	COMMAND = 0
	INSERT = 1
	VISUAL = 2
	COMMAND_GET = 3
	mode = COMMAND
	command_line = "-- COMMAND --"
	command_input = ""

	screen_width = love.window.getWidth()
	screen_height = love.window.getHeight()
	line = 1
	column = 1
	lines = {""}
	love.graphics.setBackgroundColor(33, 11, 22)
end

function love.update(dt)
	
end

function love.keypressed(key, isrep)
	-- print("keypressed: " .. key)
	if mode == INSERT then
		if key == "backspace" and #lines >= 1 then
			if lines[line]:len() == 1 and #lines > 1 then
				line = line - 1
				table.remove(lines, line + 1)
				column = 1
			elseif lines[line]:len() > 0 then
				lines[line] = lines[line]:sub(1, lines[line]:len()-1)
				column = column - 1
			end
		elseif key == "return" then
			table.insert(lines, "")
			line = line + 1

		elseif key == "escape" then
			mode = COMMAND
			command_line = "-- COMMAND --"
		end
	elseif mode == COMMAND_GET then
		-- if key == "backspace" and command_input:len() > 2 then
		-- 	command_input = command_input:sub(1, command_input:len()-2) .. '|'
		if key == "backspace" and command_input:len() > 1 then
			command_input = command_input:sub(1, command_input:len()-1)
		elseif key == "return" then
			-- assert(loadstring(string.sub(command_input, 2, command_input:len()-1)))()
			assert(loadstring(string.sub(command_input, 2)))()
			command_input = ""
		elseif key == "escape" then
			command_input = ""
			mode = COMMAND
		end
	end
end

function love.textinput(key)
	-- print(key)
	if mode == COMMAND then
		if key == "i" then
			mode = INSERT
			command_line = "-- INSERT --"
		elseif key == ":" then
			mode = COMMAND_GET
			command_input = command_input .. key
		end
	elseif mode == COMMAND_GET then
		local x = 0
		-- if command_input:len() > 1 then
		-- 	command_input = command_input:sub(0, command_input:len()-1) 
		-- 					.. key 
		-- 					.. '|'
		-- else
			command_input = command_input:sub(0, command_input:len()) 
							.. key 
		--					.. '|'
		-- end
	elseif mode == INSERT then
		lines[line] = lines[line] .. key
		column = column + 1
	end
end

function love.draw()
	local i = 10
	local inc = 20
	for each, l in pairs(lines) do
		if each == line and mode == INSERT then
			love.graphics.print(l .. "|", 10, i)
		else 
			love.graphics.print(l, 10, i)
		end
		i = i + inc
	end
	love.graphics.print(command_line, 10, screen_height-50)
	love.graphics.print("L: " .. #lines, 140, screen_height-50)
	love.graphics.print("C: " .. column, 180, screen_height-50)
	love.graphics.print(command_input, 10, screen_height-30)
end