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
--{{{ backends
prerec = 400
backends = {
    ["rec"] = {
        name = 'rec',
        f_start = function (s) awful.util.spawn_with_shell("/usr/local/bin/jack.record " .. s.file) end,
        f_stop = function (s) awful.util.spawn_with_shell("killall jack.record") end,
    },
    ["tm"] = {
        name = 'tm',
        prerec = prerec,
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
                awful.util.spawn_with_shell("screen -dm timemachine -i -f wav -t " .. prerec * 0.1 .. " -c2 mix:out_left mix:out_right")
            end
        end,
    },
    ["recordmydesktop"] = {
        -- TODO 
    }
}
--}}}
--{{{ styles
styles = {
    vertical = {
        { color = { recording = '#ff3333', stopped = '#cccccc', playing = "#33ff33" },
            f = function(self) return self.stat end, format = "%s" },
        { color = { recording = '#555555', stopped = '#444444', playing = "#444444" },
            f = function(self) return self.file:gsub(".*/","") end, format = "%s" },
        { color = { recording = '#704444', stopped = '#444444', playing = "#447044" },
            f = function(self) return count2time(self.count) end, format = "<b>%s:%s:%s.%s</b>", font = "Monospace 12", },
        { color = { recording = '#222222', stopped = '#222222', playing = "#222222" },
            f = function(self) return #self.recs, count2time(self.total) end, format = "total %s / <b>%s:%s:%s.%s</b>" },
        align = "center",
        font = 'Monospace 7',
        layout = awful.widget.layout.vertical.topdown,
        margins = { top = 1 },
        wibox = function()
            local w = wibox({ ontop = true, height = 14 })
            w.visible = false
            w.screen = 1
            w:geometry({ x = 860, y = 38, height = 200, width = 300 })
            w.opacity = 0.8
            return w
        end
    },
    horizontal = {
        { color = { recording = '#ffffff', stopped = '#ffffff', playing = "#ffffff" },
            f = function(self) return self.backend.name end, format = "%s" },
        { color = { recording = '#ff3333', stopped = '#cccccc', playing = "#33ff33" },
            f = function(self) return self.stat end, format = "%s" },
        { color = { recording = '#555555', stopped = '#444444', playing = "#444444" },
            f = function(self) return self.file:gsub(".*/","") end, format = "%s" },
        { color = { recording = '#704444', stopped = '#444444', playing = "#447044" },
            f = function(self) return count2time(self.count) end, format = "<b>%s:%s:%s.%s</b>" },
        { color = { recording = '#222222', stopped = '#222222', playing = "#222222" },
            f = function(self) return #self.recs, count2time(self.total) end, format = "total %s / <b>%s:%s:%s.%s</b>" },
        font = 'Monospace 7',
        align = "left",
        layout = awful.widget.layout.horizontal.flex,
        margins = { top = 1, bottom = 1, left = 3 },
        wibox = function()
            local w = awful.wibox({ ontop = true, height = 14, position = "bottom", screen = 1, bg = "#000000" })
            w.visible = false
            w.opacity = 0.8
            return w
        end
    },
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
    rec.style = args.style or styles.horizontal

    rec.backend = args.backend
    rec.recs = {}
    rec.stat = "stopped"
    rec.file = " "

    if rec.backend.f_new then rec.backend.f_new(rec) end

    rec.wibox = rec.style.wibox()
    rec.wibox.widgets = {}

    for i = 1, #rec.style do
        rec.wibox.widgets[i] = { widget{ type = "textbox" }, layout = rec.style.layout }
        rec.wibox.widgets[i][1].align = rec.style.align
        awful.widget.layout.margins[rec.wibox.widgets[i][1]] = rec.style.margins
    end
    rec.wibox.widgets.layout = rec.style.layout

    rec.count = 0
    rec.total = 0
    rec.timer = timer({ timeout = 0.1 })

    rec.update = function()
        rec.count = rec.count + 1
        if rec.stat == "recording" then rec.total = rec.total + 1 end
        for i, s in ipairs(rec.style) do
            local font = s.font or rec.style.font
            rec.wibox.widgets[i][1].text = string.format("<span color='%s' font_desc='%s'>"..s.format.."</span>", s.color[rec.stat], font, s.f(rec))
        end
    end
    rec.update()
    rec.timer:add_signal("timeout", rec.update)

    return rec
end
--}}}
--{{{ methods
REC = {}
--{{{ methods / display
function REC:display(f)
    if f ~= nil then
        self.wibox.visible = f
    else
        self.wibox.visible = not self.wibox.visible
    end
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
    if self.timeouter then self.timeouter:stop(); self.timeouter = nil end
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
        self.timeouter = timer({ timeout = 1 })
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
