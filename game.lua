require "ant"
require "collision"
require "map"
require "sprite"
require "faceStage"
require "rockStage"
require "shoeStage"
require "manStage"

-- DEFINES

local NONE = 0

local TILE_X_COUNT = 32
local TILE_Y_COUNT = 16

-- all game data
game = {}

--
function game.init(difficulty)
	game.title = "[ Ant v1.1 ]"

	--print_r(map.state)
	game.difficulty = difficulty

	game.sprayX = 0
	game.sprayY = 0
	game.sprayState = false
	game.spraySound = love.audio.newSource("assets/Shoot.wav" , "static")

	game.step = 0
	game.time = 0
	game.mode = "spawn"
	game.checkpoint = 0
	game.delay = 0
	game.lives = 5
	game.win = false
	game.winTimer = 0

	game.boss = false
	game.bossState = "init"
	game.initBoss = nil
	game.updateBoss = nil
	game.finishBoss = nil
	
	game.pitImage = globalImages.pit
	game.arrowImage = globalImages.arrow
	game.sodImages = {globalImages.sod1, globalImages.sod2, globalImages.sod3, globalImages.sod4}
	game.sprayImage = globalImages.spray
	game.manImages =
	{
		globalImages.man1, globalImages.man2, globalImages.man3, globalImages.man4,
		globalImages.man5, globalImages.man6, globalImages.man8, globalImages.man8
	}
	game.manRightImages = {globalImages.manRight1, globalImages.manRight2}
	game.manLeftImages = {globalImages.manLeft1, globalImages.manLeft2}

	game.blipSound = love.audio.newSource("assets/Blip.wav", "static")
	map.init()

	raids = {}

	initSprites()
	
	--print("game.load")

	--print_r(map)
end

--
function game.update(dt)

	game.time = game.time + dt
	game.step = game.step + 1

	if game.mode == "spawn" then
		game.spawn(dt)
	elseif game.mode == "play" then
		game.play(dt)

		if game.win == true then
			game.mode = "winning"
		elseif ant.health == 0 then
			game.mode = "dying"
		end
	elseif game.mode == "dying" then
		local done = ant.die(dt)
		if done then
			if game.lives > 0 then
				game.initRespawn()
				game.mode = "spawn"
			else
				game.mode = "dead"
			end
		end
	elseif game.mode == "winning" then
		game.winTimer = game.winTimer + dt
		if game.winTimer > 1.0 then
			game.mode = "win"
		end
	end
end

--
function game.draw()
	
	for i = 1, 32 do
		local f = map.loop[i]
		if f.code == SOD_FLAG then
			local y = (f.elevation + ANT_HEIGHT)
			local x = 4 * (i - 1)
			love.graphics.draw(game.sodImages[f.sodIndex], scale * x, scale * y, 0, scale, scale)
		elseif f.code == PIT_FLAG then
			local y = (f.elevation + ANT_HEIGHT - 2)
			local x = 4 * (i - 1)
			love.graphics.draw(game.pitImage, scale * x, scale * y, 0, scale, scale)
		end
	end

	for i,sprite in pairs(sprites) do
		love.graphics.draw(sprite.image, scale * sprite.x, scale * sprite.y, 0, scale, scale)
	end

	for i,raid in pairs(raids) do
		love.graphics.draw(globalImages.raid, scale * raid.x, scale * raid.y, 0, scale, scale)
	end

	local w = love.graphics.getWidth()

	if ant.godMode then
		love.graphics.setColor(0, 0, 0, 128)
		love.graphics.print("god", w - 100, 0)
	end

	love.graphics.setColor(0, 0, 0, 255)
	love.graphics.print(game.lives, w - 20, 0)
end

