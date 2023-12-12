enemy = {}
enemy.__index = enemy

local function new(statData, spriteData, animations)
    local self = {}
    setmetatable(self, enemy)

    self.x, self.y = statData.x, statData.y
    self.ox, self.oy = self.x, self.y
    
    self.aggro = statData.aggro
    self.attackAggro = statData.attackAggro
    
    self.spd = statData.spd
    self.hp = statData.hp
    self.dir = 'right'

    self.width = statData.width * player.scale
    self.height = statData.height * player.scale

    self.spriteSheet = love.graphics.newImage(spriteData.path)
    self.frameWidth = self.spriteSheet:getWidth() / spriteData.rows
    self.frameHeight = self.spriteSheet:getHeight() / spriteData.columns
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, spriteData.colliderCut)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')

    self.animations = {}
    for key, data in pairs(animations) do
        self.animations[key] = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
    end

    return self
end

function enemy:update(dt)
    self.x, self.y = self.collider:getPosition()
    self.state = self:getState()

    if self.state == 'idle' then
        self.animation = self:idle()
    elseif self.state == 'attack' then
        self.animation = self:attack()
    elseif self.state == 'moving' then
        self.animation = self:moving()
    elseif self.state == 'dmg' then
        self.animation = self:dmg()
    elseif self.state == 'dead' then
        self.animation = self:dead()
    end

    if self.currentState ~= self.state and self.state ~= '' then
        if self.state == 'idle' then
            self.ox, self.oy = self.x, self.y
        end
        
        self.currentState = self.state
        self.animation:gotoFrame(1)
    end

    self.animation:update(dt)
    self:setAnimationOrientation()
end

function enemy:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, player.scale, player.scale, self.frameWidth/2, self.frameHeight/2)
end


function enemy:idle()
    self.collider:setLinearVelocity(0, 0)

    return self.animations.idle
end

function enemy:moving()
    local angle = math.atan2(player.y - self.y, player.x - self.x)
    self.collider:setLinearVelocity(self.spd * math.cos(angle), self.spd * math.sin(angle))

    return self.animations.moving
end

function enemy:attack()
    self.attacking = true

    local intervals = self.animations.attack.intervals
    local frames = #self.animations.attack.frames + 1
    local attackFunction, angle, spd

    local calculationBeforeAttack = clock.during(intervals[4], function()
        
        local dx, dy = self.x - player.x, self.y - player.y
        if math.sqrt( dx*dx + dy*dy ) > 150 then
            return
        end

        local distanceFromPlayer = math.sqrt( dx*dx + dy*dy )
        distanceFromPlayer = ( math.abs(distanceFromPlayer) + self.attackAggro ) * distanceFromPlayer / math.abs(distanceFromPlayer)
        spd = distanceFromPlayer / (intervals[frames] - intervals[4])
        angle = math.atan2(player.y - self.y, player.x - self.x)
        
        self.collider:setLinearVelocity(0, 0)

        if self.x < player.x then
            self.dir = 'right'
        else
            self.dir = 'left'
        end

    end, function()

        attackFunction = clock.during(intervals[frames] - intervals[4], function()
            self.collider:setLinearVelocity(spd * math.cos(angle), spd * math.sin(angle))
        end, function() self.attacking = false end)

    end)


    clock.during(intervals[frames], function()
        if self.collider:enter('Player') then
            self.attacking = false
            self.collider:setLinearVelocity(0, 0)
            
            local status, errorMessage = pcall(function()
                clock.cancel(attackFunction)
                clock.cancel(calculationBeforeAttack)
            end)

            if not status and errorMessage ~= '/libraries/hump/timer.lua:89: table index is nil' then
                error(errorMessage)
            end

            return
        end
    end)

    return self.animations.attack:clone()
end

function enemy:dmg()
    return self.animations.dmg
end

function enemy:dead()
    return self.animations.dead
end

function enemy:getState()
    local dx, dy = player.x - self.x, player.y - self.y
    distanceFromPlayer = math.sqrt( dx*dx + dy*dy )
    local colliders = world:queryLine( player.x, player.y, self.x, self.y, {'Wall'} )

    if self.hp == 0 then
        return 'dead'
    elseif #colliders == 0 and (distanceFromPlayer < self.aggro or self.currentState == 'moving' or self.currentState == 'attack') then
        if self.attacking then
            return ''
        end
        
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

function enemy:isOnScreen()
    local boolX = cam.x - WIDTH / 2 < self.x and self.x < cam.x + WIDTH / 2
    local boolY = cam.y - HEIGHT / 2 < self.y and self.y < cam.y + HEIGHT / 2
    return boolX and boolY
end

function enemy:setAnimationOrientation()
    if self.dir == 'right' and self.animation.flippedH or self.dir == 'left' and not self.animation.flippedH then
        self.animation:flipH()            
    end
end

return setmetatable(enemy, { __call = function(_, ...) return new(...) end, new = new })