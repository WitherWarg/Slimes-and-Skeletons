enemy = {}
enemy.__index = enemy

--[[
    local statData = { x, y, scale, aggro, attackAggro, hp, spd, width, height }
    local spriteData = { path, rows, columns }
    local animations = {
        name = { frames, row, animSpd, onLoop },
    }
]]

function new(_, statData, spriteData, animations)
    local self = {}
    setmetatable(self, enemy)

    self.aggro = statData.aggro
    self.attackAggro = statData.attackAggro
    self.hp = statData.hp
    self.x = statData.x or player.x + self.aggro
    self.y = statData.y or player.y - self.aggro
    self.spd = statData.spd

    self.width = statData.width * player.scale
    self.height = statData.height * player.scale

    self.spriteSheet = love.graphics.newImage(spriteData.path)
    self.frameWidth = self.spriteSheet:getWidth() / spriteData.rows
    self.frameHeight = self.spriteSheet:getHeight() / spriteData.columns
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, 5)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')

    self.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
        if data.flipH then animation:flipH() end
        self.animations[key] = animation
    end

    self.animation = self.animations.idle
    self.dir = 'right'
    self.state = 'idle'

    return self
end

function enemy:update(dt)
    self.x, self.y = self.collider:getPosition()
    self.state = self:getState()

    if self.state == 'idle' then
        self.animation = self:idle(dt)
    elseif self.state == 'moving' then
        self.animation = self:moving(dt)
    elseif self.state == 'dmg' then
        self.animation = self:dmg(dt)
    elseif self.state == 'attack' and not self.attacking then
        self.animation = self:attack(dt)
    elseif self.state == 'dead' then
        self.animation = self:dead(dt)
    end

    if self.currentState ~= self.state then
        self.currentState = self.state
        self.animation:gotoFrame(1)
    end

    self.animation:update(dt)
    self:setAnimationOrientation()
end

function enemy:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, player.scale, player.scale, self.frameWidth/2, self.frameHeight/2)
end

function enemy:idle(dt)
    self.collider:setLinearVelocity(0, 0)

    return self.animations.idle
end

function enemy:moving(dt)
    local angle = math.atan2(player.y - self.y, player.x - self.x)
    self.collider:setLinearVelocity(self.spd * math.cos(angle), self.spd * math.sin(angle))

    return self.animations.moving
end

function enemy:attack(dt)
    self.attacking = true

    local intervals = self.animations.attack.intervals
    local frames = #self.animations.attack.frames + 1
    local angle = 0
    local spd = 0

    clock.script(function(wait)
        clock.during(intervals[3], function()
            local dx, dy = self.x - player.x, self.y - player.y
            
            local distanceFromPlayer = math.sqrt( dx*dx + dy*dy )
            distanceFromPlayer = ( math.abs(distanceFromPlayer) + 100 ) * distanceFromPlayer / math.abs(distanceFromPlayer)
            
            spd = distanceFromPlayer / (intervals[frames] - intervals[2])
            self.collider:setLinearVelocity(0, 0)

            angle = math.atan2(player.y - self.y, player.x - self.x)
        end)

        wait(intervals[3])

        local resetAttack = function()
            clock.after(2, function()
                self.attacking = false
            end)
        end
        local t1, t2
        
        t1 = clock.during(intervals[frames] - intervals[3], function()
            self.collider:setLinearVelocity(spd * math.cos(angle), spd * math.sin(angle))
        end)

        t2 = clock.during(intervals[frames] - intervals[3] + 2, function()
            if self.collider:enter('Player') then
                self.collider:setLinearVelocity(0, 0)
                resetAttack()

                clock.cancel(t1)
                clock.cancel(t2)
            end
        end, resetAttack)
    end)

    self.animations.attack:gotoFrame(1)
    return self.animations.attack
end

function enemy:dmg(dt)
    return self.animations.dmg
end

function enemy:dead(dt)
    return self.animations.dead
end

function enemy:getState()
    local dx, dy = player.x - self.x, player.y - self.y
    distanceFromPlayer = math.sqrt( dx*dx + dy*dy )
    local colliders = world:queryLine( player.x, player.y, self.x, self.y, {'Wall'} )

    if self.hp == 0 then
        return 'dead'
    elseif (self.state == 'moving' or #colliders == 0) and distanceFromPlayer < self.aggro then
        if self.x < player.x then
            self.dir = 'right'
        else
            self.dir = 'left'
        end

        if distanceFromPlayer < self.attackAggro then
            return 'attack'
        end

        return 'moving'
    else
        return 'idle'
    end
end

function enemy:setAnimationOrientation()
    if self.dir == 'right' and self.animation.flippedH or self.dir == 'left' and not self.animation.flippedH then
        self.animation:flipH()            
    end
end

return setmetatable(enemy, {__call = new})