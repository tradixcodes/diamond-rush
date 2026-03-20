function love.load()
	love.window.setMode(1198, 766, { resizable = true, vsync = 0, minwidth = 400, minheight = 300 })

	wf = require("library/windfield/windfield")
	sti = require("library/Simple-Tiled-Implementation/sti")
	cameraFile = require("library/hump/camera")

	cam = cameraFile()

	world = wf.newWorld(0, 0, true)
	world:setQueryDebugDrawing(true)
	world:addCollisionClass("Platform")
	world:addCollisionClass("Player" --[[, { ignores = { "Platform" } }]])

	playerStartX = 32
	playerStartY = 192

	sprites = {}
	sprites.background = love.graphics.newImage("sprites/background.png")

	player = world:newRectangleCollider(playerStartX, playerStartY, 30, 30)
	player.speed = 240
	player:setFixedRotation(true)
	player:setCollisionClass("Player")

	platforms = {}

	loadMap("aw_level1")
end

function love.update(dt)
	world:update(dt)
	gameMap:update(dt)

	local px, py = player:getPosition()
	cam:lookAt(px, love.graphics.getHeight()/2)

	local vx, vy = 0, 0
	if love.keyboard.isDown("d") then
		vx = player.speed
	elseif love.keyboard.isDown("a") then
		vx = -player.speed
	end

	if love.keyboard.isDown("s") then
		vy = player.speed
	elseif love.keyboard.isDown("w") then
		vy = -player.speed
	end

	player:setLinearVelocity(vx, vy)
end

function love.draw()
	love.graphics.draw(sprites.background, 0, 0)
	cam:attach()
		gameMap:drawLayer(gameMap.layers["walls"])
		world:draw()
	cam:detach()
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
	for i, obj in pairs(gameMap.layers["start"].objects) do 
		playerStartX = obj.x
		playerStartY = obj.y
	end
	player:setPosition(playerStartX, playerStartY)
	for i, obj in pairs(gameMap.layers["Platforms"].objects) do
		spawnPlatform(obj.x, obj.y, obj.width, obj.height)
	end
end