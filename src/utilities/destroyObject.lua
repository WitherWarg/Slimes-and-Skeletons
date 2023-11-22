return function(obj)
    if obj.collider then
        obj.collider:destroy()
        obj.collider = nil
    end
    if obj.tween then
        obj.tween:stop()
        obj.tween = nil
    end
end