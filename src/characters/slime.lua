slime = {}

function slime:load()
    self.sx, self.sy = player.sx, player.sy
    self.spd = 50
    self.aggroX, self.aggroY = 250, 250
    self.width = 14 * self.sx
    self.height = 11 * self.sy
    self.x = player.x + self.aggroX
    self.y = player.y - self.aggroY
    
    self.spriteSheet = love.graphics.newImage('sprites/characters/slime.png')
    self.frameWidth = self.spriteSheet:getWidth()/7
    self.frameHeight = self.spriteSheet:getHeight()/5
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    local colliderX = self.x - player.width/2
    local colliderY = self.y - player.height/2
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 10)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')

    self.animations = {}
        self.animSpd = 0.2
        self.animations.timer = 0

        self.animations.right = anim8.newAnimation(g('1-7', 3), self.animSpd)
        self.animations.left = anim8.newAnimation(g('1-7', 3), self.animSpd):flipH()

        self.animations.idle_right = anim8.newAnimation(g('1-4', 1), self.animSpd)
        self.animations.idle_left = anim8.newAnimation(g('1-4', 1), self.animSpd):flipH()
    
    self.animation = self.animations.idle_left
    self.dir = 'left'
end

function slime:update(dt)
    local aggroX = player.x - self.x
    local aggroY = player.y - self.y
    local control = 2
    
    local dx = 0
    if player.x + control > self.x and self.x > player.x - control then
        dx = 0
        self.x = player.x + 0.5 * player.sx
    else
        dx = aggroX/math.abs(aggroX)
    end
    local dy = 0
    if player.y + control > self.y and self.y > player.y - control then
        dy = 0
        self.y = player.y + 7 * player.sy
    else
        dy = aggroY/math.abs(aggroY)
    end

    self.x = self.collider:getX() - 0.5 * SX
    self.y = self.collider:getY() - 4 * SY

    aggroX, aggroY = math.abs(aggroX), math.abs(aggroY)
    if aggroX < self.aggroX and aggroY < self.aggroY then
        if self.x < player.x then
            self.animation = self.animations.right 
            self.dir = 'right'
        else
            self.animation = self.animations.left
            self.dir = 'left'
        end
        
        if aggroX < 40 * self.sx and aggroY < 40 * self.sy then
            self.animation:gotoFrame(1)
        end

        if self.x ~= player.x or self.y ~= player.x then
            local length = math.sqrt(dx*dx + dy*dy)
            self.collider:setLinearVelocity(self.spd * dx/length, self.spd * dy/length)
        end
    else
        if self.dir == 'right' then
            self.animation = self.animations.idle_right
        else
            self.animation = self.animations.idle_left
        end
        self.collider:setLinearVelocity(0, 0)
    end

    self.animation:update(dt)

    if self.collider:enter('Sword') then
        local collision_data = self.collider:getEnterCollisionData('Sword')

        local dx, dy = collision_data.contact:getNormal()
        dx, dy = -dx, -dy
        if player.dir == 'down' then
            dy = 1
        elseif player.dir == 'up' then
            dy = -1
        elseif player.dir == 'left' then
            dx = -1
        else
            dx = 1
        end

        dx, dy = dx*math.pow(10, 4)*SX, dy*math.pow(10, 4)*SY
        
        self.collider:applyLinearImpulse(dx, dy)

        local vx, vy = self.collider:getLinearVelocity()
        self.x = self.collider:getX() - 0.5 * SX + vx * dt
        self.y = self.collider:getY() - 4 * SY + vy * dt
    end
end

function slime:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.sx, self.sy, self.frameWidth / 2, self.frameHeight / 2)
end

function slime:resize(SX, SY)
    self.sx, self.sy = player.sx, player.sy
    self.aggroX, self.aggroY = self.aggroX*SX, self.aggroY*SY
    self.width = self.width * SX
    self.height = self.height * SY
    self.x, self.y = self.x * SX, self.y * SY

    local colliderX = self.x - self.width/2
    local colliderY = self.y - self.height/2
    self.collider:destroy()
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 10)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')
end