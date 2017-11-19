------------------ Face Stage ---------------------

face = {}

--
function face.init()
	face.x = 112
	face.y = F6 + ANT_HEIGHT - 16
	face.frame = 1

	face.images =
	{
		globalImages.face1, globalImages.face2, globalImages.face3, globalImages.face4,
		globalImages.face5, globalImages.face6, globalImages.face8, globalImages.face8
	}

	sprites.face = createSprite(face.images[1], face.x, face.y, 1)

	return true
end

--
function face.update()
	ant.move2()

	local y = map.getFloor(face.x + 12).elevation
	y = y - 7

	if y ~= face.y then
		face.y = face.y + 4
		--Beep(2)
	end

	if face.x == 0 then
		face.x = 112
		face.y = F6 + ANT_HEIGHT - 16
		face.frame = 1
	else
		face.frame = face.frame + 1
		if face.frame == 9 then
			face.frame = 1
		end
		face.x = face.x - 4
	end

	sprites.face.image = face.images[face.frame]
	sprites.face.x = face.x
	sprites.face.y = face.y

	return ant.x == (128 - 16)
end

--
function face.finish()
	sprites.face = nil
end
