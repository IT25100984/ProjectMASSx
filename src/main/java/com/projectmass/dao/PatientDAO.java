package com.projectmass.dao;

import com.projectmass.model.Patient;
import com.projectmass.util.DBConnection;
import org.springframework.stereotype.Repository;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Objects;

@Repository
public class PatientDAO {
    public boolean registerPatient(Patient patient) {
        // SQL targets the specific patient columns in your table
        String sql = "INSERT INTO users (first_name, last_name, email, password, role, blood_group, medical_history) " +
                "VALUES (?, ?, ?, ?, 'PATIENT', ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = Objects.requireNonNull(conn).prepareStatement(sql)) {

            stmt.setString(1, patient.getFirstName());
            stmt.setString(2, patient.getLastName());
            stmt.setString(3, patient.getEmail());
            stmt.setString(4, patient.getPassword());
            stmt.setString(5, patient.getBloodGroup());
            stmt.setString(6, patient.getMedicalHistory());

            return stmt.executeUpdate() > 0; // Returns true if the patient was saved
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean updateMedicalHistory(int patientID, String newHistory) {
        // Target only the medical_history column for a specific ID
        String sql = "UPDATE users SET medical_history = ? WHERE user_id = ? AND role = 'PATIENT'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = Objects.requireNonNull(conn).prepareStatement(sql)) {

            stmt.setString(1, newHistory);
            stmt.setInt(2, patientID);

            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

}