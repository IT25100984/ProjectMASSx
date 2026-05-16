package com.projectmass.dao;

import com.projectmass.model.Feedback;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@Repository
public class FeedbackDAO {

    private final JdbcTemplate jdbcTemplate;

    @Autowired
    public FeedbackDAO(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    public Integer submitFeedback(int patientId, int doctorId, Integer appointmentId, int rating, String comment) {
        String sql = "INSERT INTO feedback (patient_id, doctor_id, appointment_id, rating, comment) VALUES (?, ?, ?, ?, ?)";
        KeyHolder keyHolder = new GeneratedKeyHolder();

        try {
            jdbcTemplate.update(new PreparedStatementCreator() {
                @Override
                public PreparedStatement createPreparedStatement(Connection con) throws SQLException {
                    // Crucial: Pass Statement.RETURN_GENERATED_KEYS to let JDBC know we want the ID back
                    PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
                    ps.setInt(1, patientId);
                    ps.setInt(2, doctorId);

                    // Safe handling for nullable integer column
                    if (appointmentId != null) {
                        ps.setInt(3, appointmentId);
                    } else {
                        ps.setNull(3, Types.INTEGER);
                    }

                    ps.setInt(4, rating);
                    ps.setString(5, comment);
                    return ps;
                }
            }, keyHolder);

            // Extract the generated numeric ID key
            if (keyHolder.getKey() != null) {
                return keyHolder.getKey().intValue();
            }

            return null;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }

    /** Helper method to grab user names for file operations */
    public String getUserFullName(int userId) {
        String sql = "SELECT CONCAT(first_name, ' ', last_name) FROM users WHERE user_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, String.class, userId);
        } catch (Exception e) {
            return "Unknown User";
        }
    }

    /* Keep all other native DB methods unchanged (getFeedbackForDoctor, getFeedbackByPatient, getAllFeedback, etc.) */
    public List<Feedback> getFeedbackForDoctor(int doctorId) {
        String sql = "SELECT f.*, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, CONCAT(d.first_name, ' ', d.last_name) AS doctor_name " +
                "FROM feedback f JOIN users p ON f.patient_id = p.user_id JOIN users d ON f.doctor_id = d.user_id WHERE f.doctor_id = ? ORDER BY f.created_at DESC";
        return queryFeedback(sql, doctorId);
    }

    public List<Feedback> getFeedbackByPatient(int patientId) {
        String sql = "SELECT f.*, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, CONCAT(d.first_name, ' ', d.last_name) AS doctor_name " +
                "FROM feedback f JOIN users p ON f.patient_id = p.user_id JOIN users d ON f.doctor_id = d.user_id WHERE f.patient_id = ? ORDER BY f.created_at DESC";
        return queryFeedback(sql, patientId);
    }

    public List<Feedback> getAllFeedback() {
        String sql = "SELECT f.*, CONCAT(p.first_name, ' ', p.last_name) AS patient_name, CONCAT(d.first_name, ' ', d.last_name) AS doctor_name " +
                "FROM feedback f JOIN users p ON f.patient_id = p.user_id JOIN users d ON f.doctor_id = d.user_id ORDER BY f.created_at DESC";
        return queryFeedback(sql);
    }

    public double getAverageRating(int doctorId) {
        String sql = "SELECT COALESCE(AVG(rating), 0) FROM feedback WHERE doctor_id = ?";
        Double avg = jdbcTemplate.queryForObject(sql, Double.class, doctorId);
        return avg != null ? Math.round(avg * 10.0) / 10.0 : 0.0;
    }

    public boolean hasReviewed(int patientId, int appointmentId) {
        String sql = "SELECT COUNT(*) FROM feedback WHERE patient_id = ? AND appointment_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, patientId, appointmentId);
        return count != null && count > 0;
    }

    public boolean deleteFeedbackById(int feedbackId) {
        try {
            String sql = "DELETE FROM feedback WHERE feedback_id = ?";
            jdbcTemplate.update(sql, feedbackId);
            return true;
        } catch (Exception e) {
            System.err.println("Error deleting review record: " + e.getMessage());
            return false;
        }
    }

    public Feedback getFeedbackById(int feedbackId) {
        try {
            String sql = "SELECT f.*, " +
                    "CONCAT(p.first_name, ' ', p.last_name) AS patient_name, " +
                    "CONCAT(d.first_name, ' ', d.last_name) AS doctor_name " +
                    "FROM feedback f " +
                    "JOIN users p ON f.patient_id = p.user_id " +
                    "JOIN users d ON f.doctor_id = d.user_id " +
                    "WHERE f.feedback_id = ?";

            return jdbcTemplate.queryForObject(sql, (rs, rowNum) -> {
                Feedback f = new Feedback();
                f.setFeedbackId(rs.getInt("feedback_id"));
                f.setPatientName(rs.getString("patient_name"));
                f.setDoctorName(rs.getString("doctor_name"));
                // map other fields as necessary
                return f;
            }, feedbackId);
        } catch (Exception e) {
            System.err.println("Could not locate feedback record for tracking context: " + e.getMessage());
            return null;
        }
    }

    private List<Feedback> queryFeedback(String sql, Object... args) {
        List<Feedback> list = new ArrayList<>();
        jdbcTemplate.query(sql, rs -> {
            Feedback f = new Feedback();
            f.setFeedbackId(rs.getInt("feedback_id"));
            f.setPatientId(rs.getInt("patient_id"));
            f.setDoctorId(rs.getInt("doctor_id"));
            int apptId = rs.getInt("appointment_id");
            f.setAppointmentId(rs.wasNull() ? null : apptId);
            f.setRating(rs.getInt("rating"));
            f.setComment(rs.getString("comment"));
            f.setPatientName(rs.getString("patient_name"));
            f.setDoctorName(rs.getString("doctor_name"));
            list.add(f);
        }, args);
        return list;
    }
}