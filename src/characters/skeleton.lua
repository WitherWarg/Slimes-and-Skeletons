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

        dieRight = { frames = '1-5', row = 5, animSpd = 0.5, mode = 'pauseAtEnd' },
        dieLeft = { frames = '1-5', row = 5, animSpd = 0.5, mode = 'pauseAtEnd', flipH = true },

        dmgRight = { frames = '1-3', row = 4, mode = 'pauseAtEnd' },
        dmgLeft = { frames = '1-3', row = 4, mode = 'pauseAtEnd', flipH = true },

        strikeRight = { frames = '1-5', row = 3 },
        strikeLeft = { frames = '1-5', row = 3, flipH = true }
    }

    skeleton.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpeed or 0.2, data.mode)
        if data.flipH then animation:flipH() end
        skeleton.animations[key] = animation
    end

    skeleton.animation = skeleton.animations.idleRight

    table.insert(Skeleton, skeleton)
end

function Skeleton:update(dt)
    for i = #self, 1, -1 do
        local skeleton = self[i]

        if skeleton.x < player.x then skeleton.dir = 'right'
        else skeleton.dir = 'left' end

        if player.dead or skeleton.state == 'dead' and skeleton.animation.position == 5 then
            if skeleton.collider then
                skeleton.collider:destroy()
                skeleton.collider = nil
            end
            skeleton = nil
            table.remove(Skeleton, i)
            goto continue
        end

        skeleton.animation:update(dt)

        if skeleton.hp == 0 then
            if skeleton.collider then
                skeleton.collider:destroy()
                skeleton.collider = nil
            end
            if skeleton.tween then
                skeleton.tween:stop()
                skeleton.tween = nil
            end

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

                local angle = math.atan2(dx, dy)
                local radius = 5
                local targetX = player.x + radius * math.cos(angle)
                local targetY = player.y + radius * math.sin(angle)

                clock.during(skeleton.animation.intervals[#skeleton.animation.frames], function()
                    if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.strikeRight
                    else skeleton.animation = skeleton.animations.strikeLeft end
                    skeleton.state = 'strike'
                end)

                local frames = skeleton.animations.strikeRight.intervals
                skeleton.tween = flux.to(skeleton, frames[5], {x = targetX, y = targetY}):delay(skeleton.animation.intervals[2]):onupdate(function()
                    skeleton.collider:setPosition(skeleton.x, skeleton.y)
                end):oncomplete(function()
                    clock.during(0.5, function()
                        local right, left = skeleton.animations.idleRight, skeleton.animations.idleLeft
                        if skeleton.state == 'dmg' then right, left = skeleton.animations.dmgRight, skeleton.animations.dmgLeft
                        else skeleton.state = 'idle' end
                        if skeleton.dir == 'right' then skeleton.animation = right
                        else skeleton.animation = left end
                    end, function()
                        skeleton.strike = false
                        if skeleton.dir == 'right' then skeleton.animations.dmgRight:gotoFrame(1)
                        else skeleton.animations.dmgLeft:gotoFrame(1) end
                    end)

                    if skeleton.dir == 'right' then skeleton.animations.strikeRight:gotoFrame(1)
                    else skeleton.animations.strikeLeft:gotoFrame(1) end
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

function Skeleton:draw()
    for i = #self, 1, -1 do
        local skeleton = self[i]

        if skeleton.hp > 0 or skeleton.animation.position < 5 then
            skeleton.animation:draw(skeleton.spriteSheet, skeleton.x, skeleton.y, nil, skeleton.scale, skeleton.scale, skeleton.frameWidth / 2, skeleton.frameHeight / 2)
        end
    end
end

return Skeleton