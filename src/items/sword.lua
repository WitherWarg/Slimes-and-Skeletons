sword = {}

function sword:load()
    self.wood = {}
        self.wood.image = love.graphics.newImage('/sprites/items/wood_sword.png')
        self.sx = 1.4
        self.sy = 0.7
        self.wood.width = 8 * self.sx
        self.wood.height = 61 * self.sy
    
    self.current = self.wood
end

function sword:update(dt)
    if self.strike then
        self.strike = self.strike - dt

        if self.strike < 0 then
            if self.dir == 'down' then
                self.x = player.x + 5 * player.sx
                self.y = player.y + 6 * player.sy

                self.colliderX = player.x + player.width / 2 - self.current.width
                self.colliderY = player.y

                self.radians = math.pi / 2
            elseif self.dir == 'up' then
                self.x = player.x - 5 * player.sx
                self.y = player.y + 5 * player.sy

                self.colliderX = player.x - player.width / 2
                self.colliderY = player.y - self.current.height / 2

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
    
    if not self.strike then local timer end

    if player.strike then
        if self.strike > 0 then timer = player.animSpd end

        if self.strike < 0 and timer > 0 then
            timer = timer - love.timer.getDelta()

            love.graphics.draw(self.current.image, self.x, self.y, self.radians, self.sx, self.sy, self.current.image:getWidth() / 2, self.current.image:getHeight())
        end

        if self.dir == 'up' or self.dir == 'down' then
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.current.width, self.current.height)
        else
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.current.height, self.current.width)
        end

        self.collider:setCollisionClass('Sword')
    end
end

function sword:mousepressed(dir, swordType)
    if swordType == 'wood' then
        self.current = self.wood
    end

    if dir == 'down' then
        self.colliderX = player.x - player.width / 2
        self.colliderY = player.y
    elseif dir == 'right' then
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - player.height + self.current.width * 2
    elseif dir == 'left' then
        self.colliderX = player.x - player.width * 2
        self.colliderY = player.y - player.height + self.current.width * 2
    elseif dir == 'up' then
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - self.current.height / 2
    end

    self.strike = player.animSpd
    self.dir = dir
end

function sword:resize(SX, SY)
    self.sx, self.sy = self.sx * SX, self.sy * SY
    self.current.width = self.current.width * self.sx
    self.current.height = self.current.height * self.sy
end