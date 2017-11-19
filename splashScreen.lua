splashScreen = {}

--
function splashScreen.init()
	splashScreen.done = false

	-- Load image
	splashScreen.image = love.graphics.newImage("assets/SplashScreen.png")
	splashScreen.image:setFilter("nearest","nearest")

	-- Play music and loop it.
	music = love.audio.newSource( "assets/Splash.ogg" , "stream" )
	music:setLooping(true)
	love.audio.play(music)
end

--
function splashScreen.update(dt)
	-- nothing to do
end

--
function splashScreen.draw()
	love.graphics.draw(splashScreen.image, 0, 0, 0, 2, 2, 0, 0, 0, 0)
end

--
function splashScreen.keypressed(key)
	-- Done
	splashScreen.done = true
	love.audio.stop()
end
