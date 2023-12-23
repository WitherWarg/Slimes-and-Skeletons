function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    require('/src/utilities/require')

    Gamestate.registerEvents()
    Gamestate.switch(demo_level)
end