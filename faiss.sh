#!/bin/sh

OPENMP_VERSION="16.0.5"
OPENMP_URL="https://github.com/eugenehp/openmp-mobile/releases/download/v$OPENMP_VERSION/openmp.xcframework.zip"
OPENMP_XCFRAMEWORK="openmp.xcframework"

NAME="faiss"
NAME_C="faiss_c"
VERSION="1.7.4"
DIST="dist"
BUILD="build"
BUILD_SHARED_LIBS=OFF
CMAKE_BUILD_TYPE=Release
CPU_CORES=$(sysctl -n hw.ncpu)
CMAKE_TOOLCHAIN_FILE="$PWD/extra/ios.toolchain.cmake"
ENABLE_ARC=0
ENABLE_BITCODE=0
ENABLE_VISIBILITY=1
FAISS_ENABLE_GPU=OFF
FAISS_ENABLE_PYTHON=OFF
BUILD_SHARED_LIBS=OFF
FAISS_ENABLE_C_API=ON
NODE=$(which node)
PARALLEL=OFF # ON|OFF

# TARGETS=("13.1")
# ARCHS=("arm64;arm64e")
# PLATFORMS=("OS64")
# TRIPLES=("ios-arm64_arm64e")

TARGETS=("13.0" "13.0" "13.0" "6.0" "6.0" "13.0" "13.0" "13.0")
ARCHS=("arm64;arm64e" "arm64;arm64e;x86_64" "arm64;arm64e;x86_64" "armv7k;arm64_32" "i386" "arm64" "x86_64")
PLATFORMS=("OS64" "SIMULATOR64" "MAC_UNIVERSAL" "WATCHOS" "SIMULATOR_WATCHOS" "TVOS" "SIMULATOR_TVOS")
TRIPLES=("ios-arm64_arm64e" "ios-arm64_arm64e_x86_64-simulator" "macos-arm64_arm64e_x86_64" "watchos-arm64_32_armv7k" "watchos-i386-simulator" "tvos-arm64" "tvos-x86_64-simulator")

ROOT=$PWD
LOGS="$ROOT/logs"
FRAMEWORK_OUTPUT="$ROOT/$DIST/$NAME.xcframework"
FRAMEWORK_C_OUTPUT="$ROOT/$DIST/$NAME_C.xcframework"
CHECKSUM_FILE="$FRAMEWORK_OUTPUT.sha256"
CHECKSUM_C_FILE="$FRAMEWORK_C_OUTPUT.sha256"

function print()
{
    echo "=============================="
    echo $1
    echo "=============================="
}

function replace()
{
  NUMBER=$1
  LINE=$2
  PATH=$3
  
  /usr/bin/perl -n -i -e "print unless $. == $NUMBER" $PATH
  /usr/bin/perl -pi -e "print \"\n\" if $. == $NUMBER" $PATH
  /usr/bin/perl -pi -e "print '$LINE' if $. == $NUMBER" $PATH
}

function clear()
{
  rm -rf "$ROOT/$NAME"
  rm -rf "$ROOT/$BUILD"
  rm -rf "$ROOT/$DIST"

  rm -rf $LOGS
  mkdir -p $LOGS
}

function download()
{
  mkdir -p $DIST
  mkdir -p $BUILD

  print "Downloading OpenMP source code"
  FILENAME="v$VERSION.tar.gz"
  wget "https://github.com/facebookresearch/$NAME/archive/refs/tags/$FILENAME"
  mkdir $NAME
  tar xf $FILENAME --strip-components=1 -C $NAME
  rm -rf "$FILENAME"
  rm -rf "$FILENAME.*"

  print "Patching $NAME_C in $NAME/c_api"
  patch "$ROOT/$NAME/c_api/CMakeLists.txt" -i ./extra/CMakeLists.patch

  cd $DIST
  wget $OPENMP_URL
  unzip "$OPENMP_XCFRAMEWORK.zip"

  rm -rf "$OPENMP_XCFRAMEWORK.zip"
  cd $ROOT

  print "Downloading ios.toolchain.cmake"
  cd extra
  rm -rf ios.toolchain.cmake
  wget https://raw.githubusercontent.com/leetal/ios-cmake/master/ios.toolchain.cmake
  cd $ROOT
}

