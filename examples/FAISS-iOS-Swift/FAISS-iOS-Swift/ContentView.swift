import SwiftUI

struct ContentView: View {
    @State private var output = ""
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 16) {
            Text("FAISS iOS Swift Example")
                .font(.headline)

            Button(isRunning ? "Running..." : "Run FAISS Example") {
                isRunning = true
                output = ""
                DispatchQueue.global(qos: .userInitiated).async {
                    let result = runFAISS()
                    DispatchQueue.main.async {
                        output = result
                        isRunning = false
                    }
                }
            }
            .disabled(isRunning)

            ScrollView {
                Text(output)
                    .font(.system(.caption, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
            }
            .background(Color(.secondarySystemBackground))
            .cornerRadius(8)
        }
        .padding()
    }
}

private func faissCheck(_ code: Int32) throws {
    if code != 0 {
        let msg = String(cString: faiss_get_last_error())
        throw NSError(domain: "FAISS", code: Int(code), userInfo: [NSLocalizedDescriptionKey: msg])
    }
}

private func formatResults(_ labels: [idx_t], _ distances: [Float], nq: Int, k: Int) -> String {
    var result = "I=\n"
    for i in 0..<nq {
        for j in 0..<k {
            let label = labels[i * k + j]
            let dist = distances[i * k + j]
            result += String(format: "%5lld (d=%2.3f)  ", label, dist)
        }
        result += "\n"
    }
    return result
}

private func runFAISS() -> String {
    var log = ""

    let d: Int32 = 128
    let nb: Int32 = 100_000
    let nq: Int32 = 10_000
    let k: Int32 = 5

    log += "Generating some data...\n"
    var xb = [Float](repeating: 0, count: Int(d * nb))
    var xq = [Float](repeating: 0, count: Int(d * nq))

    for i in 0..<Int(nb) {
        for j in 0..<Int(d) {
            xb[Int(d) * i + j] = Float.random(in: 0...1)
        }
        xb[Int(d) * i] += Float(i) / 1000.0
    }
    for i in 0..<Int(nq) {
        for j in 0..<Int(d) {
            xq[Int(d) * i + j] = Float.random(in: 0...1)
        }
        xq[Int(d) * i] += Float(i) / 1000.0
    }

    log += "Building an index...\n"

    var index: OpaquePointer?
    do {
        try faissCheck(faiss_index_factory(&index, d, "Flat", METRIC_L2))
        log += "is_trained = \(faiss_Index_is_trained(index) != 0 ? "true" : "false")\n"
        try faissCheck(faiss_Index_add(index, Int64(nb), xb))
        log += "ntotal = \(faiss_Index_ntotal(index))\n"

        log += "Searching...\n"

        // Sanity check: search first 5 vectors of xb
        var labels = [idx_t](repeating: 0, count: Int(k) * 5)
        var distances = [Float](repeating: 0, count: Int(k) * 5)
        try faissCheck(faiss_Index_search(index, 5, xb, Int64(k), &distances, &labels))
        log += formatResults(labels, distances, nq: 5, k: Int(k))

        // Search xq
        labels = [idx_t](repeating: 0, count: Int(k * nq))
        distances = [Float](repeating: 0, count: Int(k * nq))
        try faissCheck(faiss_Index_search(index, Int64(nq), xq, Int64(k), &distances, &labels))
        log += formatResults(labels, distances, nq: 5, k: Int(k))

        // Search with IDSelectorRange [50, 100]
        labels = [idx_t](repeating: 0, count: Int(k * nq))
        distances = [Float](repeating: 0, count: Int(k * nq))
        var sel: OpaquePointer?
        try faissCheck(faiss_IDSelectorRange_new(&sel, 50, 100))
        var params: OpaquePointer?
        try faissCheck(faiss_SearchParameters_new(&params, sel))
        try faissCheck(faiss_Index_search_with_params(index, Int64(nq), xq, Int64(k), params, &distances, &labels))
        log += "Searching w/ IDSelectorRange [50,100]\n"
        log += formatResults(labels, distances, nq: 5, k: Int(k))
        faiss_SearchParameters_free(params)
        faiss_IDSelectorRange_free(sel)

        // Save index to disk
        let documentsPath = NSHomeDirectory() + "/Documents/example.index"
        log += "Saving index to disk...\n"
        try faissCheck(faiss_write_index_fname(index, documentsPath))

        log += "Freeing index...\n"
        faiss_Index_free(index)
        index = nil

        // HNSW example — approximate nearest neighbor search (much faster than Flat)
        log += "\n--- HNSW Index Example ---\n"
        log += "Building an HNSW index...\n"
        var hnswIndex: OpaquePointer?
        try faissCheck(faiss_index_factory(&hnswIndex, d, "HNSW32", METRIC_L2))
        try faissCheck(faiss_Index_add(hnswIndex, Int64(nb), xb))
        log += "ntotal = \(faiss_Index_ntotal(hnswIndex))\n"

        log += "Searching HNSW...\n"
        var hnswLabels = [idx_t](repeating: 0, count: Int(k) * 5)
        var hnswDistances = [Float](repeating: 0, count: Int(k) * 5)
        try faissCheck(faiss_Index_search(hnswIndex, 5, xb, Int64(k), &hnswDistances, &hnswLabels))
        log += formatResults(hnswLabels, hnswDistances, nq: 5, k: Int(k))

        faiss_Index_free(hnswIndex)
        log += "Done.\n"
    } catch {
        log += "Error: \(error.localizedDescription)\n"
        if let index = index {
            faiss_Index_free(index)
        }
    }

    return log
}
