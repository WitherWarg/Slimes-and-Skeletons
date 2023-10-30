function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    
    require('/src/utilities/require')
    
    WIDTH, HEIGHT = love.graphics.getDimensions()
    FPS = nil
    SX, SY = 1, 1
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    cam = camera()

    requireAll()

    player:load()
    slime:load()
    sword:load()
end

function love.update(dt)
    if not pause then
        player:update(dt)
        sword:update(dt)
        world:update(dt)
        slime:update(dt)
        if FPS then love.timer.sleep(1/FPS) end
    end

    cam:lookAt(player.x, player.y)
end

function love.draw()
    love.graphics.setColor(hsl(140, 90, 20))
    love.graphics.rectangle("fill", 0, 0, WIDTH, HEIGHT)

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

    debug()

    love.graphics.reset()
    playerHealth:draw()
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
end