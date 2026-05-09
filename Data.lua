MobIntel.data = {}
MobIntel.data.creature = {}
MobIntel.data.area = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MobIntel" then return end
    MobIntelDB = MobIntelDB or {}
    if not MobIntelDB.creature then MobIntelDB.creature = {} end
    if not MobIntelDB.area then MobIntelDB.area = {} end
    if not MobIntelDB.settings then MobIntelDB.settings = {} end
    if MobIntelDB.settings.autoShare == nil then MobIntelDB.settings.autoShare = false end
end)

function MobIntel.data.creature.createNote(npcInfo, npcName, text)
    local creatureNote = {}
    creatureNote.id = MobIntel.utils.createRandomId()
    creatureNote.author = UnitGUID("player")
    creatureNote.text = text
    creatureNote.npcGuid = npcInfo.guid
    creatureNote.npcId = npcInfo.npcId
    creatureNote.mapId = npcInfo.mapId
    creatureNote.npcName = npcName
    creatureNote.createdDate = time()
    creatureNote.lastEditDate = time()
    creatureNote.shared = MobIntelDB.settings.autoShare == true

    return creatureNote
end


function MobIntel.data.creature.createSpawnNote(npcInfo, npcName, range, text)
    local creatureNote = {}
    creatureNote.id = MobIntel.utils.createRandomId()
    creatureNote.author = UnitGUID("player")
    creatureNote.npcGuid = npcInfo.guid
    creatureNote.text = text
    creatureNote.npcId = npcInfo.npcId
    creatureNote.mapId = npcInfo.mapId
    creatureNote.npcName = npcName
    creatureNote.createdDate = time()
    creatureNote.lastEditDate = time()
    creatureNote.shared = MobIntelDB.settings.autoShare == true
    local mapId, x, y = MobIntel.utils.getPlayerPosition();
    creatureNote.spawn = {
        range = tonumber(range),
        mapId = mapId,
        x = x,
        y = y,
    }

    return creatureNote
end

function MobIntel.data.creature.addNote(creatureNote)
    local creatureNotes = MobIntelDB.creature[creatureNote.npcId]
    if not creatureNotes
    then
        creatureNotes = {
            npcId = creatureNote.npcId,
            notes = {},
        }
        MobIntelDB.creature[creatureNote.npcId] = creatureNotes
    end

    table.insert(creatureNotes.notes, creatureNote)
end

function MobIntel.data.creature.clearNotes(npcId)
    MobIntelDB.creature[npcId] = nil
end

function MobIntel.data.creature.getNotes(npcId)
    return MobIntelDB.creature[npcId]
end

function MobIntel.data.area.createNote(range)
    local mapId, x, y = MobIntel.utils.getPlayerPosition();
    local areaNote = {
        id = MobIntel.utils.createRandomId(),
        author = UnitGUID("player"),
        range = tonumber(range),
        mapId = mapId,
        x = x,
        y = y,
    }

    return areaNote
end

function MobIntel.data.area.addNote(areaNote)
    local areaNotes = MobIntelDB.area[areaNote.mapId]
    if not areaNotes
    then
        areaNotes = {
            mapId = areaNote.mapId,
            notes = {},
        }
        MobIntelDB.area[areaNote.mapId] = areaNotes
    end

    table.insert(areaNotes.notes, areaNote)
    
end

function MobIntel.data.area.getNotes(mapId)
    return MobIntelDB.area[mapId]
end