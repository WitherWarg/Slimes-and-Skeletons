player = {}

function player:load()
    self.scale = 3
    self.x = WIDTH/2
    self.y = HEIGHT/2
    self.spd = 240

    self.width = 7 * self.scale
    self.height = 5 * self.scale

    
    self.spriteSheet = love.graphics.newImage('/sprites/characters/player.png')
    self.frameWidth = self.spriteSheet:getWidth()/6
    self.frameHeight = self.spriteSheet:getHeight()/10
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    
    self.animations = {}        
        self.animations.down = anim8.newAnimation(g('1-6', 4), 0.2)
        self.animations.right = anim8.newAnimation(g('1-6', 5), 0.2)
        self.animations.left = anim8.newAnimation(g('1-6', 5), 0.2):flipH()
        self.animations.up = anim8.newAnimation(g('1-6', 6), 0.2)

        self.animations.idleDown = anim8.newAnimation(g('1-6', 1), 0.2)
        self.animations.idleRight = anim8.newAnimation(g('1-6', 2), 0.2)
        self.animations.idleLeft = anim8.newAnimation(g('1-6', 2), 0.2):flipH()
        self.animations.idleUp = anim8.newAnimation(g('1-6', 3), 0.2)

        self.animations.strikeDown = anim8.newAnimation(g('1-4', 7), 0.2)
        self.animations.strikeRight = anim8.newAnimation(g('1-4', 8), 0.2)
        self.animations.strikeLeft = anim8.newAnimation(g('1-4', 8), 0.2):flipH()
        self.animations.strikeUp = anim8.newAnimation(g('1-4', 9), 0.2)

        self.animations.dieRight = anim8.newAnimation(g('1-3', 10), 0.8, 'pauseAtEnd')
        self.animations.dieLeft = anim8.newAnimation(g('1-3', 10), 0.8, 'pauseAtEnd'):flipH()

        self.animation = self.animations.idleDown
        self.dir = 'down'

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, 5)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)

    self.hearts:load()
    self.sword:load()
end

function player:update(dt)
    self.sword:update(dt)
    self.dead = self.hearts.hearts == 0

    if self.dead and self.animation.position == 3 then
        if world then
            world:destroy()
            world = nil
        end
        return
    end

    self.animation:update(dt)

    if self.dead then
        if self.dir == 'right' or self.dir == 'down' then
            self.animation = self.animations.dieRight
        else
            self.animation = self.animations.dieLeft
        end
        
        if player.collider then
            player.collider:destroy()
            player.collider = nil
        end
        return
    end

    if self.strike then self.collider:setLinearVelocity(0,0)
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

    if self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local enemy = collision_data.collider:getObject()
        if self.dead then return end

        dx, dy = collision_data.contact:getNormal()
        local scalingFactor = -math.pow(10, 6)

        local dx, dy = dx*scalingFactor, dy*scalingFactor
        self.collider:applyLinearImpulse(dx, dy)

        self.hearts:damage()
    end

    self.x, self.y = self.collider:getPosition()
end

function player:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.scale, self.scale, self.frameWidth/2, self.frameHeight/2)
end

function player:mousepressed()
    self.strike = true
    
    local dx = love.mouse.getX() - WIDTH/2
    local dy = love.mouse.getY() - HEIGHT/2
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
    
    clock.after(self.animation.intervals[#self.animation.frames], function() self.strike = false end)
    self.sword:mousepressed(self.dir)
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
        table.insert(self.animations, anim8.newAnimation(g('1-3', 1), 0.2))
    end
end

function player.hearts:damage()
    self.hp = self.hp - 1
    self.animations[self.hearts]:gotoFrame(3 - self.hp)
    
    if self.hp == 0 then
        self.hearts = self.hearts - 1
        self.hp = 2
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

player.sword = {}

function player.sword:load()
    self.width = 12
    self.height = 60
    self.strike = false
end

function player.sword:update(dt)
    if self.collider and self.collider:enter('Enemy') then
        local collision_data = self.collider:getEnterCollisionData('Enemy')
        local enemy = collision_data.collider:getObject()
        if enemy.state ~= 'idle' then goto continue end

        local dx, dy = collision_data.contact:getNormal()
        dx, dy = -dx, -dy
        local scalingFactor = 100

        if enemy.dir == 'down' then dx = math.abs(dx)
        elseif enemy.dir == 'up' then dx = -math.abs(dx)
        else dy = math.abs(dy) end
        
        local x, y = enemy.collider:getPosition()
        dx = dx * scalingFactor + x
        dy = dy * scalingFactor + y
        enemy.collider:setPosition(dx, dy)
        enemy.x, enemy.y = dx, dy

        enemy.hp = enemy.hp - 1
        if enemy.hp > 0 then enemy.state = 'dmg' end
    end

    ::continue::
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function player.sword:mousepressed(dir)
    self.dir = dir

    clock.script(function(wait)
        local colliderX, colliderY = 0, 0
        local animSpd = player.animation.intervals[2]
        local change = 10

        wait(animSpd)
        self.strike = true

        if self.dir == 'right' then
            colliderX = player.x
            colliderY = player.y - self.width - change*2
        elseif self.dir == 'left' then
            colliderX = player.x - self.height
            colliderY = player.y - self.width - change*2
        elseif self.dir == 'down' then
            colliderX = player.x - self.width - change
            colliderY = player.y - self.height/2
        else
            colliderX = player.x + change
            colliderY = player.y - self.height
        end

        clock.during(player.animation.intervals[3], function()
            if self.dir == 'up' or self.dir == 'down' then
                self.collider = world:newRectangleCollider(colliderX, colliderY, self.width, self.height)
            else
                self.collider = world:newRectangleCollider(colliderX, colliderY, self.height, self.width)
            end
        
            self.collider:setCollisionClass('Sword')
        end)

        wait(animSpd)
        self.strike = false
        
        if self.dir == 'right' then
            colliderX = player.x
            colliderY = player.y
        elseif self.dir == 'left' then
            colliderX = player.x - self.height
            colliderY = player.y
        elseif self.dir == 'down' then
            colliderX = player.x + change
            colliderY = player.y - self.height/2
        else
            colliderX = player.x - self.width - change
            colliderY = player.y - self.height
        end
    end)
end

return player