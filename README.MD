# FAISS Mobile

This library provides means to compile and distribute FAISS library for iOS.

[FAISS](https://github.com/facebookresearch/faiss) is a library — developed by Facebook AI — that enables efficient similarity search. So, given a set of vectors, we can index them using Faiss — then using another vector (the query vector), we search for the most similar vectors within the index.

## Version

Latest supported version of FAISS is [1.7.4](https://github.com/facebookresearch/faiss/releases/tag/v1.7.4).

## Supported platforms

- iOS
- iOS Simulator
- tvOS
- tvOS Simulator
- watchOS
- watchOS Simulator
- macOS

## Requirements

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

## Why

Modern machine learning tools focus on the server side or desktop solutions, few of them optimise their code bases for mobile, this repository is a structured way to get the FAISS source code compiled and distributed to iOS developers.

## Getting started

Run `./faiss.sh` and it will create `dist/faiss.xcframework` that you can use in your Xcode project.

## faiss.xcframework

Once the compilation is done, you'll have XCframework created with the files below:

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

## Distribution

This package is available using following package managers.

### Swift Package Manager

`./Pacakage.swift` points to remote release hosted on this GitHub repository.
Use [these](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app) instructions to add this GitHub repository.

### Cocoapods

`./FAISS.podspec` includes all the specific details about the build.

In your `Podfile` you can add this library using this syntax:

```ruby
pod 'FAISS', :git => 'https://github.com/eugenehp/faiss-mobile.git', :tag => 'v1.7.4'
```

### Carthage

In `Cartfile` add following:

```ruby
binary "https://raw.githubusercontent.com/eugenehp/faiss-mobile/master/carthage/faiss-static-xcframework.json" ~> 1.7.4
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

## Contributing

Contributions are welcome, feel free to submit an issue or open a pull request.

## License

[MIT](./LICENSE)

Copyright © 2023 [Eugene Hauptmann](http://twitter.com/eugenehp)

## Legal

Faiss is MIT-licensed, refer to the [LICENSE file](https://github.com/facebookresearch/faiss/blob/main/LICENSE) in the top level directory.

Copyright © Meta Platforms, Inc. See the [Terms of Use](https://opensource.fb.com/legal/terms/) and [Privacy Policy](https://opensource.fb.com/legal/privacy/) for this project.
