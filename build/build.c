#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"

#include <iup.h>
#include <iuplua.h>

int main(int argc, char *argv[]) {
  lua_State * L = luaL_newstate();
  if (! L) { fputs("Failed creating Lua state.", stderr); exit(1); }
  luaL_openlibs(L);
  iuplua_open(L);
  luaopen_winapi(L);

#include "build.h"

  iuplua_close(L);
  lua_close(L);
  return 0;
}
