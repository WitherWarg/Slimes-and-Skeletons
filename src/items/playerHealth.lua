playerHealth = {}

function playerHealth:load()
    self.hp = 2
    self.hearts = 4

    self.spriteSheet = love.graphics.newImage('/img/animated/border/heart_edit.png')
    self.frameWidth = self.spriteSheet:getWidth() / 3
    self.frameHeight = self.spriteSheet:getHeight()
    local g = anim8.newGrid(self.frameWidth, self.frameHeight, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    self.animations = {}
    for i=1, self.hearts do
        table.insert(self.animations, anim8.newAnimation(g('1-3', 1), player.animSpd))
    end
end

function playerHealth:update()
    self.hp = self.hp - 1
    self.animations[self.hearts]:gotoFrame(3 - self.hp)

    if self.hp == 0 then
        self.hearts = self.hearts - 1
        self.hp = 2
    end
end

function playerHealth:draw()
    for i, animation in ipairs(self.animations) do
        animation:draw(self.spriteSheet, WIDTH - 25 * player.sx * i, 10 * player.sy, nil, player.sx, player.sy)
    end
end