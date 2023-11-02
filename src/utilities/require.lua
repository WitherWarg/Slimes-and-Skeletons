wf = require '/libraries/windfield'
anim8 = require '/libraries/anim8'
sti = require '/libraries/sti'
camera = require '/libraries/camera'
hsl = require '/src/utilities/hsl'
clock = require '/libraries/timer'

function requireAll()
    require('/src/utilities/collisionClasses')
    require('/src/utilities/debug')

    require('/src/items/sword')
    require('/src/characters/slime')
    require('/src/characters/player')
end