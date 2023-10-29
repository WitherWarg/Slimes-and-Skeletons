player = {}

function player:load()
    self.x = love.graphics.getWidth()/2
    self.y = love.graphics.getHeight()/2
    self.spd = 400
    self.width = 9 * entX
    self.height = 13 * entY
    self.swordType = 'wood'

    self.spriteSheet = love.graphics.newImage('/sprites/characters/player.png')
    self.frameWidth = self.spriteSheet:getWidth()/6
    self.frameHeight = self.spriteSheet:getHeight()/10

    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = {}
        self.animSpd = 0.2

        self.animations.down = anim8.newAnimation(g('1-6', 4), self.animSpd)
        self.animations.right = anim8.newAnimation(g('1-6', 5), self.animSpd)
        self.animations.left = anim8.newAnimation(g('1-6', 5), self.animSpd):flipH()
        self.animations.up = anim8.newAnimation(g('1-6', 6), self.animSpd)

        self.animations.idleDown = anim8.newAnimation(g('1-6', 1), self.animSpd)
        self.animations.idleRight = anim8.newAnimation(g('1-6', 2), self.animSpd)
        self.animations.idleLeft = anim8.newAnimation(g('1-6', 2), self.animSpd):flipH()
        self.animations.idleUp = anim8.newAnimation(g('1-6', 3), self.animSpd)

        self.animations.strikeDown = anim8.newAnimation(g('1-4', 7), self.animSpd)
        self.animations.strikeRight = anim8.newAnimation(g('1-4', 8), self.animSpd)
        self.animations.strikeLeft = anim8.newAnimation(g('1-4', 8), self.animSpd):flipH()
        self.animations.strikeUp = anim8.newAnimation(g('1-4', 9), self.animSpd)

        self.animation = self.animations.idleDown
        self.dir = 'down'

    local colliderX = self.x - player.width/2 + 0.5 * entX
    local colliderY = self.y - player.height/2 + 4 * entY
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 5)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)
    
    self.x = self.collider:getX()
    self.y = self.collider:getY()
end

function player:update(dt)
    if self.strike then
        self.collider:setLinearVelocity(0, 0)

        self.strikeTimer = self.strikeTimer - dt
        if self.strikeTimer <= 0 then
            self.strike = false
            self.strikeTimer = nil
        end
    else
        local dx,dy = 0,0

        if love.keyboard.isDown("right") or love.keyboard.isDown('d') then
            dx = 1
            self.animation = self.animations.right
            self.dir = 'right'
        end
        if love.keyboard.isDown("left") or love.keyboard.isDown('a') then
            dx = -1
            self.animation = self.animations.left
            self.dir = 'left'
        end
        if love.keyboard.isDown("down") or love.keyboard.isDown('s') then
            dy = 1
            self.animation = self.animations.down
            self.dir = 'down'
        end
        if love.keyboard.isDown("up") or love.keyboard.isDown('w') then
            dy = -1
            self.animation = self.animations.up
            self.dir = 'up'
        end

        local length = math.sqrt(dx^2+dy^2)
        if length ~= 0 then
            dx,dy = dx/length,dy/length
        else
            if self.dir == 'up' then
                self.animation = self.animations.idleUp
            elseif self.dir == 'down' then
                self.animation = self.animations.idleDown
            elseif self.dir =='right' then
                self.animation = self.animations.idleRight
            else
                self.animation = self.animations.idleLeft
            end
        end
        
        self.collider:setLinearVelocity(self.spd * dx, self.spd * dy)

    end
    
    local vx, vy = self.collider:getLinearVelocity()
    self.x = self.collider:getX() - 0.5 * entX + vx * dt
    self.y = self.collider:getY() - 4 * entY + vy * dt
    
    self.animation:update(dt)
    
    if SX == SY then
        self.prevX = self.x
        self.prevY = self.y
    end

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        colliders = {}

        if self.strike then
            local dx, dy = 0, 0
            if player.dir == 'right' then dx = 1 end
            if player.dir == 'left' then dx = -1 end
            if player.dir == 'up' then dy = -1 end
            if player.dir == 'down' then dy = 1 end

            local length = math.sqrt(dx*dx+dy*dy)
            dx, dy = dx/length, dy/length

            local querX = self.x + player.width * dx
            local querY = self.y + player.height * dy
            colliders = world:queryCircleArea(querX, querY, 20, {"Enemy"})
        end

        if #colliders == 0 then
            local dx, dy = collision_data.contact:getNormal()
            dx, dy = dx*-math.pow(10, 10), dy*-math.pow(10, 10)
            
            self.collider:applyLinearImpulse(dx, dy)

            local vx, vy = self.collider:getLinearVelocity()
            self.x = self.collider:getX() - 0.5 * entX + vx * dt
            self.y = self.collider:getY() - 4 * entY + vy * dt
        end
    end
end

function player:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, entX, entY, self.frameWidth/2, self.frameHeight/2)
end

function player:mousepressed()
    self.strike = true
    self.strikeTimer = player.animSpd*4

    local dx = love.mouse.getX() - love.graphics.getWidth() / 2 + self.x - cam.x
    local dy = love.mouse.getY() - love.graphics.getHeight() / 2 + self.y - cam.y
    local angle = math.deg(math.atan2(dy, dx)) - 45
    angle = (angle + 360) % 360

    if 0 <= angle and angle < 90 then
        self.animation = self.animations.strikeDown
        self.dir = 'down'
    elseif 90 <= angle and angle < 180 then
        self.animation = self.animations.strikeLeft
        self.dir = 'left'
    elseif 180 <= angle and angle < 270 then
        self.animation = self.animations.strikeUp
        self.dir = 'up'
    else
        self.animation = self.animations.strikeRight
        self.dir = 'right'
    end

    sword:mousepressed(self.dir, self.swordType)
end

function player:resize(entX, entY)
    self.width = 9 * entX
    self.height = 13 * entY
    self.x = self.prevX * SX
    self.y = self.prevY * SY

    self.collider:destroy()
    local colliderX = self.x - self.width/2 + 0.5 * entX
    local colliderY = self.y - self.height/2 + 4 * entY
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 5)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)

    self.x = self.collider:getX()
    self.y = self.collider:getY()
end