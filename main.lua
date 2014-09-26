require 'editor'

function love.load()
	file = io.tmpfile()

	screen_width = love.window.getWidth()
	screen_height = love.window.getHeight()
	variables()
	require 'vi'
	require 'norm'
	m = norm
	m:onload()
	love.graphics.setBackgroundColor(33, 11, 22)
end

function variables()	
	command_mode = false
	command_input = ""
	buffer_uno = {""}
	current_file = "/home/fao/Desktop/test.txt"
	lines = buffer_uno
	cursor_uno = {
		line = 1,
		column = 1
	}
end

function love.update(dt)
	
end

function love.keypressed(key, isrep)
	if command_mode == true then
		if key == m.keys.delete then
			command_input = command_input:sub(1, command_input:len()-1)
		elseif key == m.keys.command_enter then
			print(command_input)
			if m:command_enter(command_input) then
				if loadstring(command_input) == nil then
					command_input = "Error with input."
					command_mode = false
				else
					loadstring(command_input)()
					command_input = ""
					command_mode = false
				end
			end
		end
		m:command_mode(key, isrep)
	else
		m:keypress(key, isrep)
	end
end

function love.textinput(key)
	if command_mode == true then
		command_input = command_input:sub(0, command_input:len()) 
						.. key 
	else
		m:textin(key)
	end
end

function love.draw()
	m:draw()
	love.graphics.print("Mode : " .. m.modename, 660, screen_height-50)
end