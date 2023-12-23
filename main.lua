function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    require('src/utilities/require')
    
    gamestate.registerEvents()
    gamestate.switch(demo_level)
end