return function(obj)
    if not obj.collider:isDestroyed() then obj.collider:destroy() end
end