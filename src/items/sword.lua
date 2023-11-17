sword = {}

function sword:load()
    self.sx = 1.4
    self.sy = 0.7
    self.width = 8 * self.sx
    self.height = 61 * self.sy
    self.type = 'wood'
end

function sword:update(dt)
    if self.collider and self.collider:enter('Enemy') then
        local collision_data = sword.collider:getEnterCollisionData('Enemy')
        local enemy = collision_data.collider:getObject()

        local dx, dy = collision_data.contact:getNormal()
        local chargeX, chargeY = 1, 1
        local scalingFactor = 100
        
        if self.dir == 'left' then chargeX, chargeY = -1, 1
            elseif self.dir == 'right' or self.dir == 'down' then chargeX, chargeY = 1, 1
                else chargeX, chargeY =  -1, -1 end
            
        dx = math.abs(dx * scalingFactor) * chargeX + enemy.collider:getX()
        dy = math.abs(dy * scalingFactor) * chargeY + enemy.collider:getY()
        enemy.collider:setPosition(dx, dy)

        if not collisionExecuted then
            enemy.hp = enemy.hp - 1
            collisionExecuted = true
            
            if enemy.hp ~= 0 then
                if enemy.dir == 'right' then enemy.animation = enemy.animations.dmgRight
                else enemy.animation = enemy.animations.dmgLeft end
                
                enemy.dir = 'dmg'
                enemy.collider:setLinearVelocity(0, 0)
                enemy.animation:gotoFrame(1)
            end
        end
    else collisionExecuted = false end

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function sword:mousepressed(dir)
    self.dir = dir

    clock.script(function(wait)
        local colliderX, colliderY
        local animSpd = player.animation.intervals[2]

        wait(animSpd)
        self.strike = true

        if self.dir == 'right' then
            colliderX = player.x
            colliderY = player.y - player.height
        elseif self.dir == 'left' then
            colliderX = player.x - self.width - player.width
            colliderY = player.y - player.height
        elseif self.dir == 'down' then
            colliderX = player.x - player.width + 10
            colliderY = player.y - self.height/2
        else
            colliderX = player.x + 5
            colliderY = player.y - self.height
        end

        clock.during(player.animation.intervals[3], function()
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
            colliderX = player.x
            colliderY = player.y
        elseif self.dir == 'left' then
            colliderX = player.x - self.width - player.width
            colliderY = player.y
        elseif self.dir == 'down' then
            colliderX = player.x + 10
            colliderY = player.y - self.height/2
        else
            colliderX = player.x - player.width + 5
            colliderY = player.y - self.height
        end
    end)
end