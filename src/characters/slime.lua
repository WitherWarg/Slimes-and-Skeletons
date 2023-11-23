Slime = {}

function Slime.new(x, y)
    local slime = {}

    slime.scale = player.scale
    slime.aggro = 250
    slime.hp = 4

    slime.x = x or player.x + slime.aggro
    slime.y = y or player.y - slime.aggro
    slime.spd = player.spd / 4

    slime.width = 14 * slime.scale
    slime.height = 11 * slime.scale


    slime.spriteSheet = love.graphics.newImage('/sprites/characters/slime.png')
    slime.frameWidth = slime.spriteSheet:getWidth() / 7
    slime.frameHeight = slime.spriteSheet:getHeight() / 5
    local g = anim8.newGrid(slime.frameWidth, slime.frameHeight, slime.spriteSheet:getWidth(), slime.spriteSheet:getHeight())

    slime.collider = world:newBSGRectangleCollider(slime.x, slime.y, slime.width, slime.height, 10)
    slime.collider:setFixedRotation(true)
    slime.collider:setCollisionClass('Enemy')
    slime.collider:setObject(slime)

    local animations = {
        right = { frames = '1-6', row = 2 },
        left = { frames = '1-6', row = 2, flipH = true },

        idleRight = { frames = '1-4', row = 1 },
        idleLeft = { frames = '1-4', row = 1, flipH = true },

        dieRight = { frames = '1-5', row = 5, onLoop = 'pauseAtEnd', animSpd = 0.5 },
        dieLeft = { frames = '1-5', row = 5, flipH = true, onLoop = 'pauseAtEnd', animSpd = 0.5 },
        
        dmgRight = { frames = '1-3', row = 4 },
        dmgLeft = { frames = '1-3', row = 4, flipH = true },
        
        dashRight = { frames = '1-7', row = 3 },
        dashLeft = { frames = '1-7', row = 3, flipH = true }
    }

    slime.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
        if data.flipH then animation:flipH() end
        slime.animations[key] = animation
    end

    slime.animation = slime.animations.idleRight
    slime.dir = 'right'
    slime.state = 'idle'

    function slime:draw()
        if slime.hp > 0 or slime.animation.position < 5 then
            slime.animation:draw(slime.spriteSheet, slime.x, slime.y, nil, slime.scale, slime.scale, slime.frameWidth / 2, slime.frameHeight / 2)
        end
    end

    table.insert(Slime, slime)
end

function Slime:update(dt)
    for i = #self, 1, -1 do
        local slime = self[i]

        if slime.x < player.x then slime.dir = 'right'
        else slime.dir = 'left' end

        if player.dead or slime.state == 'dead' and slime.animation.position == 5 then
            destroyObject(slime)
            slime = nil
            table.remove(Slime, i)
            goto continue
        end

        slime.animation:update(dt)

        if slime.hp == 0 then
            destroyObject(slime)

            if slime.dir == 'right' then slime.animation = slime.animations.dieRight
            else slime.animation = slime.animations.dieLeft end
            slime.state = 'dead'
            goto continue
        end

        slime.x, slime.y = slime.collider:getPosition()
        
        local dx, dy = player.x - slime.x, player.y - slime.y
        local length = math.sqrt(dx * dx + dy * dy)
        

        if length < slime.aggro then
            if length < math.sqrt(2 * 100 * 100) and not slime.dash then
                slime.dash = true
                slime.collider:setLinearVelocity(1, 1)

                local angle = math.atan2(dy, dx)
                local radius = 5
                local targetX = player.x - radius * math.cos(angle)
                local targetY = player.y - radius * math.sin(angle)

                if slime.dir == 'right' then slime.animation = slime.animations.dashRight
                else slime.animation = slime.animations.dashLeft end
                slime.state = 'dash'

                local buffer = slime.animation.intervals[3]
                slime.tween = flux.to(slime, slime.animation.totalDuration - buffer, {x = targetX, y = targetY}):delay(buffer):onupdate(function()
                    slime.collider:setPosition(slime.x, slime.y)
                end):oncomplete(function()
                    local after = function() slime.dash = false end
                    slime.handle = clock.during(0.5, function()
                        if slime.state == 'dmg' then
                            clock.during(slime.animations.dmgRight.totalDuration, function()
                                if slime.dir == 'right' then slime.animation = slime.animations.dmgRight
                                else slime.animation = slime.animations.dmgLeft end
                            end, after)
                            clock.cancel(slime.handle)
                        else
                            slime.state = 'idle'
                            if slime.dir == 'right' then slime.animation = slime.animations.idleRight
                            else slime.animation = slime.animations.idleLeft end
                        end
                    end, after)
                end)
            elseif not slime.dash then
                if slime.dir == 'right' then slime.animation = slime.animations.right
                else slime.animation = slime.animations.left end
                slime.state = 'move'

                local angle = math.atan2(dy, dx)
                slime.collider:setLinearVelocity(slime.spd * math.cos(angle), slime.spd * math.sin(angle))
            end
        else
            if slime.dir == 'right' then slime.animation = slime.animations.idleRight
            else slime.animation = slime.animations.idleLeft end
            slime.state = 'idle'
            slime.collider:setLinearVelocity(0, 0)
        end
        
        ::continue::
    end
end

return Slime