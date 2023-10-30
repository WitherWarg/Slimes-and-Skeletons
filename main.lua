function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    
    require('/src/utilities/require')
    
    WIDTH, HEIGHT = love.graphics.getDimensions()
    FPS = nil
    SX, SY = 1, 1
    entX, entY = 3 * SX, 3 * SY
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    cam = camera()

    requireAll()

    player:load()
    --slime:load()
    sword:load()
end

function love.update(dt)
    if not pause then
        player:update(dt)
        sword:update(dt)
        world:update(dt)
        --slime:update(dt)
        if FPS then love.timer.sleep(1/FPS) end
    end

    cam:lookAt(player.x, player.y)
    local background = love.graphics.newImage('/maps/levels/Show Environnement.jpeg')
    local sx = love.graphics.getWidth()/background:getWidth()
    local sy = love.graphics.getHeight()/background:getHeight()
    cam.x = math.max(love.graphics.getWidth()/2, math.min(cam.x, background:getWidth()*sx - love.graphics.getWidth()/2))
    cam.y = math.max(love.graphics.getHeight()/2, math.min(cam.y, background:getHeight()*sx - love.graphics.getWidth()/2))
end

function love.draw()
    love.graphics.reset()
    cam:attach()
        local background = love.graphics.newImage('/maps/levels/Show Environnement.jpeg')
        local sx = love.graphics.getWidth()/background:getWidth()
        local sy = love.graphics.getHeight()/background:getHeight()
        love.graphics.draw(background, 0, 0, nil, sx, sy)

        --[[if slime.y > player.y then
            player:draw()
            slime:draw()
        else
            slime:draw()]]
            player:draw()
        --end
        
        sword:draw()
        --world:draw()
    cam:detach()

    debug()

    love.graphics.reset()
    playerHealth:draw()
end

function love.resize(w, h)
    SX, SY = (w/WIDTH), (h/HEIGHT)
    entX, entY = 3 * SX, 3 * SY
    
    sword:resize(SX, SY)
    player:resize(entX, entY)
    --slime:resize(entX, entY)
end

function love.mousepressed(x, y, button, istouch, presses)
    if button == 1 and not player.strike then
        player:mousepressed()
    end
end

function love.keypressed(key)
    if key == 'p' then
        pause = not pause
    elseif key == 'f' then
        fullscreen = not fullscreen
        love.window.setMode(WIDTH, HEIGHT, {fullscreen = fullscreen, resizable = true})
        w, h = love.graphics.getDimensions()
        love.resize(w, h)
    end
end