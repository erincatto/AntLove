scale = 4
-- This makes Sublime output from Love2D immediately
io.stdout:setvbuf("no")
function love.conf(t)
	t.window.width  = 128 * scale
	t.window.height = 64 * scale
	t.window.title  = "Ant"
end
