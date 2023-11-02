sword = {}

function sword:load()
    self.woodImage = love.graphics.newImage('/sprites/items/wood_sword.png')
    
    self.image = self.woodImage
    self.sx = 1.4
    self.sy = 0.7
    self.width = 8 * self.sx
    self.height = 61 * self.sy
end

function sword:update(dt)
    if self.strike then
        if self.dir == 'down' then
            self.x = player.x + 5 * player.sx
            self.y = player.y + 6 * player.sy

            self.colliderX = player.x + player.width / 2 - self.width
            self.colliderY = player.y

            self.radians = math.pi / 2
        elseif self.dir == 'up' then
            self.x = player.x - 5 * player.sx
            self.y = player.y + 5 * player.sy

            self.colliderX = player.x - player.width / 2
            self.colliderY = player.y - self.height / 2

            self.radians = math.pi * 3 / 2
        elseif self.dir == 'right' then
            self.x = player.x - 7 * player.sx
            self.y = player.y + 6 * player.sy

            self.colliderX = player.x + player.width / 2
            self.colliderY = player.y + player.height

            self.radians = math.pi
        else
            self.x = player.x + 7 * player.sx
            self.y = player.y + 6 * player.sy
            
            self.colliderX = player.x - player.width * 2
            self.colliderY = player.y + player.height
            
            self.radians = math.pi
        end
    end

    if not player.strike then
        self.strike = nil
    end
end

function sword:draw()
    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
    
    if self.strike == nil and player.strike then
        clock.script(function(wait)
            wait(player.animSpd)
            self.strike = true
            wait(player.animSpd)
            self.strike = false
        end)
    end

    if self.strike then
        love.graphics.draw(self.image, self.x, self.y, self.radians, self.sx, self.sy, self.image:getWidth() / 2, self.image:getHeight())
    end

    if player.strike then
        if self.dir == 'up' or self.dir == 'down' then
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.width, self.height)
        else
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.height, self.width)
        end

        self.collider:setCollisionClass('Sword')
    end
end

function sword:mousepressed(dir, swordType)
    if swordType == 'wood' then self.image = self.woodImage end
    self.dir = dir


    if self.dir == 'down' then
        self.colliderX = player.x - player.width / 2
        self.colliderY = player.y
    elseif self.dir == 'right' then
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - player.height
    elseif self.dir == 'left' then
        self.colliderX = player.x - player.width * 2
        self.colliderY = player.y - player.height
    else
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - self.height / 2
    end
end

function sword:resize(SX, SY)
    self.sx, self.sy = self.sx * SX, self.sy * SY
    self.width = self.width * self.sx
    self.height = self.height * self.sy
end