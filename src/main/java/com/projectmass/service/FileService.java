package com.projectmass.service;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public abstract class FileService<T> {

    protected abstract String getFileName();
    protected abstract String getHeader();

    // Subclasses define how to turn an object into a string line
    protected abstract String mapToString(T item);

    // Subclasses define how to check if a line matches a specific ID
    protected abstract boolean isMatch(String line, int... ids);

    public void logToFile(T data) {
        File file = new File(getFileName());
        try {
            System.out.println("File absolute path: " + file.getAbsolutePath());

            if (!file.exists()) {
                if (file.createNewFile()) {
                    try (PrintWriter out = new PrintWriter(new FileWriter(file, true))) {
                        out.println("=== " + getHeader() + " ===");
                        out.println("Generated on: " + java.time.LocalDateTime.now());
                        out.println("------------------------------------------------");
                    }
                } else {
                    System.err.println("Could not create file: " + file.getAbsolutePath());
                }
            }

            //System.out.println("Writing order: " + mapToString(data));

            try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(file, true)))) {
                out.println(mapToString(data));
                out.flush();
            }
        } catch (IOException e) {
            System.err.println("CRITICAL ERROR: Could not write to " + getFileName());
            e.printStackTrace();
        }
    }


    public List<String> readFile(int... ids) {
        List<String> results = new ArrayList<>();
        File file = new File(getFileName());

        if (!file.exists()) return results;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.startsWith("=") || line.startsWith("-") || line.trim().isEmpty()) continue;

                if (isMatch(line, ids)) {
                    results.add(line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return results;
    }

    public List<String> readAll() {
        List<String> results = new ArrayList<>();
        File file = new File(getFileName());

        if (!file.exists()) return results;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                // Skip metadata/headers
                if (line.startsWith("=") || line.startsWith("-") ||
                        line.startsWith("Generated") || line.trim().isEmpty()) continue;
                results.add(line);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return results;
    }

    public void writeAll(List<String> lines) {
        File file = new File(getFileName());
        try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(file, false)))) {
            for (String line : lines) {
                out.println(line);
            }
            out.flush();
        } catch (IOException e) {
            System.err.println("CRITICAL ERROR: Could not overwrite " + getFileName());
            e.printStackTrace(); // show the real cause
        }
    }
}
