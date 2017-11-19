------------------ Man Stage ---------------------

-- Man animation frames
local M1 = 1
local M2 = 2
local M3 = 3
local M4 = 4
local M5 = 5
local M6 = 6
local M7 = 7
local M8 = 8

-- Man x coordinates
local X0 = 72
local X1 = 76
local X2 = 80
local X3 = 84
local X4 = 88
local X5 = 92
local X6 = 96
local X7 = 100
local X8 = 104

-- Man y coordinates
local Y1 = (F0 + ANT_HEIGHT - 16)
local Y2 = (Y1 - 10)
local Y3 = (Y2 - 8)
local Y4 = (Y3 - 6)
local Y5 = (Y3 - 4)

-- Man loop left animation
local loopLeftData =
{
	X8, Y1, M2,
	X7, Y2, M3,
	X6, Y3, M4,
	X5, Y4, M5,
	X4, Y5, M6,
	X3, Y4, M7,
	X2, Y3, M8,
	X1, Y2, M3,
	X0, Y1, M2,
	X0, Y1, M1
}

-- Man loop right animation
local loopRightData =
{
	X0, Y1, M2,
	X1, Y2, M3,
	X2, Y3, M8,
	X3, Y4, M7,
	X4, Y5, M6,
	X5, Y4, M5,
	X6, Y3, M4,
	X7, Y2, M3,
	X8, Y1, M2,
	X8, Y1, M1
}

-- Length of loop data arrays
local LOOP_STEPS = 30

-- Man actions
local LLT = 0	-- loop left
local LRT = 2	-- loop right
local WLT = 4	-- slide left
local WRT = 6	-- slide right
local SPR = 8	-- spray
local PAS = 10	-- pause

-- Man action array
local actions =
{
	LLT, PAS, SPR, WRT, WLT, SPR, LRT, PAS, SPR, LLT,
	WRT, SPR, PAS, LLT, LRT, SPR, WLT, LRT, PAS, SPR
}

man = {}
local spray = {}

--
function man.init()

	if ant.x > 0 then
		ant.slide()
		return false
	end

	man.x = X8
	man.y = Y1
	man.frame = 1
	man.loopCounter = 1
	man.actionCounter = 1
	man.action = 1
	man.delay = 0

	man.images =
	{
		globalImages.man1,
		globalImages.man2,
		globalImages.man3,
		globalImages.man4,
		globalImages.man5,
		globalImages.man6,
		globalImages.man7,
		globalImages.man8
	}

	man.rightImages =
	{
		globalImages.manRight1,
		globalImages.manRight2
	}

	man.leftImages =
	{
		globalImages.manLeft1,
		globalImages.manLeft2
	}

	man.jumpSound = love.audio.newSource("assets/ManJump.wav" , "static")
	man.spraySound = love.audio.newSource("assets/Shoot.wav" , "static")

	spray.image = globalImages.spray
	spray.x = 0
	spray.y = 0

	sprites.man = createSprite(man.images[1], man.x, man.y, 1)

	man.setNext()

	return true
end

--
function man.update()
	ant.move3()

	--print("f "..man.frame..", x "..man.x..", y "..man.y)

	sprites.man.image = man.images[man.frame]
	sprites.man.x = man.x
	sprites.man.y = man.y
	updateSprite(sprites.man, man.images[man.frame], man.x, man.y)

	man.move()
	local done = (ant.x == (128-16))
	if done then
		game.win = true
	end

	return done
end

--
function man.finish()
	-- Beep(2);
	-- Delay(2);
	-- Beep(4);
	-- Delay(4);
	-- Beep(8);
	-- Delay(3);

	sprites.man = nil
end

--
function man.move()
	if man.action == LLT then
		man.loopLeft()
	elseif man.action == LRT then
		man.loopRight()
	elseif man.action == WLT then
		man.walkLeft()
	elseif man.action == WRT then
		man.walkRight()
	elseif man.action == SPR then
		man.pushSpray()
	else
		if man.delay > 0 then
			man.delay = man.delay - 1
		else
			man.setNext()
		end
	end
end

--
function man.setNext()
	man.loopCounter = 1
	man.frame = 1
	man.action = actions[man.actionCounter]
	man.actionCounter = man.actionCounter + 1
	if man.actionCounter > 20 then
		man.actionCounter = 1
	end

	if man.action == SPR then
		spray.x = man.x - 16
		spray.y = man.y

		sprites.spray = createSprite(spray.image, spray.x, spray.y, 1)

		love.audio.play(man.spraySound)
	elseif man.action == PAS then
		man.delay = 5
	end
end

--
function man.walkRight()
	man.y = Y1

	man.frame = man.frame + 1
	if man.frame > 2 then
		man.frame = 1
	end

	man.x = man.x + 4

	if man.x == X8 then
		sprites.man.image = man.images[1]
	else
		sprites.man.image = man.rightImages[man.frame]
	end

	sprites.man.x = man.x
	sprites.man.y = man.y

	if man.x == X8 then
		man.setNext()
	end
end

--
function man.walkLeft()
	man.y = Y1

	man.frame = man.frame + 1
	if man.frame > 2 then
		man.frame = 1
	end

	man.x = man.x - 4

	if man.x == X0 then
		sprites.man.image = man.images[1]
	else
		sprites.man.image = man.leftImages[man.frame]
	end

	sprites.man.x = man.x
	sprites.man.y = man.y

	if man.x == X0 then
		man.setNext()
	end
end

--
function man.loopLeft()

	--print("loop left")

	local x = loopLeftData[man.loopCounter + 0]
	local y = loopLeftData[man.loopCounter + 1]
	local frame = loopLeftData[man.loopCounter + 2]

	-- Update sprite
	sprites.man.x = x
	sprites.man.y = y
	sprites.man.image = man.images[frame]

	man.x = x
	man.y = y
	man.frame = frame

	--print("f "..man.frame..", x "..man.x..", y "..man.y)

	if man.loopCounter == 1 then
		love.audio.play(man.jumpSound)
	end

	man.loopCounter = man.loopCounter + 3

	if man.loopCounter > LOOP_STEPS then
		man.setNext()
	end
end

--
function man.loopRight()

	local x = loopRightData[man.loopCounter + 0]
	local y = loopRightData[man.loopCounter + 1]
	local frame = loopRightData[man.loopCounter + 2]

	-- Update sprite
	sprites.man.x = x
	sprites.man.y = y
	sprites.man.image = man.images[frame]

	man.x = x
	man.y = y
	man.frame = frame

	if man.loopCounter == 1 then
		love.audio.play(man.jumpSound)
	end

	man.loopCounter = man.loopCounter + 3

	if man.loopCounter > LOOP_STEPS then
		man.setNext()
	end
end

--
function man.pushSpray()
	spray.x = spray.x - 4

	if spray.x > -16 and sprites.spray ~= nil then
		sprites.spray.x = spray.x
	else
		sprites.spray = nil
		man.setNext()
	end
end
