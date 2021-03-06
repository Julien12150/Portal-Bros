mushroom = class("mushroom")

function mushroom:init(x, y, screen)
    self.x = x
    self.y = y

    self.width = 16
    self.height = 16

    self.speedx = 0
    self.speedy = 0

    self.quadi = 1

    self.mask =
    {
        "tile",
        "mario",
        "coinblock"
    }

    self.initial = false
    self.active = true
    self.static = true

    self.gravity = 0
    self.timer = 0

    self.screen = screen

    self.deSpawn = 0.5
end

function mushroom:update(dt)
    if not self.initial then
        self.y = self.y - 24 * dt
        if self.timer < 0.65 then
            self.timer = self.timer + dt
        else
            self.initial = true
            self.static = false
            self.speedx = -48
            self.gravity = 8
        end 
    end

    if not inCamera(self) then
        if self.deSpawn > 0 then
            self.deSpawn = self.deSpawn + dt
        else
            self.remove = true
        end
    else
        self.deSpawn = 0.5
    end
end

function mushroom:draw()
    pushPop(self, true)

    love.graphics.setScreen(self.screen)
    love.graphics.draw(powerupImage, powerupQuads[self.quadi], self.x, self.y)

    pushPop(self)
end

function mushroom:collect(player)
    table.insert(scoreTexts, scoretext:new("1000", self.x - 4, self.y, self.screen))
    
    playSound(growSound)

    self.remove = true

    player:grow()
end

function mushroom:upCollide(name, data)
    if name == "mario" then
        self:collect(data)
    end
end

function mushroom:downCollide(name, data)
    if name == "mario" then
        self:collect(data)
    end
end

function mushroom:leftCollide(name, data)
    if name == "mario" then
        self:collect(data)
    end

    if name == "tile" then
        self.speedx = -self.speedx
        return true
    end
end

function mushroom:rightCollide(name, data)
    if name == "mario" then
        self:collect(data)
    end

    if name == "tile" then
        self.speedx = -self.speedx
        return true
    end
end