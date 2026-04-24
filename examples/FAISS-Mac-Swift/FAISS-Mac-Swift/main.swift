import Foundation

func drand() -> Float {
    Float.random(in: 0...1)
}

func faissCheck(_ code: Int32) {
    if code != 0 {
        let msg = String(cString: faiss_get_last_error())
        fatalError("FAISS error: \(msg)")
    }
}

func printResults(_ labels: UnsafePointer<idx_t>, _ distances: UnsafePointer<Float>, nq: Int, k: Int) {
    print("I=")
    for i in 0..<nq {
        for j in 0..<k {
            let label = labels[i * k + j]
            let dist = distances[i * k + j]
            print(String(format: "%5lld (d=%2.3f)  ", label, dist), terminator: "")
        }
        print()
    }
}

// Parameters
let d: Int32 = 128       // dimension
let nb: Int32 = 100_000  // database size
let nq: Int32 = 10_000   // number of queries
let k: Int32 = 5         // number of nearest neighbors

print("Generating some data...")
var xb = [Float](repeating: 0, count: Int(d * nb))
var xq = [Float](repeating: 0, count: Int(d * nq))

for i in 0..<Int(nb) {
    for j in 0..<Int(d) {
        xb[Int(d) * i + j] = drand()
    }
    xb[Int(d) * i] += Float(i) / 1000.0
}
for i in 0..<Int(nq) {
    for j in 0..<Int(d) {
        xq[Int(d) * i + j] = drand()
    }
    xq[Int(d) * i] += Float(i) / 1000.0
}

print("Building an index...")
var index: OpaquePointer?
faissCheck(faiss_index_factory(&index, d, "Flat", METRIC_L2))
print("is_trained = \(faiss_Index_is_trained(index) != 0 ? "true" : "false")")
faissCheck(faiss_Index_add(index, Int64(nb), xb))
print("ntotal = \(faiss_Index_ntotal(index))")

print("Searching...")

// Sanity check: search first 5 vectors of xb
do {
    var labels = [idx_t](repeating: 0, count: Int(k) * 5)
    var distances = [Float](repeating: 0, count: Int(k) * 5)
    faissCheck(faiss_Index_search(index, 5, xb, Int64(k), &distances, &labels))
    printResults(labels, distances, nq: 5, k: Int(k))
}

// Search xq
do {
    var labels = [idx_t](repeating: 0, count: Int(k * nq))
    var distances = [Float](repeating: 0, count: Int(k * nq))
    faissCheck(faiss_Index_search(index, Int64(nq), xq, Int64(k), &distances, &labels))
    printResults(labels, distances, nq: 5, k: Int(k))
}

// Search with IDSelectorRange [50, 100]
do {
    var labels = [idx_t](repeating: 0, count: Int(k * nq))
    var distances = [Float](repeating: 0, count: Int(k * nq))
    var sel: OpaquePointer?
    faissCheck(faiss_IDSelectorRange_new(&sel, 50, 100))
    var params: OpaquePointer?
    faissCheck(faiss_SearchParameters_new(&params, sel))
    faissCheck(faiss_Index_search_with_params(index, Int64(nq), xq, Int64(k), params, &distances, &labels))
    print("Searching w/ IDSelectorRange [50,100]")
    printResults(labels, distances, nq: 5, k: Int(k))
    faiss_SearchParameters_free(params)
    faiss_IDSelectorRange_free(sel)
}

// Search with IDSelectorRange [20,40] OR [45,60]
do {
    var labels = [idx_t](repeating: 0, count: Int(k * nq))
    var distances = [Float](repeating: 0, count: Int(k * nq))
    var lhsSel: OpaquePointer?
    faissCheck(faiss_IDSelectorRange_new(&lhsSel, 20, 40))
    var rhsSel: OpaquePointer?
    faissCheck(faiss_IDSelectorRange_new(&rhsSel, 45, 60))
    var sel: OpaquePointer?
    faissCheck(faiss_IDSelectorOr_new(&sel, lhsSel, rhsSel))
    var params: OpaquePointer?
    faissCheck(faiss_SearchParameters_new(&params, sel))
    faissCheck(faiss_Index_search_with_params(index, Int64(nq), xq, Int64(k), params, &distances, &labels))
    print("Searching w/ IDSelectorRange [20,40] OR [45,60]")
    printResults(labels, distances, nq: 5, k: Int(k))
    faiss_SearchParameters_free(params)
    faiss_IDSelectorRange_free(lhsSel)
    faiss_IDSelectorRange_free(rhsSel)
    faiss_IDSelector_free(sel)
}

// Search with IDSelectorRange [20,40] AND [15,35] = [20,35]
do {
    var labels = [idx_t](repeating: 0, count: Int(k * nq))
    var distances = [Float](repeating: 0, count: Int(k * nq))
    var lhsSel: OpaquePointer?
    faissCheck(faiss_IDSelectorRange_new(&lhsSel, 20, 40))
    var rhsSel: OpaquePointer?
    faissCheck(faiss_IDSelectorRange_new(&rhsSel, 15, 35))
    var sel: OpaquePointer?
    faissCheck(faiss_IDSelectorAnd_new(&sel, lhsSel, rhsSel))
    var params: OpaquePointer?
    faissCheck(faiss_SearchParameters_new(&params, sel))
    faissCheck(faiss_Index_search_with_params(index, Int64(nq), xq, Int64(k), params, &distances, &labels))
    print("Searching w/ IDSelectorRange [20,40] AND [15,35] = [20,35]")
    printResults(labels, distances, nq: 5, k: Int(k))
    faiss_SearchParameters_free(params)
    faiss_IDSelectorRange_free(lhsSel)
    faiss_IDSelectorRange_free(rhsSel)
    faiss_IDSelector_free(sel)
}

print("Saving index to disk...")
faissCheck(faiss_write_index_fname(index, "example.index"))

print("Freeing index...")
faiss_Index_free(index)

// HNSW example — approximate nearest neighbor search (much faster than Flat)
print("\n--- HNSW Index Example ---")
print("Building an HNSW index...")
var hnswIndex: OpaquePointer?
faissCheck(faiss_index_factory(&hnswIndex, d, "HNSW32", METRIC_L2))
faissCheck(faiss_Index_add(hnswIndex, Int64(nb), xb))
print("ntotal = \(faiss_Index_ntotal(hnswIndex))")

print("Searching HNSW...")
do {
    var labels = [idx_t](repeating: 0, count: Int(k) * 5)
    var distances = [Float](repeating: 0, count: Int(k) * 5)
    faissCheck(faiss_Index_search(hnswIndex, 5, xb, Int64(k), &distances, &labels))
    printResults(labels, distances, nq: 5, k: Int(k))
}

faiss_Index_free(hnswIndex)
print("Done.")
