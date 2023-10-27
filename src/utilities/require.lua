wf = require '/libraries/windfield'
anim8 = require '/libraries/anim8'
sti = require '/libraries/sti'
camera = require '/libraries/camera'
hsl = require '/src/utilities/hsl'

function requireAll()
    require('/src/utilities/collisionClasses')
    require('/src/utilities/debug')

    require('/src/player')

    require('/src/enemies/slime')
    
    require('/src/items/sword')
end