require "splashScreen"
require "optionScreen"
require "game"
require "deathScreen"
require "utilities"
require "winScreen"

-- global image table
globalImages = {}

--
function love.load()
	 
	-- Load images (global assets)
	img_fn =
	{
		"ant1","ant2","ant3","ant4","sod1","sod2","sod3","sod4","arrow","pit",
		"raid","spray","manRight1","manRight2","manLeft1","manLeft2",
		"man1","man2","man3","man4","man5","man6","man7","man8",
		"rock1","rock2","rock3","rock4","shoe",
    	"face1", "face2", "face3", "face4", "face5", "face6", "face7", "face8"
	}

	for _,v in ipairs(img_fn) do
		globalImages[v] = love.graphics.newImage("assets/"..v..".png")
		globalImages[v]:setFilter("nearest","nearest")
	end

	-- Initialize font, and set it.
	font = love.graphics.newFont("assets/font.ttf", 8*scale)
	love.graphics.setFont(font)

	-- define colors (global assets)
	bgcolor = {r=150,g=150,b=150}
	fontcolor = {r=46,g=115,b=46}

	-- initial state
	state = "splash"  

	splashScreen.init()
	-- winScreen.init()
end

--
function love.draw()
	-- Set color
	love.graphics.setColor(bgcolor.r,bgcolor.g,bgcolor.b)

	-- Draw rectangle for background
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	love.graphics.rectangle("fill", 0, 0, width, height)

	-- Return the color back to normal.
	love.graphics.setColor(255,255,255)

	-- Call the state's draw function
	if state == "splash" then
		splashScreen.draw()
	elseif state == "option" then
		optionScreen.draw()
	elseif state == "game" then
		game.draw()
	elseif state == "dead" then
		deathScreen.draw()
	elseif state == "win" then
		winScreen.draw()
	end
end

--
function love.update(dt)
	-- Call the state's update function
	if state == "splash" then
		splashScreen.update(dt)
	elseif state == "option" then
		optionScreen.update(dt)
	elseif state == "game" then
		game.update(dt)
	elseif state == "dead" then
		deathScreen.update(dt)
	elseif state == "win" then
		winScreen.update(dt)
	end

	if state == "splash" and splashScreen.done == true then
		optionScreen.init()
		state = "option"
	elseif state == "option" and optionScreen.done == true then
		game.init(optionScreen.difficulty)
		state = "game"
	elseif state == "game" then
		if game.mode == "dead" then
			deathScreen.init()
			state = "dead"
		elseif game.mode == "win" then
			winScreen.init()
			state = "win"
		end
	elseif state == "dead" and deathScreen.done == true then
		game.init()
		state = "game"
	end
end

--
function love.keypressed(key)

	if key == "escape" then
		love.event.quit()
	end

	-- Call the state's keypressed function
	if state == "splash" then
		splashScreen.keypressed(key)
	elseif state == "option" then
		optionScreen.keypressed(key)
	elseif state == "game" then
		game.keypressed(key)
	elseif state == "dead" then
		deathScreen.keypressed(key)
	end
end
