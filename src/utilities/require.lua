wf = require '/libraries/windfield'
anim8 = require '/libraries/anim8'
sti = require '/libraries/sti'
camera = require '/libraries/camera'
clock = require '/libraries/timer'
flux = require '/libraries/flux'

hsl = require '/src/utilities/hsl'
createCollisionClasses = require '/src/utilities/collisionClasses'
gameStart = require '/src/utilities/gameStart'


function requireAll()    
    require('/src/items/sword')
    
    require('/src/characters/enemy')
    require('/src/characters/player')
end