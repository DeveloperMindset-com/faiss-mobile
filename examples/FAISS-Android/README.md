# Example application for Android using FAISS

Java example that uses FAISS via JNI.

## Prerequisites

- Android SDK with API level 34
- Android NDK (set `ANDROID_NDK_HOME`)

## Setup

1. Build the FAISS Android libraries first:
   ```shell
   ./faiss-android.sh build
   ```

2. Open the `FAISS-Android` folder in Android Studio.

3. Build and run on a device or emulator.

## How it works

The example uses the `FAISS` Java wrapper class which loads `libfaiss_jni.so` via JNI.

The app demonstrates:

1. Creating a Flat index (exact L2 search) with 100,000 128-dimensional vectors
2. Searching for 5 nearest neighbors
3. Saving the index to disk and reloading it
4. Creating an HNSW index (approximate search) for faster queries

## Using FAISS in your Android project

Add the prebuilt JNI libraries and Java wrapper to your project:

```groovy
android {
    sourceSets {
        main {
            java.srcDirs += ['path/to/android/java']
            jniLibs.srcDirs += ['path/to/dist-android/jni']
        }
    }
}
```

Then use the `FAISS` class:

```java
try (FAISS.Index index = FAISS.indexFactory(128, "Flat", FAISS.METRIC_L2)) {
    index.add(numVectors, vectorData);
    FAISS.SearchResult result = index.search(numQueries, queryData, k);
    for (int i = 0; i < result.nq; i++) {
        for (int j = 0; j < result.k; j++) {
            System.out.printf("Query %d: neighbor %d = %d (distance %.3f)\n",
                i, j, result.getLabel(i, j), result.getDistance(i, j));
        }
    }
}
```
