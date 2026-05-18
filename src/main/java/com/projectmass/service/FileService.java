package com.projectmass.service;

import java.io.*;
import java.util.ArrayList;
import java.util.List;

public abstract class FileService<T> {

    protected abstract String getFileName();
    protected abstract String getHeader();

    // Subclasses define how to turn an object into a delimited text row
    protected abstract String mapToString(T item);

    // Subclasses define how to check if a line matches a specific ID
    protected abstract boolean isMatch(String line, int... ids);

    public void logToFile(T data) {
        File file = new File(getFileName());
        try {
            if (!file.exists()) {
                if (file.createNewFile()) {
                    try (PrintWriter out = new PrintWriter(new FileWriter(file, true))) {
                        out.println("=== " + getHeader() + " ===");
                        out.println("Generated on: " + java.time.LocalDateTime.now());
                        out.println("------------------------------------------------");
                    }
                }
            }

            try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(file, true)))) {
                out.println(mapToString(data));
                out.flush();
            }
        } catch (IOException e) {
            System.err.println("CRITICAL ERROR: Could not write to " + getFileName());
            e.printStackTrace();
        }
    }

    /** Generic deletion engine inherited by all concrete subclasses */
    public void deleteById(int id) {
        File file = new File(getFileName());
        if (!file.exists()) return;

        List<String> linesToKeep = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                // Only evaluate data rows; bypass structural headers completely
                if (!line.startsWith("=") && !line.startsWith("-") &&
                        !line.startsWith("Generated") && !line.trim().isEmpty()) {

                    if (isMatch(line, id)) {
                        continue; // Target found: Skip adding to list to execute deletion
                    }
                }
                linesToKeep.add(line);
            }
        } catch (IOException e) {
            System.err.println("Error scanning file lines for deletion processing: " + e.getMessage());
        }

        // Overwrite file with the updated, filtered records list
        writeAll(linesToKeep);
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
            e.printStackTrace();
        }
    }
}