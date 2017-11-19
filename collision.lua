-- Collide the ant with stuff, account for damage

-- Test the overlap of two sprites
function testOverlap(sprite1, sprite2)

	-- print_r(sprite1)
	-- print_r(sprite2)
	if sprite1.x >= sprite2.x + sprite2.w then
		return false
	elseif sprite1.y >= sprite2.y + sprite2.h then
		return false
	elseif sprite2.x >= sprite1.x + sprite1.w then
		return false
	elseif sprite2.y >= sprite1.y + sprite1.h then
		return false
	else
		-- print("collided")
		-- print_r(sprite1)
		-- print_r(sprite2)
		return true
	end

end

-- Collide the ant with stuff
function collideAnt()

	for i = 1,#raids do
		local r = raids[i]
		if testOverlap(sprites.ant, raids[i]) == true then
			return true
		end
	end

	for name, sprite in pairs(sprites) do
		if sprite.damage > 0 and testOverlap(sprites.ant, sprite) then
			return true
		end
	end

	return false
end
