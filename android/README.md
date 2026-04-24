# FAISS Android

Android support for FAISS, providing JNI bindings and a Java wrapper.

## Building

```shell
./faiss-android.sh build
```

Options:
```
--ndk=<path>    Path to Android NDK
--abi=<abi>     Build for a single ABI (arm64-v8a, armeabi-v7a, x86_64, x86)
--version=<ver> FAISS version
```

Build a single ABI for faster iteration:
```shell
./faiss-android.sh build --abi=arm64-v8a
```

## Output

After building, the output is in `dist-android/`:
```
dist-android/
├── jni/
│   ├── arm64-v8a/
│   │   ├── libfaiss_jni.so
│   │   └── libc++_shared.so
│   ├── armeabi-v7a/
│   │   └── ...
│   ├── x86_64/
│   │   └── ...
│   └── x86/
│       └── ...
└── faiss-android.aar
```

## Java API

```java
import com.developermindset.faiss.FAISS;

// Create an index
FAISS.Index index = FAISS.indexFactory(128, "Flat", FAISS.METRIC_L2);

// Add vectors
index.add(n, vectors);

// Search
FAISS.SearchResult result = index.search(nq, queries, k);

// Save / load
index.writeIndex("/path/to/index.faiss");
FAISS.Index loaded = FAISS.readIndex("/path/to/index.faiss");

// Always close when done
index.close();
```

## Supported index types

All FAISS index types available via `index_factory` are supported:
- `"Flat"` — exact search (brute-force)
- `"HNSW32"` — approximate search (fast)
- `"IVF100,Flat"` — inverted file index
- `"PQ16"` — product quantization
- And more — see [FAISS documentation](https://github.com/facebookresearch/faiss/wiki/Guidelines-to-choose-an-index)
