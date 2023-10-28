sword = {}

function sword:load()
    self.wood = {}
        self.wood.image = love.graphics.newImage('/sprites/items/wood_sword.png')
        self.SX = 1.4
        self.SY = 0.7
        self.wood.width = 8 * self.SX
        self.wood.height = 61 * self.SY
    
    self.current = self.wood
end

function sword:update(dt)
    if self.strikeTimer1 then
        self.strikeTimer1 = self.strikeTimer1 - dt

        if self.strikeTimer1 < 0 then
            if self.dir == 'down' then
                self.strikeTimer1 = nil

                self.x = player.x + 5 * entX
                self.y = player.y + 6 * entY

                self.colliderX = player.x + player.width / 2 - self.current.width
                self.colliderY = player.y + player.height / 2

                self.strikeTimer2 = player.animSpd
                self.radians = math.pi / 2

            elseif self.dir == 'up' then
                self.strikeTimer1 = nil

                self.x = player.x - 5 * entX
                self.y = player.y + 5 * entY

                self.colliderX = player.x - player.width / 2
                self.colliderY = player.y - player.height * 3 / 2

                self.strikeTimer2 = player.animSpd
                self.radians = math.pi * 3 / 2

            elseif self.dir == 'right' then
                self.strikeTimer1 = nil

                self.x = player.x - 8 * entX
                self.y = player.y + 6 * entY

                self.colliderX = player.x + player.width / 2
                self.colliderY = player.y + player.height - self.current.width * 2

                self.strikeTimer2 = player.animSpd
                self.radians = math.pi

            else
                self.strikeTimer1 = nil

                self.x = player.x + 7 * entX
                self.y = player.y + 6 * entY

                self.colliderX = player.x - player.width * 2
                self.colliderY = player.y + player.height - self.current.width * 2

                self.strikeTimer2 = player.animSpd
                self.radians = math.pi
            end
        end
    end

    if self.dir and self.strikeTimer2 then
        self.strikeTimer2 = self.strikeTimer2 - dt

        if self.strikeTimer2 < 0 then        
            self.strikeTimer2 = nil
        end
    end

    --[[local status, result = pcall(function()
        if player.strike and self.collider:enter('Enemy') then
            collision = true
            local collision_data = collider:getEnterCollisionData('Enemy')
            local dx, dy = collision_data.contact:getNormal()
            dx, dy = dx*-math.pow(10, 10), dy*-math.pow(10, 10)

            collision_data.collider:applyLinearImpulse(dx, dy)
        else
            collision = false
        end
    end)]]
end

function sword:draw()
    if player.strike then
        if self.strikeTimer2 then
            love.graphics.draw(self.current.image, self.x, self.y, self.radians, self.SX, self.SY, self.current.image:getWidth() / 2, self.current.image:getHeight())
        end

        if self.collider then
            self.collider:destroy()
            self.collider = nil
        end

        if self.dir == 'up' or self.dir == 'down' then
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.current.width, self.current.height)
        else
            self.collider = world:newRectangleCollider(self.colliderX, self.colliderY, self.current.height, self.current.width)
        end

        if self.collider then
            self.collider:setCollisionClass('Sword')
        end

    elseif self.collider then
        self.collider:destroy()
        self.collider = nil
    end
end

function sword:mousepressed(dir, swordType)
    if swordType == 'wood' then
        self.current = self.wood
    end

    if dir == 'down' then
        self.colliderX = player.x - player.width / 2
        self.colliderY = player.y + player.height / 2
    elseif dir == 'right' then
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - player.height + self.current.width * 2
    elseif dir == 'left' then
        self.colliderX = player.x - player.width * 2
        self.colliderY = player.y - player.height + self.current.width * 2
    elseif dir == 'up' then
        self.colliderX = player.x + player.width / 2
        self.colliderY = player.y - player.height * 3 / 2
    end

    self.strikeTimer1 = player.animSpd
    self.dir = dir
end

function sword:resize(SX, SY)
    self.SX = 1.4 * SX
    self.SY = 0.7 * SY
    self.current.width = 8 * self.SX
    self.current.height = 61 * self.SY
end