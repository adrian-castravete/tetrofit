function love.conf(t)
	t.identity = "fkbm-tetrofit"
	--t.version = "11.1" -- be 0.10 friendly
	t.accelerometerjoystick = false
	t.externalstorage = true
	t.gammacorrect = true

	local w = t.window
	w.title = "Tetromino Fit"
	w.icon = "assets/block.png"
	w.width = 720
	w.height = 480
	w.minwidth = 360
	w.minheight = 240
	w.resizable = true
	w.usedpiscale = false
	w.hidpi = false
	w.fullscreentype = "desktop"
	w.fullscreen = true
end
