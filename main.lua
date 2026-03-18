function love.load()
	love.window.setMode(1000, 768, { resizable = true, vsync = 0, minwidth = 400, minheight = 300 })

	wf = require("library/windfield/windfield")

	world = wf.newWorld(0, 0, true)
	world:setQueryDebugDrawing(true)
	world:addCollisionClass("Platform")
	world:addCollisionClass("Player")

	box = world:newRectangleCollider(300, 100, 80, 80)
	box.speed = 240
	box:setFixedRotation(true)
	box:setCollisionClass("Player")

	platform = world:newRectangleCollider(100, 300, 500, 100)
	platform:setType("static")
	platform:setCollisionClass("Platform")
end

function love.update(dt)
	world:update(dt)

	local px, py = box:getPosition()
	if love.keyboard.isDown("d") then
		box:setX(px + box.speed * dt)
	elseif love.keyboard.isDown("a") then
		box:setX(px - box.speed * dt)
	elseif love.keyboard.isDown("s") then
		box:setY(py + box.speed * dt)
	elseif love.keyboard.isDown("w") then
		box:setY(py - box.speed * dt)
	end
end

function love.draw()
	world:draw()
end