-- Animate the floor and spawn the ant
function game.spawn(dt)

	-- print("loopIndex = " .. map.state.loopIndex)
	local spawnDelay = 0.05
	game.delay = game.delay + dt
	if game.delay >= spawnDelay then
		--print_r(map.state)

		map.loop[map.state.loopIndex].elevation = F0
		map.loop[map.state.loopIndex].code = SOD_FLAG
		map.loop[map.state.loopIndex].sodIndex = map.state.sodIndex
		map.state.loopIndex = map.state.loopIndex - 1
		game.delay = game.delay - spawnDelay
		love.audio.play(game.blipSound)
	end

	if map.state.loopIndex == 0 then
		game.delay = 0
		game.mode = "play"

		ant.init()
		ant.x = 0
		ant.y = F0

		sprites.ant = createSprite(ant.images[ant.frame], 0, F0, 0)
		sprites.ant.h = ANT_HEIGHT
		sprites.arrow = createSprite(game.arrowImage, 4, 4, 0)
	end
end

--
function game.play(dt)

	game.delay = game.delay + dt
	if game.delay < 0.1 then
		return
	end
	game.delay = game.delay - 0.1

	if game.boss == true then
		if game.bossState == "init" then
			local done = game.initBoss()
			if done == true then
				game.bossState = "active"
				-- print("boss active")
			end
		elseif game.bossState == "active" then
			local done = game.updateBoss()
			if done == true then
				game.bossState = "ending"
				-- print("boss ending")
			end

			local hit = collideAnt()
			if hit and ant.godMode == false then
				ant.health = 0
			end

		elseif game.bossState == "ending" then
			local done = game.endStage()
			if done then
				game.finishBoss()
				game.boss = false
				game.initBoss = nil
				game.updateBoss = nil
				game.finishBoss = nil
				-- print("boss ended")
			end
		end
	else
		ant.move1()

		local hit = collideAnt()
		if hit and ant.godMode == false then
			ant.health = 0
			return
		end

		if game.sprayState == true then
			game.updateSpray()
		end

		--print("SCROLL_FLAG = "..SCROLL_FLAG)
		--print("game "..ant.deltaX)
		if ant.deltaX == SCROLL_FLAG then
			game.moveWorld()
		end
	end
end

--
function game.updateSpray()
	if ant.deltaX == SCROLL_FLAG then
		game.sprayX = game.sprayX - 4
	end

	sprites.man = nil

	game.sprayX = game.sprayX - 4

	if sprites.spray ~= nil then
		sprites.spray.x = game.sprayX
	end

	if game.sprayX <= -16 then
		sprites.spray = nil
		game.sprayState = false
	end
end

--
function game.moveWorld()
	game.scroll(-4)

	if map.state.sodCount == 0 then
		game.newFloor()
	end

	map.state.sodCount = map.state.sodCount - 1

	for i = 1, 31 do
		map.loop[i].elevation = map.loop[i+1].elevation
		map.loop[i].code = map.loop[i+1].code
		map.loop[i].sodIndex = map.loop[i+1].sodIndex
	end

	map.loop[32].elevation = map.state.elevation
	map.loop[32].code = map.state.code
	map.loop[32].sodIndex = map.state.sodIndex

	--print("e: " .. map.state.elevation .. " c: " .. map.state.code .. " s: " .. map.state.sodIndex)
end

