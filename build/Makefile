CC    = gcc
LUA51 = lua
LUA52 = lua52
UPX   = upx
LIBS  = -liuplua52 -llua52 -liup -lpsapi -lMpr -luuid -lgdi32 -luser32 -lcomdlg32 -lcomctl32 -lole32
INCD  = include
LIBD  = lib

all: debug

release: build.h build.c winapi.c wutils.c rc.o
	$(CC) -static -s -o ffme.exe build.c winapi.c wutils.c rc.o -O2 -mwindows -DPSAPI_VERSION=1 -I$(INCD) -L$(LIBD) $(LIBS)

debug: build.h build.c winapi.c wutils.c rc.o
	$(CC) -static -g -o ffme.exe build.c winapi.c wutils.c rc.o -DPSAPI_VERSION=1 -I$(INCD) -L$(LIBD) $(LIBS)

build.h: build.lua
	$(LUA52) bin2c.lua build.lua > build.h

rc.o: build.rc
	windres -ibuild.rc -orc.o

build.lua:
	# squish doesn't work with 5.2 yet, so we need a 5.1 install
	$(LUA51) squish.lua --no-minify

clean:
	del *.o *.d build.lua build.h *.exe