-- DEFINES
ANT_HEIGHT = 9
ANT_WIDTH = 16

local JUMP_DEAD = 0
local JUMP_READY = 1
local JUMPING = 2

local JUMP_UP = -4
local JUMP_DOWN = 4
local SHORT_UP = -2
local SHORT_DOWN = 2
local JUMP_HEIGHT = 20

-- Stored in antDeltaX to indicate the map should scroll rather than the ant moving
SCROLL_FLAG = 0xCC

ant = {}

--
function ant.init()

	ant.jumpState = JUMP_READY
	ant.jumpElevation = 0

	ant.x = 0
	ant.y = 0
	ant.deltaX = 0
	ant.deltaY = 0
	ant.frame = 1

	ant.images = {globalImages.ant1, globalImages.ant2, globalImages.ant3, globalImages.ant4}

	ant.health = 1

	ant.godMode = false
	
	ant.jumpSound = love.audio.newSource("assets/Jump.wav" , "static")
	ant.hurtSound = love.audio.newSource("assets/Hurt.wav" , "static")

	ant.deathAnim =
	{
		{time = 0, sound = ant.hurtSound, image = nil},
		{time = 0.25, sound = nil, image = ant.frame},
		{time = 0.5, sound = nil, image = nil},
		{time = 0.75, sound = nil, image = ant.frame},
		{time = 1.0, sound = ant.hurtSound, image = nil},
		{time = 1.25, sound = nil, image = ant.frame},
		{time = 1.5, sound = nil, image = nil},
		{time = 1.75, sound = nil, image = ant.frame},
		{time = 2.0, sound = nil, image = nil}
	}
	
	-- print_r(ant.deathAnim)

	ant.deathTimer = 0
	ant.deathAnimIndex = 1
end

-- Normal movement
function ant.move1()
	ant.deltaX = 0

	ant.fall()
	ant.jump()

	if love.keyboard.isDown("right") then
		ant.goRight()
	end

	if love.keyboard.isDown("left") then
		ant.goLeft()
	end

	if ant.deltaX ~= SCROLL_FLAG then
		ant.x = ant.x + ant.deltaX
	end

	-- print("antDeltaY = " .. ant.deltaY)
	ant.y = ant.y + ant.deltaY

	sprites.ant.x = ant.x
	sprites.ant.y = ant.y
	sprites.ant.image = ant.images[ant.frame]
end

--
function ant.jump()
	if love.keyboard.isDown("space") == false then
		ant.fallTest()
		return
	end

	if ant.jumpState == JUMP_DEAD then
		return
	end

	if ant.jumpState == JUMP_READY then
		--print_r(ant)
		love.audio.play(ant.jumpSound)
		ant.jumpElevation = ant.y - JUMP_HEIGHT
	end

	ant.jumpState = JUMPING
	ant.deltaY = JUMP_UP

	if ant.y == ant.jumpElevation then
		ant.jumpState = JUMP_DEAD
		ant.deltaY = SHORT_UP
	end
end

--
function ant.fallTest()
	if ant.jumpState == JUMPING then
		ant.jumpState = JUMP_DEAD
		ant.deltaY = SHORT_UP
		return
	end

	local elevation = map.getFloor(ant.x).elevation

	if ant.y == elevation then
		ant.jumpState = JUMP_READY
		return
	end

	elevation = map.getFloor(ant.x + 12).elevation
	if ant.y == elevation then
		ant.jumpState = JUMP_READY
		return
	end
end

--
function ant.fall()
	if ant.jumpState == JUMPING then
		return false
	end

	local dy = JUMP_DOWN

	if ant.deltaY == SHORT_UP then
		dy = SHORT_DOWN
	end

	ant.deltaY = dy

	-- Ground chunks are 4 pixels wide and the ant is 16 pixels wide.
	-- The ant is always aligned with 4 ground chunks below.
	-- The left most chunk begins at ant.x
	-- THe right most chunk begins at ant.x + 12

	-- Probe ground below left edge of ant
	local floor1 = map.getFloor(ant.x)
	-- print(floorY.." "..ant.y)

	if ant.y == floor1.elevation then
		if floor1.code == PIT_FLAG and ant.godMode == false then
			-- print("dead")
			ant.health = 0
		end

		ant.deltaY = 0
	end

	-- Probe ground below right edge of ant
	local floor2 = map.getFloor(ant.x + 12)

	if ant.y == floor2.elevation then
		if floor2.code == PIT_FLAG and ant.godMode == false then
			-- print("dead")
			ant.health = 0
		end

		ant.deltaY = 0
	end

	if ant.deltaY == JUMP_DOWN then
		ant.jumpState = JUMP_DEAD
	end

	return false
end

