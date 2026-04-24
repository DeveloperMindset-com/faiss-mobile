cmake_minimum_required(VERSION 3.17 FATAL_ERROR)
project(faiss_jni LANGUAGES C CXX)

set(FAISS_INSTALL_DIR "" CACHE PATH "Path to FAISS install directory")
set(OPENBLAS_INSTALL_DIR "" CACHE PATH "Path to OpenBLAS install directory")

add_library(faiss_jni SHARED faiss_jni.c)

target_include_directories(faiss_jni PRIVATE
    ${FAISS_INSTALL_DIR}/include
    ${FAISS_INSTALL_DIR}/include/faiss/c_api
)

# Link order matters: faiss_c wraps faiss, faiss needs openblas.
# -lc++ is required because libfaiss.a is C++ and needs the C++ runtime.
target_link_libraries(faiss_jni
    ${FAISS_INSTALL_DIR}/lib/libfaiss_c.a
    ${FAISS_INSTALL_DIR}/lib/libfaiss.a
    ${OPENBLAS_INSTALL_DIR}/lib/libopenblas.a
    c++_static
    c++abi
    log
    m
)

target_link_options(faiss_jni PRIVATE -fopenmp -static-openmp)
