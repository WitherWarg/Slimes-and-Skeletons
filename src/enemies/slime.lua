slimes = {}

function new(_, x, y)
    local stats = { x = x, y = y, aggro = 140, radius = 5, strike_distance = 30, hp = 4, spd = 50, width = 14, height = 11 }
    local spriteData = { path = '/sprites/characters/slime.png', rows = 7, columns = 5 }
    local animations = {
        move = { frames = '1-6', row = 2, animSpd = 0.13 },
        idle = { frames = '1-4', row = 1 },
        die = { frames = '1-5', row = 5, onLoop = 'pauseAtEnd', animSpd = 0.5 },
        dmg = { frames = '1-3', row = 4 },
        strike = { frames = '1-7', row = 3, animSpd = 0.15 }
    }
    table.insert(slimes, enemy.new(stats, spriteData, animations))
    slimes[#slimes].parent = slimes
end

function slimes:update(dt)
    for i, slime in ipairs(slimes) do
        if slime.collider:isDestroyed() then
            table.remove(slimes, i)
        else
            slime:update(dt)
            slime:collision()
        end
    end
end

return setmetatable(slimes, {__call = new})