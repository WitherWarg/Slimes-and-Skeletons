enemy = {}
enemy.__index = enemy

-- Todo: create new timer instances in order to cancel all running timers in those intances for managing death
-- Todo: Enemy damage behaviour
-- * Note: Enemies should only damage player when in attack state

local function new(statData, spriteData, animations)
    local self = {}
    setmetatable(self, enemy)

    self.x, self.y = statData.x, statData.y
    self.ox, self.oy = self.x, self.y
    self.spd = statData.spd
    
    self.aggro = statData.aggro
    self.attackAggro = statData.attackAggro
    
    self.hp = statData.hp
    self.maxHp = self.hp
    self.visibility = 100
    
    self.width = statData.width * player.scale
    self.height = statData.height * player.scale
    
    self.spriteSheet = love.graphics.newImage(spriteData.path)
    self.frameWidth = self.spriteSheet:getWidth() / spriteData.rows
    self.frameHeight = self.spriteSheet:getHeight() / spriteData.columns
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    
    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, spriteData.colliderCut)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass('Enemy')
    self.collider:setObject(self)
    
    self.animations = {}
    for key, data in pairs(animations) do
        self.animations[key] = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
    end
    self.dir = 'right'
    
    return self
end

function enemy:update(dt)
    if self.state == 'dead' then
        goto animationUpdate
    end

    self.state = self:getState()
    self.x, self.y = self.collider:getPosition()
    
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
    
    ::animationUpdate::

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
    if self.state == 'dead' then
        flux.to(self, 5, {visibility = 0}):ease('expoin')
    end

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(hsl(0, 0, 100, self.visibility))
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, player.scale, player.scale, self.frameWidth/2, self.frameHeight/2)
    love.graphics.setColor(r, g, b, a)
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
    local attackTimer, angle, spd

    local BeforeAttackTimer = clock.during(intervals[4], function()
        
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

        attackTimer = clock.during(intervals[frames] - intervals[4], function()
            self.collider:setLinearVelocity(spd * math.cos(angle), spd * math.sin(angle))
        end, function() self.attacking = false end)

        self.cancelAttackClocks = function()
            clock.cancel(attackTimer)
            clock.cancel(BeforeAttackTimer)
        end

        self.notAttacking = true
        clock.after(intervals[frames] - intervals[4] + 2, function()
            self.notAttacking = false
        end)

    end)

    clock.during(intervals[frames], function()
        if self.collider:enter('Player') then
            self.attacking = false
            self.collider:setLinearVelocity(0, 0)
            
            pcall(self.cancelAttackClocks)
            return
        end
    end)

    return self.animations.attack:clone()
end

function enemy:dmg(dx, dy)
    if dx and dy and not self.hit then
        self.hit = true
        local s = 100 / self.maxHp
        self.collider:setLinearVelocity(0, 0)
        self.collider:applyLinearImpulse(-dx * s, -dy * s)
        self.hp = self.hp - 1

        clock.after(self.animations.dmg.totalDuration, function()
            self.hit = false
        end)
    end
    
    return self.animations.dmg
end

function enemy:dead()
    if not self.collider:isDestroyed() then
        self.collider:destroy()
        pcall(self.cancelAttackClocks)
    end
    
    if math.floor(self.visibility) == 0 then
        table.remove(self.parent, self.positionInParent)
    end

    return self.animations.die
end

function enemy:getState()
    local dx, dy = player.x - self.x, player.y - self.y
    distanceFromPlayer = math.sqrt( dx*dx + dy*dy )
    local colliders = world:queryLine( player.x, player.y, self.x, self.y, {'Wall'} )

    if self.hp == 0 then
        return 'dead'
    elseif self.hit then
        return 'dmg'
    elseif #colliders == 0 and (distanceFromPlayer < self.aggro or self.currentState == 'moving' or self.currentState == 'attack') then
        if self.attacking then
            return ''
        end
        
        if self.x < player.x then
            self.dir = 'right'
        else
            self.dir = 'left'
        end

        if distanceFromPlayer < self.attackAggro and not self.notAttacking then
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