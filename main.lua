local dtAccumulator = 0
local targetFPS = 24
local targetDelta = 1 / targetFPS

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
	player = world:newRectangleCollider(playerStartX, playerStartY, 28, 28)
	player.isMoving = false
	player.speed = 150
	player.gridX = playerStartX + 15
	player.gridY = playerStartY + 15
	player.targetX = player.gridX
	player.targetY = player.gridY
	player.animation = animations.walk
	player.direction = 1
	player:setFixedRotation(true)
	player:setCollisionClass("Player")

	platforms = {}

	loadMap("aw_level1")
end

function love.update(dt)
	dtAccumulator = dtAccumulator + dt
	while dtAccumulator >= targetDelta do
		updateGame(targetDelta)
		dtAccumulator = dtAccumulator - targetDelta
	end
end

function updateGame(dt)
	world:update(dt)
	gameMap:update(dt)

	if player.isMoving then
		player.animation:update(dt)

		local px, py = player:getPosition()

		local dx = player.targetX - px
		local dy = player.targetY - py
		local distance = math.sqrt(dx * dx + dy * dy)

		if distance < 1 then
			player:setLinearVelocity(0, 0)
			player:setPosition(player.targetX, player.targetY)

			player.gridX = player.targetX
			player.gridY = player.targetY

			player.isMoving = false
			player.animation:gotoFrame(1)
		else
			local dirX = dx / distance
			local dirY = dy / distance

			local moveX = dirX * player.speed * dt
			local moveY = dirY * player.speed * dt

			player:setPosition(px + moveX, py + moveY)
		end
	end

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
	world:draw()
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
	local fps = love.timer.getFPS()
	love.graphics.print("FPS: " .. fps, 10, 20)
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
	-- we add 15 because box2d's set position sets the player's coordinates at the middle
	player:setPosition(playerStartX + 15, playerStartY + 15)
	for i, obj in pairs(gameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end
end

function love.keypressed(key)
	if not player.isMoving then
		local grid = 32

		if key == "d" or key == "right" then
			player.targetX = player.gridX + grid
			player.direction = 1
			player.isMoving = true
		elseif key == "a" or key == "left" then
			player.targetX = player.gridX - grid
			player.direction = -1
			player.isMoving = true
		elseif key == "w" or key == "up" then
			player.targetY = player.gridY - grid
			player.isMoving = true
		elseif key == "s" or key == "down" then
			player.targetY = player.gridY + grid
			player.isMoving = true
		end
	end
end
