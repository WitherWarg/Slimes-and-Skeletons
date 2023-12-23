local folders = {
    'libraries',
    'src/functions',
    'src/utilities',
    'src/gamestates',
    'src/entities',
    'libraries/hump'
}

for _, folder in ipairs(folders) do
    local folder = '/' .. folder
    local files = love.filesystem.getDirectoryItems(folder)

    for _, file in ipairs(files) do
        pcall(function()
            local info = love.filesystem.getInfo(file)
            local moduleName = file:match("(.+)%.lua$") 

            if not moduleName then
                moduleName = file
            end

            _G[moduleName] = require(folder .. '/' .. moduleName)
        end)
    end
end