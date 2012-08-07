local ffme = require "ffme"

local ctrls = {
  txtFF      = iup.text   { expand = "YES", active = "NO", visiblecolumns = 20 },
  btnFF      = iup.button { title = "Browse", padding = "4x1", action = function() ffme:PickFF() end },
  cmbPreset  = iup.list   { dropdown = "YES", expand = "HORIZONTAL" },
  chkDeint   = iup.toggle { title = "Deinterlace" },
  chkDenoise = iup.toggle { title = "Denoise" },
  chkCrop    = iup.toggle { title = "Auto crop" },
  btnSave    = iup.button { title = "Save", padding = "4x1", action = function() ffme:SaveOpts() end },
  btnCancel  = iup.button { title = "Cancel", padding = "4x1", action = function() ffme:CloseOpts() end }
}

for k,v in pairs(ctrls) do ffme[k] = v end

ffme.dlgOpts = iup.dialog {
  iup.vbox {
    iup.hbox { 
      iup.label{ title = "Path to ffmpeg:", rastersize = "80x", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.txtFF,
      ffme.btnFF;
      minsize = "x32"
    },
    iup.hbox {
      iup.label{ title = "Preset:", rastersize = "80x", expand = "VERTICAL", fgcolor=iup.GetGlobal("DLGFGCOLOR") },
      ffme.cmbPreset;
      minsize = "x32"
    },
    iup.hbox {
      iup.fill{},
      ffme.chkDeint,
      iup.fill{},
      ffme.chkDenoise,
      iup.fill{},
      ffme.chkCrop,      
      iup.fill{},
      minsize = "x32"
    },
    iup.hbox {
      iup.fill{},
      ffme.btnSave,
      ffme.btnCancel;
      minsize = "x32"
    },
  },
  gap = 8, margin = "4x4", title = "Options", resize = "NO",
  icon = "FFME_ICON",
  close_cb = function() ffme:CloseOpts() end
}

return opts