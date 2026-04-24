# FAISS Mobile

This library provides means to compile and distribute FAISS library for iOS.

[FAISS](https://github.com/facebookresearch/faiss) is a library — developed by Facebook AI — that enables efficient similarity search. So, given a set of vectors, we can index them using Faiss — then using another vector (the query vector), we search for the most similar vectors within the index.

## Version

Latest supported version of FAISS is [1.14.1](https://github.com/facebookresearch/faiss/releases/tag/v1.14.1).

## Supported platforms

- iOS
- iOS Simulator
- tvOS
- tvOS Simulator
- watchOS
- watchOS Simulator
- macOS
- visionOS
- visionOS Simulator

## Requirements

- Git [LFS](https://docs.github.com/en/repositories/working-with-files/managing-large-files/installing-git-large-file-storage)
- Xcode (including multiple `platforms`)
- LLVM with Clang
- Homebrew
- g++
- CMake
- node
- python
- perl
- ruby (for Cocoapods)
- carthage
- swift
- [OpenMP](https://github.com/DeveloperMindset-com/openmp-mobile)

## Why

Modern machine learning tools focus on the server side or desktop solutions, few of them optimise their code bases for mobile, this repository is a structured way to get the FAISS source code compiled and distributed to iOS developers.

## Getting started

Run `./faiss.sh` and it will create `dist/faiss.xcframework` that you can use in your Xcode project.

## faiss.xcframework
<details>
<summary>Once the compilation is done, you'll have XCframework created with the files below</summary>

```shell
tree dist/faiss.xcframework -P '*.a'
dist/faiss.xcframework
├── ios-arm64_arm64e
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
├── ios-arm64_arm64e_x86_64-simulator
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
├── macos-arm64_arm64e_x86_64
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
├── tvos-arm64
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
├── tvos-x86_64-simulator
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
├── watchos-arm64_32_armv7k
│   ├── Headers
│   │   └── faiss
│   │       ├── c_api
│   │       │   ├── impl
│   │       │   └── utils
│   │       ├── impl
│   │       │   └── code_distance
│   │       ├── invlists
│   │       └── utils
│   │           ├── approx_topk
│   │           ├── approx_topk_hamming
│   │           ├── distances_fused
│   │           ├── hamming_distance
│   │           └── transpose
│   └── libfaiss.a
└── watchos-i386-simulator
    ├── Headers
    │   └── faiss
    │       ├── c_api
    │       │   ├── impl
    │       │   └── utils
    │       ├── impl
    │       │   └── code_distance
    │       ├── invlists
    │       └── utils
    │           ├── approx_topk
    │           ├── approx_topk_hamming
    │           ├── distances_fused
    │           ├── hamming_distance
    │           └── transpose
    └── libfaiss.a

106 directories, 7 files
```
</details>

## faiss_c.xcframework
<details>
<summary>A C only version, without C++ dependency is inside `faiss_c.xcframework`</summary>

```shell
dist/faiss_c.xcframework
├── Info.plist
├── ios-arm64_arm64e
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
├── ios-arm64_arm64e_x86_64-simulator
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
├── macos-arm64_arm64e_x86_64
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
├── tvos-arm64
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
├── tvos-x86_64-simulator
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
├── watchos-arm64_32_armv7k
│   ├── Headers
│   │   ├── AutoTune_c.h
│   │   ├── Clustering_c.h
│   │   ├── IndexBinary_c.h
│   │   ├── IndexFlat_c.h
│   │   ├── IndexIVFFlat_c.h
│   │   ├── IndexIVF_c.h
│   │   ├── IndexLSH_c.h
│   │   ├── IndexPreTransform_c.h
│   │   ├── IndexReplicas_c.h
│   │   ├── IndexScalarQuantizer_c.h
│   │   ├── IndexShards_c.h
│   │   ├── Index_c.h
│   │   ├── MetaIndexes_c.h
│   │   ├── VectorTransform_c.h
│   │   ├── clone_index_c.h
│   │   ├── error_c.h
│   │   ├── error_impl.h
│   │   ├── faiss_c.h
│   │   ├── impl
│   │   │   └── AuxIndexStructures_c.h
│   │   ├── index_factory_c.h
│   │   ├── index_io_c.h
│   │   ├── macros_impl.h
│   │   └── utils
│   │       └── distances_c.h
│   └── libfaiss_c.a
└── watchos-i386-simulator
    ├── Headers
    │   ├── AutoTune_c.h
    │   ├── Clustering_c.h
    │   ├── IndexBinary_c.h
    │   ├── IndexFlat_c.h
    │   ├── IndexIVFFlat_c.h
    │   ├── IndexIVF_c.h
    │   ├── IndexLSH_c.h
    │   ├── IndexPreTransform_c.h
    │   ├── IndexReplicas_c.h
    │   ├── IndexScalarQuantizer_c.h
    │   ├── IndexShards_c.h
    │   ├── Index_c.h
    │   ├── MetaIndexes_c.h
    │   ├── VectorTransform_c.h
    │   ├── clone_index_c.h
    │   ├── error_c.h
    │   ├── error_impl.h
    │   ├── faiss_c.h
    │   ├── impl
    │   │   └── AuxIndexStructures_c.h
    │   ├── index_factory_c.h
    │   ├── index_io_c.h
    │   ├── macros_impl.h
    │   └── utils
    │       └── distances_c.h
    └── libfaiss_c.a

29 directories, 169 files
```
</details>



## Distribution

This package is available using following package managers.

### Swift Package Manager

`./Package.swift` points to remote release hosted on this GitHub repository.
Use [these](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) instructions to add this GitHub repository.

SPM version points to both libraries `FAISS` in C++ and its C version `FAISS_C`.

### Cocoapods

`./FAISS.podspec` and `./FAISS_C.podspec` include all the specific details about the build.

In your `Podfile` you can add this library using this syntax:

```ruby
pod 'FAISS', :git => 'https://github.com/DeveloperMindset-com/faiss-mobile.git', :tag => 'v1.14.1'
pod 'FAISS_C', :git => 'https://github.com/DeveloperMindset-com/faiss-mobile.git', :tag => 'v1.14.1'
```

### Carthage

In `Cartfile` add following:

```ruby
binary "https://raw.githubusercontent.com/DeveloperMindset-com/faiss-mobile/master/carthage/faiss-static-xcframework.json" ~> 1.14.1
```

Slightly different for a C version:

```ruby
binary "https://raw.githubusercontent.com/DeveloperMindset-com/faiss-mobile/master/carthage/faiss-c-static-xcframework.json" ~> 1.14.1
```

## Releases

Release management works using [gh](https://cli.github.com/manual/installation).

```shell
brew install gh tree
```

To release a draft:

```shell
./faiss.sh release
```

## Examples

- `FAISS-Mac-Objective-C` [read more](/examples/FAISS-Mac-Objective-C/README.md).
- `FAISS-Mac-Objective-C++` [read more](/examples/FAISS-Mac-Objective-C++/README.md).
- `FAISS-iOS-Objective-C` [read more](/examples/FAISS-iOS-Objective-C/README.md).
- `FAISS-Mac-Swift` [read more](/examples/FAISS-Mac-Swift/README.md).
- `FAISS-iOS-Swift` [read more](/examples/FAISS-iOS-Swift/README.md).

## Contributing

Contributions are welcome, feel free to submit an issue or open a pull request.

## License

[MIT](./LICENSE)

Copyright © 2023-2026 [Eugene Hauptmann](http://linkedin.com/in/eugenehp)

## Legal

Faiss is MIT-licensed, refer to the [LICENSE file](https://github.com/facebookresearch/faiss/blob/main/LICENSE) in the top level directory.

Copyright © Meta Platforms, Inc. See the [Terms of Use](https://opensource.fb.com/legal/terms/) and [Privacy Policy](https://opensource.fb.com/legal/privacy/) for this project.
