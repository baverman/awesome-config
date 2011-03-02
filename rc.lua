require("origrc")  -- it's a symlink to /etc/xdg/awesome/rc.lua
require("vicious")
require("bobroutils")
require("tbar")
-- require("data_dump")

terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

naughty.config.margin           = 10
naughty.config.height           = 30
naughty.config.width            = 300


-- {{{ Tags
-- Define tags table.
tags = {}
for s = 1, screen.count() do
    local tt = awful.tag({"main", "con", "gimp"}, s)

    tags[s] = {}
    tags[s]["main"] = tt[1]
    tags[s]["con"] = tt[2]
    tags[s]["gimp"] = tt[3]

    screen[s]:tags(tt)

    awful.layout.set(awful.layout.suit.float, tags[s]["main"])
    awful.layout.set(awful.layout.suit.max, tags[s]["con"])
    awful.layout.set(awful.layout.suit.float, tags[s]["gimp"])

    tags[s]["main"].selected = true
end
-- }}}

mytasklist.buttons = awful.util.table.join(mytasklist.buttons,
    awful.button({ }, 2, function (c) c:kill() end) )

spacer = widget({ type = "textbox" })
spacer.text = " "

cpuwidget = awful.widget.graph()
cpuwidget:set_width(40)
cpuwidget:set_height(16)
cpuwidget:set_background_color(beautiful.bg_normal)
cpuwidget:set_color('#FF5656')
cpuwidget:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
cpuwidget.layout = awful.widget.layout.horizontal.rightleft
awful.widget.layout.margins[cpuwidget.widget] = { top = 1, left = 3 }
vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)

mytextclock = awful.widget.textclock({}, "%H:%M", 10)

awful.widget.layout.margins[mysystray] = { top = 1, bottom = 2 }

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
        local text, bg, status_image, icon = awful.widget.tasklist.label.currenttags(c, s)
        return text, bg, status_image, nil
    end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s})
    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mytaglist[s],
            mylauncher,
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        {
            s == 1 and mysystray or nil,
            spacer,
            mytextclock,
            spacer,
            cpuwidget,
            layout = awful.widget.layout.horizontal.rightleft
        },
        mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}

remove_key(globalkeys, { modkey }, 'Tab')

globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "F1", function () mypromptbox[mouse.screen]:run() end),
    awful.key({ modkey }, "[", function() awful.util.spawn("mpc volume -2") end),
    awful.key({ modkey }, "]", function() awful.util.spawn("mpc volume +2") end),

    awful.key({}, "XF86MonBrightnessUp", function() awful.util.spawn("sudo backlight up") end),
    awful.key({}, "XF86MonBrightnessDown", function() awful.util.spawn("sudo backlight down") end),

    awful.key({modkey}, "n", function() spawn_or_raise("urxvtc -name mutt -e mutt",
        match_client{instance='mutt'}) end),

    awful.key({"Control", "Mod1"}, "p",  function() spawn_or_raise("urxvtc -name ncmpcpp -e ncmpcpp",
        match_client{instance='ncmpcpp'}) end),

    awful.key({modkey}, "i",  function() spawn_or_raise("urxvtc -name mcabber -e mcabber",
        match_client{instance='mcabber'}) end),

    awful.key({"Control", "Mod1"}, "m",  function() spawn_or_raise("urxvtc -name amixer -e alsamixer",
        match_client{instance='amixer'}) end),

    awful.key({"Mod4"}, "e",  function() awful.util.spawn("awesome-menu.sh") end),
    awful.key({"Control", "Mod1"}, "x",  function() awful.util.spawn(terminal) end),
    awful.key({"Control", "Mod1"}, "\\",  function() root.cursor("left_ptr") end),

    awful.key({ modkey }, "Tab", function () focus_without_modal_transients(-1) end),

    awful.key({"Control", "Mod1"}, "c",
        function()
            if awful.tag.selected() ~= tags[1]["con"] then
                prev_selected_tag = awful.tag.selected()
                if nil == next(tags[1]["con"]:clients()) then
                    awful.util.spawn(terminal)
                else
                    awful.tag.viewonly(tags[1]["con"])
                end
            else
                if prev_selected_tag then
                    awful.tag.viewonly(prev_selected_tag)
                else
                    awful.tag.viewonly(tags[1]["main"])
                end
            end
        end
    ),

    awful.key({"Control", "Mod1"}, "=", function()
        local c = awful.mouse.client_under_pointer()
        naughty.notify({
            text = "class: " .. c.class .. "\nname: " .. c.name .. "\ninstance: " .. c.instance .. "\nrole: " .. tostring(c.role) .. "\ntype: " .. c.type,
            timeout = 5, hover_timeout = 0.5,
            width = 500,
        })
    end),

    awful.key({"Control", "Mod1"}, "]", function()
        local c = awful.mouse.client_under_pointer()
        c:tags({tags[1]["gimp"]})
        awful.tag.viewmore(c:tags(), 1)
        c:geometry{width=864, height=486, x=30, y=30}
        awful.placement.centered(c)
        client.focus = c
        c:raise()
    end)
)

