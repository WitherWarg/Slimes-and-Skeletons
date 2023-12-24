local game_over = {}

function game_over:enter()
    timer.clear()

    for _, entity in ipairs( {slime, skeleton} ) do
        for i=#entity, 1, -1 do
            local e = entity[i]
            e.timer:clear()
            table.remove(entity, i)
        end
    end

    world:destroy()
    world = nil

    if player.dir == 'up' then
        player.dir = 'right'
    elseif player.dir == 'down' then
        player.dir = 'left'
    end

    player.animation = player:getAnimation()
end

function game_over:update(dt)
    player.animation:update(dt)
    cam:lookAt(player.x, player.y)
end

function game_over:draw()
    cam:attach()

    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(hsl(0, 100, 50, 50))
    love.graphics.rectangle("fill", player.x - WIDTH/2, player.y - HEIGHT/2, WIDTH, HEIGHT)
    
    if player.animation.position == #player.animation.frames then
        love.graphics.translate(0, -25)

        local font = love.graphics.newFont('/font/game_over.ttf', 90)
        local text = 'Game Over'
        love.graphics.setFont(font)
        love.graphics.setColor(hsl(0,0,0))
        for i=1, 10 do love.graphics.print(text, player.x, player.y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2) end
        
        if math.floor(love.timer.getTime()/0.5) % 2 == 0 then
            font = love.graphics.newFont('/font/game_over.ttf', 30)
            text = 'Press any button to restart'
            love.graphics.setFont(font)
            local y = player.y + font:getHeight() * 2
            love.graphics.print(text, player.x, y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2)
        end

        love.graphics.translate(0, 25)
    end

    love.graphics.setColor(r, g, b, a)
    
    player:draw()

    cam:detach()
end

function game_over:mousepressed()
    game_over:keypressed()
end

function game_over:keypressed()
    if player.animation.position == #player.animation.frames then
        Gamestate.switch(demo_level)
    end
end

return game_over