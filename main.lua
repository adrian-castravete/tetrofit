local viewportConfiguration = {
	width = 360,
	height = 240,
}

local inputConfiguration = {
	keyboard = {
		left = {"left", "a"},
		up = {"up", "w"},
		right = {"right", "d"},
		down = {"down", "s"},
		rotateLeft = {"z", "q"},
		rotateRight = {"x", "e"},
		drop = {"space", "f"},
	},
	joystick = {
		axis = {
			[1] = {
				names = {"left", "right"},
				threshold = 0.5,
			},
			[2] = {
				names = {"up", "down"},
				threshold = 0.5,
			},
		},
		buttons = {
			[1] = "drop",
			[2] = "rotateRight",
			[3] = "rotateLeft",
		},
	},
	touch = {
		controls = {
			{
				kind = "dpad",
				anchor = "ld",
				size = 40,
				gap = 5,
				deadZone = 0.2,
			}, {
				name = "drop",
				anchor = "rd",
				size = 20,
				gapX = 20,
				gapY = 5,
			}, {
				name = "rotateLeft",
				anchor = "rd",
				size = 20,
				gapX = 35,
				gapY = 20,
			}, {
				name = "rotateRight",
				anchor = "rd",
				size = 20,
				gapX = 5,
				gapY = 20,
			},
		},
	},
}

local bootstrap = require("age.bootstrap")
bootstrap("game", viewportConfiguration, inputConfiguration)
