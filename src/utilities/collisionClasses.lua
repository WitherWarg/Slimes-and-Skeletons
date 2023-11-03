function createCollisionClasses()
    world:addCollisionClass('Player')
    world:addCollisionClass('Sword', {ignores = {'Player'}})
    world:addCollisionClass('Enemy')
end

return createCollisionClasses