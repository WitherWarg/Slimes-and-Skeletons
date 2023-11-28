return function(obj)
    if obj.tween then obj.tween:stop() end

    if not obj.collider:isDestroyed() then obj.collider:destroy() end
end