package com.projectmass.service;

import com.projectmass.model.Pharmacy;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;

@Service
public class MedFileService extends FileService<Pharmacy> {
    @Override
    protected String getFileName() { return "orders.txt"; }

    @Override
    protected String getHeader() { return "PHARMACY ORDER HISTORY"; }

    @Override
    protected String mapToString(Pharmacy pharmacy) {
        // Keeps the 6-column format: ID|Name|Qty|Price|Status|PatientID
        return pharmacy.toFileString();
    }

    @Override
    protected boolean isMatch(String line, int... ids) {
        if (line == null || line.startsWith("=") || line.startsWith("-") || line.startsWith("Generated")) {
            return false;
        }
        String[] parts = line.split("\\|");
        if (parts.length < 6) return false;

        try {
            // Patient ID is at index 5 in your toFileString()
            int filePatientID = Integer.parseInt(parts[5].trim());
            return filePatientID == ids[0];
        } catch (Exception e) {
            return false;
        }
    }

    public List<Pharmacy> getAllOrders() {
        List<Pharmacy> list = new ArrayList<>();
        List<String> lines = super.readAll();

        for (String line : lines) {
            try {
                String[] p = line.split("\\|");
                if (p.length >= 7) { // Updated check for 7 columns
                    int orderId = Integer.parseInt(p[0].trim());
                    String medName = p[1].trim();
                    int qty = Integer.parseInt(p[2].trim());
                    double price = Double.parseDouble(p[3].trim());
                    String status = p[4].trim();
                    String time = p[5].trim(); // Extracted from file
                    int patientId = Integer.parseInt(p[6].trim());

                    Pharmacy ph = new Pharmacy(orderId, patientId, 0, "2026-05-12",
                                                time, medName, qty, price, status);
                    //System.out.println("New Order: " + ph.toFileString());
                    list.add(ph);
                }
            } catch (Exception e) {
                System.err.println("Skipping malformed line: " + line);
            }
        }
        return list;
    }

    /**
     * Overwrites the file with the updated list (Used by Pharmacist)
     */
    public void saveAllOrders(List<Pharmacy> allOrders) {
        List<String> lines = new ArrayList<>();
        for (Pharmacy order : allOrders) {
            lines.add(order.toFileString());
        }
        super.writeAll(lines);
    }
}