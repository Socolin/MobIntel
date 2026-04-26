function MobIntel.commands.add(msg)
    local kind, args = strsplit(" ", msg, 2)
    if kind == "npc"
    then
        MobIntel.commands.addNpcNote(args)
    elseif kind == "spawn"
    then
        MobIntel.commands.addNpcSpawnNote(args)
    end
end

function MobIntel.commands.addNpcNote(args)
    local npcId = MobIntel.utils.getTargetNpcId()
    if not npcId
    then
        MobIntel.utils.printError("No target")
        return
    end
    if not args
    then
        MobIntel.utils.printError("No text given")
        MobIntel.commands.printHelp()
        return
    end

    local creatureNote = MobIntel.data.creature.createNote(npcId, args)
    MobIntel.data.creature.addNote(creatureNote)
    MobIntel.utils.printSuccess("Npc Note Added")
end

function MobIntel.commands.addNpcSpawnNote(args)
    local npcId = MobIntel.utils.getTargetNpcId()
    if not npcId
    then
        MobIntel.utils.printError("No target")
        return
    end

    local range, note = strsplit(" ", args, 2)

    if not note
    then
        MobIntel.utils.printError("No text given")
        MobIntel.commands.printHelp()
        return
    end

    local creatureNote = MobIntel.data.creature.createSpawnNote(npcId, range, note)
    MobIntel.data.creature.addNote(creatureNote)
    MobIntel.utils.printSuccess("Spawn Note Added")
end

function MobIntel.commands.printHelp()
    MobIntel.utils.printSuccess("/mi add <kind>")
    MobIntel.utils.printSuccess("/mi add npc <note>: Add a note on the targeted npc")
    MobIntel.utils.printSuccess("/mi add spawn <range> <note>: Add a note on the targeted npc at a given location within given range")
end

