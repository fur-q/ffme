local ffme = require "ffme"

local ctrls = {
  cmbServer = iup.list { dropdown = "YES", editbox = "YES", visiblecolumns = 20, expand = "HORIZONTAL", action = function() ffme:AllowStart() end },
  txtFile   = iup.text { expand = "YES", active = "NO", visiblecolumns = 20 },
  btnFile   = iup.button { title = "Browse", padding = "4x1", action = function() ffme:PickFile() end },
  btnOpts   = iup.button { title = "Options", padding = "4x1", action = function() ffme:ShowOpts() end },
  prbProgress = iup.progressbar { value = 0, expand = "HORIZONTAL" },
  txtStart  = iup.text { expand = "YES", tip = "Start time, in seconds or hh:mm:ss format\nLeave blank to start from the beginning" },
  txtDuration = iup.text { expand = "YES", tip = "Stream duration, in seconds or hh:mm:ss format\nLeave blank to stream until the end" },
  btnStart  = iup.button { title = "Start", padding = "4x1", active = "NO", action = function() ffme:StopStart() end },
}

for k,v in pairs(ctrls) do ffme[k] = v end

ffme.dlgMain = iup.dialog {
  iup.vbox {
    iup.hbox {
      iup.label{ title = "Server address:", rastersize = "72x", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.cmbServer;
      minsize = "x30"
    },
    iup.hbox {
      iup.label{ title = "Input file:", rastersize = "72x", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.txtFile,
      ffme.btnFile;
      minsize = "x30"
    },
    iup.hbox {
      iup.label{ title = "Start time:", rastersize = "72x", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.txtStart,
      iup.label{ title = "Duration:", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.txtDuration,
      minsize = "x30"
    },
    iup.hbox {
      ffme.prbProgress
    },
    iup.hbox {
      ffme.btnOpts,
      iup.fill{},
      ffme.btnStart;
      minsize = "x30"
    }
  },
  gap = 8, margin = "4x4", title = "ffme 0.1.0", resize = "NO",
  icon = "FFME_ICON",
  close_cb = function() ffme:StreamStopped() end
}