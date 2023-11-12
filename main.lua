function love.load()
    require('/src/utilities/require')

    love.graphics.setDefaultFilter("nearest", "nearest")
    
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    WIDTH, HEIGHT = love.graphics.getDimensions()
    FPS = nil
    SX, SY = 1, 1
    cam = camera()
    
    requireAll()
    
    createCollisionClasses()
    player:load()
    sword:load()
end

function love.update(dt)
    if not pause then
        if not player.dead then
            world:update(dt)
            sword:update(dt)
            if FPS then love.timer.sleep(1/FPS) end
        end
        
        clock.update(dt)
        Slime:update(dt)
        player:update(dt)
        cam:lookAt(player.x, player.y)
    end
end

function love.draw()
    function reset()
        love.graphics.setColor(hsl(0, 0, 100))
    end

    -- Space for the map
    love.graphics.setColor(hsl(140, 90, 20))
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

    cam:attach()
    if player.dead then
        reset()
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
    else
        reset()

        Slime:draw()
        player:draw()
        sword:draw()
        --world:draw()
    end
    cam:detach()

    love.graphics.scale(SX, SY)
    reset()
    player.hearts:draw()
end

function love.resize(w, h)
    cam:zoom((w/WIDTH+h/HEIGHT)/2)
    
    SX, SY = SX * w/WIDTH, SY * h/HEIGHT
    WIDTH, HEIGHT = w, h
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not player.strike then player:mousepressed() end
end

function love.keypressed(key)
    if player.dead then
        if key == 'space' and player.animation.position == 3 then gameStart() end
    else
        if key == 'p' or key == 'escape' then pause = not pause end

        if key == 'h' then player.hearts:heal() end

        if key == 'n' then Slime.new(20, 20) end
    end
end