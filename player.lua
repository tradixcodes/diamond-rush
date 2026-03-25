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
player.grounded = true
player:setFixedRotation(true)
player:setCollisionClass("Player")

function playerUpdate(dt) 
    if player.body then 
        local colliders = world:queryRectangleArea(player:getX() - 14, player:getY() + 14, 28, 2, {"Platform"})
        if #colliders > 0 then
            player.grounded = true
        else
            player.grounded = false
        end
    end
    if player.isMoving then
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
        player.animation:update(dt)
	end
end

function playerDraw() 
    local px, py = player:getPosition()
	player.animation:draw(sprites.playerSheet, px, py, nil, 1 * player.direction, 1, 16, 16.5)
end