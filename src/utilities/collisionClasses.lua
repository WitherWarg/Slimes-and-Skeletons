return function()
    world:addCollisionClass('Player')
    world:addCollisionClass('Sword', {ignores = {'Player'}})
    world:addCollisionClass('Enemy')
    world:addCollisionClass('SkeletonSword', {ignores = {'Enemy'}})
end