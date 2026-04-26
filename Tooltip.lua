GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    local _, unit = tooltip:GetUnit()
    if not unit then return end

    local npcId = MobIntel.utils.getNpcId(UnitGUID(unit))
    if not npcId then return end

    local creatureNotes = MobIntel.data.creature.getNotes(npcId)
    if not creatureNotes then return end
    if creatureNotes then
        tooltip:AddLine(MobIntel.utils.PLUGIN_NAME_COLOR)

        for i, value in ipairs(creatureNotes.notes) do
            local spawn = value.spawn;
            if spawn
            then
                local distance = MobIntel.utils.getDistanceTo(spawn.mapId, spawn.x, spawn.y)
                if distance and distance < spawn.range
                then
                    tooltip:AddLine("  [" .. MobIntel.utils.formatPlayerName(value.author) .. "] " .. value.text )
                end
            else
                tooltip:AddLine("  [" .. MobIntel.utils.formatPlayerName(value.author) .. "] " .. value.text )
            end
        end
    end
end)