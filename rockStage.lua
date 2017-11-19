------------------ Rock Stage ---------------------
local ROCK_BOT = (F1 + ANT_HEIGHT - 16 - 2)
local ROCK_TOP = (ROCK_BOT - 16)

local SHORT_UP = -2
local SHORT_DOWN = 2
local JUMP_UP = -4
local JUMP_DOWN = 4

rock = {}

--
function rock.init()

	if ant.x > 0 then
		ant.slide()
		return false
	end

	rock.x = 112
	rock.y = ROCK_TOP - 2
	rock.deltaY = SHORT_UP
	rock.frame = 1
	rock.images = {globalImages.rock1, globalImages.rock2, globalImages.rock3, globalImages.rock4}
	rock.bounceSound = love.audio.newSource("assets/Bounce.wav" , "static")

	sprites.rock = createSprite(rock.images[1], rock.x, rock.y, 1)

	return true
end

--
function rock.update()
	ant.move2()

	local dy = rock.deltaY
	if dy == SHORT_DOWN then
		dy = SHORT_UP
	elseif dy == SHORT_UP then
		dy = SHORT_DOWN
	end

	if rock.y == ROCK_TOP then
		if rock.deltaY == JUMP_UP then
			dy = SHORT_UP
		else
			dy = JUMP_DOWN
		end
	end

	if rock.y == ROCK_BOT then
		if rock.deltaY == JUMP_DOWN then
			dy = SHORT_DOWN
			love.audio.play(rock.bounceSound)
		else
			dy = JUMP_UP
		end
	end

	rock.deltaY = dy

	rock.frame = rock.frame + 1
	if rock.frame == 5 then
		rock.frame = 1
	end

	rock.x = rock.x - 4
	rock.y = rock.y + dy

	sprites.rock.image = rock.images[rock.frame]
	sprites.rock.x = rock.x
	sprites.rock.y = rock.y

	return ant.x == (128-16)
end

--
function rock.finish()
	sprites.rock = nil
end
