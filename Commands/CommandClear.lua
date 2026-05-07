function MobIntel.commands.clear(msg)
    local kind, args = strsplit(" ", msg, 2)
    local npcId = MobIntel.utils.getTargetNpcId()
    if not npcId
    then
        MobIntel.utils.printError("No target")
        return
    end

    if kind == "npc"
    then
        MobIntel.data.creature.clearNotes(npcId)
        MobIntel.utils.printSuccess("Notes Removed")
    end
end
