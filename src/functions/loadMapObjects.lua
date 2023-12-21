return function()
    Demo = sti('/maps/levels/Demo.lua')
    
    local Player = Demo.layers["Player"].objects[1]
    player:spawn(Player.x + Player.width/2, Player.y + Player.height/2)

    for _, obj in ipairs(Demo.layers["Slime"].objects) do
        slime(obj.x + obj.width / 2, obj.y + obj.height / 2)
    end

    for _, obj in ipairs(Demo.layers["Skeleton"].objects) do
        skeleton(obj.x + obj.width / 2, obj.y + obj.height / 2)
    end

    for _, obj in ipairs(Demo.layers["Walls"].objects) do
        local wall = world:newBSGRectangleCollider(obj.x, obj.y, obj.width, obj.height, 10)
        wall:setCollisionClass('Wall')
        wall:setType('static')
    end
end