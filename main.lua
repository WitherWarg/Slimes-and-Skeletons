function love.load()
    require('/src/utilities/require')

    love.graphics.setDefaultFilter("nearest", "nearest")
    
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    createCollisionClasses()
    FPS = nil

    SX, SY = 2, 2
    WIDTH, HEIGHT = love.graphics.getDimensions()
    WIDTH, HEIGHT = WIDTH/SX, HEIGHT/SY
    cam = camera()
    cam:zoom(SX)

    Demo = sti('/maps/levels/Demo.lua')
    
    player:load(Demo.tilewidth * Demo.width / 2, Demo.tileheight * Demo.height / 2)

    for _, obj in pairs(Demo.layers["Walls"].objects) do
        local wall = world:newBSGRectangleCollider(obj.x, obj.y, obj.width, obj.height, 10)
        wall:setType('static')
    end
end

function love.update(dt)
    if not pause then
        if not player.dead then
            world:update(dt)
            if FPS then love.timer.sleep(1/FPS) end
        end
        
        flux.update(dt)
        player:update(dt)
        slime:update(dt)
        clock.update(dt)

        cam:lookAt(player.x, player.y)
        local w, h = Demo.tilewidth * Demo.width, Demo.tileheight * Demo.height
        cam.x = math.max(math.min(cam.x, w - WIDTH/2), WIDTH/2)
        cam.y = math.max(math.min(cam.y, h - HEIGHT/2), HEIGHT/2)
    end
end

function love.draw()
    local function reset()
        love.graphics.setColor(hsl(0, 0, 100))
    end
    
    cam:attach()
    for key, value in pairs(Demo.layers) do
        if type(key) == 'number' and value.type == 'tilelayer' then
            value:draw()
        end
    end

    if player.dead then
        reset()
        deathScreen()
    end
    reset()
    drawEntities(player, slime)
    --world:draw()
    cam:detach()
    
    love.graphics.scale(SX, SY)
    reset()
    player.hearts:draw(reset)
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

        if key == 'n' then slime() end
    end
end