root.keys(globalkeys)

conkeys = awful.util.table.join(clientkeys,
    awful.key({"Shift"}, "Left", function (c) awful.client.focus.byidx(-1); client.focus:raise() end),
    awful.key({"Shift"}, "Right",function (c) awful.client.focus.byidx(1); client.focus:raise() end)
)

awful.rules.rules = awful.util.table.join(awful.rules.rules, {
    { rule = { }, properties = { tag = tags[1]["main"], switchtotag = true, focus = true, floating = true } },

    { rule = { class = "URxvt" },
        properties = { tag = tags[1]["con"], keys = conkeys, switchtotag = true,
        size_hints_honor = false, border_width = 0, floating = false } },

    { rule = { class = "Gimp" },  properties = { tag = tags[1]["gimp"], switchtotag = true } },

    { rule = { class = "Opera", instance = "opera" }, properties = { border_width = 0,
        maximized_vertical = true, maximized_horizontal = true, floating = false } },

    { rule = { class = "Snaked", role = "Editor" }, properties = { border_width = 0,
        maximized_vertical = true, maximized_horizontal = true, floating = false } },

    { rule = { modal = true }, properties = { skip_taskbar = true } },
})


-- Clock stuff
local calendar = nil
local offset = 0

function remove_calendar()
    if calendar ~= nil then
        naughty.destroy(calendar)
        calendar = nil
        offset = 0
    end
end

function add_calendar(inc_offset)
    local save_offset = offset
    remove_calendar()
    offset = save_offset + inc_offset
    local datespec = os.date("*t")
    datespec = datespec.year * 12 + datespec.month - 1 + offset
    datespec = (datespec % 12 + 1) .. " " .. math.floor(datespec / 12)
    local cal = awful.util.pread("cal -m " .. datespec)
    cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
    calendar = naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
        timeout = 0, hover_timeout = 0.5,
        width = 170,
    })
end

-- change clockbox for your clock widget (e.g. mytextclock)
mytextclock:add_signal("mouse::enter", function()
    add_calendar(0)
end)

mytextclock:add_signal("mouse::leave", remove_calendar)

mytextclock:buttons(awful.util.table.join(
    awful.button({ }, 4, function() add_calendar(-1) end),
    awful.button({ }, 5, function() add_calendar(1) end)
))


local new_im_message = false
imtimer = timer({ timeout = 5 })
imtimer:add_signal("timeout", function()
    local im_message = false
    f = io.open('/home/bobrov/.mcabber/mcabber.state')
    if f ~= nil then
        im_message = true
        f:close()
    end

    if new_im_message ~= im_message then
        new_im_message = im_message

        c = get_client(match_client{instance='mcabber'})
        if c ~= nil then
            c.urgent = new_im_message
        end
    end
end)
imtimer:start()


-- Titlebars
client.add_signal("manage", function (c, startup)
    if update_titlebar(c) then
        local g = c:geometry()
        if g.x == 0 and g.y == 0 then
            awful.placement.centered(c)
        end
    end

    c:add_signal("property::floating", update_titlebar)
    c:add_signal("property::maximized_vertical", update_titlebar)
    c:add_signal("property::maximized_horizontal", update_titlebar)
end)

function update_titlebar(c)
    local should_have_tb = awful.client.floating.get(c)
        and not c.maximized_vertical and not c.maximized_horizontal

    if c.titlebar and not should_have_tb then
        tbar.remove(c)
    end

    if not c.titlebar and should_have_tb then
        tbar.add(c, { modkey = modkey })
    end

    return should_have_tb
end
