#!/bin/sh

FLAGS="-frelease -fdata-sections -ffunction-sections -c -O2 -Wall -pipe -fversion=PYRA -fversion=BindSDL_Static -fversion=SDL_201 -fversion=SDL_Mixer_202 -I`pwd`/import -march=armv7ve+simd -mcpu=cortex-a15 -mtune=cortex-a15 -mfpu=neon-vfpv4 -mfloat-abi=hard -mthumb"

rm import/*.o*
rm import/sdl/*.o*
rm import/bindbc/sdl/*.o*
rm src/abagames/util/*.o*
rm src/abagames/util/sdl/*.o*
rm src/abagames/a7xpg/*.o*

cd import
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd ../bindbc/sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS \{\} \;
cd ../../..

cd src/abagames/util
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS -I../.. \{\} \;
cd ../../..

cd src/abagames/util/sdl
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS -I../../.. \{\} \;
cd ../../../..

cd src/abagames/a7xpg
find . -maxdepth 1 -name \*.d -type f -exec gdc $FLAGS -I../.. \{\} \;
cd ../../..

gdc -o A7Xpg -s -Wl,--gc-sections -static-libphobos import/*.o* import/sdl/*.o* import/bindbc/sdl/*.o* src/abagames/util/*.o* src/abagames/util/sdl/*.o* src/abagames/a7xpg/*.o* -lGL -lSDL2_mixer -lSDL2
