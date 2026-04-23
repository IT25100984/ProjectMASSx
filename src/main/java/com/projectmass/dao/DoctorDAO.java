package com.projectmass.dao;

import com.projectmass.model.Doctor;
import com.projectmass.util.DBConnection;
import org.springframework.stereotype.Repository;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

@Repository
public class DoctorDAO {
    public boolean registerDoctor(Doctor doctor) {
        // SQL query including the specific columns for doctors
        String sql = "INSERT INTO users (first_name, last_name, email, password, role, specialization, license_id) " +
                "VALUES (?, ?, ?, ?, 'DOCTOR', ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = Objects.requireNonNull(conn).prepareStatement(sql)) {

            stmt.setString(1, doctor.getFirstName());
            stmt.setString(2, doctor.getLastName());
            stmt.setString(3, doctor.getEmail());
            stmt.setString(4, doctor.getPassword());
            stmt.setString(5, doctor.getSpecialization());
            stmt.setInt(6, doctor.getLicenseID());

            return stmt.executeUpdate() > 0; // Success if at least one row is inserted
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<Doctor> getDoctorsBySpecialization(String spec) {
        List<Doctor> doctors = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE specialization = ? AND role = 'DOCTOR'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = Objects.requireNonNull(conn).prepareStatement(sql)) {

            stmt.setString(1, spec);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Doctor doc = new Doctor();
                    // Using the setters we confirmed earlier
                    doc.setUserID(rs.getInt("id"));
                    doc.setFirstName(rs.getString("first_name"));
                    doc.setLastName(rs.getString("last_name"));
                    doc.setSpecialization(rs.getString("specialization"));
                    doc.setLicenseID(rs.getInt("license_id"));

                    doctors.add(doc);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return doctors;
    }

}