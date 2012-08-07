require "iuplua"

-- for some reason, embedding winapi makes this line cause a segfault

--require "winapi"

local ffme = require "ffme"
require "main"
require "opts"

ffme:init()

ffme.dlgMain:show()

winapi.use_gui()

if (iup.MainLoopLevel()==0) then
  iup.MainLoop()
end