--
function ant.goRight()
	-- print("goRight")
	
	if ant.frame == 1 then
		ant.frame = 2
	else
		ant.frame = 1
	end

	-- Get the floor elevation to the right of the ant
	local floorAhead = map.getFloor(ant.x + 16)
	if floorAhead.elevation < ant.y then
		-- Hitting a wall, stop the ant
		return
	end

	ant.deltaX = 4
	if ant.x == RIGHT_EDGE then
		ant.deltaX = SCROLL_FLAG
		-- print(ant.deltaX)
	end

	-- Falling into a right corner. Pop up the ant.
	if ant.y == floorAhead.elevation then
		local floorRight = map.getFloor(ant.x + 12)
		if ant.y < floorRight.elevation then
			ant.deltaY = JUMP_UP
		end
	end
end

--
function ant.goLeft()
	if ant.frame == 3 then
		ant.frame = 4
	else
		ant.frame = 3
	end

	if ant.x == LEFT_EDGE then
		return
	end

	local floorAhead = map.getFloor(ant.x - 4)
	if floorAhead.elevation < ant.y then
		-- Hitting a wall, stop the ant
		return
	end

	ant.deltaX = -4;

	-- Falling into a left corner. Pop up the ant.
	if ant.y == floorAhead.elevation then
		local floorLeft = map.getFloor(ant.x)
		if ant.y < floorLeft.elevation then
			ant.deltaY = JUMP_UP
		end
	end
end

-- Move ant with no world scrolling
function ant.move2()
	ant.deltaX = 0

	ant.fall()
	ant.jump()

	if love.keyboard.isDown("right") then
		ant.goRight()
	end

	-- TODO kludge
	if ant.deltaX == SCROLL_FLAG then
		ant.deltaX = 4
	end

	if love.keyboard.isDown("left") then
		ant.goLeft()
	end

	ant.x = ant.x + ant.deltaX
	ant.y = ant.y + ant.deltaY

	sprites.ant.x = ant.x
	sprites.ant.y = ant.y
	sprites.ant.image = ant.images[ant.frame]
end

-- Slide ant to the left edge of the screen to prepare for a special stage.
function ant.slide()
	-- print("slide ant")
	-- Beep(1);
	ant.x = ant.x - 4
	sprites.ant.x = ant.x
	return ant.x == 0
end

-- TODO this is the same as Fall() but skips
-- calls to GetFloor since the floor in the ManStage
-- is fixed at F0
function ant.fall2()
	if ant.jumpState == JUMPING then
		return
	end

	local dy = JUMP_DOWN

	if ant.deltaY == SHORT_UP then
		dy = SHORT_DOWN
	end

	ant.deltaY = dy

	if ant.y == F0 then
		ant.deltaY = 0
	end

	if ant.deltaY == JUMP_DOWN then
		ant.jumpState = JUMP_DEAD
	end
end

-- Simplified for man stage
function ant.fallTest2()
	if ant.jumpState == JUMPING then
		ant.jumpState = JUMP_DEAD
		ant.deltaY = SHORT_UP
		return
	end

	if ant.y == F0 then
		ant.jumpState = JUMP_READY
		return
	end
end

-- TODO same as Jump() except it does not use jump elevation.
-- The floor height is fixed in the man stage.
function ant.jump2()
	if love.keyboard.isDown("space") == false then
		ant.fallTest2()
		return
	end

	if ant.jumpState == JUMP_DEAD then
		return
	end

	if ant.jumpState == JUMP_READY then
		-- Beep(2);
		love.audio.play(ant.jumpSound)
	end

	ant.jumpState = JUMPING
	ant.deltaY = JUMP_UP

	if ant.y == F0 - 20 then
		ant.jumpState = JUMP_DEAD
		ant.deltaY = SHORT_UP
	end
end

-- Simplified version for man stage
function ant.goRight2()
	if ant.frame == 1 then
		ant.frame = 2
	else
		ant.frame = 1
	end

	ant.deltaX = 4
end

-- Simplified version for man stage
function ant.goLeft2()
	if ant.frame == 3 then
		ant.frame = 4
	else
		ant.frame = 3
	end

	if ant.x == LEFT_EDGE then
		return
	end

	ant.deltaX = -4
end

-- Simplified ant movement for man stage
function ant.move3()
	ant.deltaX = 0

	ant.fall2()
	ant.jump2()
	
	if love.keyboard.isDown("right") then
		ant.goRight2()
	end

	if love.keyboard.isDown("left") then
		ant.goLeft2()
	end

	ant.x = ant.x + ant.deltaX
	ant.y = ant.y + ant.deltaY

	sprites.ant.x = ant.x
	sprites.ant.y = ant.y
	sprites.ant.image = ant.images[ant.frame]
end

-- Death animation
function ant.die(dt)

	local count = #ant.deathAnim

	if ant.deathAnimIndex > count then
		return true
	end

	-- print_r(ant.deathAnim)

	ant.deathTimer = ant.deathTimer + dt
	local index = ant.deathAnimIndex
	local anim = ant.deathAnim[index]

	if ant.deathTimer >= anim.time then
		if anim.sound ~= nil then
			love.audio.play(anim.sound)
		end

		if anim.image == nil then
			sprites.ant = nil
		else
			sprites.ant = {image = ant.images[ant.frame], x = ant.x, y = ant.y}
		end

		ant.deathAnimIndex = index + 1
	end

	return false
end
