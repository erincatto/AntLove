------------------ Shoe Stage ---------------------

local SHOE_SPACE = 20
local SHOE_1X = 24
local SHOE_2X = (SHOE_1X + SHOE_SPACE)
local SHOE_3X = (SHOE_2X + SHOE_SPACE)
local SHOE_4X = (SHOE_3X + SHOE_SPACE)

local SHOE_TOP = 9
local SHOE_BOT = 37

shoe = {}

--
function shoe.init()

	if ant.x > 0 then
		ant.slide()
		return false
	end

	shoe.y1 = SHOE_TOP
	shoe.y2 = SHOE_BOT
	shoe.deltaY = 2

	shoe.image = globalImages.shoe

	sprites.shoe1 = createSprite(shoe.image, SHOE_1X, shoe.y1, 1);
	sprites.shoe2 = createSprite(shoe.image, SHOE_2X, shoe.y2, 1);
	sprites.shoe3 = createSprite(shoe.image, SHOE_3X, shoe.y1, 1);
	sprites.shoe4 = createSprite(shoe.image, SHOE_4X, shoe.y2, 1);

	return true
end

--
function shoe.update()
	ant.move2()

	if shoe.y1 == SHOE_TOP then
		shoe.deltaY = 2
	end

	if shoe.y1 == SHOE_BOT then
		shoe.deltaY = -2
	end

	shoe.y1 = shoe.y1 + shoe.deltaY
	shoe.y2 = shoe.y2 - shoe.deltaY

	sprites.shoe1.y = shoe.y1
	sprites.shoe2.y = shoe.y2
	sprites.shoe3.y = shoe.y1
	sprites.shoe4.y = shoe.y2

	return ant.x == (128 - 16)	
end

--
function shoe.finish()
	sprites.shoe1 = nil
	sprites.shoe2 = nil
	sprites.shoe3 = nil
	sprites.shoe4 = nil
end
