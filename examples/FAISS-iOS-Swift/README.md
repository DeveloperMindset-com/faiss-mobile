# Example application for iOS using FAISS (Swift)

SwiftUI example that uses the FAISS C API via a bridging header.

See original C API code [here](../../faiss/c_api/example_c.c)

## Setup

1. Build the FAISS xcframeworks first by running `./faiss.sh build` from the project root.
2. Open `FAISS-iOS-Swift.xcodeproj` in Xcode.
3. Select a simulator or device target.
4. Build and run.

## How it works

Swift calls the FAISS C API directly through `BridgingHeader.h`. The app presents a single button that runs the FAISS example on a background thread and displays results in a scrollable text view.

The example:

1. Generates 100,000 random 128-dimensional vectors
2. Builds a flat L2 index
3. Searches for 5 nearest neighbors
4. Demonstrates filtered search using `IDSelectorRange`
5. Saves the index to the app's Documents directory

## Development

The index file is saved to the iOS Documents directory to accommodate sandbox restrictions:

```swift
let documentsPath = NSHomeDirectory() + "/Documents/example.index"
faissCheck(faiss_write_index_fname(index, documentsPath))
```
