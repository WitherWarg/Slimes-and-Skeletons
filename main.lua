function love.load()
    require('/src/utilities/require')

    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    WIDTH, HEIGHT = love.graphics.getDimensions()
    FPS = nil
    SX, SY = 1, 1
    cam = camera()
    
    requireAll()
    
    player:load()
    slime:load()
    sword:load()
end

function love.update(dt)
    if not player.dead and not pause then
        world:update(dt)
        slime:update(dt)
        player:update(dt)
        sword:update(dt)
        clock.update(dt)
        if FPS then love.timer.sleep(1/FPS) end
    end
    
    if player.dead then
        player.animation:update(dt)
    end

    cam:lookAt(player.x, player.y)
end

function love.draw()
    love.graphics.setColor(hsl(140, 90, 20))
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

    if player.dead then
        love.graphics.reset()
        cam:attach()
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
        cam:detach()
    else
        love.graphics.reset()
        cam:attach()
            if slime.y > player.y then
                player:draw()
                slime:draw()
            else
                slime:draw()
                player:draw()
            end
            
            sword:draw()
            world:draw()
        cam:detach()
    end

    debug()
    hearts:draw()
end

function love.resize(w, h)
    SX, SY = (w/WIDTH), (h/HEIGHT)
    
    sword:resize(SX, SY)
    player:resize(SX, SY)
    slime:resize(SX, SY)

    WIDTH, HEIGHT = w, h
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not player.strike then player:mousepressed() end
end

function love.keypressed(key)
    if key == 'p' or key == 'escape' then pause = not pause end

    if key == 'space' and player.dead and player.animation.position == 3 then
        player.dead = false
        love.load()
    end
end