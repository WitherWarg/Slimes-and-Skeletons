slime = {}

function slime:load()
    self.spd = 50
    self.aggroX = 300
    self.aggroY = self.aggroX
    self.width = 14 * entX
    self.height = 11 * entY
    self.x = player.x + self.aggroX - 50
    self.y = player.y + self.aggroY - 50
    
    self.spriteSheet = love.graphics.newImage('sprites/characters/slime.png')
    self.frameWidth = self.spriteSheet:getWidth()/7
    self.frameHeight = self.spriteSheet:getHeight()/5
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    colliderX = self.x - player.width/2
    colliderY = self.y - player.height/2
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 10)
    self.collider:setFixedRotation(true)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')

    self.x = self.collider:getX()
    self.y = self.collider:getY()

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
    local control = 1
    
    local dx = 0
    if player.x + control > self.x and self.x > player.x - control then
        dx = 0
    else
        dx = aggroX/math.abs(aggroX)
    end
    local dy = 0
    if player.y + control > self.y and self.y > player.y - control then
        dy = 0
    else
        dy = aggroY/math.abs(aggroY)
    end

    aggroX, aggroY = math.abs(aggroX), math.abs(aggroY)
    if aggroX < self.aggroX and aggroY < self.aggroY then
        if self.x < player.x then
            self.animation = self.animations.right 
            self.dir = 'right'
        else
            self.animation = self.animations.left
            self.dir = 'left'
        end
        
        self.x = self.collider:getX() - 0.5 * entX
        self.y = self.collider:getY() - 4 * entY

        if aggroX < 40 * entX and aggroY < 40 * entY then
            self.animation:gotoFrame(1)
        end
        
        local length = math.sqrt(dx*dx + dy*dy)
        self.collider:setLinearVelocity(self.spd * dx/length, self.spd * dy/length)
    else
        if self.dir == 'right' then
            self.animation = self.animations.idle_right
        else
            self.animation = self.animations.idle_left
        end
        self.collider:setLinearVelocity(0, 0)
    end

    self.animation:update(dt)

    if SX == SY then
        self.prevX = self.x
        self.prevY = self.y
    end

    if self.collider:enter('Sword') then
        local collision_data = self.collider:getEnterCollisionData('Sword')

        local dx, dy = collision_data.contact:getNormal()
        dx, dy = dx*-math.pow(10, 4), dy*-math.pow(10, 4)
        
        self.collider:applyLinearImpulse(dx, dy)

        local vx, vy = self.collider:getLinearVelocity()
        self.x = self.collider:getX() - 0.5 * entX + vx * dt
        self.y = self.collider:getY() - 4 * entY + vy * dt
    end
end

function slime:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, entX, entY, self.frameWidth / 2, self.frameHeight / 2)
end

function slime:resize(entX, entY)
    self.aggroX = 300 * entX
    self.aggroY = 300 * entY
    self.width = 14 * entX
    self.height = 11 * entY
    self.x = self.prevX * SX
    self.y = self.prevY * SY

    self.collider:destroy()
    colliderX = self.x - player.width/2
    colliderY = self.y - player.height/2
    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 10)
    self.collider:setObject(self)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')

    self.x = self.collider:getX()
    self.y = self.collider:getY()
end