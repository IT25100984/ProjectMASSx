package com.projectmass.service;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

public class FileService {

    private static final String FILE_NAME = "billHistory.txt";

    public static void logAppointmentToHistory(String data) {
        try {
            // 1. Get the path to the project root
            File file = new File(FILE_NAME);

            // 2. Defensive Check: If file doesn't exist, create it manually
            if (!file.exists()) {
                System.out.println("DEBUG: File does not exist. Creating new file: " + file.getAbsolutePath());
                file.createNewFile();

                // Optional: Write a header if it's a brand new file
                try (PrintWriter out = new PrintWriter(new FileWriter(file, true))) {
                    out.println("=== PROJECT MASS APPOINTMENT BILLING HISTORY ===");
                    out.println("Generated on: " + java.time.LocalDateTime.now());
                    out.println("------------------------------------------------");
                }
            }

            // 3. Append the actual data
            try (PrintWriter out = new PrintWriter(new BufferedWriter(new FileWriter(file, true)))) {
                out.println(data);
                out.flush(); // Force the data out of the RAM and onto the disk
                System.out.println("DEBUG: Successfully wrote to file.");
            }

        } catch (IOException e) {
            System.err.println("CRITICAL ERROR: Could not write to file system.");
            e.printStackTrace();
        }
    }

    public static List<String> getHistoryForAppointment(int targetID) {
        List<String> history = new ArrayList<>();
        try (BufferedReader br = new BufferedReader(new FileReader("billHistory.txt"))) {
            String line;
            while ((line = br.readLine()) != null) {
                // Check if the line starts with our target Appointment ID
                if (line.startsWith(targetID + "|")) {
                    history.add(line);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return history;
    }

    public static List<String> readHistory(int patientID, int doctorID) {
        List<String> results = new ArrayList<>();
        File file = new File(FILE_NAME);

        if (!file.exists()) return results;

        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            String line;
            while ((line = br.readLine()) != null) {
                // Skip headers or empty lines
                if (line.startsWith("=") || line.startsWith("-") || line.trim().isEmpty()) continue;

                String[] parts = line.split("\\|");
                if (parts.length >= 4) {
                    // Assuming format: ApptID | PatientID | DoctorID | Type | Details | Cost
                    // Adjust the index [1] and [2] based on how you order your log string
                    try {
                        int filePatientID = Integer.parseInt(parts[1].trim());
                        int fileDoctorID = Integer.parseInt(parts[2].trim());

                        if (filePatientID == patientID && fileDoctorID == doctorID) {
                            results.add(line);
                        }
                    } catch (NumberFormatException e) {
                        // Skip lines that don't have valid IDs
                    }
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        return results;
    }

}