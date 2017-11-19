winScreen = {}

--
function winScreen.init()
	winScreen.done = false

	-- Load image
	winScreen.image = love.graphics.newImage("assets/WinScreen.png")
	winScreen.image:setFilter("nearest","nearest")

	-- Play music and loop it.
	music = love.audio.newSource( "assets/Win.ogg" , "stream" )
	music:setLooping(true)
	love.audio.play(music)

	local toasts = {
		"Buuuuuuuuurrrrrrp!",
		"Way to go Schmo",
		"Gadzooks, its flat!",
		"Virus Installed",
		"Where's the pretzels?",
		"Don't drink it all!"
	}

	math.randomseed(os.time())
	
	local toastCount = #toasts
	winScreen.toast = toasts[math.random(toastCount)]
end

--
function winScreen.update(dt)
	-- nothing to do
end

--
function winScreen.draw()
	love.graphics.draw(winScreen.image, 0, 0, 0, 2, 2, 0, 0, 0, 0)

	love.graphics.setColor(0, 0, 0, 128)
	love.graphics.print(winScreen.toast, 20, 20)
end

--
function winScreen.keypressed(key)
	-- Done
	winScreen.done = true
	love.audio.stop()
end
