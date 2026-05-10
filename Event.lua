MobIntel.event = {}
local listeners = {}

function MobIntel.event.on(event, callback)
    listeners[event] = listeners[event] or {}
    table.insert(listeners[event], callback)
end

function MobIntel.event.trigger(event, ...)
    if not listeners[event] then return end
    for _, callback in ipairs(listeners[event]) do
        callback(...)
    end
end
