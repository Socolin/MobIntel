MobIntel.sharing = {}
MobIntel.sharing.actionQueue = {}

local pluginPrefix = "MobIntel"
local playerName = UnitName("player")
local playerGuid = UnitGUID("player")
local receivingNotes = {}

local function OnEvent(self, event, ...)
	if event == "CHAT_MSG_ADDON" then
        local prefix, text, channel, sender = ...
        if prefix ~= pluginPrefix then return end
        if (sender == playerName) then return end

        local opCode, messageData = strsplit("|", text, 2)
        if opCode == "HELLO" then
            MobIntel.sharing.enqueueMessage(sender, "SYNC_STATUS|" .. C_EncodingUtil.SerializeJSON({playerGuid = playerGuid, lastEditDate = MobIntel.data.getLastEditDate()}))
        elseif opCode == "SYNC_STATUS" then
            local parameters = C_EncodingUtil.DeserializeJSON(messageData)
            if parameters
            then
                local lastEditDateFromSender = MobIntel.data.sharing.getLastEditDateFromSource(parameters.playerGuid)
                if parameters.lastEditDate > lastEditDateFromSender
                then
                    MobIntel.sharing.enqueueMessage(sender, "REQUEST_NOTES|" .. C_EncodingUtil.SerializeJSON({lastEditDate = lastEditDateFromSender}))
                end
            end
        elseif opCode == "REQUEST_NOTES" then
            local parameters = C_EncodingUtil.DeserializeJSON(messageData)
            if parameters
            then
                local notesToSend = MobIntel.data.sharing.getNotesEditedSince(parameters.lastEditDate);
                MobIntel.sharing.sendNotesTo(notesToSend, sender)
            end
        elseif opCode == "START_NOTES" then
            local parameters = C_EncodingUtil.DeserializeJSON(messageData)
            if parameters
            then
                receivingNotes[sender] = ""
                -- FIXME
            end
        elseif opCode == "CHUNK_NOTES" then
            receivingNotes[sender] = receivingNotes[sender] .. messageData
        elseif opCode == "END_NOTES" then
            local recievedNotes = C_EncodingUtil.DeserializeCBOR(receivingNotes[sender])
            MobIntel.data.sharing.mergeReceivedNotes(recievedNotes)
            receivingNotes[sender] = nil
        end
        -- print(event, text, sender)
	elseif event == "PLAYER_ENTERING_WORLD" then
		local isLogin, isReload = ...
		if isLogin or isReload then
			C_ChatInfo.RegisterAddonMessagePrefix(pluginPrefix)
            MobIntel.sharing.enqueueMessage("GUILD", "HELLO")
		end
	end
end

MobIntel.event.on("CREATURE_NOTE_ADDED", function (note)
    local notesToSend = {}
    if not note.sharing then return end
    if note.author ~= playerGuid then return end
    table.insert(notesToSend, {type = "creature", note = note})
    MobIntel.sharing.sendNotesTo(notesToSend, "GUILD")
end)

MobIntel.event.on("CREATURE_NOTE_UPDATED", function (note)
    local notesToSend = {}
    if not note.sharing then return end
    if note.author ~= playerGuid then return end
    table.insert(notesToSend, {type = "creature", note = note})
    MobIntel.sharing.sendNotesTo(notesToSend, "GUILD")
end)

MobIntel.event.on("CREATURE_NOTE_DELETED", function (deletedNote)
    local notesToSend = {}
    if not deletedNote.sharing then return end
    if deletedNote.author ~= playerGuid then return end
    table.insert(notesToSend, {type = "deleted", note = deletedNote})
    MobIntel.sharing.sendNotesTo(notesToSend, "GUILD")
end)

local elapsed = 0
local function OnUpdate(self, delta)
    elapsed = elapsed + delta
    if elapsed < 0.15 then return end
    elapsed = 0

    if #MobIntel.sharing.actionQueue == 0 then return end

    local action = table.remove(MobIntel.sharing.actionQueue, 1)
    if action.type == "sendMessage"
    then
        local success = C_ChatInfo.SendAddonMessage(pluginPrefix, action.message, action.channel, action.target)
    if not success then
           table.insert(MobIntel.sharing.actionQueue, 1, action)
        end
    end
end

-- C_EncodingUtil.SerializeCBOR()

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", OnEvent)
f:SetScript("OnUpdate", OnUpdate)

function MobIntel.sharing.sendNotesTo(notes, target)
    if not #notes
    then
        return
    end
    -- print("Sending ", #notes, " to ", target)
    local serializedNotes = C_EncodingUtil.SerializeCBOR(notes)
    local chunks = MobIntel.utils.splitIntoChunks(serializedNotes, 220)

    MobIntel.sharing.enqueueMessage(target, "START_NOTES|" .. C_EncodingUtil.SerializeJSON({lastEditDate = MobIntel.data.getLastEditDate(), count = #chunks}))
    for index, value in ipairs(chunks) do
        MobIntel.sharing.enqueueMessage(target, "CHUNK_NOTES|" .. value)
    end
    MobIntel.sharing.enqueueMessage(target, "END_NOTES|")
end


function MobIntel.sharing.enqueueMessage(target, message)
    if target == "GUILD"
    then
        table.insert(MobIntel.sharing.actionQueue, {
            type = "sendMessage",
            channel = "GUILD",
            message = message
        })
    else
        table.insert(MobIntel.sharing.actionQueue, {
            type = "sendMessage",
            channel = "WHISPER",
            target = target,
            message = message
        })
    end
end