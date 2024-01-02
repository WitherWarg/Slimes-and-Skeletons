local drawMapLayers = function(layers)
    love.graphics.setColor(hsl(0, 0, 100))

    for id, layer in pairs(layers) do
        if type(id) == 'number' and layer.type == 'tilelayer' then
            layer:draw()
        end
    end
end

local drawText = function()
    love.graphics.push()
    love.graphics.translate(0, -25)
    
    local font = game_over.font
    love.graphics.setFont(font)
    love.graphics.setColor(0,0,0)

    local text = 'Congratulations'
    for i=1, 10 do
        love.graphics.print(text, player.x, player.y, nil, nil, nil, font:getWidth(text) / 2, font:getHeight() / 2)
    end
    
    if math.floor(love.timer.getTime()/0.5) % 2 == 0 then
        text = 'Press escape to quit'
        local w, h = font:getWidth(text), font:getHeight()
        love.graphics.print(text, player.x, player.y + h + player.height, nil, 1/3, 1/3, w/2, h/2)
    end

    love.graphics.pop()
end

local game_won = {}

function game_won:enter(previous)
    self.previous = previous
    pcall(function() game_over:enter() end)
    player.animation = player.animations.idle_down
    self.font = love.graphics.newFont('/font/game_over.ttf', 90 * cam.scale)
end

function game_won:update(dt)
    game_over:update(dt)
end

function game_won:draw()
    cam:attach()
        local r, g, b, a = love.graphics.getColor()

        love.graphics.setColor(hsl(129, 50, 39))
        love.graphics.rectangle("fill", player.x - WIDTH/2, player.y - HEIGHT/2, WIDTH, HEIGHT)

        love.graphics.push()
            love.graphics.translate(0, -25)
            drawText()
        love.graphics.pop()

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