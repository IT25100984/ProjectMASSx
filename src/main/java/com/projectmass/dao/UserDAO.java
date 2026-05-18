package com.projectmass.dao;

import com.projectmass.model.Admin;
import com.projectmass.model.Doctor;
import com.projectmass.model.Patient;
import com.projectmass.model.User;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.List;

@Repository
public class UserDAO {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public UserDAO(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    // UPDATED: Now uses GeneratedKeyHolder to fetch auto-increment IDs for file synchronization
    public boolean saveUser(User user) {
        String sql = "INSERT INTO users (first_name, last_name, email, password, role) VALUES (?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        int rowsAffected = jdbcTemplate.update(connection -> {
            // Inform the driver we need to capture the database-generated keys
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getFirstName());
            ps.setString(2, user.getLastName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPassword());
            ps.setString(5, user.getRole());
            return ps;
        }, keyHolder);

        // If row was successfully inserted, capture the key and update our object state
        if (rowsAffected > 0 && keyHolder.getKey() != null) {
            user.setUserID(keyHolder.getKey().intValue());
            return true;
        }
        return false;
    }

    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";

        List<User> users = jdbcTemplate.query(sql, (rs, rowNum) -> {
            String role = rs.getString("role");
            User user;

            if ("DOCTOR".equalsIgnoreCase(role)) {
                Doctor doc = new Doctor();
                doc.setSpecialization(rs.getString("specialization"));
                doc.setLicenseID(rs.getInt("license_id"));
                user = doc;
            } else if ("PATIENT".equalsIgnoreCase(role)) {
                Patient pat = new Patient();
                pat.setBloodGroup(rs.getString("blood_group"));
                pat.setMedicalHistory(rs.getString("medical_history"));
                user = pat;
            } else if ("ADMIN".equalsIgnoreCase(role)) {
                Admin admin = new Admin();
                admin.setUserID(rs.getInt("user_id"));
                admin.setFirstName(rs.getString("first_name"));
                admin.setLastName(rs.getString("last_name"));
                admin.setEmail(rs.getString("email"));
                admin.setRole(role);
                user = admin;
            } else {
                user = new User();
            }

            // Common User Fields
            user.setUserID(rs.getInt("user_id"));
            user.setFirstName(rs.getString("first_name"));
            user.setLastName(rs.getString("last_name"));
            user.setEmail(rs.getString("email"));
            user.setRole(role);
            return user;
        }, email, password);

        return users.isEmpty() ? null : users.getFirst();
    }

    // NEW: Deletion method required to complete individual CRUD requirements (Delete)
    public boolean deleteUserById(int userId) {
        String sql = "DELETE FROM users WHERE user_id = ?";
        return jdbcTemplate.update(sql, userId) > 0;
    }

    // For Patients
    public boolean updateProfile(int userId, String bloodGroup, String medicalHistory) {
        String sql = "UPDATE users SET blood_group = ?, medical_history = ? WHERE user_id = ?";
        return jdbcTemplate.update(sql, bloodGroup, medicalHistory, userId) > 0;
    }

    // For Doctors
    public boolean updateProfile(int userId, String specialization, int licenseId) {
        String sql = "UPDATE users SET specialization = ?, license_id = ? WHERE user_id = ?";
        return jdbcTemplate.update(sql, specialization, licenseId, userId) > 0;
    }

    public List<User> getAllDoctors() {
        String sql = "SELECT user_id, first_name, last_name, specialization, license_id FROM users WHERE role = 'DOCTOR'";
        return jdbcTemplate.query(sql, doctorRowMapper());
    }

    // FIXED: Added license_id to select query to prevent SQLExceptions inside doctorRowMapper
    public List<User> getDoctorsBySpecialization(String specialization) {
        String query = "SELECT user_id, first_name, last_name, specialization, license_id FROM users WHERE role = 'DOCTOR' AND specialization = ?";
        return jdbcTemplate.query(query, doctorRowMapper(), specialization);
    }

    private RowMapper<User> doctorRowMapper() {
        return (rs, rowNum) -> {
            Doctor doc = new Doctor();
            doc.setUserID(rs.getInt("user_id"));
            doc.setFirstName(rs.getString("first_name"));
            doc.setLastName(rs.getString("last_name"));
            doc.setRole("DOCTOR");
            doc.setSpecialization(rs.getString("specialization"));
            doc.setLicenseID(rs.getInt("license_id"));
            return doc;
        };
    }
}