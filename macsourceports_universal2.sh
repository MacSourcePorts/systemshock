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
install_name_tool -change $PWD/build_ext/fluidsynth-lite/src/libfluidsynth.1.dylib $PWD/build_ext/fluidsynth-lite/lib/x86_64/libfluidsynth.1.dylib ${X86_64_BUILD_FOLDER}/systemshock

mkdir -p ${X86_64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${X86_64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${X86_64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${X86_64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"

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

mkdir -p ${ARM64_BUILD_FOLDER}/${WRAPPER_NAME}
mkdir -p ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
mkdir -p ${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}
mv ${ARM64_BUILD_FOLDER}/${EXECUTABLE_NAME} ${ARM64_BUILD_FOLDER}/${EXECUTABLE_FOLDER_PATH}
cp ${ICONSDIR}/${ICONS} "${ARM64_BUILD_FOLDER}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/${ICONS}"

create the app bundle
"../MSPScripts/build_app_bundle.sh"

#copy resources
# cp build-x86_64/${EXECUTABLE_FOLDER_PATH}/ecwolf.pk3 "${BUILT_PRODUCTS_DIR}/${EXECUTABLE_FOLDER_PATH}"

#sign and notarize
# "../MSPScripts/sign_and_notarize.sh" "$1"