--
function game.newFloor()
	map.state.dataIndex = map.state.dataIndex + 2

	--print_r(map.state)
	--print(map.state.dataIndex)
	--print_r(map)

	local elevation = map.data[map.state.dataIndex + 0]
	local code = map.data[map.state.dataIndex + 1]

	map.state.elevation = elevation
	map.state.code = code

	--print(map.data[1])
	--print(elevation)
	--print_r(map.state)

	if code < 0xF0 then
		-- Sod
		map.state.code = SOD_FLAG
		map.state.sodCount = code
	elseif code == PIT_FLAG then
		map.state.code = PIT_FLAG
		map.state.sodCount = 12
	elseif code == RAID_FLAG then
		if game.difficulty > 0 then
			local w, h = globalImages.raid:getDimensions()
			local raid = createSprite(globalImages.raid, 128-4, elevation + 1, 1)
			table.insert(raids, raid)
		end
		map.state.code = SOD_FLAG
		map.state.sodCount = 4
	elseif code == SPRAY_FLAG then
		map.state.sodCount = 1
		map.state.code = SOD_FLAG

		if game.difficulty > 1 then
			game.sprayState = true
			game.sprayX = 128-32
			game.sprayY = elevation - 7
			love.audio.play(game.spraySound)
			sprites.man = createSprite(game.manImages[1], 128-16, game.sprayY, 1)
			sprites.spray = createSprite(game.sprayImage, game.sprayX, game.sprayY, 1)
		end
	elseif code == ROCK_FLAG then
		-- print("rock stage")
		game.initBoss = rock.init
		game.updateBoss = rock.update
		game.finishBoss = rock.finish
		game.boss = true
		game.bossState = "init"
		map.state.code = SOD_FLAG
		map.state.sodCount = 1
	elseif code == SHOE_FLAG then
		-- print("shoe stage")
		game.initBoss = shoe.init
		game.updateBoss = shoe.update
		game.finishBoss = shoe.finish
		game.boss = true
		game.bossState = "init"
		map.state.code = SOD_FLAG
		map.state.sodCount = 1
	elseif code == FACE_FLAG then
		-- print("face stage")
		game.initBoss = face.init
		game.updateBoss = face.update
		game.finishBoss = face.finish
		game.boss = true
		game.bossState = "init"
		map.state.code = SOD_FLAG
		map.state.sodCount = 1
	elseif code == MAN_FLAG then
		-- print("man stage")
		game.initBoss = man.init
		game.updateBoss = man.update
		game.finishBoss = man.finish
		game.boss = true
		game.bossState = "init"
		map.state.code = SOD_FLAG
		map.state.sodCount = 1
	else
		map.state.sodCount = 1
	end
end

--
function game.scroll(deltaX)

	-- todo don't remove spray?
	for i,o in pairs(sprites) do
		if o ~= sprites.ant then
			o.x = o.x + deltaX
			if o.x <= -16 then
				-- print("removing "..i)
				sprites[i] = nil
			end
		end
	end

	-- Loop backwards to allow removal
	for i = #raids, 1, -1 do
		raids[i].x = raids[i].x + deltaX
		if raids[i].x <= -16 then
			table.remove(raids, i)
			-- print("remove raid, count = "..#raids)
		end
	end
end

--
function game.initRespawn()
	-- print("respawn, data index = "..map.state.checkpoint)
	map.state.dataIndex = map.state.checkpoint
	map.state.loopIndex = 32
	map.state.sodCount = 0
	map.state.elevation = F0
	game.lives = game.lives - 1
	game.boss = false
	initSprites()
	raids = {}

	for i = 1, 32 do
		map.loop[i] = {elevation = F0, code = NONE_FLAG, sodIndex = 1}
	end
end

------- Boss Stages Common --------

-- Returns true if the scrolling is done.
function game.endStage()

	-- Advance to next sod type
	local sodIndex = map.state.sodIndex + 1
	if sodIndex == 5 then
		sodIndex = 1
	end

	-- Scrolling done?
	if ant.x == 0 then
		map.state.sodIndex = sodIndex

		-- Save checkpoint
		map.state.checkpoint = map.state.dataIndex
		return true
	end

	-- Scroll left 4 pixels
	for i = 1, 31 do
		map.loop[i].elevation = map.loop[i+1].elevation
		map.loop[i].code = map.loop[i+1].code
		map.loop[i].sodIndex = map.loop[i+1].sodIndex
	end

	map.loop[32].elevation = F1
	map.loop[32].code = SOD_FLAG
	map.loop[32].sodIndex = sodIndex

	map.state.elevation = F1
	map.state.code = SOD_FLAG

	--print("e: " .. map.state.elevation .. " c: " .. map.state.code .. " s: " .. sodIndex)

	ant.x = ant.x - 4
	sprites.ant.x = ant.x

	game.scroll(-4)

	-- Beep(1);

	return false
end

------------------ Debug -----------------
function game.keypressed(key)
	if key == "s" then
		print_r(sprites)
	end

	if key == "g" then
		ant.godMode = not ant.godMode
	end
end
