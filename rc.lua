require("awful")
require("awful.rules")
require("beautiful")
require("naughty")
require("keygrabber")

require("vicious")
require("bobroutils")
require("tbar")
require("rsi")
--require("debug")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/home/bobrov/.config/awesome/theme/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvtc"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

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

    awful.layout.set(awful.layout.suit.max, tags[s]["main"])
    awful.layout.set(awful.layout.suit.max, tags[s]["con"])
    awful.layout.set(awful.layout.suit.float, tags[s]["gimp"])

    tags[s]["main"].selected = true
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock({align = "right"}, "%H:%M", 10)
awful.widget.layout.margins[mytextclock] = { right = 1 }

-- Create a systray
mysystray = widget({ type = "systray" })
awful.widget.layout.margins[mysystray] = { left = 4 }

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}

mytaglist = {}
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ modkey }, 1, awful.client.movetotag)
)

mytasklist = {}
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 2, function (c) c:kill() end),
    awful.button({ }, 1, function (c)
        if not c:isvisible() then
          awful.tag.viewonly(c:tags()[1])
        end
        client.focus = c
        c:raise()
    end)
)

cpuwidget = awful.widget.graph()
cpuwidget:set_width(40)
cpuwidget:set_height(16)
cpuwidget:set_background_color(beautiful.bg_normal)
cpuwidget:set_color('#FF5656')
cpuwidget:set_gradient_colors({ '#FF5656', '#88A175', '#AECF96' })
cpuwidget.layout = awful.widget.layout.horizontal.rightleft
awful.widget.layout.margins[cpuwidget.widget] = { top = 1, left = 3, right = 5 }
vicious.register(cpuwidget, vicious.widgets.cpu, '$1', 1)


for s = 1, screen.count() do
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
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
            mytextclock,
            cpuwidget,
            layout = awful.widget.layout.horizontal.rightleft
        },
        mytasklist[s],
        layout = awful.widget.layout.horizontal.leftright
    }
end
-- }}}


-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),

    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    -- My Keys
    awful.key({ modkey }, "b",   rsi.start_rest ),
    awful.key({ modkey }, "Left",   function() awful.tag.viewprev(); check_focus() end ),
    awful.key({ modkey }, "Right",  function() awful.tag.viewnext(); check_focus() end ),

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

    awful.key({ modkey }, "Tab", function ()
        local hist = focus_history_without_modal_transients(1)

        if #hist < 2 then
            return
        end

        client.focus = hist[2]
        hist[2]:raise()
        local lastidx = 2
        local first_client = hist[1]

        keygrabber.run(function(mod, key, event)
            if key == 'Super_L' and event == 'release' then
                if client.focus ~= first_client then
                    awful.client.focus.history.add(first_client)
                    if client.focus.modal and client.focus.transient_for then
                        awful.client.focus.history.add(client.focus.transient_for)
                    end
                    awful.client.focus.history.add(client.focus)
                end
                return false
            end

            if key == 'Tab' and event == 'press' then
                lastidx = lastidx + 1
                if lastidx > #hist then
                    lastidx = 1
                end
                client.focus = hist[lastidx]
                hist[lastidx]:raise()
            end

            return true
        end)
    end),

    awful.key({"Control", "Mod1"}, "c",
        function()
            if awful.tag.selected() ~= tags[1]["con"] then
                prev_selected_tag = awful.tag.selected()
                if nil == next(tags[1]["con"]:clients()) then
                    awful.util.spawn(terminal)
                else
                    awful.tag.viewonly(tags[1]["con"])
                    check_focus(nil)
                end
            else
                if prev_selected_tag then
                    awful.tag.viewonly(prev_selected_tag)
                    check_focus(nil)
                else
                    awful.tag.viewonly(tags[1]["main"])
                    check_focus(nil)
                end
            end
        end
    ),

    awful.key({"Control", "Mod1"}, "=", function()
        local c = awful.mouse.client_under_pointer()
        naughty.notify({
            text = "class: " .. c.class .. "\nname: " .. c.name .. "\ninstance: " .. c.instance .. "\nrole: " .. tostring(c.role) .. "\ntype: " .. c.type .. "\nfloat: " .. tostring(isfloating(c)),
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

clientkeys = awful.util.table.join(
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  floating_toggle                                  ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end)
)

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

conkeys = awful.util.table.join(clientkeys,
    awful.key({"Shift"}, "Left", function (c) awful.client.focus.byidx(-1); client.focus:raise() end),
    awful.key({"Shift"}, "Right",function (c) awful.client.focus.byidx(1); client.focus:raise() end)
)

-- Handles tab key to fast switch between gimp image and tollboxes windows
gimp_box_keys = awful.util.table.join(clientkeys,
    awful.key({}, "Tab", function (c)
        local boxes = get_clients(function(c) return c.role=="gimp-toolbox" or c.role=="gimp-dock" end)
        local boxes_are_visible = true
        for _, c in pairs(boxes) do
            if not c.above then
                boxes_are_visible = false
                break
            end
        end

        if boxes_are_visible then
            for _, c in pairs(boxes) do
                c.below = true
            end

            local c = get_client(match_client{role="gimp-image-window"})
            if c then
                client.focus = c
            end
        else
            for _, c in pairs(boxes) do
                c.above = true
            end
        end
    end)
)

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },

    { rule = { }, properties = { tag = tags[1]["main"], switchtotag = true, floating = true } },

    { rule = { class = "URxvt" },
        properties = { tag = tags[1]["con"], keys = conkeys, switchtotag = true,
        size_hints_honor = false, border_width = 0, floating = false } },

    { rule = { class = "Gimp" },  properties = { tag = tags[1]["gimp"], switchtotag = true } },
    { rule = { instance = "gimp", type = "dialog" },  properties = { above = true } },
    { rule = { role = "gimp-image-window" }, properties = { size_hints_honor = false, keys = gimp_box_keys,
        border_width = 0, floating = false, maximized_vertical = true, maximized_horizontal = true } },
    { rule = { role = "gimp-toolbox" },  properties = { size_hints_honor = false,
        floating = false, skip_taskbar = true, focus = false, keys = gimp_box_keys,
        geometry = {x=0, y=19, height=581, width=400}, below = true } },
    { rule = { role = "gimp-dock" },  properties = { size_hints_honor = false,
        floating = false, skip_taskbar = true, focus = false, keys = gimp_box_keys,
        geometry = {x=624, y=19, height=581, width=400}, below = true } },

    { rule = { class = "Opera", instance = "opera" }, properties = { border_width = 0, floating = false } },
    { rule = { class = "Namoroka", role = "browser" }, properties = { border_width = 0, floating = false } },

    { rule = { class = "Snaked", role = "Editor" }, properties = { border_width = 0, floating = false } },

    { rule = { modal = true }, properties = { skip_taskbar = true, floating = true } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    if update_titlebar(c) then
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.centered(c)
        end
    end

    c:add_signal("property::floating", update_titlebar)
end)

client.add_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    update_titlebar(c)
end)

client.add_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    update_titlebar(c)
end)
-- }}}

function update_titlebar(c)
    local should_have_tb = isfloating(c)

    if c.titlebar and not should_have_tb then
        tbar.remove(c)
    end

    if not c.titlebar and should_have_tb then
        tbar.add(c, { modkey = modkey })
    end

    if not c.modal then
        c.skip_taskbar = should_have_tb and client.focus == c
    end

    return should_have_tb
end

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
        text = string.format('<span font_desc="%s">%s</span>',
            "monospace", os.date("%a, %d %B %Y") .. "\n" .. cal),
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

rsi.run()
