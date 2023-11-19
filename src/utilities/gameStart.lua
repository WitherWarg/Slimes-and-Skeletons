function gameStart()
    world = wf.newWorld(0, 0)
    world:setQueryDebugDrawing(true)
        
    createCollisionClasses()
    player:load()
    
    player.dead = false
end

return gameStart