#include <jni.h>
#include <stdlib.h>
#include <string.h>

#include <faiss_c.h>
#include <error_c.h>
#include <Index_c.h>
#include <IndexFlat_c.h>
#include <index_factory_c.h>
#include <index_io_c.h>
#include <impl/AuxIndexStructures_c.h>
#include <AutoTune_c.h>

#define JNI_METHOD(return_type, method_name) \
    JNIEXPORT return_type JNICALL Java_com_developermindset_faiss_FAISS_##method_name

static void throw_java_exception(JNIEnv *env, const char *msg) {
    jclass cls = (*env)->FindClass(env, "java/lang/RuntimeException");
    (*env)->ThrowNew(env, cls, msg);
}

static int check_faiss_error(JNIEnv *env, int code) {
    if (code != 0) {
        const char *msg = faiss_get_last_error();
        throw_java_exception(env, msg ? msg : "Unknown FAISS error");
        return 1;
    }
    return 0;
}

JNI_METHOD(jlong, nativeIndexFactory)(JNIEnv *env, jclass cls, jint d, jstring description, jint metric) {
    const char *desc = (*env)->GetStringUTFChars(env, description, NULL);
    FaissIndex *index = NULL;
    int rc = faiss_index_factory(&index, (int)d, desc, (FaissMetricType)metric);
    (*env)->ReleaseStringUTFChars(env, description, desc);
    if (check_faiss_error(env, rc)) return 0;
    return (jlong)(intptr_t)index;
}

JNI_METHOD(void, nativeIndexFree)(JNIEnv *env, jclass cls, jlong indexPtr) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    if (index) faiss_Index_free(index);
}

JNI_METHOD(void, nativeAdd)(JNIEnv *env, jclass cls, jlong indexPtr, jint n, jfloatArray vectors) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    jfloat *data = (*env)->GetFloatArrayElements(env, vectors, NULL);
    int rc = faiss_Index_add(index, (idx_t)n, data);
    (*env)->ReleaseFloatArrayElements(env, vectors, data, JNI_ABORT);
    check_faiss_error(env, rc);
}

JNI_METHOD(jlongArray, nativeSearch)(JNIEnv *env, jclass cls, jlong indexPtr, jint nq, jfloatArray queries, jint k, jfloatArray distances) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    jfloat *qdata = (*env)->GetFloatArrayElements(env, queries, NULL);
    jfloat *ddata = (*env)->GetFloatArrayElements(env, distances, NULL);

    idx_t *labels = (idx_t *)malloc(sizeof(idx_t) * nq * k);
    int rc = faiss_Index_search(index, (idx_t)nq, qdata, (idx_t)k, ddata, labels);

    (*env)->ReleaseFloatArrayElements(env, queries, qdata, JNI_ABORT);
    (*env)->SetFloatArrayRegion(env, distances, 0, nq * k, ddata);
    (*env)->ReleaseFloatArrayElements(env, distances, ddata, 0);

    if (check_faiss_error(env, rc)) {
        free(labels);
        return NULL;
    }

    jlongArray result = (*env)->NewLongArray(env, nq * k);
    jlong *resultData = (*env)->GetLongArrayElements(env, result, NULL);
    for (int i = 0; i < nq * k; i++) {
        resultData[i] = (jlong)labels[i];
    }
    (*env)->ReleaseLongArrayElements(env, result, resultData, 0);
    free(labels);

    return result;
}

JNI_METHOD(jboolean, nativeIsTrained)(JNIEnv *env, jclass cls, jlong indexPtr) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    return faiss_Index_is_trained(index) != 0;
}

JNI_METHOD(jlong, nativeNtotal)(JNIEnv *env, jclass cls, jlong indexPtr) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    return (jlong)faiss_Index_ntotal(index);
}

JNI_METHOD(jint, nativeDimension)(JNIEnv *env, jclass cls, jlong indexPtr) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    return (jint)faiss_Index_d(index);
}

JNI_METHOD(void, nativeWriteIndex)(JNIEnv *env, jclass cls, jlong indexPtr, jstring path) {
    FaissIndex *index = (FaissIndex *)(intptr_t)indexPtr;
    const char *cpath = (*env)->GetStringUTFChars(env, path, NULL);
    int rc = faiss_write_index_fname(index, cpath);
    (*env)->ReleaseStringUTFChars(env, path, cpath);
    check_faiss_error(env, rc);
}

JNI_METHOD(jlong, nativeReadIndex)(JNIEnv *env, jclass cls, jstring path) {
    const char *cpath = (*env)->GetStringUTFChars(env, path, NULL);
    FaissIndex *index = NULL;
    int rc = faiss_read_index_fname(cpath, 0, &index);
    (*env)->ReleaseStringUTFChars(env, path, cpath);
    if (check_faiss_error(env, rc)) return 0;
    return (jlong)(intptr_t)index;
}

JNI_METHOD(jint, nativeMetricL2)(JNIEnv *env, jclass cls) {
    return (jint)METRIC_L2;
}

JNI_METHOD(jint, nativeMetricInnerProduct)(JNIEnv *env, jclass cls) {
    return (jint)METRIC_INNER_PRODUCT;
}
