local weevil = require("weevil")

local cfg = {
  servers = { "rtmp://live.yycast.com/live?u=jizzwizard256&p=YIVISE/jizzwizard256" },
  ffmpeg  = "ffmpeg",
  preset  = "default",
  deint   = "OFF",
  denoise = "OFF",
  crop    = "OFF"
}

setmetatable(cfg, {__index = {

  file = "",

  load = function(self, file)
    getmetatable(self).__index.file = file
    weevil:readfile(file, self)
  end,

  save = function(self, file)
    if not file then file = self.file end
    weevil:writefile(file, self)
  end

}})

return cfg
