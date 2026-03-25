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
	require("player")

	platforms = {}

	loadMap("aw_level1")
	
	dtAccumulator = 0
	targetFPS = 24
	targetDelta = 1 / targetFPS
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

	playerUpdate(dt)
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
	playerDraw()
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
	player:setPosition(playerStartX, playerStartY)
	for i, obj in pairs(gameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x + (obj.width / 2), obj.y + (obj.height / 2), obj.width, obj.height)
	end
end

function love.keypressed(key)
	if not player.isMoving then
		local grid = 32

		if key == "d" or key == "right" then
			local nextX = player.gridX + grid
			if canMoveTo(nextX, player.gridY) then
				player.targetX = nextX
				player.direction = 1
				player.isMoving = true
			end
		elseif key == "a" or key == "left" then
			local nextX = player.gridX - grid
			if canMoveTo(nextX, player.gridY) then
				player.targetX = nextX
				player.direction = -1
				player.isMoving = true
			end
		elseif key == "w" or key == "up" then
			local nextY = player.gridY - grid
			if canMoveTo(player.gridX, nextY) then
				player.targetY = nextY
				player.isMoving = true
			end
		elseif key == "s" or key == "down" then
			local nextY = player.gridY + grid
			if canMoveTo(player.gridX, nextY) then
				player.targetY = nextY
				player.isMoving = true
			end
		end
	end
end

function canMoveTo(x, y) 
    local colliders = world:queryRectangleArea(x - 14, y - 14, 28, 28, {"Platform"})
    return #colliders == 0
end
