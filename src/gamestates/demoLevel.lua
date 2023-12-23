local demo_level = {}

function demo_level:enter()
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    createCollisionClasses()

    FPS = nil

    loadMapObjects()

    cam = camera()
    cam:zoom(3)

    WIDTH, HEIGHT = love.graphics.getDimensions()
    WIDTH, HEIGHT = WIDTH / cam.scale, HEIGHT / cam.scale
    
    hud = camera()
    hud:zoom(cam.scale)
    hud:lookAt(WIDTH / 2, HEIGHT / 2)
end

function demo_level:update(dt)
    if pause then return end
    if FPS then love.timer.sleep(1/FPS) end
    
    world:update(dt)
    player:update(dt)
    
    for _, e in ipairs(slime) do e:update(dt) end
    for _, e in ipairs(skeleton) do e:update(dt) end
    
    flux.update(dt)
    timer.update(dt)

    cam:lookAt(player.x, player.y)
    local w, h = Demo.tilewidth * Demo.width, Demo.tileheight * Demo.height
    cam.x = math.max(math.min( cam.x, w - WIDTH/2 ), WIDTH/2)
    cam.y = math.max(math.min( cam.y, h - HEIGHT/2 ), HEIGHT/2)
end

function demo_level:draw()
    cam:attach()

    for key, value in pairs(Demo.layers) do
        if type(key) == 'number' and value.type == 'tilelayer' then
            value:draw()
        end
    end

    local entities = {}
        
    table.insert(entities, player)
    for _, e in ipairs(slime) do table.insert(entities, e) end
    for _, e in ipairs(skeleton) do table.insert(entities, e) end

    table.sort(entities, function(a, b) return a.y < b.y end)

    for _, e in ipairs(entities) do
        love.graphics.push()

        if e.state == 'dead' and e.animation.timer < 0.4 then
            local r = 1
            love.graphics.translate(love.math.random(-r, r), love.math.random(-r, r))
        end
        e:draw()

        love.graphics.pop()
    end

    cam:detach()

    hud:attach()

    local health_bar = love.graphics.newImage('/sprites/objects/hearts/health_bar/health_bar_decoration.png')
    local health_level = love.graphics.newImage('/sprites/objects/hearts/health_bar/health_bar.png')

    love.graphics.draw(health_bar, 10, 10)

    local width = player.hp / player.maxHp * health_level:getWidth()
    local quad = love.graphics.newQuad(0, 0, width, health_level:getHeight(), health_level:getDimensions())
    love.graphics.draw(health_level, quad, 24, 10)

    hud:detach()
end

function demo_level:mousepressed(x, y, button)
    if pause then return end

    if button == 1 then
        player:mousepressed(cam:mousePosition())
    end
end

function demo_level:keypressed(key)
    if key == 'p' or key == 'escape' then pause = not pause end

    if key == 'k' then player.hp = 0 end
end

return demo_level