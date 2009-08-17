---------------------------
-- my awesome theme -------
---------------------------

theme = {}

theme.rodentbane_bg = "red"

theme.font = "ProggyTinyTTSZ 12"
theme.tasklist_font = "Sans 7"
theme.titlebar_font = "Sans 7"

theme.bg_normal     = "#171717"
theme.bg_focus      = "#3D3A30"
theme.bg_urgent     = "#171717"

theme.fg_normal     = "#575244"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffc500"

theme.border_width  = 1
theme.border_normal = "#171717"
theme.border_focus  = "#3D3A30"
theme.border_marked = "#91231c"

theme.widget_label = "#333333"
theme.widget_value = "#555555"

theme.help_font = "Monospace 6.5"
theme.help_highlight = theme.fg_urgent

theme.tasklist_floating_icon = "~/.config/awesome/icons/floating.png"

theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"
theme.menu_height   = 15
theme.menu_width    = 100


theme.wallpaper_cmd = { "hsetroot -solid '#3D3A30'" }

local layout_icons = "/home/koniu/.config/awesome/icons/layouts/"
theme.layout_fairh = layout_icons .. "fairh.png"
theme.layout_fairv = layout_icons .. "fairv.png"
theme.layout_floating = layout_icons .. "floating.png"
theme.layout_magnifier = layout_icons .. "magnifier.png"
theme.layout_max = layout_icons .. "max.png"
theme.layout_tilebottom = layout_icons .. "tilebottom.png"
theme.layout_tileleft = layout_icons .. "tileleft.png"
theme.layout_tile = layout_icons .. "tile.png"
theme.layout_tiletop = layout_icons .. "tiletop.png"

theme.awesome_icon = "/usr/share/awesome/icons/awesome16.png"

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
