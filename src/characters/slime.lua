slime = {}

function slime:load()
    self.sx, self.sy = player.sx, player.sy
    self.aggro = 250

    self.x = player.x + self.aggro
    self.y = player.y - self.aggro
    self.spd = player.spd/4

    self.width = 14 * self.sx
    self.height = 11 * self.sy
    
    self.hp = 4
    self.dead = false

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

        self.animations.die_right = anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd')
        self.animations.die_left =  anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd'):flipH()
    
    self.animation = self.animations.idle_left
    self.dir = 'left'
end

function slime:update(dt)
    if not self.dead then
        local dx = player.x - self.x
        local dy = player.y - self.y
        local length = math.sqrt(dx*dx+dy*dy)
        local control = 4/9
        
        if player.x + control > self.x and self.x > player.x - control then
            dx = 0
            self.x = player.x + player.cx * player.sx
        else
            dx = dx/math.abs(dx)
        end
        if player.y + control > self.y and self.y > player.y - control then
            dy = 0
            self.y = player.y + player.cy * player.sy
        else
            dy = dy/math.abs(dy)
        end

        self.x = self.collider:getX() - 0.5 * SX
        self.y = self.collider:getY() - 4 * SY

        if length < self.aggro then
            if self.x < player.x then
                self.animation = self.animations.right 
                self.dir = 'right'
            else
                self.animation = self.animations.left
                self.dir = 'left'
            end
            
            if length < math.sqrt(3200) then
                self.animation:gotoFrame(1)
            end

            length = math.sqrt(dx*dx + dy*dy)
            self.collider:setLinearVelocity(self.spd * dx/length, self.spd * dy/length)
        else
            if self.dir == 'right' then
                self.animation = self.animations.idle_right
            else
                self.animation = self.animations.idle_left
            end
            self.collider:setLinearVelocity(0, 0)
        end

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
            
            self.hp = self.hp - 1/2
            if self.hp == 0 then
                self:die()
            end
        end
    end

    self.animation:update(dt)
end

function slime:draw()
    if not (self.dead and self.animation.position == 5) then self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.sx, self.sy, self.frameWidth / 2, self.frameHeight / 2) end
end

function slime:die()
    self.dead = true
    self.collider:destroy()
    if self.dir == 'right' then self.animation = self.animations.die_right
    else self.animation = self.animations.die_left end
end