player = {}

function player:spawn(x, y)
    self.scale = 1.5
    self.x, self.y = x or WIDTH/2, y or HEIGHT/2
    
    self.maxSpd = 200
    self.spd = 0
    self.acceleration = 800

    self.width = 7 * self.scale
    self.height = 5 * self.scale

    self.hp = 100
    self.maxHp = self.hp

    self.spriteSheet = love.graphics.newImage('/sprites/characters/player.png')
    self.frameWidth, self.frameHeight = self.spriteSheet:getWidth()/6, self.spriteSheet:getHeight()/10
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())
    
    local animations = {
        move = {
            frames = '1-6',
            downRow = 4,
            upRow = 6,
            horizontalRow = 5
        },
        idle = {
            frames = '1-6',
            downRow = 1,
            upRow = 3,
            horizontalRow = 2
        },
        strike = {
            frames = '1-4',
            downRow = 7,
            upRow = 9,
            horizontalRow = 8
        },
        dead = {
            frames = '1-3',
            onLoop = 'pauseAtEnd',
            animSpd = 0.8,
            horizontalRow = 10
        }
    }

    self.animations = {}
    for key, anim in pairs(animations) do
        if anim.downRow then
            self.animations[key .. '_down'] = anim8.newAnimation(g(anim.frames, anim.downRow), anim.animSpd or 0.2, anim.onLoop)
        end

        if anim.upRow then
            self.animations[key .. '_up'] = anim8.newAnimation(g(anim.frames, anim.upRow), anim.animSpd or 0.2, anim.onLoop)
        end

        if anim.horizontalRow then
            self.animations[key .. '_right'] = anim8.newAnimation(g(anim.frames, anim.horizontalRow), anim.animSpd or 0.2, anim.onLoop)
            self.animations[key .. '_left'] = self.animations[key .. '_right']:clone():flipH()
        end
    end

    self.dir = 'down'

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, 2.5)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)
end

function player:update(dt)
    local dx, dy = self:getVectors()
    self:updateState(dx, dy)

    if self.state == 'dead' then
        if self.dir == 'up' then
            self.dir = 'right'
        elseif self.dir == 'down' then
            self.dir = 'left'
        end

        if world then
            self:kill()
        end
    else
        self:updateSpd(dt, dx, dy)

        self.collider:setLinearVelocity(self.spd * dx, self.spd * dy)
        self.x, self.y = self.collider:getPosition()
        self.x, self.y = math.floor(self.x), math.floor(self.y)

        self:updateSpd(dt, dx, dy)
    end

    self.animation = self:getAnimation()

    if self.state ~= self.currentState then
        self.animation:gotoFrame(1)
        self.currentState = self.state
    end

    self.animation:update(dt)
end

function player:draw()
    self.animation:draw(self.spriteSheet, self.x, self.y, nil, player.scale, player.scale, self.frameWidth/2, self.frameHeight/2)
end

function player:mousepressed()
    if self.state == 'strike' then return end
    self.state = 'strike'

    local dx, dy = self:getStrikeVectors()

    clock.script(function(wait)
        local waitTime = self.animations.strike_down.intervals[2] + 0.1
        wait(waitTime - 0.1)

        clock.during(self.animations.strike_down.totalDuration - waitTime, function()
            self:queryForEnemies(dx, dy)
        end, function()
            self.state = 'idle'
        end)
    end)
end


function player:getStrikeVectors()
    local mx, my = cam:mousePosition()
    local angle = math.pi / 4
    local dx, dy = player.x - mx + 0.1, player.y - my + 0.1
    
    dx = dx * math.cos(angle) - dy * math.sin(angle)
    dy = dx * math.sin(angle) + dy * math.cos(angle)
    dx, dy = dx / math.abs(dx), dy / math.abs(dy)

    if dx == 1 and dy == -1 then
        self.dir = 'down'
    elseif dx == -1 and dy == 1 then
        self.dir = 'up'
    elseif dx == -1 and dx == -1 then
        self.dir = 'right'
    elseif dx == 1 and dy == 1 then
        self.dir = 'left'
    end

    return dx, dy
end

function player:queryForEnemies(dx, dy)
    local triangleVectors = {
        vector(0, 8 * SY),
        vector(4 * SX, 0),
        vector(-4 * SX, 0)
    }
    local triangle = {}

    local angle = math.atan2(dy, dx) + math.pi / 4
    for _, vec2 in ipairs(triangleVectors) do
        vec2 = vec2:rotated(angle) + vector(player.x, player.y)
        table.insert(triangle, vec2.x)
        table.insert(triangle, vec2.y)
    end

    local enemies = world:queryPolygonArea(triangle, {'Enemy'})

    for i, enemy in ipairs(enemies) do
        enemy:getObject():dmg()
    end
end

function player:getVectors()
    local dx,dy = 0,0

    if self.state == 'strike' then
        return dx, dy
    end

    if love.keyboard.isDown('d') then
        dx = 1
        self.dir = 'right'
    end
    if love.keyboard.isDown('a') or love.keyboard.isDown('a') then
        dx = -1
        self.dir = 'left'
    end
    if love.keyboard.isDown('s') then
        dy = 1
        self.dir = 'down'
    end
    if love.keyboard.isDown('w') then
        dy = -1
        self.dir = 'up'
    end
    
    local length = math.sqrt(dx*dx + dy*dy)
    if length ~= 0 then
        dx,dy = dx/length,dy/length
    end

    return dx, dy
end

function player:updateState(dx, dy)
    if self.hp == 0 then
        self.state = 'dead'
    elseif self.state == 'strike' then
        self.state = 'strike'
    elseif dx == 0 and dy == 0 then
        self.state = 'idle'
    else
        self.state = 'move'
    end
end

function player:getAnimation()
    return self.animations[self.state .. '_' .. self.dir]
end

function player:updateSpd(dt, dx, dy)
    if self.state == 'idle' or self.state == 'strike' then
        self.spd = math.max(self.spd - self.acceleration / 2 * dt, 0)
    elseif self.state == 'move' then
        self.spd = math.min(self.spd + self.acceleration / 2 * dt, self.maxSpd)
    end
end

function player:kill()
    clock.clear()

    world:destroy()
    world = nil
end

return player