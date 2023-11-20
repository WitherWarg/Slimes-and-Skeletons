Skeleton = {}

function Skeleton.new(x, y)
    local enemy = {}

    enemy.scale = player.scale
    enemy.aggro = 250
    enemy.hp = 4

    enemy.x = x or player.x + enemy.aggro
    enemy.y = y or player.y - enemy.aggro
    enemy.spd = player.spd / 4

    enemy.width = colliderData.width * enemy.scale
    enemy.height = colliderData.height * enemy.scale


    enemy.spriteSheet = love.graphics.newImage(frameData.path)
    enemy.frameWidth = enemy.spriteSheet:getWidth() / frameData.columns
    enemy.frameHeight = enemy.spriteSheet:getHeight() / frameData.rows
    local g = anim8.newGrid(enemy.frameWidth, enemy.frameHeight, enemy.spriteSheet:getWidth(), enemy.spriteSheet:getHeight())

    enemy.collider = world:newBSGRectangleCollider(enemy.x, enemy.y, enemy.width, enemy.height, colliderData.cut)
    enemy.collider:setFixedRotation(true)
    enemy.collider:setCollisionClass('Enemy')
    enemy.collider:setObject(enemy)

    local animations = {
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

    enemy.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpeed, data.mode)
        if data.flipH then animation:flipH() end
        enemy.animations[key] = animation
    end

    enemy.animation = enemy.animations.idleRight

    table.insert(Enemy, enemy)
end

return Skeleton