return function()
    player:draw()

    if player.animation.position == 3 then
        love.graphics.setColor(hsl(0, 100, 50, 50))
        love.graphics.rectangle("fill", cam.x - WIDTH/2, cam.y - HEIGHT/2, WIDTH, HEIGHT)

        local font = love.graphics.newFont('/font/game_over.ttf', 100)
        local text = 'Game Over'
        love.graphics.setFont(font)
        love.graphics.setColor(hsl(0,0,0))
        for i=1, 10 do love.graphics.print(text, cam.x, cam.y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2) end
        
        if math.floor(love.timer.getTime()/0.5) % 2 == 0 then
            font = love.graphics.newFont('/font/game_over.ttf', 40)
            text = 'Press space to restart'
            love.graphics.setFont(font)
            local y = cam.y + font:getHeight() * 2
            love.graphics.print(text, cam.x, y, nil, 1, 1, font:getWidth(text)/2, font:getHeight()/2)
        end
    end
end