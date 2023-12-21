return function()
    local r, g, b, a = love.graphics.getColor()

    love.graphics.setColor(hsl(0, 100, 50, 50))
    love.graphics.rectangle("fill", player.x - WIDTH/2, player.y - HEIGHT/2, WIDTH, HEIGHT)
    
    if player.animation.position == #player.animation.frames then
        love.graphics.translate(0, -25)

        local font = love.graphics.newFont('/font/game_over.ttf', 30 * cam.scale)
        local text = 'Game Over'
        love.graphics.setFont(font)
        love.graphics.setColor(hsl(0,0,0))
        for i=1, 10 do love.graphics.print(text, player.x, player.y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2) end
        
        if math.floor(love.timer.getTime()/0.5) % 2 == 0 then
            font = love.graphics.newFont('/font/game_over.ttf', 10 * cam.scale)
            text = 'Press any button to restart'
            love.graphics.setFont(font)
            local y = player.y + font:getHeight() * 2
            love.graphics.print(text, player.x, y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2)
        end

        love.graphics.translate(0, 25)
    end

    love.graphics.setColor(r, g, b, a)
end