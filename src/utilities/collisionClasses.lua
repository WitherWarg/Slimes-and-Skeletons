return function()
    world:addCollisionClass('Player')
    world:addCollisionClass('Enemy')
    world:addCollisionClass('Wall')
    world:addCollisionClass('Dead', {ignores = {'All'}})
end