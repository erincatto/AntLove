
sprites = {}

-- Init sprites
function initSprites()
	sprites = {}
end

-- Create a new sprite
function createSprite(image, x, y, damage)
	w, h = image:getDimensions()
	return {image = image, x = x, y = y, w = w, h = h, damage = damage}
end

-- Update an existing sprite with new image and coordinates
function updateSprite(sprite, image, x, y)
	sprite.image = image
	sprite.x = x
	sprite.y = y

	w, h = image:getDimensions()
	sprite.w = w
	sprite.h = h
end
