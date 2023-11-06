slimes = {}

function newSlime(x, y)
    slime = {}

    slime.sx, slime.sy = player.sx, player.sy
    slime.aggro = 250

    slime.x = x or player.x + slime.aggro
    slime.y = y or player.y - slime.aggro
    slime.spd = player.spd/4

    slime.width = 14 * slime.sx
    slime.height = 11 * slime.sy
    
    slime.hp = 4
    slime.dead = false

    slime.spriteSheet = love.graphics.newImage('sprites/characters/slime.png')
    slime.frameWidth = slime.spriteSheet:getWidth()/7
    slime.frameHeight = slime.spriteSheet:getHeight()/5
    local g = anim8.newGrid(slime.frameWidth, slime.frameHeight, slime.spriteSheet:getWidth(), slime.spriteSheet:getHeight())

    local colliderX = slime.x - player.width/2
    local colliderY = slime.y - player.height/2
    slime.collider = world:newBSGRectangleCollider(colliderX, colliderY, slime.width, slime.height, 10)
    slime.collider:setFixedRotation(true)
    slime.collider:setCollisionClass('Enemy')
    slime.collider:setObject(slime)

    slime.animations = {}
        slime.animSpd = 0.2
        slime.animations.timer = 0

        slime.animations.right = anim8.newAnimation(g('1-7', 3), slime.animSpd)
        slime.animations.left = anim8.newAnimation(g('1-7', 3), slime.animSpd):flipH()

        slime.animations.idle_right = anim8.newAnimation(g('1-4', 1), slime.animSpd)
        slime.animations.idle_left = anim8.newAnimation(g('1-4', 1), slime.animSpd):flipH()

        slime.animations.die_right = anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd')
        slime.animations.die_left =  anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd'):flipH()
    
    slime.animation = slime.animations.idle_left
    slime.dir = 'left'

    table.insert(slimes, slime)
end

function slimes:update(dt)
    if #self == 0 then return end

    for i, slime in ipairs(self) do

    if slime.dead and slime.animation.position == 5 then
        slime.collider:destroy()
        slime = nil
        table.remove(slimes, i)
        goto continue
    end
    
    slime.animation:update(dt)

    if slime.dead then goto continue end

    local dx = player.x - slime.x
    local dy = player.y - slime.y
    local length = math.sqrt(dx*dx+dy*dy)
    local control = 4/9
    
    if player.x + control > slime.x and slime.x > player.x - control then
        dx = 0
        slime.x = player.x + player.cx * player.sx
    else
        dx = dx/math.abs(dx)
    end
    if player.y + control > slime.y and slime.y > player.y - control then
        dy = 0
        slime.y = player.y + player.cy * player.sy
    else
        dy = dy/math.abs(dy)
    end

    slime.x = slime.collider:getX() - 0.5 * SX
    slime.y = slime.collider:getY() - 4 * SY

    if length < slime.aggro then
        if slime.x < player.x then
            slime.animation = slime.animations.right 
            slime.dir = 'right'
        else
            slime.animation = slime.animations.left
            slime.dir = 'left'
        end
        
        if length < math.sqrt(3200) then
            slime.animation:gotoFrame(1)
        end

        length = math.sqrt(dx*dx + dy*dy)
        slime.collider:setLinearVelocity(slime.spd * dx/length, slime.spd * dy/length)
    else
        if slime.dir == 'right' then
            slime.animation = slime.animations.idle_right
        else
            slime.animation = slime.animations.idle_left
        end
        slime.collider:setLinearVelocity(0, 0)
    end

    if slime.collider:enter('Sword') then
        local collision_data = slime.collider:getEnterCollisionData('Sword')

        local dx, dy = collision_data.contact:getNormal()
        dx, dy = -dx, -dy
        if player.dir == 'down' then
            dy = 1
        elseif player.dir == 'up' then
            dy = -1
        elseif player.dir == 'left' then
            dx = -1
        else
            dx = 1
        end

        dx, dy = dx*math.pow(10, 4)*SX, dy*math.pow(10, 4)*SY
        
        slime.collider:applyLinearImpulse(dx, dy)
        
        slime.hp = slime.hp - 1/2
        if slime.hp == 0 then
            killSlime(slime)
        end
    end

    ::continue::
    end
end

function slimes:draw()
    if #slimes == 0 then return end
    
    for _, slime in ipairs(self) do
        if slime.dead and slime.animation.position == 5 then goto continue end
        slime.animation:draw(slime.spriteSheet, slime.x, slime.y, nil, slime.sx, slime.sy, slime.frameWidth / 2, slime.frameHeight / 2)
        ::continue::
    end
end

function killSlime(slime)
    slime.dead = true
    slime.collider:setType('static')
    if slime.dir == 'right' then slime.animation = slime.animations.die_right
    else slime.animation = slime.animations.die_left end
end