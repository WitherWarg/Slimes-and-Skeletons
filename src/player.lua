player = {}

function player:load(x, y)
    self.scale = 3
    self.x = x or WIDTH/2
    self.y = y or HEIGHT/2
    self.spd = 240

    self.width = 7 * self.scale
    self.height = 5 * self.scale

    
    self.spriteSheet = love.graphics.newImage('/sprites/characters/player.png')
    self.frameWidth, self.frameHeight = self.spriteSheet:getWidth()/6, self.spriteSheet:getHeight()/10
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
end

function player:update(dt)
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

    local function damage(dmg, collision_data)
        dx, dy = collision_data.contact:getNormal()
        local scalingFactor = -math.pow(10, 6)
        
        local dx, dy = dx*scalingFactor, dy*scalingFactor
        self.collider:applyLinearImpulse(dx, dy)
        
        self.hearts:damage(dmg)
    end

    if self.dead then return end
    if self.collider:enter('SkeletonSword') then damage(2, self.collider:getEnterCollisionData('SkeletonSword'))
    elseif self.collider:enter('Enemy') then damage(1, self.collider:getEnterCollisionData('Enemy')) end

    self.x, self.y = self.collider:getPosition()
end

function player:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.scale, self.scale, self.frameWidth/2, self.frameHeight/2)
end

function player:mousepressed()
    self.strike = true
    
    local x, y = cam:mousePosition()
    local dx = x - player.x
    local dy = y - player.y
    local angle = math.deg(math.atan2(dy, dx)) - 45
    angle = (angle + 360) % 360
    
    local polygon, width, height = {}, self.frameWidth*self.scale/4, self.frameHeight*self.scale/3
    if 0 <= angle and angle < 90 then
        self.animation = self.animations.strikeDown:clone()
        self.dir = 'down'
    elseif 90 <= angle and angle < 180 then
        self.animation = self.animations.strikeLeft:clone()
        self.dir = 'left'
    elseif 180 <= angle and angle < 270 then
        self.animation = self.animations.strikeUp:clone()
        self.dir = 'up'
    else
        self.animation = self.animations.strikeRight:clone()
        self.dir = 'right'
    end

    local polygon, width, height
    if self.dir == 'right' or self.dir == 'left' then
        width, height = self.frameWidth*self.scale/4, self.frameHeight*self.scale/3

        if self.dir == 'right' then
            polygon = {
                self.x + width, self.y,
                self.x, self.y - height,
                self.x, self.y + height,
            }
        else
            polygon = {
                self.x - width, self.y,
                self.x, self.y - height,
                self.x, self.y + height,
            }
        end
    else
        height, width = self.frameWidth*self.scale/4, self.frameHeight*self.scale/3

        if self.dir == 'down' then
            polygon = {
                self.x + width, self.y,
                self.x - width, self.y,
                self.x, self.y + height,
            }
        else
            polygon = {
                self.x + width, self.y,
                self.x - width, self.y,
                self.x, self.y - height*1.5,
            }
        end
    end

    
    clock.after(self.animation.intervals[#self.animation.frames], function() self.strike = false end)
    
    clock.script(function(wait)
        wait(self.animation.intervals[2])
        
        self.swordCollider = world:newPolygonCollider(polygon)
        self.swordCollider:setType('static')
        self.swordCollider:setCollisionClass('Sword')

        wait(self.animation.intervals[2])
        self.swordCollider:destroy()
    end)
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

function player.hearts:damage(dmg)
    if self.hp - dmg < 0 then
        self.animations[self.hearts]:gotoFrame(#self.animations[self.hearts].frames)
        self.hearts = self.hearts - 1
        self.hp = 2
        dmg = dmg - 2
    end

    if self.hearts == 0 then return end

    self.hp = self.hp - dmg
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

return player