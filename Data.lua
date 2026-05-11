MobIntel.data = {}
MobIntel.data.creature = {}
MobIntel.data.area = {}
MobIntel.data.sharing = {}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "MobIntel" then return end
    MobIntelDB = MobIntelDB or {}
    if not MobIntelDB.creature then MobIntelDB.creature = {} end
    if not MobIntelDB.area then MobIntelDB.area = {} end
    if not MobIntelDB.settings then MobIntelDB.settings = {} end
    if not MobIntelDB.sharing then MobIntelDB.sharing = {} end
    if not MobIntelDB.sharing.deletedNotes then MobIntelDB.sharing.deletedNotes = {} end
    if not MobIntelDB.sharing.sourceInfo then MobIntelDB.sharing.sourceInfo = {} end
    if not MobIntelDB.lastEditDate then MobIntelDB.lastEditDate = time() end
    if MobIntelDB.settings.autoShare == nil then MobIntelDB.settings.autoShare = true end

    -- for npcId, creatureData in pairs(MobIntelDB.creature) do
    --     for j, note in ipairs(creatureData.notes) do
    --         if not note.createdDate
    --         then
    --             note.createdDate = time()
    --         end
    --         if not note.lastEditDate1
    --         then
    --             note.lastEditDate = note.createdDate
    --         end
    --         if not note.authorName
    --         then
    --             note.authorName = UnitName("Player")
    --         end
    --     end
    -- end

    for npcId, creatureData in pairs(MobIntelDB.creature) do
        for j, note in ipairs(creatureData.notes) do
            if note.author == MobIntel.utils.getCurrentPlayerGuid()
            then
                MobIntelDB.lastEditDate = max(MobIntelDB.lastEditDate, note.lastEditDate)
            end
        end
    end

end)

---@class NpcInfo
---@field guid string
---@field npcId string
---@field mapId string

---@class SpawnInfo
---@field range number
---@field mapId number
---@field x number
---@field y number

---@class CreatureNote
---@field id string
---@field author string
---@field authorName string
---@field text string
---@field npcGuid string|nil
---@field npcId string
---@field mapId number
---@field npcName string
---@field createdDate number
---@field lastEditDate number
---@field shared boolean
---@field spawn SpawnInfo|nil

---@class CreatureNotes
---@field npcId string
---@field notes CreatureNote[]

---@class AreaNote
---@field id string
---@field author string
---@field authorName string
---@field range number
---@field mapId number
---@field x number
---@field y number

---@class AreaNotes
---@field mapId number
---@field notes AreaNote[]

---@class DeletedNote
---@field type string
---@field npcId string
---@field noteId string
---@field deletionDate number

---@class SharingNote
---@field type string
---@field note any

---@class SourceInfo
---@field playerName string
---@field allowed boolean

---@param npcInfo NpcInfo
---@param npcName string
---@param text string
---@return CreatureNote
function MobIntel.data.creature.createNote(npcInfo, npcName, text)
    local creatureNote = {}
    creatureNote.id = MobIntel.utils.createRandomId()
    creatureNote.author = UnitGUID("player")
    creatureNote.authorName = UnitName("player")
    creatureNote.text = text
    creatureNote.npcGuid = npcInfo.guid
    creatureNote.npcId = npcInfo.npcId
    creatureNote.mapId = C_Map.GetBestMapForUnit("player")
    creatureNote.npcName = npcName
    creatureNote.createdDate = time()
    creatureNote.lastEditDate = time()
    creatureNote.shared = MobIntelDB.settings.autoShare == true

    return creatureNote
end

---@param npcInfo NpcInfo
---@param npcName string
---@param range number
---@param text string
---@return CreatureNote
function MobIntel.data.creature.createSpawnNote(npcInfo, npcName, range, text)
    local creatureNote = {}
    creatureNote.id = MobIntel.utils.createRandomId()
    creatureNote.author = UnitGUID("player")
    creatureNote.authorName = UnitName("player")
    creatureNote.npcGuid = npcInfo.guid
    creatureNote.text = text
    creatureNote.npcId = npcInfo.npcId
    creatureNote.mapId = C_Map.GetBestMapForUnit("player")
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

---@param creatureNote CreatureNote
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
    MobIntel.event.trigger("CREATURE_NOTE_ADDED", creatureNote)
end

---@param creatureNote CreatureNote
---@param text string
function MobIntel.data.creature.updateNoteText(creatureNote, text)
    creatureNote.text = text
    creatureNote.lastEditDate = time()
    MobIntelDB.lastEditDate = time()
    MobIntel.event.trigger("CREATURE_NOTE_UPDATED", creatureNote)
end

---@param creatureNote CreatureNote
---@param shared boolean
function MobIntel.data.creature.updateNoteShared(creatureNote, shared)
    creatureNote.shared = shared
    creatureNote.lastEditDate = time()
    MobIntelDB.lastEditDate = time()
    MobIntel.event.trigger("CREATURE_NOTE_UPDATED", creatureNote)
