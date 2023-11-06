player = {}

function player:load()
    self.sx, self.sy = 3, 3
    self.x = WIDTH/2
    self.y = HEIGHT/2
    self.spd = 240

    self.width = 7 * self.sx
    self.height = 5 * self.sy

    
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

        self.animations.die_right = anim8.newAnimation(g('1-3', 10), 0.8, 'pauseAtEnd')
        self.animations.die_left = anim8.newAnimation(g('1-3', 10), 0.8, 'pauseAtEnd'):flipH()

        self.animation = self.animations.idleDown
        self.dir = 'down'

    self.cx = 0.5 * self.sx
    self.cy = 6 * self.sy
    local colliderX = self.x - self.width/2 + self.cx
    local colliderY = self.y - self.height/2 + self.cy

    self.collider = world:newBSGRectangleCollider(colliderX, colliderY, self.width, self.height, 5)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)

    self.hearts:load()
end

function player:update(dt)
    if pause then return end

    if self.dead and self.animation.position == 3 then return end

    self.animation:update(dt)

    if self.dead then return end

    if self.strike then
        self.collider:setLinearVelocity(0,0)
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
    
    self.x = self.collider:getX() - self.cx
    self.y = self.collider:getY() - self.cy

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local enemy = collision_data.collider:getObject()
        if enemy.dead then return end

        local dx, dy = collision_data.contact:getNormal()
        dx, dy = -dx*math.pow(10, 10), -dy*math.pow(10, 10)
            
        self.collider:applyLinearImpulse(dx, dy)

        self.hearts:takeDamage()
    end
end

function player:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.sx, self.sy, self.frameWidth/2, self.frameHeight/2)
end

function player:mousepressed()
    self.strike = true
    clock.after(player.animSpd*4, function() self.strike = false end)

    local dx = love.mouse.getX() + self.x - WIDTH/2 - self.x
    local dy = love.mouse.getY() + self.y - HEIGHT/2 - self.y
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

    self.animation:gotoFrame(1)

    sword:mousepressed(self.dir)
end

function player:die()
    self.dead = true
    if self.dir == 'right' or self.dir == 'down' then
        self.animation = self.animations.die_right
    else
        self.animation = self.animations.die_left
    end

    world:destroy()
    for i in ipairs(slimes) do table.remove(slimes, i) end
end

player.hearts = {}

function player.hearts:load()
    self.hp = 2
    self.hearts = 4
    self.maxHearts = self.hearts

    self.spriteSheet = love.graphics.newImage('/sprites/objects/hearts/animated/border/heart_edit.png')
    self.frameWidth = self.spriteSheet:getWidth() / 3
    self.frameHeight = self.spriteSheet:getHeight()
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = {}
    for i=1, self.hearts do
        table.insert(self.animations, anim8.newAnimation(g('1-3', 1), player.animSpd))
    end
end

function player.hearts:takeDamage()
    self.hp = self.hp - 1
    self.animations[self.hearts]:gotoFrame(3 - self.hp)

    if self.hp == 0 then
        self.hearts = self.hearts - 1
        self.hp = 2
    end

    if self.hearts == 0 then
        player:die()
    end
end

function player.hearts:draw()
    for i, animation in ipairs(self.animations) do
        animation:draw(self.spriteSheet, (self.frameWidth+5)*(i-1)*2 + 600, 20, nil, 2, 2)
    end
end

function player.hearts:heal()
    self.hearts = 4
    self.hp = 2

    for i, animation in ipairs(self.animations) do
        animation:gotoFrame(1)
    end
end