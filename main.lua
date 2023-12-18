function love.load()
    require('/src/utilities/require')

    love.graphics.setDefaultFilter("nearest", "nearest")
    
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
    createCollisionClasses()
    FPS = nil

    Demo = sti('/maps/levels/Demo.lua')
    
    local Player = Demo.layers["Player"].objects[1]
    player:spawn(Player.x + Player.width/2, Player.y + Player.height/2)

    for _, obj in pairs(Demo.layers["Walls"].objects) do
        local wall = world:newBSGRectangleCollider(obj.x, obj.y, obj.width, obj.height, 10)
        wall:setCollisionClass('Wall')
        wall:setType('static')
    end

    SX, SY = 3, 3
    WIDTH, HEIGHT = love.graphics.getDimensions()
    WIDTH, HEIGHT = WIDTH/SX, HEIGHT/SY
    cam = camera()
    cam:zoom(SX)
    hud = camera()
    hud:zoom(SX)
    hud:lookAt(WIDTH/2, HEIGHT/2)
end

function love.update(dt)
    if pause then return end
    if player.state == 'dead' then
        player.animation:update(dt)
        return
    end
    if FPS then
        love.timer.sleep(1/FPS)
    end
    
    world:update(dt)
    player:update(dt)
    for _, e in ipairs(slime) do e:update(dt) end
    for _, e in ipairs(skeleton) do e:update(dt) end
    cam:update(dt)
    flux.update(dt)
    clock.update(dt)
end

function love.draw()
    if player.state == 'dead' then
        cam:attach()
            deathScreen()
            player:draw()
        cam:detach()

        return
    end

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
        for _, e in ipairs(entities) do e:draw() end
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

function love.mousepressed(x, y, button, istouch, presses)
    if pause or player.state == 'dead' then return end

    if button == 1 then
        player:mousepressed()
    end
end

function love.keypressed(key)
    if key == 'p' or key == 'escape' then pause = not pause end
    
    if pause or player.state == 'dead' then return end

    if key == 'n' then slime(player.x + 240, player.y) end

    if key == 'down' then player.hp = math.max( player.hp - 20, 0 ) end
    if key == 'up' then player.hp = math.min( player.hp + 20, player.maxHp ) end
end