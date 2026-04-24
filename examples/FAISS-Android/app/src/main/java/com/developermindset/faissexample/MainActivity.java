package com.developermindset.faissexample;

import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;
import androidx.appcompat.app.AppCompatActivity;

import com.developermindset.faiss.FAISS;

import java.io.File;
import java.util.Random;

public class MainActivity extends AppCompatActivity {

    private TextView outputView;
    private Button runButton;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        outputView = findViewById(R.id.output);
        runButton = findViewById(R.id.runButton);

        runButton.setOnClickListener(v -> {
            runButton.setEnabled(false);
            runButton.setText("Running...");
            outputView.setText("");

            new Thread(() -> {
                String result = runFAISS();
                runOnUiThread(() -> {
                    outputView.setText(result);
                    runButton.setEnabled(true);
                    runButton.setText("Run FAISS Example");
                });
            }).start();
        });
    }

    private String runFAISS() {
        StringBuilder log = new StringBuilder();
        Random rand = new Random();

        int d = 128;      // dimension
        int nb = 100000;  // database size
        int nq = 5;       // number of queries
        int k = 5;        // nearest neighbors

        log.append("Generating some data...\n");
        float[] xb = new float[d * nb];
        float[] xq = new float[d * nq];

        for (int i = 0; i < nb; i++) {
            for (int j = 0; j < d; j++)
                xb[d * i + j] = rand.nextFloat();
            xb[d * i] += i / 1000.0f;
        }
        for (int i = 0; i < nq; i++) {
            for (int j = 0; j < d; j++)
                xq[d * i + j] = rand.nextFloat();
            xq[d * i] += i / 1000.0f;
        }

        // Flat index (exact search)
        log.append("\n--- Flat Index (exact search) ---\n");
        try (FAISS.Index index = FAISS.indexFactory(d, "Flat", FAISS.METRIC_L2)) {
            log.append("is_trained = ").append(index.isTrained()).append("\n");
            index.add(nb, xb);
            log.append("ntotal = ").append(index.ntotal()).append("\n");

            log.append("Searching...\n");
            FAISS.SearchResult result = index.search(nq, xq, k);
            log.append(formatResults(result));

            // Save and reload
            String indexPath = new File(getFilesDir(), "example.index").getAbsolutePath();
            log.append("Saving index to ").append(indexPath).append("...\n");
            index.writeIndex(indexPath);
            log.append("Saved.\n");

            try (FAISS.Index loaded = FAISS.readIndex(indexPath)) {
                log.append("Loaded index: ntotal = ").append(loaded.ntotal()).append("\n");
            }
        }

        // HNSW index (approximate search)
        log.append("\n--- HNSW Index (approximate search) ---\n");
        try (FAISS.Index index = FAISS.indexFactory(d, "HNSW32", FAISS.METRIC_L2)) {
            index.add(nb, xb);
            log.append("ntotal = ").append(index.ntotal()).append("\n");

            log.append("Searching HNSW...\n");
            FAISS.SearchResult result = index.search(nq, xq, k);
            log.append(formatResults(result));
        }

        log.append("\nDone.\n");
        return log.toString();
    }

    private String formatResults(FAISS.SearchResult result) {
        StringBuilder sb = new StringBuilder("I=\n");
        for (int i = 0; i < result.nq; i++) {
            for (int j = 0; j < result.k; j++) {
                sb.append(String.format("%5d (d=%2.3f)  ",
                        result.getLabel(i, j),
                        result.getDistance(i, j)));
            }
            sb.append("\n");
        }
        return sb.toString();
    }
}
