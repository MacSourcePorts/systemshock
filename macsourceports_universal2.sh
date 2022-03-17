# game/app specific values
export APP_VERSION="1.0"
export ICONSDIR="osx-linux"
export ICONSFILENAME="systemshock"
export PRODUCT_NAME="systemshock"
export EXECUTABLE_NAME="systemshock"
export PKGINFO="APPLESS1"
export COPYRIGHT_TEXT="System Shock © 1994 Looking Glass Studios, Inc. All rights reserved."

#constants
source ../MSPScripts/constants.sh

rm -rf ${BUILT_PRODUCTS_DIR}

# build x86_64 fluidsynth
cd build_ext/fluidsynth-lite
#for the first one we can just delete the whole lib dir
rm -rf lib
mkdir -p lib/x86_64
cd lib/x86_64
cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=x86_64 ../..
cmake --build .
cp -a src/libfluidsynth* ../../src
cp -a include/fluidsynth/version.h ../../include/fluidsynth
cd ../../../../

# create x86_64 makefiles with cmake
rm -rf ${X86_64_BUILD_FOLDER}
mkdir ${X86_64_BUILD_FOLDER}
cd ${X86_64_BUILD_FOLDER}
/usr/local/bin/cmake -DCMAKE_OSX_ARCHITECTURES=x86_64 \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
    -B. -S..

# perform x86_64 build with make
cd ${X86_64_BUILD_FOLDER}
make -j$NCPU

#DEBUG: Make Xcode proj
# cd ..
# rm -rf xcode-x86_64
# mkdir xcode-x86_64
# cd xcode-x86_64
# /usr/local/bin/cmake \
#     -G Xcode \
#     -DCMAKE_OSX_ARCHITECTURES=x86_64 \
#     -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
#     -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
#     -DENABLE_SDL2=ON \
#     -DENABLE_SOUND=ON \
#     -DSDL2_DIR=/usr/local/opt/sdl2/lib/cmake/SDL2 \
#     -DSDL2_MIXER_LIBRARIES=/usr/local/lib/libSDL2_mixer.dylib \
#     -DENABLE_FLUIDSYNTH="BUNDLED" \
#     -B. -S..

#tweak x86_64 install name
cd ..
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/x86_64/libfluidsynth.1.dylib ${X86_64_BUILD_FOLDER}/systemshock

mkdir -p ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
mkdir -p ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
cp windows.sf2 ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res

# build arm64 fluidsynth
cd build_ext/fluidsynth-lite
mkdir -p lib/arm64
cd lib/arm64
/usr/local/bin/cmake -DBUILD_SHARED_LIBS=ON -DCMAKE_BUILD_TYPE=Release -DCMAKE_OSX_ARCHITECTURES=arm64 -DCMAKE_C_FLAGS_RELEASE="-arch arm64" ../..
/usr/local/bin/cmake --build .
cp -a src/libfluidsynth* ../../src
cp -a include/fluidsynth/version.h ../../include/fluidsynth
cd ../../../../

# create arm64 makefiles with cmake
rm -rf ${ARM64_BUILD_FOLDER}
mkdir ${ARM64_BUILD_FOLDER}
cd ${ARM64_BUILD_FOLDER}
cmake -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_C_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_CXX_FLAGS="-DSDL_DISABLE_IMMINTRIN_H -DGL_SILENCE_DEPRECATION" \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.9 \
    -DENABLE_SDL2=ON \
    -DENABLE_SOUND=ON \
    -DSDL2_DIR=/opt/homebrew/opt/sdl2/lib/cmake/SDL2 \
    -DSDL2_MIXER_LIBRARIES=/opt/homebrew/lib/libSDL2_mixer.dylib \
    -DENABLE_FLUIDSYNTH="BUNDLED" \
     -B. -S..

# perform arm64 build with make
cd ${ARM64_BUILD_FOLDER}
make -j$NCPU

#tweak arm64 install name
cd ..
echo install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/arm64/libfluidsynth.1.dylib ${ARM64_BUILD_FOLDER}/systemshock
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/arm64/libfluidsynth.1.dylib ${ARM64_BUILD_FOLDER}/systemshock

mkdir -p ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res
mkdir -p ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"
cp windows.sf2 ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}/res

create the app bundle
"../MSPScripts/build_app_bundle.sh"

mkdir -p ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/res
cp windows.sf2 ${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}/res

#sign and notarize
"../MSPScripts/sign_and_notarize.sh" "$1"