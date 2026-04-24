#!/bin/bash

NAME="faiss"
NAME_C="faiss_c"
VERSION="1.14.1"
DIST="dist-android"
BUILD="build-android"
CPU_CORES=$(nproc 2>/dev/null || sysctl -n hw.ncpu)
OPENBLAS_VERSION="0.3.28"

ABIS=("arm64-v8a" "armeabi-v7a" "x86_64" "x86")
API_LEVEL=24

ROOT=$PWD
LOGS="$ROOT/logs"

# Detect Android NDK
if [ -n "$ANDROID_NDK_HOME" ]; then
    NDK="$ANDROID_NDK_HOME"
elif [ -n "$ANDROID_NDK" ]; then
    NDK="$ANDROID_NDK"
elif [ -d "$HOME/Library/Android/sdk/ndk" ]; then
    NDK=$(ls -d "$HOME/Library/Android/sdk/ndk/"* 2>/dev/null | sort -V | tail -1)
elif [ -d "$HOME/Android/Sdk/ndk" ]; then
    NDK=$(ls -d "$HOME/Android/Sdk/ndk/"* 2>/dev/null | sort -V | tail -1)
fi

NDK_TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"

function print() {
    echo "=============================="
    echo "$1"
    echo "=============================="
}

function check_ndk() {
    if [ -z "$NDK" ] || [ ! -f "$NDK_TOOLCHAIN" ]; then
        echo "Error: Android NDK not found."
        echo "Set ANDROID_NDK_HOME to your NDK installation path."
        echo "  export ANDROID_NDK_HOME=\$HOME/Library/Android/sdk/ndk/<version>"
        exit 1
    fi
    print "Using Android NDK: $NDK"
}

function clear() {
    rm -rf "$ROOT/$BUILD"
    rm -rf "$ROOT/$DIST"

    rm -rf $LOGS
    mkdir -p $LOGS
}

function download_openblas() {
    print "Downloading OpenBLAS $OPENBLAS_VERSION"
    mkdir -p "$ROOT/$BUILD"
    cd "$ROOT/$BUILD"

    if [ ! -d "OpenBLAS" ]; then
        curl -L -o "openblas.tar.gz" \
            "https://github.com/OpenMathLib/OpenBLAS/releases/download/v$OPENBLAS_VERSION/OpenBLAS-$OPENBLAS_VERSION.tar.gz"
        mkdir -p OpenBLAS
        tar xf openblas.tar.gz --strip-components=1 -C OpenBLAS
        rm -f openblas.tar.gz
    fi

    cd "$ROOT"
}

function build_openblas() {
    ABI=$1
    print "Building OpenBLAS for $ABI"

    OPENBLAS_SRC="$ROOT/$BUILD/OpenBLAS"
    OPENBLAS_BUILD="$ROOT/$BUILD/openblas/$ABI"
    OPENBLAS_INSTALL="$ROOT/$BUILD/openblas/install/$ABI"

    rm -rf "$OPENBLAS_BUILD"
    mkdir -p "$OPENBLAS_BUILD"
    mkdir -p "$OPENBLAS_INSTALL"

    cmake "$OPENBLAS_SRC" -G Ninja -B "$OPENBLAS_BUILD" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_TOOLCHAIN" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$API_LEVEL" \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$OPENBLAS_INSTALL" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_WITHOUT_LAPACK=OFF \
        -DNOFORTRAN=ON \
        -DC_LAPACK=ON

    cmake --build "$OPENBLAS_BUILD" -j "$CPU_CORES"
    cmake --build "$OPENBLAS_BUILD" --target install
}

function configure_faiss() {
    ABI=$1
    BUILD_DIR="$ROOT/$BUILD/$NAME/$ABI"
    OUTPUT="$ROOT/$BUILD/$NAME/install/$ABI"
    OPENBLAS_INSTALL="$ROOT/$BUILD/openblas/install/$ABI"

    print "Configuring $NAME for $ABI"

    rm -rf "$BUILD_DIR"
    mkdir -p "$BUILD_DIR"

    cmake "$ROOT/$NAME" -G Ninja -B "$BUILD_DIR" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_TOOLCHAIN" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$API_LEVEL" \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$OUTPUT" \
        -DBUILD_SHARED_LIBS=OFF \
        -DBUILD_TESTING=OFF \
        -DFAISS_ENABLE_GPU=OFF \
        -DFAISS_ENABLE_PYTHON=OFF \
        -DFAISS_ENABLE_C_API=ON \
        -DCMAKE_WARN_DEPRECATED=0 \
        -DCMAKE_PREFIX_PATH="$OPENBLAS_INSTALL" \
        -DBLAS_LIBRARIES="$OPENBLAS_INSTALL/lib/libopenblas.a" \
        -DLAPACK_LIBRARIES="$OPENBLAS_INSTALL/lib/libopenblas.a" \
        -DCMAKE_CXX_FLAGS="-Wno-shorten-64-to-32 -Wno-deprecated-declarations"
}

function build_faiss() {
    ABI=$1
    BUILD_DIR="$ROOT/$BUILD/$NAME/$ABI"

    print "Building $NAME for $ABI"
    cmake --build "$BUILD_DIR" -j "$CPU_CORES"
}