function configure()
{
    ARCH=$1
    PLATFORM=$2
    TARGET=$3
    TRIPLE=$4
    BUILD_DIR="$ROOT/$BUILD/$NAME/$PLATFORM"
    OUTPUT="$ROOT/$BUILD/$NAME/install/$PLATFORM"

    EXTRA_FLAGS=""

    echo "Configuring $NAME for $ARCH in $OUTPUT"

    rm -rf $BUILD_DIR
    mkdir -p $BUILD_DIR

    CMAKE_FRAMEWORK_PATH="$ROOT/$DIST/$OPENMP_XCFRAMEWORK/$TRIPLE"

    cmake $NAME\
        -G Xcode\
        -B $BUILD_DIR\
        -DBUILD_SHARED_LIBS=$BUILD_SHARED_LIBS\
        -DCMAKE_TOOLCHAIN_FILE=$CMAKE_TOOLCHAIN_FILE\
        -DCMAKE_INSTALL_PREFIX=$OUTPUT\
        -DPLATFORM=$PLATFORM\
        -DENABLE_BITCODE=$ENABLE_BITCODE\
        -DENABLE_ARC=$ENABLE_ARC\
        -DENABLE_VISIBILITY=$ENABLE_VISIBILITY\
        -DDEPLOYMENT_TARGET=$TARGET\
        -DARCHS=$ARCH\
        -DFAISS_ENABLE_GPU=$FAISS_ENABLE_GPU\
        -DFAISS_ENABLE_PYTHON=$FAISS_ENABLE_PYTHON\
        -DBUILD_SHARED_LIBS=$BUILD_SHARED_LIBS\
        -DFAISS_ENABLE_C_API=$FAISS_ENABLE_C_API\
        -DCMAKE_WARN_DEPRECATED=0\
        -DBUILD_TESTING=OFF\
        -DOpenMP_CXX_LIB_NAMES="libomp"\
        -DOpenMP_libomp_LIBRARY="$CMAKE_FRAMEWORK_PATH/libomp.a"\
        -DOpenMP_CXX_FLAGS="-Xpreprocessor -fopenmp -I$CMAKE_FRAMEWORK_PATH/Headers"\
        -DCMAKE_CXX_FLAGS="-Wno-shorten-64-to-32 -Wno-deprecated-declarations"\
        $EXTRA_FLAGS
}

function build()
{
    ARCH=$1
    PLATFORM=$2
    BUILD_DIR="$ROOT/$BUILD/$NAME/$PLATFORM"
    OUTPUT="$ROOT/$BUILD/$NAME/install/$PLATFORM"

    cmake --build $BUILD_DIR -j $CPU_CORES
}

function install()
{
    ARCH=$1
    PLATFORM=$2
    BUILD_DIR="$ROOT/$BUILD/$NAME/$PLATFORM"
    OUTPUT="$ROOT/$BUILD/$NAME/install/$PLATFORM"

    rm -rf "$OUTPUT"
    mkdir -p $OUTPUT
 
    cmake --build $BUILD_DIR --target install
}

function framework()
{
    echo "Preparing framework for $NAME"

    rm -rf $FRAMEWORK_OUTPUT
    rm -rf $FRAMEWORK_C_OUTPUT
    mkdir -p $FRAMEWORK_OUTPUT
    mkdir -p $FRAMEWORK_C_OUTPUT

    command="xcodebuild -create-xcframework"
    command_c="xcodebuild -create-xcframework"

    for PLATFORM in ${PLATFORMS[@]}; do
        OUTPUT="$ROOT/$BUILD/$NAME/install/$PLATFORM"
        command+=" -library $OUTPUT/lib/libfaiss.a -headers $OUTPUT/include"
        command_c+=" -library $OUTPUT/lib/libfaiss_c.a -headers $OUTPUT/include/faiss/c_api"
    done

    command+=" -output $FRAMEWORK_OUTPUT"
    command_c+=" -output $FRAMEWORK_C_OUTPUT"

    $command
    $command_c

    ditto -c -k --sequesterRsrc --keepParent "$FRAMEWORK_OUTPUT" "$FRAMEWORK_OUTPUT.zip"
    ditto -c -k --sequesterRsrc --keepParent "$FRAMEWORK_C_OUTPUT" "$FRAMEWORK_C_OUTPUT.zip"
    # openssl dgst -sha256 "$XCFRAMEWORK_FOLDER.zip"
    
    CHECKSUM=$(swift package compute-checksum "$FRAMEWORK_OUTPUT.zip")
    echo $CHECKSUM > $CHECKSUM_FILE
    echo "$NAME - $CHECKSUM"

    CHECKSUM_C=$(swift package compute-checksum "$FRAMEWORK_C_OUTPUT.zip")
    echo $CHECKSUM_C > $CHECKSUM_C_FILE
    echo "$NAME_C $CHECKSUM"

    update $CHECKSUM $CHECKSUM_C
}

