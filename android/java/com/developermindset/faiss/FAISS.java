package com.developermindset.faiss;

/**
 * Java wrapper for the FAISS similarity search library.
 *
 * Usage:
 * <pre>
 *   FAISS.Index index = FAISS.indexFactory(128, "Flat", FAISS.METRIC_L2);
 *   index.add(numVectors, vectorData);
 *   FAISS.SearchResult result = index.search(numQueries, queryData, k);
 *   index.close();
 * </pre>
 */
public class FAISS {

    static {
        System.loadLibrary("faiss_jni");
    }

    public static final int METRIC_L2 = nativeMetricL2();
    public static final int METRIC_INNER_PRODUCT = nativeMetricInnerProduct();

    /**
     * Create an index using the factory pattern.
     *
     * @param d          Vector dimension
     * @param description Index type (e.g., "Flat", "HNSW32", "IVF100,Flat")
     * @param metric     Distance metric (METRIC_L2 or METRIC_INNER_PRODUCT)
     * @return A new Index instance
     */
    public static Index indexFactory(int d, String description, int metric) {
        long ptr = nativeIndexFactory(d, description, metric);
        return new Index(ptr);
    }

    /**
     * Read an index from a file.
     *
     * @param path Path to the index file
     * @return The loaded Index instance
     */
    public static Index readIndex(String path) {
        long ptr = nativeReadIndex(path);
        return new Index(ptr);
    }

    /**
     * Represents a FAISS index. Must be closed after use to free native memory.
     */
    public static class Index implements AutoCloseable {
        private long nativePtr;

        Index(long ptr) {
            this.nativePtr = ptr;
        }

        /**
         * Add vectors to the index.
         *
         * @param n       Number of vectors
         * @param vectors Float array of size n * d
         */
        public void add(int n, float[] vectors) {
            checkNotClosed();
            nativeAdd(nativePtr, n, vectors);
        }

        /**
         * Search for k nearest neighbors.
         *
         * @param nq      Number of query vectors
         * @param queries Float array of size nq * d
         * @param k       Number of nearest neighbors to find
         * @return SearchResult containing labels and distances
         */
        public SearchResult search(int nq, float[] queries, int k) {
            checkNotClosed();
            float[] distances = new float[nq * k];
            long[] labels = nativeSearch(nativePtr, nq, queries, k, distances);
            return new SearchResult(labels, distances, nq, k);
        }

        /** Returns true if the index is trained. */
        public boolean isTrained() {
            checkNotClosed();
            return nativeIsTrained(nativePtr);
        }

        /** Returns the total number of indexed vectors. */
        public long ntotal() {
            checkNotClosed();
            return nativeNtotal(nativePtr);
        }

        /** Returns the vector dimension. */
        public int dimension() {
            checkNotClosed();
            return nativeDimension(nativePtr);
        }

        /**
         * Write the index to a file.
         *
         * @param path File path to write to
         */
        public void writeIndex(String path) {
            checkNotClosed();
            nativeWriteIndex(nativePtr, path);
        }

        @Override
        public void close() {
            if (nativePtr != 0) {
                nativeIndexFree(nativePtr);
                nativePtr = 0;
            }
        }

        private void checkNotClosed() {
            if (nativePtr == 0) {
                throw new IllegalStateException("Index has been closed");
            }
        }
    }

    /**
     * Holds the results of a search query.
     */
    public static class SearchResult {
        /** Nearest neighbor IDs, shape [nq * k] */
        public final long[] labels;
        /** Distances to nearest neighbors, shape [nq * k] */
        public final float[] distances;
        /** Number of query vectors */
        public final int nq;
        /** Number of neighbors per query */
        public final int k;

        SearchResult(long[] labels, float[] distances, int nq, int k) {
            this.labels = labels;
            this.distances = distances;
            this.nq = nq;
            this.k = k;
        }

        /** Get the label of the j-th neighbor for the i-th query. */
        public long getLabel(int i, int j) {
            return labels[i * k + j];
        }

        /** Get the distance of the j-th neighbor for the i-th query. */
        public float getDistance(int i, int j) {
            return distances[i * k + j];
        }
    }

    // Native methods
    private static native long nativeIndexFactory(int d, String description, int metric);
    private static native void nativeIndexFree(long indexPtr);
    private static native void nativeAdd(long indexPtr, int n, float[] vectors);
    private static native long[] nativeSearch(long indexPtr, int nq, float[] queries, int k, float[] distances);
    private static native boolean nativeIsTrained(long indexPtr);
    private static native long nativeNtotal(long indexPtr);
    private static native int nativeDimension(long indexPtr);
    private static native void nativeWriteIndex(long indexPtr, String path);
    private static native long nativeReadIndex(String path);
    private static native int nativeMetricL2();
    private static native int nativeMetricInnerProduct();
}
