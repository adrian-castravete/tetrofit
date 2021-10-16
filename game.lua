local lg = love.graphics
local images = {
	empty = lg.newImage("assets/empty.png"),
	fixed = lg.newImage("assets/fixed-block.png"),
	block = lg.newImage("assets/block.png"),
	pointer = lg.newImage("assets/pointer.png"),
}

local consts = {
	mapWidth = 10,
	mapHeight = 10,
}

local age = require("age")

age.thing {
	name = "block",
	cx = 0,
	cy = 0,
	x = 0,
	y = 0,
	ox = 0,
	oy = 0,
	image = images.fixed,
	layer = "bk",

	reposition = function (e)
		e.x = e.cx * 16
		e.y = e.cy * 16
	end,

	init = function (e)
		e:reposition()
	end,

	system = function (e)
		lg.draw(e.image, e.ox+e.x, e.oy+e.y)
	end,
}

age.thing {
	name = "player",
	parents = {"block"},
	cx = 5,
	cy = 5,
	debounceTimeout = 0.4,
	debounce = {},
	buttons = {},
	obuttons = {},
	messages = {"btnPressed", "btnReleased", "setOffset"},

	init = function (e)
		local p = {0, 0}
		local bs = {p}
		local function addBlock(p)
			local x = p[1]
			local y = p[2]
			local ds = {}
			local function checkDir(dx, dy)
				local nx = x + dx
				local ny = y + dy
				local found = false
				for i=1, #bs do
					local ox = bs[i][1]
					local oy = bs[i][2]
					if nx == ox and ny == oy then
						found = true
					end
				end
				if not found then
					ds[#ds + 1] = {nx, ny}
				end
			end
			checkDir(-1, 0)
			checkDir(0, -1)
			checkDir(1, 0)
			checkDir(0, 1)
			bs[#bs + 1] = ds[math.random(1, #ds)]
		end
		addBlock(p)
		addBlock(p)
		addBlock(bs[math.random(1, #bs)])
		e.blocks = bs
	end,

	system = function (e, isActive, dt)
		if not e.ready then
			e.ready = true
			age.message("playerOnline", e.id)
		end

		e:handleButtons(dt)

		for _, b in ipairs(e.blocks) do
			local x, y = b[1], b[2]
			lg.draw(images.pointer,
			e.ox + (e.cx + x) * 16,
			e.oy + (e.cy + y) * 16)
		end
	end,

	fit = function (e, dx, dy)
		for _, b in ipairs(e.blocks) do
			local x, y = b[1], b[2]
			if e.cx + x + dx < 1 or e.cy + y + dy < 1 or
				e.cx + x + dx > consts.mapWidth or
				e.cy + y + dy > consts.mapHeight then
				return false
			end
		end
		return true
	end,

	refit = function (e)
		for _, b in ipairs(e.blocks) do
			local x = b[1]
			local y = b[2]
			if e.cx + x < 1 then
				e.cx = 1 - x
			end
			if e.cy + y < 1 then
				e.cy = 1 - y
			end
			if e.cx + x > consts.mapWidth then
				e.cx = consts.mapWidth - x
			end
			if e.cy + y > consts.mapHeight then
				e.cy = consts.mapHeight - y
			end
		end
	end,

	handleButtons = function (e, dt)
		local pressed, justPressed = {}, {}
		for key, value in pairs(e.buttons) do
			if value then
				pressed[key] = true
			else
				pressed[key] = false
			end
			if value and not e.obuttons[key] then
				justPressed[key] = true
			else
				justPressed[key] = false
			end
			e.obuttons[key] = value
		end

		local function movement(dir, dx, dy)
			if not e.debounce[dir] then
				e.debounce[dir] = 0
			end
			local dd = e.debounce[dir]
			if pressed[dir] and dd >= e.debounceTimeout then
				if e:fit(dx, dy) then
					e.cx = e.cx + dx
					e.cy = e.cy + dy
				end
				dd = 0
			end
			if not pressed[dir] then
				dd = e.debounceTimeout
			end
			e.debounce[dir] = dd + dt
		end

		local function rotate(dir, dx, dy)
			if justPressed[dir] then
				for i, b in ipairs(e.blocks) do
					e.blocks[i] = {b[2] * dx, b[1] * dy}
				end
				e:refit()
			end
		end

		movement("left", -1, 0)
		movement("up", 0, -1)
		movement("right", 1, 0)
		movement("down", 0, 1)

		rotate("rotateLeft", 1, -1)
		rotate("rotateRight", -1, 1)

		if justPressed["drop"] then
			age.message("placePiece", e.cx, e.cy, e.blocks)
		end
	end,

	btnPressed = function (e, btn)
		e.buttons[btn] = true
	end,

	btnReleased = function (e, btn)
		e.buttons[btn] = false
	end,

	setOffset = function (e, id, x, y)
		if e.id ~= id then return end

		e.ox = x
		e.oy = y
	end,
}

age.thing {
	name = "game-field",
	width = consts.mapWidth,
	height = consts.mapHeight,
	x = (360 - 16*(consts.mapWidth+2)) * 0.5,
	y = (240 - 16*(consts.mapHeight+2)) * 0.5,
	map = {},
	messages = {"playerOnline", "placePiece"},

	init = function (e)
		for j=1, e.height do
			e.map[j] = {}
			for i=1, e.width do
				local c = math.random() < 0.1 and 2 or 0
				e.map[j][i] = c
				if c == 2 then
					age.entity("block", {
						cx = i,
						cy = j,
						ox = e.x,
						oy = e.y,
					})
				end
			end
		end
	end,

	system = function (e)
		for j=1, e.height do
			for i=1, e.width do
				lg.draw(images.empty, e.x + i*16, e.y + j*16)
			end
		end
	end,

	playerOnline = function (e, id)
		age.message("setOffset", id, e.x, e.y)
	end,

	placePiece = function (e, x, y, blocks)
		for _, b in ipairs(blocks) do
			local ox, oy = x+b[1], y+b[2]
			local c = e.map[oy][ox]
			if c == 0 then
				e.map[oy][ox] = 1
				age.entity("block", {
					ox = e.x,
					oy = e.y,
					cx = ox,
					cy = oy,
					image = images.block,
				})
			end
		end
	end,
}

age.scene {
	name = "play",
	layers = {"bg", "bk", "sp"},
	init = function ()
		age.entity("game-field", {
			layer = "bg",
		})
		age.entity("player", {
			layer = "sp",
		})
	end,
}

local function pressed(btn)
	age.message("btnPressed", btn)
end

local function released(btn)
	age.message("btnReleased", btn)
end

local function start()
	age.play("play")
end

local function update(dt)
	age.update(dt)
end

return {
	start = start,
	update = update,
	pressed = pressed,
	released = released,
}