function update()
{
    print "Updating the versions in SPM, Cocoapods"
    CHECKSUM=$1
    CHECKSUM_C=$1

    # SPM via Package.swift 
    replace 4 "let version = \"$VERSION\"" "./Package.swift"
    replace 5 "let checksum = \"$CHECKSUM\"" "./Package.swift"
    replace 6 "let checksum_c = \"$CHECKSUM_C\"" "./Package.swift"
    
    # Cocoapods via FAISS.podspec
    replace 2 "  version              = \"$VERSION\"" "./FAISS.podspec"

    # Carthage via carthage/faiss-static-xcframework.json
    $NODE extra/update-carthage.js $VERSION
}

function single_platform()
{
    ARCH=$1
    PLATFORM=$2
    TARGET=$3
    TRIPLE=$4

    print "Preparing single platform: $NAME on $PLATFORM:$TARGET($ARCH) as $TRIPLE"

    (
        print "Configuring $NAME on $PLATFORM:$TARGET($ARCH) as $TRIPLE"
        configure $ARCH $PLATFORM $TARGET $TRIPLE
        
        print "Configuring $NAME on $PLATFORM:$TARGET($ARCH) as $TRIPLE"
        build $ARCH $PLATFORM

        print "Configuring $NAME on $PLATFORM:$TARGET($ARCH) as $TRIPLE"
        install $ARCH $PLATFORM
    ) > "$LOGS/$PLATFORM-$TARGET.log"
}

function start()
{
    clear
    download
    
    for index in ${!PLATFORMS[@]}; do
        ARCH=${ARCHS[$index]}
        PLATFORM=${PLATFORMS[$index]}
        TARGET=${TARGETS[$index]}
        TRIPLE=${TRIPLES[$index]}
        
        if [ $PARALLEL == "ON" ]
        then
            single_platform $ARCH $PLATFORM $TARGET $TRIPLE & # ampersand enables platfrom runs in parallel
        else
            single_platform $ARCH $PLATFORM $TARGET $TRIPLE
        fi
    done

    framework
}

function release()
{
    print "Releasing $VERSION"

    TAG="v$VERSION"
    NOTES="$ROOT/notes.txt"
    CHECKSUM=$(cat $CHECKSUM_FILE)
    CHECKSUM_C=$(cat $CHECKSUM_C_FILE)

    cd $FRAMEWORK_OUTPUT
    cd ../
    
    echo "# Release $VERSION" > $NOTES
    echo "" >> $NOTES
    
    echo "## $NAME" >> $NOTES
    echo "\`\`\`shell" >> $NOTES
    # tree "$NAME.xcframework" >> $NOTES
    tree "$NAME.xcframework" -P '*.a' >> $NOTES
    echo "\`\`\`" >> $NOTES
    echo "" >> $NOTES
    echo "Checksum for $NAME - \`$CHECKSUM\`" >> $NOTES
    echo "" >> $NOTES
    
    echo "## $NAME_C" >> $NOTES
    echo "\`\`\`shell" >> $NOTES
    tree "$NAME_C.xcframework" >> $NOTES
    echo "\`\`\`" >> $NOTES
    echo "" >> $NOTES
    echo "Checksum for $NAME_C - \`$CHECKSUM_C\`" >> $NOTES
    echo "" >> $NOTES
    

    cd $ROOT

    if [ $(git tag -l "v$VERSION") ]; then
        git tag -d "v$VERSION"
    fi
    
    gh release create -d \
        -t "$VERSION" \
        -F $NOTES \
        $TAG \
        "$FRAMEWORK_OUTPUT.zip" \
        "$FRAMEWORK_C_OUTPUT.zip" \
        $CHECKSUM_FILE \
        $CHECKSUM_C_FILE \
    
    rm $NOTES

    gh release view $TAG -w
}

# start

if [ "$1" == "release" ]
then
    release
else
    start
fi