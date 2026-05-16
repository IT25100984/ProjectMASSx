package com.projectmass.service;

import com.projectmass.model.Feedback;
import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;

@Service
public class FeedbackFileService {

    private static final String FILE_PATH = "feedback.txt";

    /** Appends a clean, single-line review entry WITH its Database ID into the text file */
    public void writeFeedbackToFile(Integer id, String patientName, String doctorName, int rating, String comment) {
        try (FileWriter fw = new FileWriter(FILE_PATH, true);
             BufferedWriter bw = new BufferedWriter(fw);
             PrintWriter out = new PrintWriter(bw)) {

            // Clean up text comments to prevent multi-line file breaks
            String cleanComment = (comment != null) ? comment.replaceAll("\\r?\\n", " ") : "No comment left.";

            // Format: ID|Patient Name|Doctor Name|Rating|Comment
            out.println(id + "|" + patientName + "|" + doctorName + "|" + rating + "|" + cleanComment);

        } catch (IOException e) {
            System.err.println("Error writing to feedback text file: " + e.getMessage());
        }
    }

    /** Deletes a specific line by matching the exact database ID integer */
    public void deleteFeedbackFromFile(Integer targetId) {
        try {
            Path path = Paths.get(FILE_PATH);
            if (!Files.exists(path) || targetId == null) return;

            List<String> lines = Files.readAllLines(path);
            List<String> updatedLines = new ArrayList<>();
            boolean lineRemoved = false;

            for (String line : lines) {
                if (line.trim().isEmpty()) continue;

                String[] tokens = line.split("\\|");

                // Ensure the line has the new format containing the ID
                if (tokens.length >= 5) {
                    try {
                        Integer fileId = Integer.parseInt(tokens[0].trim());
                        // If IDs match, skip this line to delete it
                        if (!lineRemoved && fileId.equals(targetId)) {
                            lineRemoved = true;
                            continue;
                        }
                    } catch (NumberFormatException e) {
                        System.err.println("Encountered malformed ID in text file, skipping line.");
                    }
                }
                // Add non-matching lines back to the keep list
                updatedLines.add(line);
            }

            Files.write(path, updatedLines, StandardOpenOption.WRITE, StandardOpenOption.TRUNCATE_EXISTING);
            System.out.println("Text file sync completed. Match found and deleted: " + lineRemoved);

        } catch (IOException e) {
            System.err.println("Failed to update feedback.txt: " + e.getMessage());
        }
    }

    /** Reads raw text data lines back into Feedback models for public consumption */
    public List<Feedback> getFeedbackFromTextFile() {
        List<Feedback> fileList = new ArrayList<>();
        File file = new File(FILE_PATH);

        if (!file.exists()) return fileList;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                if (line.trim().isEmpty() || !line.contains("|")) continue; // Skip empty/malformed rows

                String[] tokens = line.split("\\|");

                // Now checking for the 5-column format: ID|Patient|Doctor|Rating|Comment
                if (tokens.length >= 5) {
                    try {
                        Feedback f = new Feedback();

                        // Parse and set the feedback ID
                        f.setFeedbackId(Integer.parseInt(tokens[0].trim()));

                        // Shift indices by 1 to accommodate the ID column
                        f.setPatientName(tokens[1].trim());
                        f.setDoctorName(tokens[2].trim());
                        f.setRating(Integer.parseInt(tokens[3].trim()));
                        f.setComment(tokens[4].trim());

                        fileList.add(f);
                    } catch (NumberFormatException nfe) {
                        System.err.println("Skipping malformed text line structural data parse step: " + nfe.getMessage());
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("Error reading feedback text file: " + e.getMessage());
        }
        return fileList;
    }
}