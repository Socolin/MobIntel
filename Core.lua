MobIntel = {}
MobIntel.utils = {}

MobIntel.utils.PLUGIN_NAME_COLOR = "|cFF954FFF" .. "[Mob Intel]" .. "|r"
local ERROR_CHAT_CODE = "|cFFFF0000"
local SUCCESS_CHAT_CODE = "|cFF47b54c"


function MobIntel.utils.printError(msg)
    print(MobIntel.utils.PLUGIN_NAME_COLOR .. " " .. ERROR_CHAT_CODE .. msg .. "|r")
end

function MobIntel.utils.printSuccess(msg)
    print(MobIntel.utils.PLUGIN_NAME_COLOR .. " " .. SUCCESS_CHAT_CODE .. msg .. "|r")
end

function MobIntel.utils.getTargetNpcId()
    return MobIntel.utils.getNpcId(UnitGUID("target"))
end

function MobIntel.utils.getTargetNpcInfo()
    return MobIntel.utils.getNpcInfo(UnitGUID("target"))
end

function MobIntel.utils.getTargetNpcName()
    return UnitName("target")
end

function MobIntel.utils.createRandomId()
    return time() .. "_" .. math.random(1, 999999)
end

function MobIntel.utils.formatPlayerName(playerGuid)
    local name, englishClass, localizedRace, englishRace, sex, name = GetPlayerInfoByGUID(playerGuid)
    if not name then
        -- fallback: just show the raw guid or a placeholder
        return "|cFFFFFFFFUnknown player|r"
    end
    local color = RAID_CLASS_COLORS[englishClass]
    if color
    then
        local hex = string.format("|cFF%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        return hex .. name .. "|r"
    else
        return name
    end
end

function MobIntel.utils.getPlayerPosition()
    local mapId = C_Map.GetBestMapForUnit("player")
    if not mapId
    then
        return nil
    end
    local position = C_Map.GetPlayerMapPosition(mapId, "player")
    if not position
    then
        return nil
    end
    return mapId, position.x, position.y
end

function MobIntel.utils.getDistanceTo(mapId, x, y)
    local playerMapId, playerX, playerY = MobIntel.utils.getPlayerPosition()
    if playerMapId ~= mapId
    then
        return nil
    end
    if not playerX and not playerY
    then
        return nil
    end

    local mapWidth, mapHeight = MobIntel.utils.getMapSize(mapId)
    local dx = (playerX - x) * mapWidth
    local dy = (playerY - y) * mapHeight
    return math.sqrt(dx * dx + dy * dy)
end

function MobIntel.utils.getMapSize(mapId)
    local vectorCenter = CreateVector2D(0.5, 0.5)
    local vectorTopLeft = CreateVector2D(0, 0)
    local _, topLeftPos = C_Map.GetWorldPosFromMapPos(mapId, vectorTopLeft)
    local _, centerPos = C_Map.GetWorldPosFromMapPos(mapId, vectorCenter)
    local top, left = topLeftPos:GetXY()
    local bottom, right = centerPos:GetXY()
    return (left - right) * 2, (top - bottom) * 2
end

function MobIntel.utils.getNpcId(guid)
    if not guid then
        return nil
    end

    local unitType, _, _, _, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature"
    then
        return nil
    end

    return npcId;
end


function MobIntel.utils.getNpcInfo(guid)
    if not guid then
        return nil
    end

    local unitType, _, _, mapId, _, npcId = strsplit("-", guid)
    if unitType ~= "Creature"
    then
        return nil
    end

    return {
        guid = guid,
        npcId = npcId,
        mapId = mapId
    }
end