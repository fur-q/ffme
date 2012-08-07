-- TODO:
-- test if autocrop actually does anything
-- comment preset files
-- crash test

local cfg    = require "config"
local weevil = require "weevil"

local function contains(tbl, val)
  for k,v in pairs(tbl) do if v == val then return true end end return false 
end

local preset = {  
  ["-codec:v"]   = "libx264",
  ["-codec:a"]   = "libfaac",
  ["-f"]         = "flv",
  ["-g"]         = "50",
}

local ffme = {}

function ffme:init()
  cfg:load("ffme.cfg")
  for k,v in pairs(cfg.servers) do self.cmbServer[k] = v end
  self:SetTitle("Stopped")
end

-- main

-- set the titlebar text
function ffme:SetTitle(str)
  self.dlgMain.title = string.format("%s - ffme 0.1.0", str)
end

-- convert ffmpeg's time format to seconds
function ffme:TimeToSecs(time)
  local h, m, s = time:match("(%d%d):(%d%d):(%d%d)")
  return h and h * 3600 + m * 60 + s or false
end

function ffme:GetDuration(d)
  local total = self:TimeToSecs(d)
  local start, dur = self.txtStart.value, self.txtDuration.value
  start = self:TimeToSecs(start) or tonumber(start) or 0
  dur = self:TimeToSecs(dur) or tonumber(dur) or 0
  self.duration = dur > 0 and dur or start and total - start or total
end

-- enable the start button when valid values are in the relevant places
-- FIXME these are nil when empty because what the fuck?
function ffme:AllowStart()
  if self.cmbServer.value ~= "" and self.txtFile.value ~= "" then
    self.btnStart.active = "YES" 
  else
    self.btnStart.active = "NO" 
  end
end

-- called by the browse button, pick a file
function ffme:PickFile()
  local fdlg = iup.filedlg{}
  fdlg:popup()
  if fdlg.status == "0" then
    self.txtFile.value = fdlg.value
    self:AllowStart()
  end
end

-- turn the flags table into an ffmpeg command
function ffme:CreateFlags()
  local fmt = " -re -i \"%s\" %s %s"
  if self.txtStart.value and self.txtStart.value ~= "" then
    fmt = " -ss " .. self.txtStart.value .. fmt
  end
  if self.txtDuration.value and self.txtDuration.value ~= "" then
    fmt = " -t " .. self.txtDuration.value .. fmt
  end
  weevil:readfile("presets/"..cfg.preset..".lua", preset)
  local filters = {}
  if preset["-vf"] then filters[#filters+1] = preset["-vf"] end
  if cfg.deint == "YES"   then filters[#filters+1] = "yadif=0:-1:0" end
  if cfg.denoise == "YES" then filters[#filters+1] = "hqdn3d=4:3:4:3" end
  if cfg.crop == "YES"    then filters[#filters+1] = "cropdetect=24:16:0" end
  if #filters > 0 then
    preset["-vf"] = string.format("\"%s\"", table.concat(filters, ", "))
  end
  local out = {}
  for k,v in pairs(preset) do
    out[#out+1] = k .. " " .. v
  end
  return string.format(fmt, self.txtFile.value, table.concat(out, " "), self.cmbServer.value)
end

-- called when the stream is stopped, resets everything to default state
function ffme:StreamStopped()
  if self.ffmpeg then self.ffmpeg:kill() self.ffmpeg:close() end
  self.ffmpeg, self.pipe, self.timer = nil, nil, nil
  self:SetTitle("Stopped")
  self.running = false
  self.prbProgress.value = 0
  self.btnStart.title = "Start"
end

-- called when the stop/start button is pressed
function ffme:StopStart()
  if not self.ffmpeg then -- start the stream
    self.btnStart.active = "NO"
    if not contains(cfg.servers, self.cmbServer.value) then
      table.insert(cfg.servers, 1, self.cmbServer.value)
      cfg:save()
    end
    local flags = self:CreateFlags()
    local cmd = cfg.ffmpeg .. flags
    self.ffmpeg, self.pipe = winapi.spawn_process(cmd)
    if not self.pipe then
      iup.Alarm("Error", "ffmpeg not found", "OK")
    else
      local out, err = {}
      while true do
        local r = self.pipe:read()
        if not r then err = out[#out]:match(".+\n(.-)\n.-$") break end
        if r:find("\r$") then break end
        out[#out+1] = r
      end
      if err then 
        iup.Alarm("ffmpeg error", err, "OK") 
        self.btnStart.active = "YES"
        return
      end
      local dur = table.concat(out):match("Duration: (%S+)")
      if not dur then return end -- this should never happen either
      -- all is well, so let's go
      self:GetDuration(dur)
      self.btnStart.active = "YES"
      self.btnStart.title = "Stop"
      self.timer = self.pipe:read_async(function(l) self:UpdateProgress(l) end)  
    end
  else -- stop the stream
    self:StreamStopped()
  end
end

function ffme:UpdateProgress(line)
  if line and line ~= "" then
    local fps, time, btr = line:match("fps=%s*(%d+).+time=(%S+) bitrate=%s*(%d+)")
    if not fps then return end
    local complete = self:TimeToSecs(time) / self.duration
    self.prbProgress.value = complete
    self:SetTitle(string.format("%.1f%% done (%s FPS, %skbps)", complete * 100, fps, btr))
  else
    -- check for errors?
    self:StreamStopped()
    return true
  end
end

-- options

function ffme:ShowOpts()
  local pre = {}
  for f in winapi.files("presets\\*.lua") do pre[#pre+1] = f:sub(1,-5) end
  table.sort(pre)
  for k,v in pairs(pre) do
    self.cmbPreset[k] = v
    if cfg.preset == v then self.cmbPreset.value = k end
  end
  self.txtFF.value      = cfg.ffmpeg
  self.chkDeint.value   = cfg.deint
  self.chkDenoise.value = cfg.denoise
  self.chkCrop.value    = cfg.crop
  self.dlgOpts:popup(self.dlgMain.x + 32, self.dlgMain.y + 32)
end

function ffme:PickFF()
  local fdlg = iup.filedlg{}
  fdlg:popup()
  if fdlg.status == "0" then
    self.txtFF.value = fdlg.value
  end
end

function ffme:CloseOpts()
  self.dlgOpts:hide()
end

function ffme:SaveOpts()
  cfg.ffmpeg  = self.txtFF.value
  cfg.preset  = self.cmbPreset[self.cmbPreset.value]
  cfg.deint   = self.chkDeint.value
  cfg.denoise = self.chkDenoise.value
  cfg.crop    = self.chkCrop.value
  cfg:save()
  self.dlgOpts:hide()
end

return ffme