function install_faiss() {
    ABI=$1
    BUILD_DIR="$ROOT/$BUILD/$NAME/$ABI"
    OUTPUT="$ROOT/$BUILD/$NAME/install/$ABI"

    print "Installing $NAME for $ABI"
    rm -rf "$OUTPUT"
    mkdir -p "$OUTPUT"
    cmake --build "$BUILD_DIR" --target install
}

function build_jni() {
    ABI=$1
    OUTPUT="$ROOT/$BUILD/$NAME/install/$ABI"
    OPENBLAS_INSTALL="$ROOT/$BUILD/openblas/install/$ABI"
    JNI_BUILD="$ROOT/$BUILD/jni/$ABI"
    JNI_OUTPUT="$ROOT/$DIST/jni/$ABI"

    print "Building JNI wrapper for $ABI"

    rm -rf "$JNI_BUILD"
    mkdir -p "$JNI_BUILD"
    mkdir -p "$JNI_OUTPUT"

    cmake "$ROOT/android/jni" -G Ninja -B "$JNI_BUILD" \
        -DCMAKE_TOOLCHAIN_FILE="$NDK_TOOLCHAIN" \
        -DANDROID_ABI="$ABI" \
        -DANDROID_PLATFORM="android-$API_LEVEL" \
        -DANDROID_STL=c++_shared \
        -DCMAKE_BUILD_TYPE=Release \
        -DFAISS_INSTALL_DIR="$OUTPUT" \
        -DOPENBLAS_INSTALL_DIR="$OPENBLAS_INSTALL"

    cmake --build "$JNI_BUILD" -j "$CPU_CORES"

    cp "$JNI_BUILD/libfaiss_jni.so" "$JNI_OUTPUT/"
}

function package_aar() {
    print "Packaging AAR"

    AAR_DIR="$ROOT/$DIST/aar"
    rm -rf "$AAR_DIR"
    mkdir -p "$AAR_DIR"

    # Copy JNI libraries
    for ABI in "${ABIS[@]}"; do
        mkdir -p "$AAR_DIR/jni/$ABI"
        cp "$ROOT/$DIST/jni/$ABI/libfaiss_jni.so" "$AAR_DIR/jni/$ABI/"

        # Copy libc++_shared.so from NDK
        LIBCXX=$(find "$NDK" -name "libc++_shared.so" -path "*/$ABI/*" | head -1)
        if [ -n "$LIBCXX" ]; then
            cp "$LIBCXX" "$AAR_DIR/jni/$ABI/"
        fi
    done

    # Copy Java classes
    mkdir -p "$AAR_DIR/classes"
    JAVA_SRC="$ROOT/android/java"
    javac -source 8 -target 8 -d "$AAR_DIR/classes" \
        $(find "$JAVA_SRC" -name "*.java") 2>/dev/null || true

    # Create classes.jar
    cd "$AAR_DIR/classes"
    jar cf "$AAR_DIR/classes.jar" . 2>/dev/null || true
    cd "$ROOT"
    rm -rf "$AAR_DIR/classes"

    # Create AndroidManifest.xml
    cat > "$AAR_DIR/AndroidManifest.xml" << 'MANIFEST'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.developermindset.faiss">
    <uses-sdk android:minSdkVersion="24" />
</manifest>
MANIFEST

    # Package AAR
    cd "$AAR_DIR"
    zip -r "$ROOT/$DIST/faiss-android.aar" . -x "*.DS_Store"
    cd "$ROOT"

    print "AAR created at $DIST/faiss-android.aar"
}

function single_abi() {
    ABI=$1

    print "Building all for $ABI"

    (
        build_openblas "$ABI"
        configure_faiss "$ABI"
        build_faiss "$ABI"
        install_faiss "$ABI"
        build_jni "$ABI"
    ) > "$LOGS/android-$ABI.log" 2>&1
}

function build() {
    check_ndk
    clear

    print "Initializing FAISS submodule"
    git submodule update --init --recursive

    download_openblas

    for ABI in "${ABIS[@]}"; do
        single_abi "$ABI"
    done

    package_aar
}

# parse arguments
for arg in "$@"; do
    case $arg in
        --version=*)
            VERSION="${arg#*=}"
            shift
            ;;
        --abi=*)
            ABIS=("${arg#*=}")
            shift
            ;;
        --ndk=*)
            NDK="${arg#*=}"
            NDK_TOOLCHAIN="$NDK/build/cmake/android.toolchain.cmake"
            shift
            ;;
    esac
done

# start CLI
option="${1}"

case ${option} in
"build")
    echo "Building FAISS for Android" && build
    ;;
"clear")
    echo "Clearing Android build" && clear
    ;;
*)
    echo "Usage: ./faiss-android.sh [build|clear]"
    echo "Options:"
    echo "  --ndk=<path>        Path to Android NDK"
    echo "  --abi=<abi>         Build for a single ABI (arm64-v8a, armeabi-v7a, x86_64, x86)"
    echo "  --version=<ver>     FAISS version"
    ;;
esac
