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

    slime.animations = {}
        slime.animations.right = anim8.newAnimation(g('1-6', 2), 0.2)
        slime.animations.left = anim8.newAnimation(g('1-6', 2), 0.2):flipH()

        slime.animations.idleRight = anim8.newAnimation(g('1-4', 1), 0.2)
        slime.animations.idleLeft = anim8.newAnimation(g('1-4', 1), 0.2):flipH()

        slime.animations.dieRight = anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd')
        slime.animations.dieLeft = anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd'):flipH()

        slime.animations.dmgRight = anim8.newAnimation(g('1-3', 4), 0.2, 'pauseAtEnd')
        slime.animations.dmgLeft = anim8.newAnimation(g('1-3', 4), 0.2, 'pauseAtEnd'):flipH()

        slime.strike = false
        slime.animations.strikeRight = anim8.newAnimation(g('1-7', 3), 0.2)
        slime.animations.strikeLeft = anim8.newAnimation(g('1-7', 3), 0.2):flipH()

    slime.animation = slime.animations.idleRight
    slime.dir = 'right'

    table.insert(Slime, slime)
end

function Slime:update(dt)
    for i = #self, 1, -1 do
        local slime = self[i]

        if player.dead or slime.hp == 0 and slime.animation.position == 5 then
            slime = nil
            table.remove(Slime, i)
            goto continue
        end

        slime.animation:update(dt)

        if slime.hp == 0 then
            if slime.collider then
                slime.collider:destroy()
                slime.collider = nil
            end
            if slime.tween then
                slime.tween:stop()
                slime.tween = nil
            end

            if slime.dir == 'right' then slime.animation = slime.animations.dieRight
            else slime.animation = slime.animations.dieLeft end
            goto continue
        end

        if slime.x < player.x then slime.dir = 'right'
        else slime.dir = 'left' end

        slime.x, slime.y = slime.collider:getPosition()

        local dx, dy = player.x - slime.x, player.y - slime.y
        local length = math.sqrt(dx * dx + dy * dy)

        if slime.dir == 'dmg' and slime.animation.position ~= 3 then goto continue end
        if length < slime.aggro then
            if length < math.sqrt(2 * 100 * 100) and not slime.strike then
                slime.strike = true
                slime.collider:setLinearVelocity(1, 1)

                local angle = math.atan2(slime.y - player.y, slime.x - player.x)
                local radius = 5
                local targetX = player.x + radius * math.cos(angle)
                local targetY = player.y + radius * math.sin(angle)

                clock.during(slime.animation.intervals[#slime.animation.frames], function()
                    if slime.dir == 'right' then slime.animation = slime.animations.strikeRight
                    else slime.animation = slime.animations.strikeLeft end
                end)

                slime.tween = flux.to(slime, slime.animation.intervals[5], {x = targetX, y = targetY}):delay(slime.animation.intervals[2]):onupdate(function()
                    slime.collider:setPosition(slime.x, slime.y)
                end):oncomplete(function()
                    clock.during(0.5, function()
                        if slime.dir == 'right' then slime.animation = slime.animations.idleRight
                        else slime.animation = slime.animations.idleLeft end
                    end, function() slime.strike = false end)

                    if slime.dir == 'right' then slime.animations.strikeRight:gotoFrame(1)
                    else slime.animations.strikeLeft:gotoFrame(1) end
                end)
            elseif not slime.strike then
                if slime.dir == 'right' then slime.animation = slime.animations.right
                else slime.animation = slime.animations.left end

                dx = dx / math.abs(dx)
                dy = dy / math.abs(dy)
                length = math.sqrt(dx * dx + dy * dy)
                slime.collider:setLinearVelocity(slime.spd * dx / length, slime.spd * dy / length)
            end
        else
            if slime.dir == 'right' then slime.animation = slime.animations.idleRight
            else slime.animation = slime.animations.idleLeft end
            slime.collider:setLinearVelocity(0, 0)
        end

        ::continue::
    end
end

function Slime:draw()
    for i = #self, 1, -1 do
        local slime = self[i]

        if slime.hp > 0 or slime.animation.position < 5 then
            slime.animation:draw(slime.spriteSheet, slime.x, slime.y, nil, slime.scale, slime.scale, slime.frameWidth / 2, slime.frameHeight / 2)
        end
    end
end

return Slime