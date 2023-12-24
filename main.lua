function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    require('/src/load/require')

    Gamestate.registerEvents()
    Gamestate.switch(demo_level)
end