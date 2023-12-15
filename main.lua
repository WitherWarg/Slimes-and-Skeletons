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
end

function love.update(dt)
    if pause then return end
    if FPS then
        love.timer.sleep(1/FPS)
    end
    
    world:update(dt)
    updateAll(dt, player, slime, skeleton)
    flux.update(dt)
    clock.update(dt)

    cam:lookAt(player.x, player.y)
    local w, h = Demo.tilewidth * Demo.width, Demo.tileheight * Demo.height
    cam.x = math.max(math.min( cam.x, w - WIDTH/2 ), WIDTH/2)
    cam.y = math.max(math.min( cam.y, h - HEIGHT/2 ), HEIGHT/2)
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
        drawEntities(player, slime, skeleton)
        world:draw()
    cam:detach()

    reset()
    local font = love.graphics.newFont(15*SX)
    love.graphics.setFont(font)
end

function love.mousepressed(x, y, button, istouch, presses)
    if pause then return end

    if button == 1 then
        player:mousepressed()
    end
end

function love.keypressed(key)
    if key == 'p' or key == 'escape' then pause = not pause end
    
    if pause then return end

    if key == 'n' then slime(player.x + 240, player.y) end
end