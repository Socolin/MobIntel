function MobIntel.commands.delete(msg)
    local kind, args = strsplit(" ", msg, 2)
    if kind == "npc" or kind == "spawn"
    then
        MobIntel.commands.deleteNpcNote(args)
    end
end

function MobIntel.commands.deleteNpcNote(args)
    local npcId = MobIntel.utils.getTargetNpcId()
    if not npcId then return end

    local noteNumber, _ = strsplit(" ", args, 2)
    if not noteNumber
    then
        return
    end
    
    local creatureNotes = MobIntel.data.creature.getNotes(npcId)
    if not creatureNotes then return end
    if creatureNotes then
        table.remove(creatureNotes.notes, tonumber(noteNumber))
        if #creatureNotes.notes == 0
        then
            MobIntel.data.creature.clearNotes(npcId)
        end
    end

    MobIntel.utils.printSuccess("Note Deleted")
end