function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    math.randomseed(os.time())
    
    require('/src/utilities/require')
    
    WIDTH, HEIGHT = love.graphics.getDimensions()
    SX, SY = 1, 1
    entX, entY = 3 * SX, 3 * SY
    world = wf.newWorld(0, 0)
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
        cam:lookAt(player.x, player.y)
        
        if FPS then love.timer.sleep(1/FPS) end
    end
end

function love.draw()
    love.graphics.setColor(hsl(103, 28, 38))
    love.graphics.rectangle("fill", 0, 0, WIDTH*SX, HEIGHT*SY)

    love.graphics.reset()
    cam:attach()
        if slime.y > player.y then
            player:draw()
            sword:draw()
            slime:draw()
        else
            slime:draw()
            player:draw()
            sword:draw()
        end
        --world:draw()
    cam:detach()

    local status, result = pcall(function()
        debug(collision)
    end)

    if not status then
        love.graphics.reset()
        love.graphics.print(result)
    end
end

function love.resize(w, h)
    SX, SY = (w/WIDTH), (h/HEIGHT)
    entX, entY = 3 * SX, 3 * SY
    
    sword:resize(SX, SY)
    player:resize(entX, entY)
    slime:resize(entX, entY)
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