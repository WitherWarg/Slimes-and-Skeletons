return function(t)
    if type(t) == 'table' then
        for key, value in pairs(t) do
            print(string.format("%s: %s", key, value))
        end
    end
end