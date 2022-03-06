# game/app specific values
export APP_VERSION="1.3.99999"
# ecwolf builds an .icns file, we will use that once it's been built
export ICONSDIR="build-arm64/ecwolf.app/Contents/Resources"
export ICONSFILENAME="icon"
export PRODUCT_NAME="ecwolf"
export EXECUTABLE_NAME="ecwolf"
export PKGINFO="APPLECWF"
export COPYRIGHT_TEXT="Wolfenstein 3-D Copyright © 1992 id Software, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

# build x86_64 fluidsynth
cd build_ext/fluidsynth-lite
rm -rf lib/x86_64
mkdir lib/x86_64
make clean
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="-arch x86_64" .
cmake --build .
cp -a src/libfluidsynth* lib/x86_64
cd ../..

# create x86_64 makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
cmake -DCMAKE_C_FLAGS="-arch x86_64" \
    -DCMAKE_CXX_FLAGS="-arch x86_64" \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
    ..

# perform x86_64 build with make
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

#tweak x86_64 install name
cd ..
echo install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/x86_64/libfluidsynth.1.dylib ${X86_64_BUILD_FOLDER}/systemshock
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/x86_64/libfluidsynth.1.dylib ${X86_64_BUILD_FOLDER}/systemshock

# build arm64 fluidsynth
cd build_ext/fluidsynth-lite
rm -rf lib/arm64
mkdir lib/arm64
make clean
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_C_FLAGS_RELEASE="-arch arm64" .
cmake --build .
cp -a src/libfluidsynth* lib/arm64
cd ../..

# create arm64 makefiles with cmake
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_C_FLAGS="-arch arm64 -DSDL_DISABLE_IMMINTRIN_H" \
    -DCMAKE_CXX_FLAGS="-arch arm64 -DSDL_DISABLE_IMMINTRIN_H" \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/opt/homebrew/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/opt/homebrew/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
    ..

# perform arm64 build with make
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

#tweak arm64 install name
cd ..
echo install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/arm64/libfluidsynth.1.dylib ${ARM64_BUILD_FOLDER}/systemshock
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/arm64/libfluidsynth.1.dylib ${ARM64_BUILD_FOLDER}/systemshock

# create the app bundle
# "../MSPScripts/build_app_bundle.sh"

#copy resources
# cp build-x86_64/${EXECUTABLE_FOLDER_PATH}/ecwolf.pk3 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

#sign and notarize
# "../MSPScripts/sign_and_notarize.sh" "$1"