slime = {}

function new(_, x, y)
    local statData = { x = x, y = y, aggro = 150, attackAggro = 50, hp = 4, spd = 50, width = 14, height = 11 }

    local spriteData = { path = '/sprites/characters/slime.png', rows = 7, columns = 5 }
    local animations = {
        moving = { frames = '1-6', row = 2, animSpd = 0.13 },
        idle = { frames = '1-4', row = 1 },
        die = { frames = '1-5', row = 5, onLoop = 'pauseAtEnd', animSpd = 0.5 },
        dmg = { frames = '1-3', row = 4 },
        attack = { frames = '1-7', row = 3, animSpd = { ['1-2']=0.25, ['3-5']=0.15, ['6-7']=0.2 } }
    }
    table.insert(slime, enemy(statData, spriteData, animations))
    slime[#slime].parent = slime
end

function slime:update(dt)
    for _, self in ipairs(slime) do
        self:update(dt)
    end
end

return setmetatable(slime, {__call = new})