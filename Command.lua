MobIntel.commands = {}


SLASH_MOBINTEL1 = "/mobintel"
SLASH_MOBINTEL2 = "/mi"
SlashCmdList["MOBINTEL"] = function(msg)
    local command, commandArgs = strsplit(" ", msg, 2)
    local handler = MobIntel.commands[command]
    if handler then
        handler(commandArgs)
    else
        MobIntel.utils.printError("Command not found")
    end
end