-- weevil: a tiny, human-readable table serialiser
-- by furq at b23 dot be
-- 2012/08/08

local weevil = {}

local type, pairs, tostring = type, pairs, tostring
local sfmt, conc = string.format, table.concat

local function loader(str)
  if _VERSION:match(".2$") then
    return load(sfmt("return %s", str), nil, "t", {})
  end
  if _VERSION:match(".1$") then
    return setfenv(loadstring(sfmt("return %s", str)), {})
  end
  error()
end

local function keyname(k)
  return type(k) == "number" and sfmt('[%d]', k) or
  k:match('^[%a_][%w_]*$') and k or sfmt('["%s"]', k)
end

function weevil:write(t, i)
  local i, out = i or 0, {}
  local fmt = "%"..(i+2).."s%s = %s"
  for k,v in pairs(t) do
    if type(v) ~= "userdata" and type(v) ~= "function" and type(v) ~= "thread" then
      out[#out+1] = sfmt(
        fmt, "", keyname(k),
        type(v) == "table" and self:write(v, i+2) or 
        type(v) == "string" and sfmt('"%s"', v:gsub("\\", "\\\\")) or tostring(v)
      )
    end
  end
  return sfmt("{\n%s\n%"..i.."s}", conc(out, ",\n"), "")
end

function weevil:writefile(file, tbl)
  local f = assert(io.open(file, "w+"))
  f:write(self:write(tbl))
  f:close()
end

function weevil:read(str, out)
  local out, fnc = out or {}, loader(str)
  local tbl = fnc()
  if type(tbl) == "table" then for k,v in pairs(tbl) do out[k] = v end end
  return out
end

function weevil:readfile(file, tbl)
  local f = io.open(file, "r")
  if not f then return false end
  local str = f:read("*a")
  f:close()
  local out = self:read(str, tbl)
  return tbl and out or true
end

return weevil