-- ffme: a poorly named ffmpeg frontend
-- designed for streaming to RTMP servers (like FME)
-- by furq at b23 dot be
-- 2012/08/08

-- TODO:
-- better ffmpeg parsing - some files just hang on read()
-- fix the default choice in the servers combobox
-- test if autocrop actually does anything
-- comment preset files
-- add some default commonly-used RTMP servers (justin, ustream etc)?
-- add option to send FME 2.5 flashvar? (for ustream)
-- proper GUI for preset files?

-- BUGS THAT ARE PROBABLY WINAPI'S FAULT:
-- getenv("COMSPEC") weirdness, only seems to affect my windows install
-- winapi.files() will sometimes return random strings of junk chars
-- winapi.read_async seems to randomly segfault for kicks (fixed?)

require "iuplua"

-- for some reason, embedding winapi makes this line cause a segfault
-- uncomment it if you want to run it with the interpreter
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