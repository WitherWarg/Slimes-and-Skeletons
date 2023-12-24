local drawMapLayers = function(layers)
    for id, layer in pairs(layers) do
        if type(id) == 'number' and layer.type == 'tilelayer' then
            layer:draw()
        end
    end
end

local game_won = {}

function game_won:enter(previous)
    self.previous = previous
    pcall(function() game_over:enter() end)
    player.animation = player.animations.idle_down
end

function game_won:update(dt)
    game_over:update(dt)
end

function game_won:draw()
    love.graphics.setColor(100, 100, 100)

    cam:attach()
    
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(hsl(120, 100, 50, 50))
    love.graphics.rectangle("fill", player.x - WIDTH/2, player.y - HEIGHT/2, WIDTH, HEIGHT)

    love.graphics.translate(0, -25)

    local font = love.graphics.newFont('/font/game_over.ttf', 90)
    local text = 'CONGRATULATIONS'
    love.graphics.setFont(font)
    love.graphics.setColor(0, 0, 0)
    for i=1, 10 do love.graphics.print(text, player.x, player.y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2) end
    
    if math.floor(love.timer.getTime()/0.5) % 2 == 0 then
        font = love.graphics.newFont('/font/game_over.ttf', 30)
        text = 'Press escape to quit'
        love.graphics.setFont(font)
        local y = player.y + font:getHeight() * 2
        love.graphics.print(text, player.x, y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2)
    end

    love.graphics.translate(0, 25)
    love.graphics.setColor(r, g, b, a)
    
    player:draw()

    cam:detach()
end

function game_won:mousepressed()
    game_won:keypressed()
end

function game_won:keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    Gamestate.switch(self.previous)
end

return game_won