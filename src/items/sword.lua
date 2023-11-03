sword = {}

function sword:load()
    self.woodImage = love.graphics.newImage('/sprites/items/wood_sword.png')
    
    self.image = self.woodImage
    self.sx = 1.4
    self.sy = 0.7
    self.width = 8 * self.sx
    self.height = 61 * self.sy
    self.type = 'wood'
end

function sword:update(dt)
    if self.dir == 'down' then
        self.x = player.x + 5 * player.sx
        self.y = player.y + 6 * player.sy

        self.radians = math.pi / 2
    elseif self.dir == 'up' then
        self.x = player.x - 5 * player.sx
        self.y = player.y + 5 * player.sy

        self.radians = math.pi * 3 / 2
    elseif self.dir == 'right' then
        self.x = player.x - 7 * player.sx
        self.y = player.y + 6 * player.sy

        self.radians = math.pi
    else
        self.x = player.x + 7 * player.sx
        self.y = player.y + 6 * player.sy

        self.radians = math.pi
    end

    if self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function sword:draw()
    if self.strike then
        love.graphics.draw(self.image, self.x, self.y, self.radians, self.sx, self.sy, self.image:getWidth() / 2, self.image:getHeight())
    end
end

function sword:mousepressed(dir)
    if self.type == 'wood' then self.image = self.woodImage end
    self.dir = dir

    clock.script(function(wait)
        local colliderX, colliderY

        wait(player.animSpd)
        self.strike = true

        if self.dir == 'down' then
            colliderX = player.x - player.width / 2
            colliderY = player.y
        elseif self.dir == 'right' then
            colliderX = player.x + player.width / 2
            colliderY = player.y - player.height
        elseif self.dir == 'left' then
            colliderX = player.x - player.width * 2
            colliderY = player.y - player.height
        else
            colliderX = player.x + player.width / 2
            colliderY = player.y - self.height / 2
        end

        clock.during(player.animSpd*3, function()
            if self.dir == 'up' or self.dir == 'down' then
                self.collider = world:newRectangleCollider(colliderX, colliderY, self.width, self.height)
            else
                self.collider = world:newRectangleCollider(colliderX, colliderY, self.height, self.width)
            end
        
            self.collider:setCollisionClass('Sword')
        end)

        wait(player.animSpd)
        self.strike = false

        if self.dir == 'down' then
            colliderX = player.x + player.width / 2 - self.width
            colliderY = player.y
        elseif self.dir == 'up' then
            colliderX = player.x - player.width / 2
            colliderY = player.y - self.height / 2
        elseif self.dir == 'right' then
            colliderX = player.x + player.width / 2
            colliderY = player.y + player.height
        else            
            colliderX = player.x - player.width * 2
            colliderY = player.y + player.height
        end
    end)
end