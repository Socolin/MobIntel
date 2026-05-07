function MobIntel.commands.list(msg)
    if not msg
    then
        MobIntel.commands.printListHelp()
        return
    end
    local kind, args = strsplit(" ", msg, 2)
    if kind == "npc" or kind == "spawn"
    then
        MobIntel.commands.listNpcNote(args)
    end
end

function MobIntel.commands.listNpcNote(args)
    local npcId = MobIntel.utils.getTargetNpcId()
    if not npcId then return end

    local creatureNotes = MobIntel.data.creature.getNotes(npcId)
    if not creatureNotes then return end
    if creatureNotes then
        for i, value in ipairs(creatureNotes.notes) do
            local spawn = value.spawn;
            if spawn
            then
                MobIntel.utils.printSuccess(" - " .. tostring(i) .. " [" .. MobIntel.utils.formatPlayerName(value.author) .. "] [Spawn r:" .. spawn.range .. "] " .. value.text)
            else
                MobIntel.utils.printSuccess(" - " .. tostring(i) .. " [" .. MobIntel.utils.formatPlayerName(value.author) .. "] " .. value.text)
            end
        end
    end
end


function MobIntel.commands.printListHelp()
    MobIntel.utils.printSuccess("/mi list <kind>")
end