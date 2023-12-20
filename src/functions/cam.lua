function cam:update(dt)
	self:lookAt(player.x, player.y)
    local w, h = Demo.tilewidth * Demo.width, Demo.tileheight * Demo.height
    self.x = math.max(math.min( self.x, w - WIDTH/2 ), WIDTH/2)
    self.y = math.max(math.min( self.y, h - HEIGHT/2 ), HEIGHT/2)
end