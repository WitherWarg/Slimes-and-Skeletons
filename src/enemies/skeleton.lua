skeleton = {}

local function new(x, y)
    local statData = { x = x, y = y, aggro = 200, attackAggro = 70, hp = 4, spd = 75, width = 8, height = 4 }
    local spriteData = { path = '/sprites/characters/skeleton.png', rows = 6, columns = 5, colliderCut = 2 }
    local animations = {
        moving = { frames = '1-6', row = 2 },
        idle = { frames = '1-6', row = 1 },
        die = { frames = '1-5', row = 5, animSpd = 0.5, onLoop = 'pauseAtEnd' },
        dmg = { frames = '1-3', row = 4},
        attack = { frames = '1-5', row = 3, animSpd = {['1-2']=0.5, ['3-5']=0.2} }
    }

    table.insert(skeleton, enemy(statData, spriteData, animations))
    skeleton[#skeleton].parent = skeleton
    skeleton[#skeleton].positionInParent = #skeleton
end

return setmetatable(skeleton, { __call = function(_, ...) new(...) end, new = new })