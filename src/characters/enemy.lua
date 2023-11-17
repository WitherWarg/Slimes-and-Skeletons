--[[
    frameData = {
        width,
        height,
        path,
        columns,
        rows,
        animations = {
            name = { frames, row, animSpd, flipH, mode }
        }
    }
]]

Enemy = {}


function Enemy.new(x, y, dir, frameData, colliderCut)
    local enemy = {}

    enemy.scale = player.scale
    enemy.aggro = 250
    enemy.hp = 4

    enemy.x = x or player.x + enemy.aggro
    enemy.y = y or player.y - enemy.aggro
    enemy.spd = player.spd / 4

    enemy.width = frameData.width * enemy.scale
    enemy.height = frameData.height * enemy.scale


    enemy.spriteSheet = love.graphics.newImage(frameData.path)
    enemy.frameWidth = enemy.spriteSheet:getWidth() / frameData.columns
    enemy.frameHeight = enemy.spriteSheet:getHeight() / frameData.rows
    local g = anim8.newGrid(enemy.frameWidth, enemy.frameHeight, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())

    enemy.collider = world:newBSGRectangleCollider(enemy.x, enemy.y, enemy.width, enemy.height, colliderCut)
    enemy.collider:setFixedRotation(true)
    enemy.collider:setCollisionClass('Enemy')
    enemy.collider:setObject(enemy)

    enemy.animations = {}
    for key, data in pairs(frameData.animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpeed or 0.2, data.mode)
        if data.flipH then animation:flipH() end
        enemy.animations[key] = animation
    end

    enemy.animation = enemy.animations.idleRight

    table.insert(Enemy, enemy)
end

function Enemy:update(dt)
    for i = #self, 1, -1 do
        local enemy = self[i]
        
        local bool = enemy.hp == 0 and enemy.animation.position == 5
        if player.dead or bool then
            if enemy.collider then enemy.collider:destroy() end
            enemy.collider = nil
            enemy.tween:stop()
            enemy.tween = nil
            enemy = nil
            table.remove(Enemy, i)
            goto continue
        end

        enemy.animation:update(dt)
        enemy.x = enemy.collider:getX()
        enemy.y = enemy.collider:getY()

        if enemy.x < player.x then enemy.dir = 'right'
        else enemy.dir = 'left' end

        if enemy.hp == 0 then
            enemy.collider:setType('static')

            if enemy.dir == 'right' then enemy.animation = enemy.animations.dieRight
            else enemy.animation = enemy.animations.dieLeft end
            goto continue
        end

        local dx, dy = player.x - enemy.x, player.y - enemy.y
        local length = math.sqrt(dx * dx + dy * dy)

        if enemy.dir == 'dmg' and enemy.animation.position ~= 3 then goto continue end
        if length < enemy.aggro then
            if length < math.sqrt(2 * 100 * 100) and not strikeExecuted then
                strikeExecuted = true
                enemy.collider:setLinearVelocity(1, 1)

                local angle = math.atan2(enemy.y - player.y, enemy.x - player.x)
                local radius = 5
                local targetX = player.x + radius * math.cos(angle)
                local targetY = player.y + radius * math.sin(angle)

                clock.during(enemy.animation.totalDuration, function()
                    if enemy.dir == 'right' then enemy.animation = enemy.animations.strikeRight
                    else enemy.animation = enemy.animations.strikeLeft end
                end)

                enemy.tween = flux.to(enemy, enemy.animation.intervals[6], {x = targetX, y = targetY}):delay(enemy.animation.intervals[3]):onupdate(function()
                    enemy.collider:setPosition(enemy.x, enemy.y)
                end):oncomplete(function()
                    strikeExecuted = false
                    if enemy.dir == 'right' then enemy.animations.strikeRight:gotoFrame(1)
                    else enemy.animations.strikeLeft:gotoFrame(1) end
                end)
            else
                if enemy.dir == 'right' then enemy.animation = enemy.animations.right
                else enemy.animation = enemy.animations.left end

                dx = dx / math.abs(dx)
                dy = dy / math.abs(dy)
                length = math.sqrt(dx * dx + dy * dy)
                enemy.collider:setLinearVelocity(enemy.spd * dx / length, enemy.spd * dy / length)
            end
        else
            if enemy.dir == 'right' then enemy.animation = enemy.animations.idleRight
            else enemy.animation = enemy.animations.idleLeft end
            enemy.collider:setLinearVelocity(0, 0)
        end

        ::continue::
    end
end

function Enemy:draw()
    for i = #self, 1, -1 do
        local enemy = self[i]

        if enemy.hp > 0 or enemy.animation.position < 5 then
            enemy.animation:draw(enemy.spriteSheet, enemy.x, enemy.y, nil, enemy.scale, enemy.scale, enemy.frameWidth / 2, enemy.frameHeight / 2)
        end
    end
end

function newSlime(x, y, dir)
    local frameData = {
        width = 14,
        height = 11,
        path = '/sprites/characters/slime.png',
        columns = 7,
        rows = 5,
        animations = {
            right = { frames = '1-6', row = 2, animSpd = 0.2 },
            left = { frames = '1-6', row = 2, animSpd = 0.2, flipH = true },

            idleRight = { frames = '1-4', row = 1, animSpd = 0.2 },
            idleLeft = { frames = '1-4', row = 1, animSpd = 0.2, flipH = true },

            dieRight = { frames = '1-5', row = 5, animSpd = 0.2, mode = 'pauseAtEnd' },
            dieLeft = { frames = '1-5', row = 5, animSpd = 0.2, flipH = true, mode = 'pauseAtEnd' },
            
            dmgRight = { frames = '1-3', row = 4, animSpd = 0.2, mode = 'pauseAtEnd' },
            dmgLeft = { frames = '1-3', row = 4, animSpd = 0.2, flipH = true, mode = 'pauseAtEnd' },
            
            strikeRight = { frames = '1-7', row = 3, animSpd = 0.2 },
            strikeLeft = { frames = '1-7', row = 3, animSpd = 0.2, flipH = true }
        }
    }

    Enemy.new(x, y, dir, frameData, 10)
end

function newSkeleton(x, y, dir)
    local frameData = {
        width = 8,
        height = 4,
        path = '/sprites/characters/skeleton.png',
        columns = 6,
        rows = 5,
        animations = {
            right = { frames = '1-6', row = 2, animSpd = 0.2 },
            left = { frames = '1-6', row = 2, animSpd = 0.2, flipH = true },

            idleRight = { frames = '1-6', row = 1, animSpd = 0.2 },
            idleLeft = { frames = '1-6', row = 1, animSpd = 0.2, flipH = true },

            dieRight = { frames = '1-5', row = 5, animSpd = 0.5, mode = 'pauseAtEnd' },
            dieLeft = { frames = '1-5', row = 5, animSpd = 0.5, mode = 'pauseAtEnd', flipH = true },

            dmgRight = { frames = '1-3', row = 4, animSpd = 0.2, mode = 'pauseAtEnd' },
            dmgLeft = { frames = '1-3', row = 4, animSpd = 0.2, mode = 'pauseAtEnd', flipH = true },

            strikeRight = { frames = '1-5', row = 3, animSpd = 0.2 },
            strikeLeft = { frames = '1-5', row = 3, animSpd = 0.2, flipH = true }
        }
    }

    Enemy.new(x, y, dir, frameData, 5)
end