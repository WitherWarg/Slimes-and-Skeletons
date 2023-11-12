Slime = {}

function Slime.new(x, y)
    slime = {}

    slime.scale = player.scale
    slime.aggro = 250

    slime.x = x or player.x + slime.aggro
    slime.y = y or player.y - slime.aggro
    slime.spd = player.spd/4

    slime.width = 14 * slime.scale
    slime.height = 11 * slime.scale
    
    slime.hp = 4
    slime.dead = false

    slime.spriteSheet = love.graphics.newImage('/sprites/characters/slime.png')
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

        slime.animations.right = anim8.newAnimation(g('1-7', 3), slime.animSpd)
        slime.animations.left = anim8.newAnimation(g('1-7', 3), slime.animSpd):flipH()

        slime.animations.idle_right = anim8.newAnimation(g('1-4', 1), slime.animSpd)
        slime.animations.idle_left = anim8.newAnimation(g('1-4', 1), slime.animSpd):flipH()

        slime.animations.die_right = anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd')
        slime.animations.die_left =  anim8.newAnimation(g('1-5', 5), 0.5, 'pauseAtEnd'):flipH()
    
    slime.animation = slime.animations.idle_left
    slime.dir = 'left'

    table.insert(Slime, slime)
end

function Slime:update(dt)
    for i=#self, 1, -1 do
        local slime = self[i]

        if slime.hp == 0 and slime.animation.position == 5 then
            slime.collider:destroy()
            slime = nil

            table.remove(Slime, i)
            goto continue
        end
        
        slime.animation:update(dt)

        if slime.hp == 0 then
            slime.x = slime.collider:getX() - 0.5 * SX
            slime.y = slime.collider:getY() - 4 * SY
            slime.collider:setType('static')

            if slime.dir == 'right' then slime.animation = slime.animations.die_right
                else slime.animation = slime.animations.die_left end
            goto continue
        end

        local dx, dy = player.x - slime.x, player.y - slime.y
        local length = math.sqrt(dx*dx+dy*dy)
        local control = 5
        
        if player.x + control > slime.x and slime.x > player.x - control then
            dx = 0
        else
            dx = dx/math.abs(dx)
        end
        
        if player.y + control > slime.y and slime.y > player.y - control then
            dy = 0
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

        ::continue::
    end
end

function Slime:draw()
    for i=#self, 1, -1 do
        local slime = self[i]

        if slime.hp > 0 or slime.animation.position < 5 then
            slime.animation:draw(slime.spriteSheet, slime.x, slime.y, nil, slime.scale, slime.scale, slime.frameWidth/2, slime.frameHeight/2)
        end
    end
end