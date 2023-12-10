return function()
    world:addCollisionClass('Player')
    world:addCollisionClass('Sword', {ignores = {'All'}})
    world:addCollisionClass('Enemy')
    world:addCollisionClass('SkeletonSword', {ignores = {'Enemy'}})
    world:addCollisionClass('Dead', {ignores = {'All'}})
    world:addCollisionClass('Wall')
end