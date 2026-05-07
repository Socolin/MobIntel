MobIntel.area = {}

local frame = CreateFrame("Frame")
-- local elapsed = 0
local activeMapId = -1
local activeAreaNotes = {}

frame:SetScript("OnUpdate", function(self, delta)
    -- elapsed = elapsed + delta
    -- if elapsed < 0.1 then return end
    -- elapsed = 0

    local mapId, x, y = MobIntel.utils.getPlayerPosition();
    if not mapId
    then
        return
    end
    if activeMapId ~= mapId
    then
        MobIntel.area.exitMap(activeMapId)
        MobIntel.area.enterMap(mapId)
        activeMapId = mapId
    end

    MobIntel.area.updateMarkers(mapId, x, y)
end)


function MobIntel.area.exitMap(mapId)
    if mapId == -1
    then
        return
    end
end

function MobIntel.area.enterMap(mapId)
    local areaNotes = MobIntel.data.area.getNotes(mapId)
    if not areaNotes
    then
        return
    end

    for i, areaNote in ipairs(areaNotes.notes) do
        local activeAreaNote = MobIntel.area.createPin(areaNote);
        table.insert(activeAreaNotes, activeAreaNote)

        -- local distance = MobIntel.utils.getDistanceTo(areaNote.mapId, areaNote.x, areaNote.y)
        -- if distance and distance < areaNote.range
        -- then
        --     print(areaNote.text)
        -- end
    end
end

function MobIntel.area.createPin(areaNote)
    local pin = CreateFrame("Frame", nil, Minimap)
    pin:SetSize(12, 12)
    local texture = pin:CreateTexture()
    texture:SetAllPoints()
    texture:SetTexture("Interface/Minimap/ObjectIcons")

    return {
        pin = pin,
        areaNote = areaNote,
    }
end

function MobIntel.area.updateMarkers(mapId, playerX, playerY)
    local mapWidth, mapHeight = MobIntel.utils.getMapSize(mapId)

    for i, activeAreaNote in ipairs(activeAreaNotes) do
        local areaNote = activeAreaNote.areaNote
        local pin = activeAreaNote.pin
        local minimapRadius = Minimap:GetWidth() / 2
        local zoom = Minimap:GetZoom()

        local minimapZoomTable = {
            [0] = 233, [1] = 187, [2] = 156, [3] = 128,
            [4] = 100,  [5] = 64
        }
        local yardRadius = minimapZoomTable[zoom] or 233
        local scale = minimapRadius / yardRadius

        local dx = (areaNote.x - playerX) * mapWidth
        local dy = (areaNote.y - playerY) * mapHeight
        local distance = sqrt((dx*dx) + (dy*dy))
        local angle = math.atan2(dy, dx)
        local pixelDistanceFromCenter = math.min(distance, yardRadius) * scale

        pin:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * pixelDistanceFromCenter, -math.sin(angle) * pixelDistanceFromCenter)
    end

end