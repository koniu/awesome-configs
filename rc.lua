--{{{ requires

require("dbg")
require("awful")
require("awful.autofocus")
require("beautiful")
require("naughty")
require("shifty")
require("handy")
require("wicked")
require("inotify")
require("obvious.popup_run_prompt")

dofile("/home/koniu/.config/awesome/functions.lua")
--}}}

--{{{ vars

--{{{ vars / common
theme_path = "/home/koniu/.config/awesome/theme.dark.master.lua"
icon_path = "/home/koniu/.config/awesome/icons/"
beautiful.init(theme_path)
modkey = "Mod4"
if screen.count() == 2 then LCD = 2 else LCD = 1 end

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.max,
    awful.layout.suit.tile,
--    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
--    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.floating,
--    awful.layout.suit.fair.horizontal,
    awful.layout.suit.max.fullscreen,
--    awful.layout.suit.magnifier,
}

--custom
config = {}
config.terminal = "urxvtc"

config.tasklist_noicons = true
-- step for scrolling
config.step = 15

-- screen offset it scrolls within
config.scroll_offset = 2

-- some shortcuts
join = awful.util.table.join
doc = awful.doc


--}}}

--{{{ vars / handy
handy.combo_subst = {
["(%u)"] = function(m) return string.lower(m) end,
  control = "ctl",
  mod1 = "alt",
  mod4 = "win",
  mod5 = "ralt",
  XF86 = "x",
  forward = "fwd",
}

handy.combo_ignore_groups = {
  "1. global actions" ,
  "default"
}
--}}}

--{{{ vars / shifty

--{{{ vars / shifty / config.tags
shifty.config.tags = {

["sys"]     = { position = 0, exclusive = true, mwfact = 0.75307, screen = LCD, layout = "tilebottom"               },
["jack"]    = { position = 0, exclusive = true, mwfact = 0.85, nmaster = 1, screen = LCD, layout = "tilebottom"     },
["term"]    = { position = 2, exclusive = true, screen = LCD, layout = 'tilebottom'                                 },
["www"]     = { position = 3, exclusive = true, screen = LCD                                                        },
["fb"]      = { position = 9, exclusive = true, layout = "tilebottom", mwfact=0.85                                  },
["dir"]     = { rel_index = 1, exclusive = false                                                                    },
["gq"]      = { rel_index = 1, exclusive = true                                                                     },
["vid"]     = { rel_index = 1, exclusive = true                                                                     },
["pdf"]     = { rel_index = 1, exclusive = true                                                                     },
["gimp"]    = { spawn = "gimp", icon = "/usr/share/icons/hicolor/16x16/apps/gimp.png",
                layout = "max", icon_only = true, sweep_delay = 2, exclusive = true                                 },
["xev"]     = { rel_index = 0, spawn = "urxvtc -title 'Event Tester' -name xev -e sh -c 'xev -id $WINDOWID'"        },
["live"]    = { icon = "/home/koniu/live.png", layout = "floating", sweep_delay = 2, icon_only = false              },
["im"]      = { position = 1, spawn = "urxvtc -title IRC -name irc -e screen -t irc -S irc -R irssi"                },
["tetris"]  = { rel_index = 0, spawn = "urxvtc -font '-*-*-*-*-*-*-*-240-*-*-*-*-*-2' -name tetris -e tetris"       },
["X"]       = { rel_index = 1, spawn = "awtester", layout = awful.layout.suit.tile.top, mwfact = 0.75               },

}
--}}}

--{{{ vars / shifty / config.apps
shifty.config.apps = {

    -- tag matches
    { match = { "tail", "^top", "fping", "mtr", "htop", "iwconfig", "Wicd", "apt"
                                                    },  tag = "sys",                                  },
    { match = { "urxvt"                             },  tag = "term", slave = true                    },
    { match = { "^mc$"                              },  tag = "dir", opacity = 0.8                    },
    { match = { "Wine"                              },  tag = "wine",                                 },
    { match = { "Ardour.*", "Jamin",                },  tag = "ardour",                               },
    { match = { "Gmpc",                             },  tag = "mpd",                                  },
    { match = { "[Mm]player",                       },  tag = "vid",                                  },
    { match = { "^Acroread.*", "^Evince$"           },  tag = "pdf",                                  },
    { match = { "^irc$",                            },  tag = "im",                                   },
    { match = { "Deluge", "nicotine", "Tucan.py", "^jd.Main$"
                                                    },  tag = "dl"                                    },

    -- bristol
    { match = { "^BasicWin$",                       },  tag = "bristol",  float = 1                    },

    -- htop
    { match = { "^htop$",                           },
      keys = join(remap({}, "Delete", {75,36}),
                  remap({}, "period", {{50,60},116,36}),
                  remap({}, "comma", {{50,59},111,36}))
    },

    -- gajim
    { match = { "^Gajim",                           },  tag = "im",                                   },
    { match = { "^messages$",                       },  nopopup = true, slave = true, border_width = 0},
    { match = { "^roster$",                         },  float = true, geometry = { 0,34,186,734 },
                                                        dockable = true, struts = { left = 186 },
                                                        skip_taskbar = true, border_width = 0, nofocus = true,
                                                        props = { skip_focus = true }                 },

    -- foobar2000
    { match = { "foobar2000.exe",                   },  tag = "fb",  nopopup = 1,                     },
    { match = { "^Playlist Search$", "^ReplayGain Scan",  "^Connecting to discogs$", "^Moving Files$",
                "^Converting.*", "^Updating album/artist art", "^Copying Files$", "^Updating Files$",
                "^Spectrum$", "^Spectrogram$"                                                         },
              float = false, slave = 1, nofocus = 1, nopopup = 1                                      },

    -- awtester
    { match = { "^awtester$",                       },  tag = "X", float = false                      },
    { match = { "^awtesterlog$",                    },  tag = "X", slave = true, nofocus = true,
                                                        border_width = 0                              },

    -- popterm (aka scratchpad)
    { match = { "popterm" },
      intrusive = true, opacity = 0.8, float = true, sticky = true, ontop = true,
      geometry = { 0, 568, 1024, 200 }, hidden = false, skip_taskbar = true,
      startup = { hidden = true }
    },

    -- ableton live
    { match = { "^Live$",                           },   tag = "live", nopopup = true,
                                                        geometry = { 0, 34, 1400, 1000 },             },
    -- www browsers
    { match = { "Iceweasel.*", "Firefox.*", "^Chrome$", "^x.www.browser$", "^sensible.browser$", "^Minefield$" },
      tag = "www",                                                                                    },

    -- qjackctl tweaks
    { match = { "Patchage"                          },  tag = "jack", props = { killhide = 1 },       },
    { match = { "jackctl"                           },  tag = "jack", slave = true,                   },
    { match = { "Informat.*CK Audio Connection Kit" },  kill = true,                                  },
    { match = { "qjackctlMessagesForm",
                "Error.*Connection Kit"             },  nopopup = true,                               },

    { match = { "qjackctlMainForm",                 },  wfact = 0.5                                   },
    -- gimp
    { match = { "Gimp",                             },  tag = "gimp",
      keys = join(
        awful.key({ "Mod1" }, "b", function(c) local a = getclient("role", "gimp-toolbox")
                                               if a then a.hidden = not a.hidden end
                                               end, nil, "Toggle toolbox"),
        awful.key({ "Mod1" }, "v", function(c) local a = getclient("role", "gimp-dock")
                                               if a then a.hidden = not a.hidden end
                                               end, nil, "Toggle dock"))                              },
    { match = { "^gimp.toolbox$",                   },  struts = { right=172}, skip_taskbar = true,
                                                        geometry = {852,34,172,734}, slave = true,
                                                        border_width = 0                              },

    { match = { "^gimp.dock$",                      },  struts = { left=170}, skip_taskbar = true,
                                                        geometry = {0,34,170,734}, slave = true,
                                                        border_width = 0                              },
    -- geeqie
    { match = { "^Geeqie$"                          },  tag = "gq"                                    },
    { match = { "Full screen...Geeqie"              },  intrusive = true, border_width = 0, fullscreen = 1, ontop=true },
    { match = { "Tools...Geeqie"                    },
      keys = join(awful.key({}, "Escape", function(c)  getclient("id", c.group_id + 2):kill() end))   },
    { match = { "^gimp%-image%-window$"             }, nopopup = true, slave = true                   },

    -- various tweaks
    { match = { "^JACK Rack MIDI Controls$"         },  float = false,                                },
    { match = { "sqlitebrowser"                     },  slave = true, float = false, tag = "sql"      },
    { match = { "^xev$"                             },  skip_taskbar = true, tag = "xev", opacity =.8 },

    -- menu
    { match = { "^menu$",                           },  skip_taskbar = true, dockable = true,
                                                        ontop = true, opacity = 0.9                   },
    -- slaves
    { match = { "xmag","^Downloads$", "ufraw", "qjackctl", "fping", "watch",
                                                    },  slave = true,                                 },

    -- floats
    { match = { "recordMyDesktop", "Skype", "QQQjackctl", "MPlayer", "xmag", "gcolor2", "javax.swing",
                "^Install user style$"
                                                    },  float = true,                                 },
    -- nopopup
    { match = { "^Downloads$",
                                                    },  nofocus = true,                             },

    -- intruders
    { match = { "^dialog$", "xmag", "gcolor2", "^Download$", "^menu$",
                                                    },  intrusive = true,                             },

    -- all
    { match = { "" },
      honorsizehints = false,
      buttons = join(
        awful.button({ }, 1, function (c) client.focus = c; c:raise() end, nil, "Focus client"),
        awful.button({ "Mod1" }, 1, awful.mouse.client.move, nil, "Move client"),
        awful.button({ "Mod1" }, 3, awful.mouse.client.resize, nil, "Resize client" )
      ),
    },

}
--}}}

--{{{ vars / shifty / gittags(tm)

local gittags = {
  [ "d:awsm" ] = { push = "push mg +", main = "zsh", dir = "/home/koniu/awesome", commit = "-a -s",
                   url = "http://git.naquadah.org/?p=awesome.git;a=shortlog;h=refs/heads/master" },
[ "d:shifty" ] = { push = "push mg +", main = "vim lib/shifty.lua.in", dir = "/home/koniu/shifty", commit = "-a -s",
                   url = "http://git.mercenariesguild.net/?p=awesome.git;a=shortlog;h=refs/heads/shifty-master" },
  [ "d:conf" ] = { push = "push origin +", main = "vim rc.lua", dir = "/home/koniu/.config/awesome", commit = "-a",
                   url = "http://github.com/koniu/awesome-configs/commits/master/rc.lua" },
  [ "d:obv" ] = { push = "", main = "zsh", dir = "/home/koniu/.config/awesome/obvious", commit = "-a -s",
                   url = "http://git.mercenariesguild.net/?p=obvious.git;a=shortlog;h=refs/heads/master" },
  [ "d:vali" ] = { push = "", main = "zsh", dir = "/home/koniu/data/kit/git/validichro", commit = "-a",
                   url = "" },
}


for n, v in pairs(gittags) do

  --{{{ vars / shifty / gittags(tm) / commands
  local spawn = "urxvtc -name "..n.."main -title '"..v.main.."' -cd "..v.dir.." -e "..v.main
  local see_www = function() awful.tag.viewonly(shifty.name2tag("www")) end
  local cmds = {
    log = function() terminal("-font 6x10 -name "..n.."pop -hold -title '"..n.." git log' -cd "..v.dir.." -e git -p log") end,
    diff = function() terminal("-font 6x10 -name "..n.."pop -hold -title '"..n.." git diff' -cd "..v.dir.." -e git -p diff --patch-with-stat") end,
    pull = function() terminal("-name "..n.."pop -hold -title '"..n.." git pull' -cd "..v.dir.." -e git pull") end,
    status = function() terminal("-name "..n.."pop -hold -title '"..n.." git status' -cd "..v.dir.." -e git status") end,
    prompt = function() terminal("-name "..n.."cmd -title '"..n.." git prompt' -cd "..v.dir.." -e zsh") end,
    commit = function() terminal("-name "..n.."cmd -hold -title '"..n.." git commit' -cd "..v.dir.." -e git commit "..v.commit) end,
    gitweb = function() awful.util.spawn(browser..v.url.."'"); see_www(); end,
    apidoc = function() awful.util.spawn(browser .. "http://awesome.naquadah.org/doc/api/"); see_www(); end,
    push = function()
                local br=awful.util.pread("cd "..v.dir.."; git branch --no-color 2> /dev/null | grep \\*")
                br = br:sub(3, #br-1)
                terminal("-name "..n.."pop -hold -title '"..n.." git push "..br.."' -cd "..v.dir.." -e git "..v.push..br)
           end,
    branch = function()
                prompt.exec({
                  history = os.getenv("HOME") .. "/.cache/awesome/history_gittags-"..n,
                  args = {
                    fg_cursor = "#FF1CA9", bg_cursor = beautiful.bg_normal, ul_cursor="single",
                    selectall = true, prompt = "<span color='#FF1CA9'>Branch</span>: ",
                  },

                run_function = function(line)
                  local txt = awful.util.pread("cd "..v.dir.."; git checkout "..line.." 2>&1")
                  local clr = "white"
                  if txt:find("^error") then
                    clr = "red"
                  elseif txt:find("^Switched") then
                    clr = "green"
                  end
                  naughty.notify{ text="<span color='"..clr.."'>"..txt:sub(1,#txt-1).."</span>" }
                end,

                completion_function = function (cmd, cur_pos, ncomp)
                  local branches = {}
                  local matches = {}
                  local g = io.popen("cd "..v.dir.."; git branch")
                  for line in g:lines() do table.insert(branches, line:sub(3, #line)) end
                  g:close()
                  if cur_pos ~= #cmd + 1 and cmd:sub(cur_pos, cur_pos) ~= " " then return cmd, cur_pos end
                  for i, j in ipairs(branches) do
                    if branches[i]:find("^" .. cmd:sub(1, cur_pos)) then
                      table.insert(matches, branches[i])
                    end
                  end
                  if #matches == 0 then return cmd, cur_pos end
                  while ncomp > #matches do ncomp = ncomp - #matches end

                  return matches[ncomp], cur_pos
                end})
            end
  }
  --}}}

  --{{{ vars / shifty / gittags(tm) / tag settings + bindings
  awful.doc.set_default({ group = "gittags(tm)" })
  shifty.config.tags[n] = {
    position = 9, exclusive = true,  screen = LCD, layout = awful.layout.suit.tile.bottom, spawn = spawn, mwfact = 0.7,
    keys  = awful.util.table.join(
              awful.key({ modkey }, "l", cmds.log, nil, "git log" ),
              awful.key({ modkey }, "d", cmds.diff, nil, "git diff"),
              awful.key({ modkey }, ".", cmds.push, nil, "git push"),
              awful.key({ modkey }, ",", cmds.pull, nil, "git pull"),
              awful.key({ modkey }, "c", cmds.commit, nil, "git commit"),
              awful.key({ modkey }, "s", cmds.status, nil, "git status"),
              awful.key({ modkey }, "w", cmds.gitweb, nil, "gitweb"),
              awful.key({ modkey }, "a", cmds.apidoc, nil, "api reference"),
              awful.key({ modkey }, "b", cmds.branch, nil, "git checkout"),
              awful.key({ modkey }, "grave", cmds.prompt, nil, "cmdline")
            ),
  }
  awful.doc.set_default({ })
  --}}}

  --{{{ vars / shifty / gittags(tm) / client settings + bindings
  awful.doc.set_default({ group = "gittags(tm) / client" })
  -- match to tags
  table.insert(shifty.config.apps,
               { match = { n.."main$", n.."cmd$", n.."pop$" }, tag = n })
  -- slave/skip_taskbar popups and commandline
  table.insert(shifty.config.apps,
               { match = { n.."cmd$", n.."pop$" }, slave = true, titlebar = true, skip_taskbar = true })
  -- popups die on 'q'
  table.insert(shifty.config.apps,
               { match = { n.."pop$" }, keys = join(awful.key({}, "q", function(c) c:kill() end, nil, "quit")), })
  -- reload main window with mod+alt+l
  table.insert(shifty.config.apps,
               { match = { n.."main$" }, keys = join(awful.key({"Mod1", modkey}, "l", function(c) c:kill(); awful.util.spawn(spawn) end, nil, "reload client")), })
  -- reload commands on mod+alt+l
  for m, f in pairs(cmds) do
    table.insert(shifty.config.apps,
               { match = { n.." git "..m },
                 keys = join(awful.key({"Mod1", modkey}, "l", function(c) c:kill(); f() end, nil, "reload client")), })
  end
  awful.doc.set_default({ })
  --}}}

end
--}}}

shifty.config.defaults = {
    layout = "max",
    leave_kills = false,
}

shifty.config.default_name = "?"
shifty.config.layouts = layouts
shifty.init()
--}}}

--{{{ vars / naughty
naughty.config.spacing = 1
naughty.config.default_preset = {
  font = 'Monospace 6.5',
  border_width = 1,
  margin = 5,
  screen = LCD,
  opacity = 0.95,
}
--}}}

--{{{ vars / widgets
config.widgets = {}
config.widgets.watchmount = { "/dev/sda2", "/media/", "/mnt/" }
config.widgets.autostart = {
  default = "urxvtc -name mc -geometry 169x55 -e mc %f",
  movies = "urxvtc -name mc -geometry 169x55 -e mc %f ~/data/tmp",
  photo = "gq %f",
  p6000 = "gq %f/dcim",
}
config.widgets.space = "   "
config.widgets.wifi = "wlan1"
--}}}

--{{{ vars / audio
require("jackmix")
mixer = jackmix.new{
  port = 1234,
  host = "localhost",
  step = 2,
  state_file = "/home/koniu/.cache/mixer",
}

require("recorder")
rek = recorder.new{
  backend = recorder.backends.rec,
  style = recorder.styles.horizontal,
}
--}}}

--}}}

--{{{ prompts
prompt.presets = {

  --{{{ prompts / defaults
  default = {
    position = "top",
    width = 1, height = 34, border_width = 0, opacity = 0.9, margin = { top = 12, left = 12 },
    slide = true, move_speed = 0.003, move_amount = 1, autoexec = 1
  },
  --}}}

  --{{{ prompts / run
  run =  {
    completion_function = awful.completion.shell,
    run_function = function(s)
      local rv = awful.util.spawn(s, true)
      if rv then naughty.notify({ text = awful.util.escape(rv), timeout = 0, hover_timeout = 0.2 }) end
    end,
    history = os.getenv("HOME") .. "/.cache/awesome/history",
    args = { prompt = "<span color='#CC8400'>Run</span>: ", fg_cursor = "#FFA500",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", autoexec = 1},
  },
  --}}}

  --{{{ prompts / lua
  lua = {
    completion_function = lua_completion,
    run_function = function(s)
      local r, msg = pcall(awful.util.eval, s)
      if not r then naughty.notify({ text = awful.util.escape(msg), timeout = 0, hover_timeout = 0.2 }) end
    end,
    history = os.getenv("HOME") .. "/.cache/awesome/history_eval",
    args = { prompt = "<span color = '#A7CC00'>Lua</span>: ", fg_cursor = "#D1FF00",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", },
  },
  --}}}

  --{{{ prompts / calc
  calc = {
    completion_function = lua_completion,
    run_function = calculator,
    history = os.getenv("HOME") .. "/.cache/awesome/history_calc",
    args = { prompt = "<span color='#007478'>Calc</span>: ", fg_cursor = "#00A5AB",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", selectall = true, },
  },
  --}}}

  --{{{ prompts / dict
  dict = {
    completion_function = function() return false end,
    run_function = dictionary,
    history = os.getenv("HOME") .. "/.cache/awesome/history_dict",
    args = { prompt = "<span color='#0073CC'>Dict</span>: ", fg_cursor = "#008DFA",
             bg_cursor = beautiful.bg_normal, ul_cursor = "single", selectall = true, },
  },
  --}}}

  --{{{ prompts / kill
  kill = {
    completion_function = kill_completion,
    run_function = kill,
    history = "",
    args = { prompt = "<span color='#CC3F3F'>Kill</span>: ", fg_cursor = "#FF4F4F",
             bg_cursor = beautiful.bg_normal, ul_cursor= "single", },
  },
  --}}}

  --{{{ prompts / api
  api = {
    completion_function = lua_completion,
    run_function =  function(n) handy.get(loadstring("return " .. n)()) end,
    history =  os.getenv("HOME") .. "/.cache/awesome/help_search",
    args = { prompt = "<span color='#CC3F7D'>Help</span>: ", fg_cursor = "#FF4F9B",
             bg_cursor = beautiful.bg_normal, ul_cursor= "single", },
  },
  --}}}
}
--}}}

--{{{ widgets

--{{{ widgets / jack

--{{{ widgets / jack / functions
function jack_volume()
  if type(mixer.state) == "number" then
    return pad(math.ceil(mixer.state) .. "%",3)
  else
    return "<span color='#aa4444'>m  </span>"
  end
end

function jack_status()
  local ps = psgrep({command = "^/usr/bin/jackd"})
  local stat, vol
  if not ps then
    stat = "off"
    vol = ""
  elseif ps[1].command:find("dfirewire") or ps[1].command:find("dfreebob") then
    stat = "fw"
    vol = jack_volume()
  elseif ps[1].command:find("dalsa") then
    stat = "alsa"
    vol = jack_volume()
  end
  return stat, vol
end

function jack_toggle(pre)
  local state, vol = jack_status()
  if pre == "alsa" or state == "off" or state == "fw" then
    awful.util.spawn_with_shell("jackwrap -R -dalsa -r44100 -p512 -n3 -o0")
  elseif pre == "fw" or state == "alsa" then
    awful.util.spawn_with_shell("jackwrap -R -dfirewire -dhw:1 -r44100 -p512 -n3 -o0")
  end
end
--}}}

jackwidget = widget({ type = 'textbox' })
jackwidget:buttons(join(
  awful.button({}, 3, jack_toggle),
  awful.button({}, 1, function() cli_toggle("patchage", "class", "Patchage") end)
))

--}}}

--{{{ widgets / wifi
function dump_autoap()
  --awful.util.spawn_with_shell('curl -s http://10.6.6.1/user/autoap.htm  > /tmp/.awesome.autoap')
end

function show_netpopup()
  naughty.destroy(netpopup)
  local iwconfig = awful.util.pread("/sbin/iwconfig " .. config.widgets.wifi)
  local ifconfig = awful.util.pread("/sbin/ifconfig " .. config.widgets.wifi)
  local route = awful.util.pread("/bin/ip route")
  local iwgetid = awful.util.pread("/sbin/iwgetid -c")

  local start, endd = iwconfig:find('".*"')
  if not start or not endd then return end
  local essid = iwconfig:sub(start+1, endd-1)

  start, endd = iwconfig:find("Rate.* Mb/s")
  if not start or not endd then return end
  local rate = iwconfig:sub(start+5,endd-5)

  local start, endd = ifconfig:find("inet addr:.* Bcast")
  if not start or not endd then return end
  local ip = ifconfig:sub(start+10, endd-5)

  local start, endd = route:find("via %d+%.%d+%.%d+%.%d+ dev " .. config.widgets.wifi)
  if not start or not endd then return end
  local gw = route:sub(start+4,endd-9)

  local start, endd = iwgetid:find("Channel:%d+")
  if not start or not endd then return end
  local channel = iwgetid:sub(start+8,endd)

  local autoap = get_autoap()
  netpopup = naughty.notify({ text = "<span color='#26241E'>essid: </span>" .. essid .. " (<span color='#26241E'>channel</span> " .. channel .. ", " .. rate .. " <span color='#26241E'>mbps</span>" .. ")\n" ..
    ((autoap and ("<span color='#26241E'>autoap essid: </span>" .. autoap.ap .. "\n")) or "") ..
--    ((autoap and ("<b>autoap gw: </b>" .. autoap.gw .. "\n")) or "" ) ..
    ((autoap and ("<span color='#26241E'>autoap loss: </span>" .. autoap.loss .. "\n")) or "" ) ..
    "<span color='#26241E'>ip: </span>" .. ip .. "\n" ..
    "<span color='#26241E'>gw: </span>" .. gw,
    timeout = 5, hover_timeout = 0.2 })
end

function get_autoap()
   local ap = ""
   local f = io.open('/tmp/.awesome.autoap')
   if not f then return end
   local line = f:read("*a")
   f:close()
   if not line then return end

   local aar, beg = line:find('<title>')
   if not aar or not beg then return end
   if line:sub(beg+32, beg+32) == 'S' then ap = "<span color=\"#FF602E\">searching...</span>"
   elseif line:sub(beg+32,beg+32) == 'C' then
     endd = line:find('</title>', beg)
     ap = line:sub(beg+47,endd-2)
   end

   local start, endd = line:find("rescanning%. %d+%% packet loss")
   if not start or not endd then return end
   local loss = line:sub(start+12,endd-12)

   if last_ap and ap ~= last_ap then naughty.notify({title = "AutoAP network", text = ap, timeout = 10})
   last_ap = ap end
   return { ap = ap, loss = loss, gw = gw}
end

local function get_wifi()
  local v = ''
  local a = io.open('/sys/class/net/'..config.widgets.wifi..'/wireless/link')

  if not a then
    netup = nil
    return '<span color="#D9544C">off</span>'
  end
  v = math.floor(a:read() / 0.7)
  a:close()
  if v == 0 then
      v = '<span color="#D9544C">down</span>'
      netup = nil
  else
      v = string.format("%-4s", v .. "%")
       netup = 1
  end
  return v
end

wifiwidget = widget({
  type = 'textbox',
  name = 'wifiwdget',
})

wifiwidget:buttons(join(
  awful.button({}, 1, function () cli_toggle("wicd-gtk -n >& /dev/null", "class", "Wicd-client.py")  end, nil, "show networks"),
  awful.button({}, 2, show_netpopup, nil, "show autoap status"),
  awful.button({}, 3, function () terminal("-name iwconfig -e watch -n1 /sbin/iwconfig "..config.widgets.wifi) end, nil, "show iwconfig")
))

wifiwidget:add_signal("mouse::enter", function() show_netpopup() end)
wifiwidget:add_signal("mouse::leave", function() naughty.destroy(netpopup) end)

awful.doc.set(wifiwidget, { class = "widgets", description = "This widget shows WIFI range", name = "wifiwidget" })

--}}}

--{{{ widgets / net
netwidget = widget({
  type = 'textbox',
  name = 'netwidget',

})
netwidget:buttons(join(
  awful.button({}, 3, function () terminal("-name fping -e fping -le 10.6.6.1 google.com") end),
  awful.button({}, 1, function () terminal("-name mtr -e mtr google.com") end)
))
netwidget.width = 100

--}}}

--{{{ widgets / cpugraph
cpugraphwidget = awful.widget.graph({ layout = awful.widget.layout.horizontal.leftright })
cpugraphwidget.widget:buttons(join(
  awful.button({}, 3, function () terminal("-name top -e top") end),
  awful.button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_CPU") end)
))

cpugraphwidget:set_color('#252020')
cpugraphwidget:set_border_color('#000000')
cpugraphwidget:set_background_color('#000000')
cpugraphwidget:set_height(14)
cpugraphwidget:set_width(40)
cpugraphwidget:set_scale(false)
awful.widget.layout.margins[cpugraphwidget.widget] = { top = 1 }

awful.doc.set(cpugraphwidget, "cpugraph")
--}}}

--{{{ widgets / battery
batterywidget = widget({
  type = 'textbox',
  name = 'batterywidget',
  align = 'right'
})


local function get_bat()
  local color = 'orange'
  local v = ''
  local a = io.open('/sys/class/power_supply/BAT0/status')
  if not a then return end
  local status = a:read()
  a:close()
  local b = io.open('/sys/class/power_supply/BAT0/current_now')
  local current = b:read()
  b:close()
  if status == "Full" or tonumber(current) == 0 then
    v = ''
  else
    local a = io.open('/sys/class/power_supply/BAT0/energy_full')
    local full = a:read()
    a:close()
    local a = io.open('/sys/class/power_supply/BAT0/energy_now')
    local now = a:read()
    a:close()

    bat = math.floor(now*100/full)

    if status == "Discharging" then
      if   bat < 11 then color="#D9544C"
      elseif   bat < 31 then color="#D9A24C"
      else           color="#D9CD4C"
      end
    elseif status == "Charging" then color="#ABD94C"
    end

    v = widgettext('BAT', bat .. '%',nil,color)
  end

  return v
end
--}}}

--{{{ widgets / memgraph
memgraphwidget = awful.widget.graph({ })
memgraphwidget.widget:buttons(join(
  awful.button({}, 3, function () terminal("-name top -e top") end),
  awful.button({}, 1, function () terminal("-name htop -e htop --sort-key PERCENT_MEM") end)
))

memgraphwidget:set_color('#0F120F')
memgraphwidget:set_border_color('#000000')
memgraphwidget:set_background_color('#000000')
memgraphwidget:set_height(14)
memgraphwidget:set_width(40)
memgraphwidget:set_scale(false)
awful.widget.layout.margins[memgraphwidget.widget] = { left = 1, top = 1, right = 2 }

function get_mem()
    -- Return MEM usage values
    local f = io.open('/proc/meminfo')

    ---- {{ Get data
    for line in f:lines() do
        line = splitbywhitespace(line)

        if line[1] == 'MemTotal:' then
            mem_total = math.floor(line[2]/1024)
        elseif line[1] == 'MemFree:' then
            free = math.floor(line[2]/1024)
        elseif line[1] == 'Buffers:' then
            buffers = math.floor(line[2]/1024)
        elseif line[1] == 'Cached:' then
            cached = math.floor(line[2]/1024)
        end
    end
    f:close()

    ---- {{ Calculate percentage
    mem_free=free+buffers+cached
    mem_inuse=mem_total-mem_free

    mem_usepercent = math.floor(mem_inuse/mem_total*100)
    mem_cache_percent = math.floor((cached+buffers)/mem_total*100)

    return {mem_usepercent, mem_cache_percent, mem_total, mem_free}
end
--}}}

--{{{ widgets / cputemp
cputempwidget = widget({
    type = 'textbox',
    name = 'cputempwidget',
    align = 'left',
})
awful.widget.layout.margins[cputempwidget] = { left = 5 }
--cputempwidget.text = 'cpu'
local function get_cputemp()
  local f = io.open('/sys/class/hwmon/hwmon1/device/temp1_input')
  local v = f:read() / 1000
  f:close()
  return v
end
--}}}

--{{{ widgets / fan
fanwidget = widget({
    type = 'textbox',
    name = 'fanwidget',
    align = 'left',
})


local function get_fan()
  local f = io.open('/sys/class/hwmon/hwmon1/device/fan1_input')
  local v = f:read()
  f:close()
  return v
end
--}}}

--{{{ widgets / mounts
function get_mounts()
   local v = {}
   local f = io.open('/tmp/.awesome.df')
   if not f then return end
   local l = f:lines()
   for line in l do
     for p,q in pairs(config.widgets.watchmount) do
    if line:find(q) ~= nil then
      local tmp = {}
                for id in line:gmatch("%S+") do table.insert(tmp,id) end
      if #tmp > 6 then tmp[6]=tmp[6]..' '..tmp[7] end -- hack: space in mountpoint
      table.insert(v,{tmp[6], tmp[4], q})
    end
  end

   end
   f:close()
   return v
end

function dump_mounts()
  os.execute('df -h > /tmp/.awesome.df &')
end

function mountlist()
    local w = { layout = awful.widget.layout.horizontal.leftright }

    local function update()
        local mnts = get_mounts()
        if not mnts or #mnts == 0 then return end
        local len = w.len or #w
        -- Add more widgets
        if len < #mnts then
            for i = len + 1, #mnts do
                w[i] = widget({ type = "textbox", align = "right" })
                awful.doc.set(w[i], { name = "mountwidget", description = "Mount widget", class = "widgets" })
            end
        -- Remove widgets
        elseif len > #mnts then
            for i = #mnts + 1, len do
                w[i] = nil
            end
        end
        -- Update widgets text
        for i,mnt in ipairs(mnts) do
            local tmp = {}
            local esc=string.gsub(mnt[1],' ','\\ ')
            w[i].text = mnt[1]:gsub(mnt[3],''):upper() ..
                       '<span color="' .. beautiful.widget_value .. '">' .. mnt[2] .. '</span>' ..
                        config.widgets.space

            w[i]:buttons(join(

              awful.button({}, 1,
              function ()
                local action
                for m, spwn in pairs(config.widgets.autostart) do
                  if mnt[1]:lower():find(m) then
                    action = spwn
                    break
                  end
                end
                if not action then action = config.widgets.autostart.default end
                action = action:gsub("%%f", esc)
                awful.util.spawn_with_shell(action)
              end, nil, "Open"),

              awful.button({}, 2,
              function ()
                local action = config.widgets.autostart.default
                action = action:gsub("%%f", esc)
                awful.util.spawn_with_shell(action)
              end, nil, "Browse"),

              awful.button({}, 3,
              function ()
                local cli = client.get()
                local t = "Volume in use:"
                for i,c in ipairs(cli) do
                  if c.name:find(esc) then

                  end
                end
                awful.util.spawn("eject " .. esc, false)
                awful.util.spawn("pumount " .. esc, false)
                --awful.util.spawn("pumount -l " .. esc)
              end, nil, "Unmount")

            ))
        end
    end
    local t = timer({ timeout = 1 })
    t:add_signal("timeout", update)
    t:start()
    update()
    return w
end
mountwidget = mountlist()
--}}}

--{{{ widgets / apt
aptwidget = widget({ type = "textbox", name = "aptwidget", align="right"})

aptwidget:buttons(join(
  awful.button({ }, 1, function () terminal("-name apt -geometry 169x55 -title aptitude -e sudo aptitude") end)
))

function get_apt()
  local f = io.open('/tmp/.awesome.apt')
  if not f then return end
  local apt = f:read()
  f:close()
  if not apt then return end
  if tonumber(apt) > 0 then
    aptwidget.text  = widgettext('APT', apt  , nil, '#99C399' )
  else
    aptwidget.text = ''
  end
end

function dump_apt()
  os.execute("sudo apt-get upgrade -s | grep upgraded | tail -n1 | awk '{ print $1 }' > /tmp/.awesome.apt &")
end
--}}}

--{{{ widgets / clock
clockwidget = widget({ type = "textbox", })
awful.doc.set(clockwidget, { description = "System time", class = "widgets", name = "clockwidget" })

calendar = nil
local offset = 0

function remove_calendar()
        if calendar ~= nil then
            naughty.destroy(calendar)
            calendar = nil
            offset = 0
        end
end

function showcalendar(inc_offset)
        local save_offset = offset
        remove_calendar()
        if inc_offset == 666 then
                offset = 0
        else
                offset = save_offset + inc_offset
        end
        local datespec = os.date("*t")
        local date = datespec.year * 12 + datespec.month - 1 + offset
        date = (date % 12 + 1) .. " " .. math.floor(date / 12)
        cal = awful.util.pread("cal " .. date)
        cal = string.gsub(cal, "^%s*(.-)%s*$", "%1")
        cal = string.gsub(cal, "Mo Tu We Th Fr Sa Su", "<span color='#333028'>Mo Tu We Th Fr Sa Su</span>")
        local day = pad(datespec.day, 2, " ")
        if offset == 0 then cal = string.gsub(cal, "([\n ])(" .. day .. ")", "%1<span color='orange'>%2</span>") end
        calendar = naughty.notify({
                    text = os.date("<b><span color=\"white\">%a, %d %B %Y</span></b>\n\n") .. cal,
                    timeout = 0, hover_timeout = 0.5, --height=130
        })
end

clockwidget:buttons(join(
  awful.button({ }, 1, function () showcalendar(-1) end, nil, "Show previous month"),
  awful.button({ }, 2, function () showcalendar(666) end, nil, "Show current month"),
  awful.button({ }, 3, function () showcalendar(1) end, nil, "Show next month"),
  awful.button({ }, 4, function () showcalendar(-1) end, nil, "Show previous month"),
  awful.button({ }, 5, function () showcalendar(1) end, nil, "Show next month")
))

clockwidget:add_signal("mouse::enter", function() showcalendar(0) end)
clockwidget:add_signal("mouse::leave", function() remove_calendar() end)
--}}}

--{{{ widgets / systray
mysystray = widget({ type = "systray", name = "mysystray", align = "right" })
--}}}

--{{{ widgets / layoutbox
mylayoutbox = {}
for s = 1, screen.count() do
  mylayoutbox[s] = awful.widget.layoutbox(s, { })
  mylayoutbox[s].image = img
  mylayoutbox[s].resize = false
  mylayoutbox[s]:buttons(join(
    awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
    awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
    awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
  ))
  awful.widget.layout.margins[mylayoutbox[s]] = { top = 4, left = 2, right = 2 }
end
--}}}

--{{{ widgets / hook functions
function hook_1s()
  local color,color2=''

  cpugraphwidget:add_value(wicked.widgets.cpu()[1]/100)
  local a = get_mem()
  memgraphwidget:add_value(a[1] / 100)

  cputempwidget.text   = widgettext('CPU', get_cputemp() .. '°C')
  fanwidget.text    = widgettext('FAN', string.format("%-4s",get_fan()))
  wifiwidget.text    = widgettext('WIFI', get_wifi())

  local stat,vol = jack_status()
  if stat == "fw" or stat == "alsa" then stat = "<span color='#333333'>"..stat.." </span>" end
  jackwidget.text   = widgettext('JCK', (stat or "off") ..  (vol or ""))

  if netup then
  local b = wicked.widgets.net()
  if b['{'..config.widgets.wifi.. ' down_kb}'] > 0 then color = beautiful.widget_value; color = beautiful.widget_value else color = '#333333' end
  if b['{'..config.widgets.wifi.. ' up_kb}'] > 0 then color2 = beautiful.widget_value else color2 = '#333333' end
    netwidget.text = widgettext('NET', string.format('%3s <span color="#333333">/</span> %-3s', b['{'..config.widgets.wifi..' down_kb}'], b['{'..config.widgets.wifi.. ' up_kb}']), nil, color2)
  else
    netwidget.text = ''
  end
  clockwidget.text = (rec or "") .. "<span font_desc='' color='#cccccc'>" .. os.date("%H<span color='#999999'>:</span>%M<span color='#999999'>:</span>%S") .. "</span> "
end
hook_1s()

function hook_3s ()
  dump_mounts()
  get_mounts()
end
hook_3s()

function hook_5s ()
  batterywidget.text = get_bat()
--  get_mail()
  get_apt()
  dump_autoap()
  get_autoap()
end
hook_5s()

function hook_1m ()
--  dump_mail()
end

function hook_10m ()
  dump_apt()
end
--}}}

--{{{ widgets / taglist
mytaglist = {}
mytaglist.buttons = join(
  awful.button({ }, 1, awful.tag.viewonly, nil, "Switch to tag"),
  awful.button({ modkey }, 1, awful.client.movetotag, nil, "Move client to tag"),
  awful.button({ }, 3, awful.tag.viewtoggle, nil, "Toggle tag"),
  awful.button({ modkey }, 3, awful.client.toggletag, nil, "Toggle client on tag"),
  awful.button({ }, 4, awful.tag.viewnext, nil, "Switch to next tag"),
  awful.button({ }, 5, awful.tag.viewprev, nil, "Switch to previous tag")
)

for s = 1, screen.count() do
  mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons, nil, {{item = "icon" }, {item = "title", margin={left=6}}, layout = awful.widget.layout.horizontal.leftright})
  awful.doc.set(mytaglist[s], { name = "mytaglist", class = "widgets", description = "Taglist widget" })
end

shifty.taglist = mytaglist
--}}}

--{{{ widgets / tasklist
mytasklist = {}
mytasklist.buttons = join(
  awful.button({ }, 1, function (c)
    if not c:isvisible() then awful.tag.viewonly(c:tags()[1]) end
    client.focus = c
    c:raise()
    end, nil, "Focus client"),
  awful.button({ }, 2, function ()
    if instance then
      instance:hide(); instance = nil
    else
      instance = awful.menu.clients({ width=250 })
    end
    end, nil, "Show menu with all clients"),
  awful.button({ }, 3, function (c) c.minimized = true end, nil, "Minimize client"),
  awful.button({ }, 4, function ()
    awful.client.focus.byidx(1)
    if client.focus then client.focus:raise() end
    end, nil, "Focus next client"),
  awful.button({ }, 5, function ()
    awful.client.focus.byidx(-1)
    if client.focus then client.focus:raise() end
    end, nil, "Focus previous client")
  )

for s = 1, screen.count() do
  mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons, nil,
    { layout = awful.widget.layout.horizontal.flex,
      {
        item = "title",
        margin = { top = 1, left = 4, right = 4 },
        bg_align  = "right",
      }
    }
  )

  awful.doc.set(mytasklist[s], { name = "mytasklist", class = "widgets", description = "Tasklist widget" })
end
--}}}

--{{{ widgets / tagprompt
mytagprompt = {}
for s = 1, screen.count() do
  mytagprompt[s] = widget({  type = 'textbox', })
end
--}}}

-- }}}

--{{{ panel

widgetz = {

    memgraphwidget,
    cpugraphwidget,
    cputempwidget,
    fanwidget,
    wifiwidget,
    netwidget,
    layout = awful.widget.layout.horizontal.leftright,

    {
      mountwidget,
      aptwidget,
      jackwidget,
      batterywidget,
      mysystray,
      clockwidget,
      layout = awful.widget.layout.horizontal.rightleft,
    }
}


tabbar = {}
for s = 1, screen.count() do
  tabbar[s] = awful.wibox({ position = "top", name = "tabbar" .. s, screen = s,
                            fg = beautiful.fg_normal, bg = beautiful.bg_normal, height = 34 })
  tabbar[s].widgets = {
    layout = awful.widget.layout.vertical.flex,
    widgetz,
    {
      mytaglist[s],
      mytagprompt[s],
      mylayoutbox[s],
      mytasklist[s],
      layout = awful.widget.layout.horizontal.leftright
    }
  }

  awful.doc.set(tabbar[s], { name = "tabbar", class = "panels", description  = "Panel with tag/task-list" })
end
--}}}

-- {{{ bindings

-- {{{ bindings / global
globalkeys = join(

-- {{{ bindings / global / spawns

  awful.doc.set_default({ group = "1. global actions" }),

  awful.key({ modkey            }, "grave",       function () terminal() end, nil, "terminal"),
  awful.key({ modkey            }, "x",           function () awful.util.spawn("xkill", false) end, nil, "xkill"),
  awful.key({                   }, "XF86Launch1", popterm, nil, "popup terminal"),
  awful.key({ modkey, "Control" }, "grave",       function () terminal("-name tail -title log/awesome -e tail -fn0 /home/koniu/log/awesome") end, nil, "awesome log"),
  awful.key({                   }, "Print",       function () awful.util.spawn_with_shell("~/bin/shot") end, nil, "screenshot"),
  awful.key({ "Control"         }, "Print",       function () awful.util.spawn_with_shell("sleep 1s; ~/bin/shot -s") end, nil, "selective screenshot"),
  awful.key({ "Mod1"            }, "Print",       function () awful.util.spawn_with_shell("sleep 5s; ~/bin/shot") end, nil, "delayed screenshot"),
  awful.key({ "Control", "Mod1" }, "Delete",      function () cli_toggle("urxvtc -name htop -e htop --sort-key PERCENT_CPU", "instance","htop") end),

-- }}}

-- {{{ bindings / global / tag manipulation
  awful.doc.set_default({ group = "2. tag manipulation" }),
  awful.key({                   }, "XF86Back",    awful.tag.viewprev, nil, "previous tag"),
  awful.key({                   }, "XF86Forward", awful.tag.viewnext, nil, "next tag"),
  awful.key({  modkey           }, "XF86Back",    shifty.shift_prev, nil, "move tag left" ),
  awful.key({  modkey           }, "XF86Forward", shifty.shift_next, nil, "move tag right"),

  awful.key({ modkey            }, "t",           function() shifty.add({ rel_index = 1 }) end, nil, "new tag"),
  awful.key({ modkey, "Control" }, "t",           function() shifty.add({ rel_index = 1, nopopup = true }) end, nil, "new tag in bg"),
  awful.key({ modkey            }, "r",           shifty.rename, nil, "tag rename"),
  awful.key({ modkey            }, "w",           shifty.del, nil, "tag delete"),

  awful.key({ modkey            }, 'i',           ti, nil, "tag info"),
-- }}}

-- {{{ bindings / global / client manipulation
  awful.doc.set_default({ group = "3. client manipulation" }),
  awful.key({ "Shift"           }, "XF86Back",    shifty.send_prev, nil, "move to prev tag"),
  awful.key({ "Shift"           }, "XF86Forward", shifty.send_next, nil, "move to next tag"),
  awful.key({ "Control"         }, "XF86Back",    function () myfocus(-1) end, nil, "focus previous"),
  awful.key({ "Control"         }, "XF86Forward", function () myfocus(1)  end, nil, "focus next"),
  awful.key({ modkey, "Shift"   }, "XF86Back",    function () awful.client.swap.byidx(-1) end, nil, "swap with prev"),
  awful.key({ modkey, "Shift"   }, "XF86Forward", function () awful.client.swap.byidx(1) end, nil, "swap with next"),
-- }}}

-- {{{ bindings / global / mm keys
  awful.key({ "Shift"           }, "XF86Launch1",   function() rek:display() end),
  awful.key({                   }, "XF86Launch1",   function() rek:toggle() end),
  awful.key({ "Control","Shift" }, "XF86Launch1",   function() rek:replay() end),
  awful.key({ "Mod5"            }, "XF86Launch1",   function() rek:ab() end),

  awful.key({                 }, "XF86AudioNext",  function () awful.util.spawn('mm next') end),
  awful.key({                 }, "XF86AudioPrev",  function () awful.util.spawn('mm prev') end),
  awful.key({ "Control"       }, "XF86AudioNext",  function () awful.util.spawn('mm ff') end),
  awful.key({ "Control"       }, "XF86AudioPrev",  function () awful.util.spawn('mm rew ') end),
  awful.key({                 }, "XF86AudioPlay",  function () awful.util.spawn('mm play') end),
  awful.key({                 }, "XF86AudioStop",  function () awful.util.spawn('mm stop') end),

  awful.key({                 }, "XF86AudioMute",         function() mixer:mute()         end),
  awful.key({                 }, "XF86AudioRaiseVolume",  function() mixer:volume_up()    end),
  awful.key({                 }, "XF86AudioLowerVolume",  function() mixer:volume_down()  end),
-- }}}

-- {{{ bindings / global / default rc.lua keys

  awful.doc.set_default({ group = "default" }),
  awful.key({ modkey            }, "Escape",      awful.tag.history.restore, nil, "prev selected tags"),
  awful.key({ modkey, "Control" }, "Escape",      function () awful.tag.history.restore(mouse.screen, 1) end, nil, "prev selected tags"),
  awful.key({ modkey, "Control" }, "j",           function () awful.screen.focus(1) end, nil, "next screen"),
  awful.key({ modkey, "Control" }, "k",           function () awful.screen.focus(-1) end, nil, "prev screen"),
  awful.key({ modkey            }, "Tab",         function () awful.client.focus.history.previous(); if client.focus then client.focus:raise() end end, nil, "prev foused client"),
  awful.key({ modkey            }, "u",           awful.client.urgent.jumpto, nil, "jump to urgent"),

-- Standard program

  awful.key({ modkey, "Control" }, "r",           function () naughty.notify{ text = awful.util.escape(awful.util.restart()) } end, nil, "restart awesome"),
  awful.key({ modkey, "Shift"   }, "q",           awesome.quit, nil, "quit awesome"),

-- Layout manipulation
  awful.key({ modkey            }, "l",           function () awful.tag.incmwfact(0.05) end),
  awful.key({ modkey            }, "h",           function () awful.tag.incmwfact(-0.05) end),
  awful.key({ modkey, "Shift"   }, "h",           function () awful.tag.incnmaster(1) end),
  awful.key({ modkey, "Shift"   }, "l",           function () awful.tag.incnmaster(-1) end),
  awful.key({ modkey, "Control" }, "h",           function () awful.tag.incncol(1) end),
  awful.key({ modkey, "Control" }, "l",           function () awful.tag.incncol(-1) end),
  awful.key({ modkey            }, "space",       function () awful.layout.inc(layouts, 1) end),
  awful.key({ modkey, "Shift"   }, "space",       function () awful.layout.inc(layouts, -1) end),
--}}}

-- {{{ bindings / global / prompts
  awful.doc.set_default({ group = "9. prompts" }),
  awful.key({ "Mod1"            }, "F2",  function () prompt.exec(prompt.presets.run) end, nil, "run"),
  awful.key({ "Mod1"            }, "F1",  function () prompt.exec(prompt.presets.lua) end, nil, "lua"),
  awful.key({ modkey, "Mod1"    }, "c",   function () prompt.presets.calc.args.text = val and tostring(val); prompt.exec(prompt.presets.calc) end, nil, "calc"),
  awful.key({ modkey, "Mod1"    }, "d",   function () prompt.presets.dict.args.text = selection(); prompt.exec(prompt.presets.dict) end, nil, "dict"),
  awful.key({ modkey, "Mod1"    }, "k",   function () prompt.exec(prompt.presets.kill) end, nil, "kill"),
  awful.key({ modkey            }, "slash",       function () prompt.exec(prompt.presets.api) end, "help prompt"),
  awful.key({ modkey            }, "F1",          handy.run, nil, "help mode"),
  awful.key({ modkey, "Control" }, "F1",          handy.whatsthis, nil, "what's this"),
-- }}}

-- {{{ bindings / global / prompts / tagjump
  awful.key({ "Mod5" }, "/", function ()
    wi = mytagprompt[mouse.screen]
    wi.bg_image = image("/home/koniu/.config/awesome/icons/arrow.png")

    awful.prompt.run({
        fg_cursor = "#DDFF00", bg_cursor=beautiful.bg_normal, ul_cursor = "single",
        prompt = "   ", text = " ", selectall = true, autoexec = 1
      },
      wi,
      function(n) local t = shifty.name2tag(n); if t then awful.tag.viewonly(t) end end,
      function (cmd, cur_pos, ncomp, matches) return shifty.completion(cmd, cur_pos, ncomp, { "existing" }) end,
      os.getenv("HOME") .. "/.cache/awesome/tagjump",
      nil,
      function() wi.bg_image = nil; wi.text = "" end)
  end, nil, "jump to tag")
-- }}}

-- }}}

)

-- {{{ bindings / global / shifty.getpos
for i=0, ( shifty.config.maxtags or 9 ) do
  globalkeys = join(globalkeys, awful.key({ modkey }, i,
  function ()
    local t = awful.tag.viewonly(shifty.getpos(i))
  end))
  globalkeys = join(globalkeys, awful.key({ modkey, "Control" }, i,
  function ()
    local t = shifty.getpos(i)
    t.selected = not t.selected
  end))
  globalkeys = join(globalkeys, awful.key({ modkey, "Control", "Shift" }, i,
  function ()
    if client.focus then
      awful.client.toggletag(shifty.getpos(i))
    end
  end))
  -- move clients to other tags
  globalkeys = join(globalkeys, awful.key({ modkey, "Shift" }, i,
    function ()
      if client.focus then
        t = shifty.getpos(i)
        awful.client.movetotag(t)
        awful.tag.viewonly(t)
      end
    end))
end
-- }}}

--{{{ bindings / client
clientkeys = join(
  awful.doc.set_default({ group = "3. client manipulation" }),
  awful.key({ modkey            }, "Up",       function (c) c.maximized_horizontal = not c.maximized_horizontal
                                                     c.maximized_vertical = not c.maximized_vertical end, nil, "maximize"),
  awful.key({ modkey            }, "Down",    function (c) c.minimized = true end, nil, "minimize"),
  awful.key({ modkey            }, "f",       function (c) c.fullscreen = not c.fullscreen end, nil, "fullscreen"),
  awful.key({ modkey, "Control" }, "space",   awful.client.floating.toggle, nil, "set floating"),
  awful.key({ modkey, "Control" }, "Return",  function (c) c:swap(awful.client.getmaster()) end, nil, "swap with master"),
  awful.key({ modkey            }, "o",       awful.client.movetoscreen, nil, "move to screen"),
  awful.key({ modkey, "Shift"   }, "r",       function (c) c:redraw() end, nil, "redraw"),
  awful.key({ modkey,           }, "q",       function (c) if not awful.client.property.get(c, "killhide") then c:kill() else c.hidden = true end end, nil, "kill client"),
  awful.key({ "Mod1", "Mod4"    }, "i",       ci),
  awful.key({ "Mod1", "Mod4"    }, "a",       function(c) c.ontop = not c.ontop end, nil, "toggle on top"),

  awful.key({ modkey            }, "Up",      function (c) awful.client.swap.bydirection("up", c) end),
  awful.key({ modkey            }, "Down",    function (c) awful.client.swap.bydirection("down", c) end),
  awful.key({ modkey            }, "Left",    function (c) awful.client.swap.bydirection("left", c) end),
  awful.key({ modkey            }, "Right",   function (c) awful.client.swap.bydirection("right", c) end)
),
--}}}

-- {{{ bindings / set keys and buttons
awful.doc.set_default({})
root.buttons(join(
  awful.button({ }, 3, function () mymainmenu:toggle() end),
  awful.button({ }, 4, awful.tag.viewnext),
  awful.button({ }, 5, awful.tag.viewprev)
))
root.keys(globalkeys)
shifty.config.clientkeys = clientkeys
shifty.config.globalkeys = globalkeys
-- }}}

-- }}}

-- {{{ signals

-- {{{ signals / focus
client.add_signal("focus", function (c)
  -- see if the client needs scrolling
  local ws = screen[c.screen].workarea
  local geom = c:geometry()
  if (geom.width > ws.width or geom.height > ws.height)
    and not (awful.client.dockable.get(c) or c.fullscreen) then
      scrolltimer = timer({ timeout = 0.01 })
      scrolltimer:add_signal("timeout", scrollclient)
      scrolltimer:start()
  end
  -- change border color
  if awful.client.floating.get(c) and not awful.client.dockable.get(c) then
    c.border_color = '#26241E'
  else
    c.border_color = beautiful.border_focus
  end
end)
-- }}}

-- {{{ signals / unfocus
client.add_signal("unfocus", function (c)
  -- kill scrolling timer
  if scrolltimer and scrolltimer.started then scrolltimer:stop() end
  -- change border color
  if not awful.client.dockable.get(c) then
    c.border_color = beautiful.border_normal
  end
end)
-- }}}

-- {{{ signals / mouse_enter
client.add_signal("manage", function (c, startup)
    -- Sloppy focus, but disabled for magnifier layout
    c:add_signal("mouse::enter", function(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
        and awful.client.focus.filter(c) then
        client.focus = c
    end end)
end)
-- }}}

--{{{ signals / timers
timers = {
  { t = 1,    f = hook_1s   },
  { t = 30,   f = hook_1m   },
  { t = 3,    f = hook_3s   },
  { t = 5,    f = hook_5s   },
  { t = 600,  f = hook_10m  },
}

for i, tmr in ipairs(timers) do
  timers[i].timer = timer({ timeout = tmr.t })
  timers[i].timer:add_signal("timeout", tmr.f)
  timers[i].timer:start()
end
-- }}}

-- }}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=2:tabstop=2:softtabstop=2:encoding=utf-8:textwidth=80
