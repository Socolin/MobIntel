MobIntel.data = {}
MobIntel.data.creature = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MobIntel" then return end
    MobIntelDB = MobIntelDB or {}
    if not MobIntelDB.creature then MobIntelDB.creature = {} end
end)


function MobIntel.data.creature.createNote(npcId, text)
    local creatureNote = {}
    creatureNote.author = UnitGUID("player")
    creatureNote.text = text
    creatureNote.npcId = npcId

    return creatureNote
end


function MobIntel.data.creature.createSpawnNote(npcId, range, text)
    local creatureNote = {}
    creatureNote.author = UnitGUID("player")
    creatureNote.text = text
    creatureNote.npcId = npcId
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