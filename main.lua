require 'editor'

function love.load()
	love.keyboard.setKeyRepeat(true)

	screen_width = love.window.getWidth()
	screen_height = love.window.getHeight()
	variables()
	require 'vi'
	require 'norm'
	editor:switch_mode(norm)
	love.graphics.setBackgroundColor(33, 11, 22)
	editor:load_init_file()
end

function variables()	
	command_mode = false
	command_input = ""
	buffer_uno = {""}
	current_dir = editor:get_homedir()
	current_file = current_dir .. "filename.txt"
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
			local ci = command_input
			if m:command_enter(command_input) then
				if loadstring(command_input) == nil then
					command_input = "Error with input."
					command_mode = false
				else
					loadstring(command_input)()
					if command_input == ci then
						command_input = ""
					end
					command_mode = false
				end
			else
				if command_input == ci then
					print(ci)
					print(command_input)
					command_input = ""
				end
				command_mode = false
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