success, theme = pcall(function() return dofile('/usr/share/awesome/themes/default/theme.lua') end)

if not success then
    return print("E: beautiful: error loading theme file " .. theme)
elseif theme then
    theme_dir = "/home/bobrov/.config/awesome/theme/"

    -- theme.wallpaper_cmd = { "awsetbg /usr/share/archlinux/wallpaper/archlinux-simplyblack.png" }
    -- theme.wallpaper_cmd = { "awsetbg " .. theme_dir .. "1599_magicstone_1920x1080-900509.jpeg" }
    theme.wallpaper_cmd = { "awsetbg /home/bobrov/wallpapers/story.jpg" }

    theme.tasklist_floating_icon = nil -- theme_dir .. "float.png"
    theme.awesome_icon = theme_dir .. "icons/awesome19.png"

    theme.taglist_squares_sel   = theme_dir .. "icons/squarefw.png"
    theme.taglist_squares_unsel = theme_dir .. "icons/squarew.png"

    theme.font = "DejaVu Sans 8"

    theme.titlebar_close_button_normal = theme_dir .. "icons/close_normal.png"
    theme.titlebar_close_button_focus = theme_dir .. "icons/close_focus.png"
    theme.titlebar_icon_focus = theme_dir .. "icons/tb_sq_normal.png"
    theme.titlebar_icon_normal = theme_dir .. "icons/tb_sq_focus.png"
end

return theme
