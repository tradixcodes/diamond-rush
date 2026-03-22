function love.load()
	-- library used for world physics it's a better box2d by love
	wf = require("library/windfield/windfield")
	-- tiled map loader and renderer for love
	sti = require("library/Simple-Tiled-Implementation/sti")
	-- we are basically using this library only for the camera capablities
	cameraFile = require("library/hump/camera")
	anim8 = require("library/anim8/anim8")

	--creates a camera object
	cam = cameraFile()
	cam:zoom(2)

	-- creates a physics world, with no gravity on either x or y axis, oh physics calculations stop when the object is at a state of rest
	world = wf.newWorld(0, 0, true)
	-- draws outlines around your physics hitboxes
	world:setQueryDebugDrawing(true)
	world:addCollisionClass("Platform")
	world:addCollisionClass("Player" --[[, { ignores = { "Platform" } }]])

	sprites = {}
	sprites.playerSheet = love.graphics.newImage("sprites/walking_animation.png")

	local grid = anim8.newGrid(32, 33, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

	animations = {}
	animations.walk = anim8.newAnimation(grid("1-3", 1), 0.05)
	-- creates a body
	playerStartX, playerStartY = 32, 192
	player = world:newRectangleCollider(playerStartX, playerStartY, 30, 30)
	player.isMoving = false
	player.speed = 250
	player.animation = animations.walk
	player.direction = 1
	player:setFixedRotation(true)
	player:setCollisionClass("Player")

	platforms = {}

	loadMap("aw_level1")
end

function love.update(dt)
	world:update(dt)
	gameMap:update(dt)

	local px, py = player:getPosition()

	local zoomLevel = 2
	local halfW = (love.graphics.getWidth() / 2) / zoomLevel
	local halfH = (love.graphics.getHeight() / 2) / zoomLevel

	local camX = math.max(halfW, math.min(px, mapWidth - halfW))
	local camY = math.max(halfH, math.min(py, mapHeight - halfH))

	cam:lookAt(camX, camY)
end

function love.draw()
	local px, py = player:getPosition()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["background"])
	gameMap:drawLayer(gameMap.layers["walls"])
	-- world:draw()
	local px, py = player:getPosition()
	player.animation:draw(sprites.playerSheet, px, py, nil, 1 * player.direction, 1, 16, 16.5)
	cam:detach()
	love.graphics.printf(
		"Player Hitbox: " .. math.floor(px) .. ", " .. math.floor(py),
		10,
		10,
		love.graphics.getWidth(),
		"left"
	)
end

function spawnPlatform(x, y, width, height)
	if width > 0 and height > 0 then
		local platform = world:newRectangleCollider(x, y, width, height, { collision_class = "Platform" })
		platform:setType("static")
		table.insert(platforms, platform)
	end
end

function loadMap(mapName)
	gameMap = sti("maps/" .. mapName .. ".lua")

	mapWidth = gameMap.width * gameMap.tilewidth
	mapHeight = gameMap.height * gameMap.tileheight

	for i, obj in pairs(gameMap.layers["start"].objects) do
		playerStartX = obj.x
		playerStartY = obj.y
	end
	player:setPosition(playerStartX + 15, playerStartY + 15)
	for i, obj in pairs(gameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end
end

function love.keypressed(key)
	local x, y = player:getPosition()
	local grid = 32

	if key == "d" or key == "right" then
		player:setPosition(x + grid, y)
	elseif key == "a" or key == "left" then
		player:setPosition(x - grid, y)
	elseif key == "w" or key == "up" then
		player:setPosition(x, y - grid)
	elseif key == "s" or key == "down" then
		player:setPosition(x, y + grid)
	end
end
