return function(...)
    local input = {...}
    local entities = {}

    local function iterate(t)
        for _, table in ipairs(t) do
            if type(table.draw) == 'function' then
                table.insert(entities, table)
            else
                iterate(table)
            end
        end
    end

    iterate(input)
    table.sort(entities, function(a, b)
        return a.y < b.y
    end)

    for _, entity in ipairs(entities) do
        entity:draw()
    end
end