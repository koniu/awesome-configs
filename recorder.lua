--{{{ envirnonment
local os = os
local io = io
local ipairs = ipairs
local setmetatable = setmetatable
local math = math
local table = table
local unpack = unpack
local string = string
local widget = widget
local wibox = wibox
local timer = timer
local pad = pad
local psgrep = psgrep
local awful = require("awful")

module("recorder")
--}}}

--{{{ configuration
backends = {
    ["jack.record"] = {
        f_start = function (s) awful.util.spawn_with_shell("/usr/local/bin/jack.record " .. s.file) end,
        f_stop = function (s) awful.util.spawn_with_shell("killall jack.record") end,
    },
    ["timemachine"] = {
        prerec = 150,
        f_start = function (s)
            s.outfile = "/home/koniu/tm-" .. os.date("%Y-%m-%dT%H:%M:%S", os.date("%s") - (s.backend.prerec or 0)*0.1) .. ".wav"
            awful.util.spawn_with_shell("oscsend localhost 7133 /start") 
        end,
        f_stop = function (s)
            awful.util.spawn_with_shell("oscsend localhost 7133 /stop") 
            awful.util.spawn_with_shell("mv ".. s.outfile .. " " .. s.file)
        end,
        f_new = function (s)
            if not psgrep({command = 'timemachine'}) then
                awful.util.spawn_with_shell("screen -dm timemachine -i -f wav -t 15 -c2 mix:out_left mix:out_right")
            end
        end,
    },
    ["recordmydesktop"] = {
        -- TODO 
    }
}

style = {
        { color = { recording = '#ff3333', stopped = '#cccccc', playing = "#33ff33" }, font = 'Monospace 7',
            f = function(self) return self.stat end, format = "%s" },
        { color = { recording = '#555555', stopped = '#444444', playing = "#444444" }, font = 'Monospace 7',
            f = function(self) return self.file:gsub(".*/","") end, format = "%s" },
        { color = { recording = '#704444', stopped = '#444444', playing = "#447044" }, font = 'Terminus 20',
            f = function(self) return count2time(self.count) end, format = "<b>%s:%s:%s.%s</b>" },
        { color = { recording = '#222222', stopped = '#222222', playing = "#222222" }, font = 'Monospace 7',
            f = function(self) return #self.recs, count2time(self.total) end, format = "total %s / <b>%s:%s:%s.%s</b>" },
}
--}}}

--{{{ count2time
function count2time(count)
    local h, m, s, t
    h = pad(math.floor(count / 36000), 2)
    m = pad(math.floor((count - h * 36000) / 600), 2)
    s = pad(math.floor((count - h * 36000 - m * 600) / 10), 2)
    t = math.floor(count - h * 36000 - m * 600 - s * 10)
    return h, m, s, t
end
--}}}

--{{{ constructor
function new(args)
    local rec = setmetatable({}, { __index = REC })
    
    rec.backend = args.backend
    rec.recs = {}

    if rec.backend.f_new then rec.backend.f_new(rec) end

    -- wibox
    rec.wibox = wibox({ ontop = true, width = 160, height = 70})
    rec.wibox.visible = false
    rec.wibox.screen = 1
    rec.wibox.widgets = {}
    rec.wibox:geometry({ x = 860, y = 38 })
    
    -- widgets

    for i = 1, #style do
        rec.wibox.widgets[i] = { widget({ type = "textbox" }), layout = awful.widget.layout.horizontal.flex }
        rec.wibox.widgets[i][1].align = "center"
        awful.widget.layout.margins[rec.wibox.widgets[i][1]] = { top = 1, bottom = 0 }
        rec.wibox.widgets[i][1].border_color = "red"
        rec.wibox.widgets[i][1].border_width = 0

    end
    rec.wibox.widgets.layout = awful.widget.layout.vertical.topdown

    rec.count = 0
    rec.total = 0
    rec.timer = timer({ timeout = 0.1 })

    rec.update = function()
        rec.count = rec.count + 1
        if rec.stat == "recording" then rec.total = rec.total + 1 end
        for i, s in ipairs(style) do
            rec.wibox.widgets[i][1].text = string.format("<span color='%s' font_desc='%s'>"..s.format.."</span>", s.color[rec.stat], s.font, s.f(rec))
        end
    end

    rec.timer:add_signal("timeout", rec.update)

    return rec
end
--}}}

--{{{ methods

REC = {}

--{{{ methods / display
function REC:display(f)
    self.wibox.visible = f or not self.wibox.visible
end
--}}}

--{{{ methods / toggle
function REC:toggle()
    if self.timer.started then self:stop() else self:start() end
end
--}}}

--{{{ methods / start
function REC:start()
    if self.playtimer then self.playtimer:stop(); self.playtimer = nil end
    self.stat = "recording"
    self.count = self.backend.prerec or 0
    self.total = self.total + (self.backend.prerec or 0)

    local fn = os.date("%Y%m%d-%H%M%S", os.date("%s") - (self.backend.prerec or 0)*0.1) .. ((self.backend.prerec and "p") or "").. ".wav"
    self.file = "~/data/audio/samples/__rec/".. fn
    self.backend.f_start(self)
    self.timer:start()
    if not self.wibox.visible then
        self:display(true)
        self.popup = true
    end
end
--}}}

--{{{ methods / stop
function REC:stop()
    self.stat = "stopped"
    self.backend.f_stop(self)
    self.timer:stop()

    table.insert(self.recs, { file = self.file, length = self.count })
    self.update()
    if self.popup then
        self.timeouter = timer({ timeout = 3 })
        self.timeouter:add_signal("timeout", function() self:display(false); self.timeouter:stop(); self.timeouter=nil; self.popup=nil end)
        self.timeouter:start()
    end

end
--}}}

--{{{ methods / replay
function REC:replay()
    self.stat = "playing"
    self.count = 0
    if self.playtimer then self.playtimer:stop() self.playtimer = nil end
    self.playtimer = timer({ timeout = 0.1 })
    self.playtimer:add_signal("timeout", self.update)
    self.playtimer:add_signal("timeout", function() if self.recs[#self.recs].length <= self.count then self.playtimer:stop() self.stat = "stopped" self.update() end  end)
    self.playtimer:start()
    awful.util.spawn_with_shell("/usr/local/bin/jack.play " .. self.file)
end
--}}}

--{{{ methods / ab
function REC:ab()
    if self.stat == "stopped" then
        self:start()
    elseif self.stat == "recording" then
        self:stop()
        self:replay()
        self.abtimer = timer({ timeout = self.recs[#self.recs].length * 0.1 - 0.3})
        self.abtimer:add_signal("timeout", function () self:replay() end)
        self.abtimer:start()
    elseif self.stat == "playing" then
        self.abtimer:stop()
        self.stat = "stopped"
        self.update()
        self.abtimer = nil
    end
end
--}}}

--}}}

-- vim: foldmethod=marker:filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4:encoding=utf-8:textwidth=80
