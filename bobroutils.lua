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

function log(...)
    for k, v in ipairs({...}) do
        io.stderr:write(tostring(v) .. ' ')
    end
    io.stderr:write('\n')
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

function focus_history_without_modal_transients(screen)
    local modal_transients = get_modal_transients()
    local result = {}

    local vc = awful.client.visible(screen)
    for k, c in ipairs(awful.client.data.focus) do
        if c.screen == screen then
            for j, vcc in ipairs(vc) do
                if vcc == c and not modal_transients[c] then
                    table.insert(result, c)
                    break
                end
            end
        end
    end

    return result
end

function remove_key(keys, mods, key)
    for i, k in pairs(keys) do
        if awful.key.match(k, mods, key) then
            table.remove(keys, i)
        end
    end
end

-- Give focus on tag selection change.
-- @param obj An object that should have a .screen property.
function check_focus(obj)
    if not client.focus or not client.focus:isvisible() then
        local c = awful.client.focus.history.get(1, 0)
        if c then client.focus = c end
    end
end

client.add_signal("unmanage", check_focus)
client.add_signal("new", function(c)
    c:add_signal("untagged", check_focus)
    c:add_signal("property::hidden", check_focus)
    c:add_signal("property::minimized", check_focus)
end)

function floating_set(c, s)
    if c then
        awful.client.property.set(c, "floating", s)
        local screen = c.screen
        if s == true then
            c:geometry(awful.client.property.get(c, "floating_geometry"))
        end
        c.screen = screen

        if s then
            if c.maximized_horizontal then
                c.maximized_horizontal = false
            end
            if c.maximized_vertical then
                c.maximized_vertical = false
            end
        end
    end
end

function isfloating(c)
    if awful.client.property.get(c, "floating") then
        return true
    else
        return false
    end
end

function floating_toggle(c)
    floating_set(c, not isfloating(c))
end