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

    createCollisionClasses()
    player:load()

    function printTable(t, check)
        check = check or true
        for key, value in pairs(t) do
            if type(value) == 'table' and check then printTable(value) end
            print(key, value)
        end
    end
end

function love.update(dt)
    if not pause then
        if not player.dead then
            world:update(dt)
            flux.update(dt)
            if FPS then love.timer.sleep(1/FPS) end
        end
        
        player:update(dt)
        Slime:update(dt)
        Skeleton:update(dt)
        clock.update(dt)
        cam:lookAt(player.x, player.y)
    end
end

function love.draw()
    local function reset()
        love.graphics.setColor(hsl(0, 0, 100))
    end

    -- Space for the map
    love.graphics.setColor(hsl(140, 90, 20))
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

    cam:attach()
    if player.dead then
        reset()
        deathScreen()
    else
        reset()
        drawEntities(player, Slime, Skeleton)
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
    if pause then return end
    if button == 1 and not player.strike then player:mousepressed() end
end

function love.keypressed(key)
    if player.dead and not pause then
        if key == 'space' and player.animation.position == 3 then gameStart() end
    else
        if key == 'p' or key == 'escape' then pause = not pause end
        
        if pause then return end
        if key == 'h' then player.hearts:heal() end

        if key == 'n' then Slime.new() end
    end
end