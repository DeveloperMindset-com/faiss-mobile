# Example application for macOS using FAISS (Swift)

Swift example that uses the FAISS C API via a bridging header.

See original C API code [here](../../faiss/c_api/example_c.c)

## Setup

1. Build the FAISS xcframeworks first by running `./faiss.sh build` from the project root.
2. Open `FAISS-Mac-Swift.xcodeproj` in Xcode.
3. Build and run.

## How it works

Swift calls the FAISS C API directly through `BridgingHeader.h`. The example:

1. Generates 100,000 random 128-dimensional vectors
2. Builds a flat L2 index
3. Searches for 5 nearest neighbors
4. Demonstrates filtered search using `IDSelectorRange`
5. Saves the index to disk

## Output

```shell
Generating some data...
Building an index...
is_trained = true
ntotal = 100000
Searching...
I=
    0 (d=0.000)     23 (d=14.844)    362 (d=15.461)    916 (d=15.552)    274 (d=15.662)
    1 (d=0.000)    439 (d=16.097)    119 (d=16.541)    287 (d=16.663)     62 (d=16.753)
    2 (d=0.000)    516 (d=15.073)     12 (d=15.188)    309 (d=15.515)    518 (d=15.874)
    3 (d=0.000)     23 (d=16.026)    149 (d=16.311)    837 (d=16.374)    679 (d=16.875)
    4 (d=0.000)   1024 (d=14.741)     93 (d=15.248)    832 (d=15.626)    155 (d=15.706)
Searching w/ IDSelectorRange [50,100]
...
Saving index to disk...
Freeing index...
Done.
```