end

---@return number
function MobIntel.data.getLastEditDate()
    return MobIntelDB.lastEditDate
end

---@param npcId string
---@param noteId string
function MobIntel.data.creature.deleteNote(npcId, noteId)
    local creatureData = MobIntelDB.creature[npcId]
    if not creatureData then return end
    for i, note in ipairs(creatureData.notes) do
        if note.id == noteId then
            local deletedNote = table.remove(creatureData.notes, i)
            MobIntel.event.trigger("CREATURE_NOTE_DELETED", deletedNote)
            table.insert(MobIntelDB.sharing.deletedNotes, {type = "creature", npcId = npcId, noteId = note.Id, deletionDate = time()})
            if #creatureData.notes == 0 then
                MobIntelDB.creature[npcId] = nil
            end
            return
        end
    end
end

---@param npcId string
function MobIntel.data.creature.clearNotes(npcId)
    -- FIXME: Notify deletion for all notes
    MobIntelDB.creature[npcId] = nil
end

---@param npcId string
---@return CreatureNotes|nil
function MobIntel.data.creature.getNotes(npcId)
    return MobIntelDB.creature[npcId]
end

---@return CreatureNote|nil
function MobIntel.data.creature.getNote(npcId, noteId)
    ---@type CreatureNotes
    local creatureData = MobIntelDB.creature[npcId]
    if not creatureData then return nil end
        for i, note in ipairs(creatureData.notes) do
        if note.id == noteId then
            return note
        end
    end
    return nil
end

---@param playerName string
---@return boolean
function MobIntel.data.sharing.isSourceAllowed(playerName)
    local sourceInfo = MobIntelDB.sourceInfo[playerName]
    if not sourceInfo
    then
        sourceInfo = {
            playerName = playerName,
            allowed = true
        }
        MobIntelDB.creature[playerName] = sourceInfo
    end

    return sourceInfo.allowed
end

---@param sourcePlayerGuid string
---@return number
function MobIntel.data.sharing.getLastEditDateFromSource(sourcePlayerGuid)
    local maxLastEditDate = 0

    for npcId, creatureData in pairs(MobIntelDB.creature) do
        for j, note in ipairs(creatureData.notes) do
            if note.author == sourcePlayerGuid
            then
                maxLastEditDate = max(maxLastEditDate, note.lastEditDate)
            end
        end
    end

    return maxLastEditDate
end

---@param receivedNotes SharingNote[]
function MobIntel.data.sharing.mergeReceivedNotes(receivedNotes)
    for i, value in ipairs(receivedNotes) do
        if value.type == "creature"
        then
            ---@type CreatureNote
            local updatedNote = value.note
            local existingNote = MobIntel.data.creature.getNote(updatedNote.npcId, updatedNote.id)
            if existingNote
            then
                existingNote.text = updatedNote.text
                existingNote.lastEditDate = updatedNote.lastEditDate
            else
                MobIntel.data.creature.addNote(updatedNote)
            end
        elseif value.type == "delete"
        then
            ---@type DeletedNote
            local deletedNote = value.note
            if deletedNote.type == "creature"
            then
                MobIntel.data.creature.deletedNote(deletedNote.npcId, deletedNote.noteId)
            end
        end
        
    end
end

---@param minEditDate number
---@return SharingNote[]
function MobIntel.data.sharing.getNotesEditedSince(minEditDate)
    if MobIntelDB.lastEditDate <= minEditDate
    then
        return {}
    end

    local notesToSend = {}

    for npcId, creatureData in pairs(MobIntelDB.creature) do
        for j, note in ipairs(creatureData.notes) do
            if note.author == MobIntel.utils.getCurrentPlayerGuid() and note.lastEditDate > minEditDate
            then
                table.insert(notesToSend, {type = "creature", note = note})
            end
        end
    end

    for i, deletedNote in ipairs(MobIntelDB.sharing.deletedNotes) do
        if deletedNote.deletionDate > minEditDate
        then
            table.insert(notesToSend, {type = "deleted", note = deletedNote})
        end
    end

    return notesToSend;
end

---@param range number
---@return AreaNote
function MobIntel.data.area.createNote(range)
    local mapId, x, y = MobIntel.utils.getPlayerPosition();
    local areaNote = {
        id = MobIntel.utils.createRandomId(),
        author = UnitGUID("player"),
        authorName = UnitName("player"),
        range = tonumber(range),
        mapId = mapId,
        x = x,
        y = y,
    }

    return areaNote
end

---@param areaNote AreaNote
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
    MobIntelDB.lastEditDate = time()
end

---@param mapId number
---@return AreaNotes|nil
function MobIntel.data.area.getNotes(mapId)
    return MobIntelDB.area[mapId]
end
