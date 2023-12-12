return function(dt, ...)
    local input = {...}
    local entities = {}

    local function iterate(t)
        for _, tbl in ipairs(t) do
            if type(tbl.draw) == 'function' then
                table.insert(entities, tbl)
            else
                iterate(tbl)
            end
        end
    end

    iterate(input)

    for _, entity in ipairs(entities) do
        entity:update(dt)
    end
end