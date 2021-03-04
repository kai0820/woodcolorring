local Log = {}
local TAB = "   "
function Log.print(...)
    print(...)
end

function Log.printAll(params, space)
    space = space ~= nil and space .. TAB or ""
    if type(params) ~= "table" then
        Log.print(params)
        return
    end
    -- Log.print(type(params) .. ":")
    for k,v in pairs(params) do
        if type(v) ~= "table" then
            -- Log.print(space .. "table:")
            Log.print(space .. k .. ":" .. v)
            -- Log.print(space .. "value = " .. v, type(v))
            -- Log.print(k, v)
        else
            Log.print(k .. ":")
            Log.printAll(v, space)
        end
    end

end

return Log