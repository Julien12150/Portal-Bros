local tiled = {}

local tileProperties =
{
    [3] = {passive = true}, [4] = {passive = true}, [5] = {passive = true}, [6] = {passive = true}, [7] = {breakable = true}, [10] = {passive = true},
    [12] = {passive = true}, [13] = {passive = true}, [23] = {passive = true}, [24] = {passive = true}, [25] = {passive = true},
    [26] = {passive = true}, [27] = {passive = true}, [28] = {passive = true}, [30] = {passive = true}, [31] = {passive = true},
    [32] = {passive = true}, [33] = {passive = true}, [34] = {passive = true}, [35] = {passive = true}, [36] = {passive = true},
    [44] = {passive = true}, [45] = {passive = true}, [46] = {passive = true}, [47] = {passive = true}, [48] = {passive = true},
    [49] = {breakable = true}, [51] = {passive = true}, [52] = {passive = true}, [53] = {passive = true}, [54] = {passive = true}, [55] = {passive = true},
    [56] = {passive = true}, [57] = {passive = true}, [65] = {passive = true}, [66] = {passive = true}, [67] = {passive = true}, 
    [68] = {passive = true}, [69] = {passive = true}, [73] = {passive = true}, [74] = {passive = true}, [75] = {passive = true},
    [77] = {passive = true}, [86] = {passive = true}, [87] = {passive = true}, [88] = {passive = true}, [93] = {passive = true},
    [94] = {passive = true}, [95] = {passive = true}, [96] = {passive = true}, [97] = {passive = true}, [99] = {passive = true},
    [100] = {passive = true}, [101] = {passive = true}, [103] = {passive = true}, [104] = {passive = true}, [105] = {passive = true},
    [106] = {passive = true}, [107] = {passive = true}, [108] = {passive = true}, [109] = {passive = true},
    [115] = {visible = false, passive = true}, [120] = {passive = true}, [121] = {passive = true}, [123] = {passive = true},
}

function tiled:loadMap(path)
    self.map = require(path)

    self.mapWidth = {["top"] = 0, ["bottom"] = 0}
    self.mapHeight = self.map.height

    self.tiles = {}
    self.objects = {}
    self.music = {["top"] = "", ["bottom"] = ""}

    self:loadData("top")
    self:loadData("bottom")


    self.topScreen = {} 
    
    local count = 1
    
    while (love.filesystem.isFile("maps/smb/top/1-1_" .. count .. ".png")) do
        self.topScreen[count] = love.graphics.newImage("maps/smb/top/1-1_" .. count .. ".png")
        count = count + 1
    end
    
    self.bottomScreen = love.graphics.newImage("maps/smb/bottom/1-1_1.png")
end

function tiled:loadData(screen)
    local mapData, entityData = self.map.layers
    for k, v in ipairs(mapData) do
        if v.type == "tilelayer" then
            if v.name == screen .. "Tiles" then
                mapData = self.map.layers[k].data

                self.mapWidth[screen] = self.map.layers[k].properties.width
                self.mapHeight = self.map.layers[k].properties.height

                backgroundColori[screen] = self.map.layers[k].properties.background or 1

                self.music[screen] = self.map.layers[k].properties.music
            end
        elseif v.type == "objectgroup" then
            if v.name == screen .. "Objects" then
                entityData = self.map.layers[k].objects
            end
        end
    end

    
    for y = 1, self.mapHeight do
        for x = 1, self.map.width do
            local r = mapData[(y - 1) * self.map.width + x]

            if r > 0 then
                local properties = {}
                if not tileProperties[r] or tileProperties[r].breakable or tileProperties[r].visible then
                    table.insert(self.tiles, tile:new((x - 1) * 16, (y - 1) * 16, r, tileProperties[r], screen))
                end   
            end
        end
    end

    for k, v in ipairs(entityData) do
        if not self.objects[v.name] then
            self.objects[v.name] = {}
        end
        table.insert(self.objects[v.name], _G[v.name]:new(v.x, v.y, v.properties, screen))
    end
end

function tiled:render()
    love.graphics.setScreen("top")

    if objects["mario"][1].screen == "top" then
        love.graphics.setColor(unpack(backgroundColors[backgroundColori["top"]]))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(255, 255, 255)

        for x = 1, #self.topScreen do
            local t = {screen = "top", i = x, x = (x - 1) * 400, width = 400}
            pushPop(t, true)

            if inCamera(t) then
                love.graphics.draw(self.topScreen[x], 0 + (x - 1) * 400, 0)
            end

            pushPop(t)
        end
    end

    love.graphics.push()
    
    if objects["mario"][1].screen == "bottom" then
        love.graphics.setColor(unpack(backgroundColors[backgroundColori["bottom"]]))
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        love.graphics.setColor(255, 255, 255)

        local t = {screen = "bottom", x = 0, width = 400, i = 1}
        love.graphics.setScreen("bottom")
        if inCamera(t) then
            love.graphics.draw(self.bottomScreen, 0, 0)
        end
    end
    
    love.graphics.pop()
end

function tiled:changeSong(screen)
    local otherScreen = "top"
    if screen == "top" then
        otherScreen = "bottom"
    end
    print(self.music[otherScreen], self.music[screen])
    _G[self.music[otherScreen] .. "Song"]:stop()
    playSound(_G[self.music[screen] .. "Song"])
end

function tiled:getWidth(screen)
    return self.mapWidth[screen]
end

function tiled:getTiles()
    return self.tiles
end

function tiled:getObjects(name)
    return self.objects[name]
end

return tiled