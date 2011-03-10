function get_client(matcher)
    for _, c in pairs(client.get()) do
        if matcher(c) then
            return c
        end
    end
end

function get_clients(matcher)
    result = {}
    for _, c in pairs(client.get()) do
        if matcher(c) then
            table.insert(result, c)
        end
    end
    return result
end

function spawn_or_raise(cmd, matcher)
    local c = get_client(matcher)
    if c then
        awful.tag.viewmore(c:tags(), 1)
        client.focus = c
        c:raise()
    else
        awful.util.spawn(cmd)
    end
end

function match_client(args)
    return function(c)
        local ismatched = true
        if args.instance then
            ismatched = ismatched and c.instance == args.instance
        end
        if args.role then
            ismatched = ismatched and c.role == args.role
        end
        return ismatched
    end
end

function log(str)
    f = io.open("/tmp/awesome.log", "a+")
    f:write(str, "\n")
    f:close()
end

function rfile(filename)
    f = io.open(filename)
    result = f:read()
    f:close()
    return result
end

function get_modal_transients()
    local result = {}
    for _, c in pairs(client.get()) do
        if c.modal and c.transient_for then
            result[c.transient_for] = true
        end
    end
    return result
end

function focus_without_modal_transients(idx)
    local modal_transients = get_modal_transients()

    local i = idx
    local c = nil
    repeat
        c = awful.client.next(i)
        if not modal_transients[c] then break end
        i = i + idx
    until c == nil

    if c then
        client.focus = c
        c:raise()
        if c.modal then
            awful.client.focus.history.add(c.transient_for)
        end
    end
end

function remove_key(keys, mods, key)
    for i, k in pairs(keys) do
        if awful.key.match(k, mods, key) then
            table.remove(keys, i)
        end
    end
end