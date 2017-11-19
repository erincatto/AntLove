optionScreen = {}

--
function optionScreen.init()
	optionScreen.done = false
	optionScreen.difficulty = 0
end

--
function optionScreen.update(dt)
	-- nothing to do
end

--
function optionScreen.draw()
	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print("(E)asy", 180, 80)
	love.graphics.print("(M)edium", 180, 120)
	love.graphics.print("(H)ard", 180, 160)
end

--
function optionScreen.keypressed(key)
	if key == "e" then
		optionScreen.difficulty = 0
		optionScreen.done = true
	elseif key == "m" then
		optionScreen.difficulty = 1
		optionScreen.done = true
	elseif key == "h" then
		optionScreen.difficulty = 2
		optionScreen.done = true
	end
end
