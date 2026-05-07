function MobIntel.commands.add(msg)
    local kind, args = strsplit(" ", msg, 2)
    if kind == "npc"
    then
        MobIntel.commands.addNpcNote(args)
    elseif kind == "spawn"
    then
        MobIntel.commands.addNpcSpawnNote(args)
    elseif kind == "area"
    then
        MobIntel.commands.addAreaNote(args)
    end
end

function MobIntel.commands.addNpcNote(args)
    local npcName = MobIntel.utils.getTargetNpcName() or ""
    local npcInfo = MobIntel.utils.getTargetNpcInfo()
    if not npcInfo
    then
        MobIntel.utils.printError("No target")
        return nil
    end
    if not args
    then
        MobIntel.utils.printError("No text given")
        MobIntel.commands.printAddHelp()
        return
    end

    local creatureNote = MobIntel.data.creature.createNote(npcInfo, npcName, args)
    MobIntel.data.creature.addNote(creatureNote)
    MobIntel.utils.printSuccess("Npc Note Added")
end

function MobIntel.commands.addNpcSpawnNote(args)
    local npcName = MobIntel.utils.getTargetNpcName() or ""
    local npcInfo = MobIntel.utils.getTargetNpcInfo()
    if not npcInfo
    then
        MobIntel.utils.printError("No target")
        return nil
    end

    local range, note = strsplit(" ", args, 2)

    if not note
    then
        MobIntel.utils.printError("No text given")
        MobIntel.commands.printAddHelp()
        return
    end


    local _, x, y = MobIntel.utils.getPlayerPosition();
    if not x and not y
    then
        MobIntel.utils.printError("Position unknown, not usable in dungeon")
        return
    end
    print(x, y)

    local creatureNote = MobIntel.data.creature.createSpawnNote(npcInfo, npcName, range, note)
    MobIntel.data.creature.addNote(creatureNote)
    MobIntel.utils.printSuccess("Spawn Note Added")
end

function MobIntel.commands.addAreaNote(args)
    local range, note = strsplit(" ", args, 2)
    local areaNote = MobIntel.data.area.createNote()
    MobIntel.data.area.addNote(areaNote)
end

function MobIntel.commands.printAddHelp()
    MobIntel.utils.printSuccess("/mi add <kind>")
    MobIntel.utils.printSuccess("/mi add npc <note>: Add a note on the targeted npc")
    MobIntel.utils.printSuccess("/mi add spawn <range> <note>: Add a note on the targeted npc at a given location within given range")
end

