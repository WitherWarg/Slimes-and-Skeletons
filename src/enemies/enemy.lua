enemy = {}
enemy.__index = enemy

--[[
    local stats = { x, y, scale, hp, spd, width, height }
    local spriteData = { path, rows, columns }
    local animations = {
        name = { frames, row, animSpd, onLoop },
    }
]]

function enemy.new(stats, spriteData, animations)
    local self = {}
    setmetatable(self, enemy)

    self.scale = player.scale
    self.aggro = stats.aggro
    self.hp = stats.hp
    self.x = stats.x or player.x + self.aggro
    self.y = stats.y or player.y - self.aggro
    self.spd = stats.spd

    self.width = stats.width * self.scale
    self.height = stats.height * self.scale

    self.spriteSheet = love.graphics.newImage(spriteData.path)
    self.frameWidth = self.spriteSheet:getWidth() / spriteData.rows
    self.frameHeight = self.spriteSheet:getHeight() / spriteData.columns
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.collider = world:newBSGRectangleCollider(self.x, self.y, self.width, self.height, 10)
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
    if player.dead or self.state == 'dead' and self.animation.position == #self.animation.frames then
        destroyObject(self)
        self = nil
        return
    end

    self.animation:update(dt)

    if self.hp == 0 then
        self.state = 'dead'
        self.animation = self.animations.die
        self:setAnimationOrientation()
        self.collider:setCollisionClass('Dead')

        return
    end

    if self.x < player.x then
        self.dir = 'right'
    else
        self.dir = 'left'
    end

    self.x, self.y = self.collider:getPosition()
    
    local dx, dy = player.x - self.x, player.y - self.y
    local length = math.sqrt(dx * dx + dy * dy)

    if length < self.aggro then
        if length < math.sqrt(2 * 100 * 100) and not self.strike then
            self.strike = true
            self.collider:setLinearVelocity(1, 1)
            self.animation = self.animations.strike
            self:setAnimationOrientation()
            
            local currentDir = self.dir
            local angle, radius, targetX, targetY, defX
            
            self.timer = clock.during(self.animation.intervals[3], function()
                if currentDir ~= self.dir then
                    self.animation:flipH()
                    currentDir = self.dir
                end

                dx, dy = player.x - self.x, player.y - self.y
                angle = math.atan2(dy, dx)
                radius = 5
                targetX = player.x - radius * math.cos(angle)
                targetY = player.y - radius * math.sin(angle)
            end, function()
                self.tween = flux.to(self, self.animation.totalDuration - self.animation.intervals[3], {x = targetX, y = targetY}):onupdate(function()
                    self.state = 'strike'
                    self.collider:setPosition(self.x, self.y)
                end):oncomplete(function()
                    local function after() self.strike = false end
                    self.handle = clock.during(0.7, function()
                        if self.state == 'dmg' then
                            self.animations.dmg:gotoFrame(1)
                            clock.during(self.animations.dmg.totalDuration, function()
                                self.animation = self.animations.dmg
                                self:setAnimationOrientation()
                            end, after)
                            clock.cancel(self.handle)
                        else
                            self.state = 'idle'
                            self.animation = self.animations.idle
                            self:setAnimationOrientation()
                        end
                    end, after)
                end)
            end)
        elseif not self.strike then
            self.animation = self.animations.move
            self:setAnimationOrientation()
            self.state = 'move'

            local angle = math.atan2(dy, dx)
            self.collider:setLinearVelocity(self.spd * math.cos(angle), self.spd * math.sin(angle))
        end
    else
        self.animation = self.animations.idle
        self:setAnimationOrientation()
        self.state = 'idle'
        self.collider:setLinearVelocity(0, 0)
    end
end

function enemy:collision()
    if self.collider:enter('Sword') and (self.state == 'idle' or self.animation.position >= #self.animation.frames - 2) then
        local collision_data = self.collider:getEnterCollisionData('Sword')
        local dx, dy = collision_data.contact:getNormal()
        local s = 200
        self.collider:applyLinearImpulse(-dx*s, -dy*s)
        clock.during(self.animation.intervals[#self.animation.frames - 2], function()
            self.x, self.y = self.collider:getPosition()
        end)

        self.hp = self.hp - 1
        if self.hp < 1 then
            self.state = 'dead'
        else
            self.state = 'dmg'
        end
    end
end

function enemy:draw()
    if self.state ~= 'dead' or self.animation.position < #self.animation.frames then
        self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.scale, self.scale, self.frameWidth/2, self.frameHeight/2)
    end
end

function enemy:setAnimationOrientation()
    if self.dir == 'right' and self.animation.flippedH or self.dir == 'left' and not self.animation.flippedH then
        self.animation:flipH()            
    end
end

return enemy