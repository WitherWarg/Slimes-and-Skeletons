function debug(...)
    local text = {...}
    
    if #text > 0 then
        local font = love.graphics.setNewFont(10*(SX+SY))

        local len = ''
        for i=1, #text do
            text[i] = tostring(text[i])
            if font:getWidth(text[i]) > font:getWidth(len) then len = text[i] end
        end
        
        local textWidth = font:getWidth(len) + 10
        local lineHeight = font:getHeight() + 5
        local textHeight = lineHeight * #text + 5
        
        love.graphics.setColor(hsl(0, 0, 0, 60))
        love.graphics.rectangle("fill", 20, 20, textWidth, textHeight)

        love.graphics.setFont(font)
        love.graphics.setColor(hsl(0, 0, 75))
        
        for i, line in ipairs(text) do
            love.graphics.print(line, 25, 25 + (i - 1) * lineHeight)
        end
    end
end