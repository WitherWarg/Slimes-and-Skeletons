Skeleton = {}

function Skeleton.new(x, y)
    local skeleton = {}

    skeleton.scale = player.scale
    skeleton.aggro = 300
    skeleton.hp = 6

    skeleton.x = x or player.x + skeleton.aggro
    skeleton.y = y or player.y - skeleton.aggro
    skeleton.spd = player.spd / 3

    skeleton.width = 8 * skeleton.scale
    skeleton.height = 4 * skeleton.scale


    skeleton.spriteSheet = love.graphics.newImage('/sprites/characters/skeleton.png')
    skeleton.frameWidth = skeleton.spriteSheet:getWidth() / 6
    skeleton.frameHeight = skeleton.spriteSheet:getHeight() / 5
    local g = anim8.newGrid(skeleton.frameWidth, skeleton.frameHeight, skeleton.spriteSheet:getWidth(), skeleton.spriteSheet:getHeight())

    skeleton.collider = world:newBSGRectangleCollider(skeleton.x, skeleton.y, skeleton.width, skeleton.height, 5)
    skeleton.collider:setFixedRotation(true)
    skeleton.collider:setCollisionClass('Enemy')
    skeleton.collider:setObject(skeleton)

    local animations = {
        right = { frames = '1-6', row = 2 },
        left = { frames = '1-6', row = 2, flipH = true },

        idleRight = { frames = '1-6', row = 1 },
        idleLeft = { frames = '1-6', row = 1, flipH = true },

        dieRight = { frames = '1-5', row = 5, animSpd = 0.5, onLoop = 'pauseAtEnd' },
        dieLeft = { frames = '1-5', row = 5, animSpd = 0.5, onLoop = 'pauseAtEnd', flipH = true },

        dmgRight = { frames = '1-3', row = 4},
        dmgLeft = { frames = '1-3', row = 4, flipH = true },

        strikeRight = { frames = '1-5', row = 3, animSpd = {['1-2']=0.5, ['3-5']=0.2} },
        strikeLeft = { frames = '1-5', row = 3, flipH = true, animSpd = {['1-2']=0.5, ['3-5']=0.2} }
    }

    skeleton.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
        if data.flipH then animation:flipH() end
        skeleton.animations[key] = animation
    end

    skeleton.animation = skeleton.animations.idleRight
    skeleton.dir = 'right'
    skeleton.state = 'idle'

    function skeleton:draw()
        if skeleton.hp > 0 or skeleton.animation.position < 5 then
            skeleton.animation:draw(skeleton.spriteSheet, skeleton.x, skeleton.y, nil, skeleton.scale, skeleton.scale, skeleton.frameWidth/2, skeleton.frameHeight/2)
        end
    end

    skeleton.sword = {}
        skeleton.sword.width = 12
        skeleton.sword.height = 60
        skeleton.sword.strike = false

    function skeleton.sword:update(dt)
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

    function skeleton.sword:mousepressed(dir)
        self.dir = dir

        clock.script(function(wait)
            local colliderX, colliderY = 0, 0
            local animSpd = skeleton.animation.intervals[2]
            local change = 10

            wait(animSpd)
            self.strike = true

            if self.dir == 'right' then
                colliderX = skeleton.x
                colliderY = skeleton.y - self.width - change*2
            elseif self.dir == 'left' then
                colliderX = skeleton.x - self.height
                colliderY = skeleton.y - self.width - change*2
            elseif self.dir == 'down' then
                colliderX = skeleton.x - self.width - change
                colliderY = skeleton.y - self.height/2
            else
                colliderX = skeleton.x + change
                colliderY = skeleton.y - self.height
            end

            clock.during(skeleton.animation.intervals[3], function()
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
                colliderX = skeleton.x
                colliderY = skeleton.y
            elseif self.dir == 'left' then
                colliderX = skeleton.x - self.height
                colliderY = skeleton.y
            elseif self.dir == 'down' then
                colliderX = skeleton.x + change
                colliderY = skeleton.y - self.height/2
            else
                colliderX = skeleton.x - self.width - change
                colliderY = skeleton.y - self.height
            end
        end)
    end

    table.insert(Skeleton, skeleton)
end

function Skeleton:update(dt)
    for i = #self, 1, -1 do
        local skeleton = self[i]

        if skeleton.x < player.x then skeleton.dir = 'right'
        else skeleton.dir = 'left' end

        if player.dead or skeleton.state == 'dead' and skeleton.animation.position == 5 then
            destroyObject(skeleton)
            skeleton = nil
            table.remove(Skeleton, i)
            goto continue
        end

        skeleton.animation:update(dt)

        if skeleton.hp == 0 then
            destroyObject(skeleton)

            if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.dieRight
            else skeleton.animation = skeleton.animations.dieLeft end
            skeleton.state = 'dead'
            goto continue
        end

        skeleton.x, skeleton.y = skeleton.collider:getPosition()
        
        local dx, dy = player.x - skeleton.x, player.y - skeleton.y
        local length = math.sqrt(dx * dx + dy * dy)
        

        if length < skeleton.aggro then
            if length < math.sqrt(2 * 100 * 100) and not skeleton.strike then
                skeleton.strike = true
                skeleton.collider:setLinearVelocity(1, 1)

                local angle = math.atan2(dy, dx)
                local radius = 30
                local targetX = player.x - radius * math.cos(angle)
                local targetY = player.y - radius * math.sin(angle)

                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.strikeRight
                else skeleton.animation = skeleton.animations.strikeLeft end
                skeleton.state = 'strike'

                local buffer = skeleton.animation.intervals[3]
                skeleton.tween = flux.to(skeleton, skeleton.animation.totalDuration - buffer, {x = targetX, y = targetY}):delay(buffer):onupdate(function()
                    skeleton.collider:setPosition(skeleton.x, skeleton.y)
                end):oncomplete(function()
                    local after = function() skeleton.strike = false end
                    skeleton.handle = clock.during(0.5, function()
                        if skeleton.state == 'dmg' then
                            clock.during(skeleton.animations.dmgRight.totalDuration, function()
                                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.dmgRight
                                else skeleton.animation = skeleton.animations.dmgLeft end
                            end, after)
                            clock.cancel(skeleton.handle)
                        else
                            skeleton.state = 'idle'
                            if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.idleRight
                            else skeleton.animation = skeleton.animations.idleLeft end
                        end
                    end, after)
                end)
            elseif not skeleton.strike then
                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.right
                else skeleton.animation = skeleton.animations.left end
                skeleton.state = 'move'

                local angle = math.atan2(dy, dx)
                skeleton.collider:setLinearVelocity(skeleton.spd * math.cos(angle), skeleton.spd * math.sin(angle))
            end
        else
            if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.idleRight
            else skeleton.animation = skeleton.animations.idleLeft end
            skeleton.state = 'idle'
            skeleton.collider:setLinearVelocity(0, 0)
        end
        
        ::continue::
    end
end

return Skeleton