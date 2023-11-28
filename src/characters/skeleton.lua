Skeleton = {}

function Skeleton.new(x, y)
    local skeleton = {}

    skeleton.scale = player.scale
    skeleton.aggro = 300
    skeleton.hp = 6

    skeleton.x = x or player.x + skeleton.aggro
    skeleton.y = y or player.y - skeleton.aggro
    skeleton.spd = player.spd / 3

    skeleton.width = 8 * skeleton.scale
    skeleton.height = 4 * skeleton.scale

    skeleton.spriteSheet = love.graphics.newImage('/sprites/characters/skeleton.png')
    skeleton.frameWidth = skeleton.spriteSheet:getWidth() / 6
    skeleton.frameHeight = skeleton.spriteSheet:getHeight() / 5
    local g = anim8.newGrid(skeleton.frameWidth, skeleton.frameHeight, skeleton.spriteSheet:getWidth(), skeleton.spriteSheet:getHeight())

    skeleton.collider = world:newBSGRectangleCollider(skeleton.x, skeleton.y, skeleton.width, skeleton.height, 5)
    skeleton.collider:setFixedRotation(true)
    skeleton.collider:setCollisionClass('Enemy')
    skeleton.collider:setObject(skeleton)

    local animations = {
        right = { frames = '1-6', row = 2 },
        left = { frames = '1-6', row = 2, flipH = true },

        idleRight = { frames = '1-6', row = 1 },
        idleLeft = { frames = '1-6', row = 1, flipH = true },

        dieRight = { frames = '1-5', row = 5, animSpd = 0.5, onLoop = 'pauseAtEnd' },
        dieLeft = { frames = '1-5', row = 5, animSpd = 0.5, onLoop = 'pauseAtEnd', flipH = true },

        dmgRight = { frames = '1-3', row = 4},
        dmgLeft = { frames = '1-3', row = 4, flipH = true },

        strikeRight = { frames = '1-5', row = 3, animSpd = {['1-2']=0.5, ['3-5']=0.2} },
        strikeLeft = { frames = '1-5', row = 3, flipH = true, animSpd = {['1-2']=0.5, ['3-5']=0.2} }
    }

    skeleton.animations = {}
    for key, data in pairs(animations) do
        local animation = anim8.newAnimation(g(data.frames, data.row), data.animSpd or 0.2, data.onLoop)
        if data.flipH then animation:flipH() end
        skeleton.animations[key] = animation
    end

    skeleton.animation = skeleton.animations.idleRight
    skeleton.dir = 'right'
    skeleton.state = 'idle'

    function skeleton:draw()
        if self.hp > 0 or self.animation.position < 5 then
            self.animation:draw(self.spriteSheet, self.x, self.y, nil, self.scale, self.scale, self.frameWidth/2, self.frameHeight/2)
        end
    end

    skeleton.sword = {}
        skeleton.sword.width = 60
        skeleton.sword.height = 12

    function skeleton.sword:strike(defX)
        clock.script(function(wait)
            local intervals = skeleton.animation.intervals

            self.handle = clock.during((intervals[6] - intervals[3]), function()
                defX()
                if self.collider and not self.collider:isDestroyed() then self.collider:setPosition(self.x, self.y) end
            end)
            
            clock.during(intervals[5] - intervals[3], function() self.y = skeleton.y - skeleton.frameHeight/2 end)

            wait(intervals[4] - intervals[3])

            self.collider = world:newRectangleCollider(self.x, self.y, self.width, self.height)
            self.collider:setFixedRotation(true)
            self.collider:setCollisionClass('SkeletonSword')

            wait(intervals[6] - intervals[5])

            clock.during(intervals[6] - intervals[5], function() self.y = skeleton.y end)

            wait(intervals[6] - intervals[5])
            destroyObject(self)
        end)
    end

    table.insert(Skeleton, skeleton)
end

function Skeleton:update(dt)
    for i = #self, 1, -1 do
        local skeleton = self[i]

        if player.dead or skeleton.state == 'dead' and skeleton.animation.position == #skeleton.animation.frames then
            skeleton = nil
            table.remove(Skeleton, i)
            goto continue
        end

        if skeleton.x < player.x then skeleton.dir = 'right'
        else skeleton.dir = 'left' end
        skeleton.animation:update(dt)

        if skeleton.hp == 0 then
            destroyObject(skeleton)

            if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.dieRight
            else skeleton.animation = skeleton.animations.dieLeft end
            skeleton.state = 'dead'
            goto continue
        end

        skeleton.x, skeleton.y = skeleton.collider:getPosition()
        
        local dx, dy = player.x - skeleton.x, player.y - skeleton.y
        local length = math.sqrt(dx * dx + dy * dy)

        if length < skeleton.aggro then
            if length < math.sqrt(2 * 100 * 100) and not skeleton.strike then
                skeleton.strike = true
                skeleton.collider:setLinearVelocity(1, 1)

                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.strikeRight:clone()
                else skeleton.animation = skeleton.animations.strikeLeft:clone() end
                
                local currentDir = skeleton.dir
                skeleton.state = 'strike'
                local angle, radius, targetX, targetY, defX
                
                skeleton.timer = clock.during(skeleton.animations.strikeRight.intervals[3], function()                    
                    if currentDir ~= skeleton.dir then
                        skeleton.animation:flipH()
                        currentDir = skeleton.dir
                    end

                    dx, dy = player.x - skeleton.x, player.y - skeleton.y
                    angle = math.atan2(dy, dx)
                    radius = skeleton.sword.width/2
                    targetX = player.x - radius * math.cos(angle)
                    targetY = player.y + 20 - radius/2 * math.sin(angle)

                    if skeleton.dir == 'right' then defX = function() skeleton.sword.x = skeleton.x + skeleton.sword.width/2 end
                    else defX = function() skeleton.sword.x = skeleton.x - skeleton.sword.width + skeleton.sword.width/2 end end
                end, function()
                    skeleton.tween = flux.to(skeleton, skeleton.animation.totalDuration - skeleton.animation.intervals[3], {x = targetX, y = targetY}):onstart(function()
                        skeleton.sword:strike(defX)
                    end):onupdate(function()
                        if skeleton.collider then skeleton.collider:setPosition(skeleton.x, skeleton.y) end
                    end):oncomplete(function()
                        local after = function() skeleton.strike = false end
                        skeleton.handle = clock.during(0.5, function()
                            if skeleton.state == 'dmg' then
                                clock.during(skeleton.animations.dmgRight.totalDuration, function()
                                    if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.dmgRight
                                    else skeleton.animation = skeleton.animations.dmgLeft end
                                end, after)
                                clock.cancel(skeleton.handle)
                            else
                                skeleton.state = 'idle'
                                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.idleRight
                                else skeleton.animation = skeleton.animations.idleLeft end
                            end
                        end, after)
                    end)
                end)
            elseif not skeleton.strike then
                if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.right
                else skeleton.animation = skeleton.animations.left end
                skeleton.state = 'move'

                local angle = math.atan2(dy, dx)
                skeleton.collider:setLinearVelocity(skeleton.spd * math.cos(angle), skeleton.spd * math.sin(angle))
            end
        else
            if skeleton.dir == 'right' then skeleton.animation = skeleton.animations.idleRight
            else skeleton.animation = skeleton.animations.idleLeft end
            skeleton.state = 'idle'
            skeleton.collider:setLinearVelocity(0, 0)
        end
        
        ::continue::
    end
end

return Skeleton