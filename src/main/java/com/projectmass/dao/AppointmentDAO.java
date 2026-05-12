package com.projectmass.dao;

import com.projectmass.dto.AppointmentDTO;
import com.projectmass.model.Appointment;
import com.projectmass.model.Consultation;
import com.projectmass.model.Surgery;
import com.projectmass.service.ApptFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.Time;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Repository
public class AppointmentDAO implements AppointmentDAOInterface {

    private final JdbcTemplate jdbcTemplate;
    private final ApptFileService apptFileService;

    @Autowired
    public AppointmentDAO(DataSource dataSource, ApptFileService apptFileService) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.apptFileService = apptFileService;
    }


    private RowMapper<AppointmentDTO> appointmentRowMapper() {
        return (rs, rowNum) -> {
            String rawTime = rs.getString("appt_time");
            if (rawTime != null && rawTime.length() >= 5) {
                rawTime = rawTime.substring(0, 5);
            }

            int id = rs.getInt("appointment_id");
            String fullDateTime = rs.getString("appt_date") + " at " + rawTime;
            String oppositeName = rs.getString("opposite_name");
            String status = rs.getString("status");
            boolean isRescheduled = rs.getBoolean("is_rescheduled");
            int lastModifiedBy = rs.getInt("last_modified_by");

            // EXTRACT THE MISSING COLUMNS
            String type = rs.getString("appointment_type");
            String charge = rs.getString("additional_charge");

            // PASS THEM INTO THE CONSTRUCTOR (Ensure this matches your DTO constructor order)
            return new AppointmentDTO(id, fullDateTime, oppositeName, status,
                    isRescheduled, lastModifiedBy, type, charge);
        };
    }

    public List<AppointmentDTO> getAppointmentsByPatient(int patientId) {
        String sql = "SELECT a.*, CONCAT(u.first_name, ' ', u.last_name) AS opposite_name " +
                "FROM appointments a " +
                "JOIN users u ON a.doctor_id = u.user_id " + // Joining with doctors
                "WHERE a.patient_id = ? AND a.appt_date >= CURDATE() " +
                "ORDER BY " +
                "  CASE WHEN a.appt_date = CURDATE() THEN 1 ELSE 2 END, " +
                "  CASE WHEN a.status = 'CONFIRMED' THEN 1 " +
                "       WHEN a.status = 'RESCHEDULED' THEN 2 " +
                "       WHEN a.status = 'PENDING' THEN 3 " +
                "       ELSE 4 END, " +
                "  a.appt_date ASC, a.appt_time ASC";

        return jdbcTemplate.query(sql, appointmentRowMapper(), patientId);
    }

    public List<AppointmentDTO> getAppointmentsByDoctor(int doctorId) {
        String sql = "SELECT a.*, CONCAT(u.first_name, ' ', u.last_name) AS opposite_name " +
                "FROM appointments a " +
                "JOIN users u ON a.patient_id = u.user_id " + // Joining with patients
                "WHERE a.doctor_id = ? AND a.appt_date >= CURDATE() " + // Hide past dates
                "ORDER BY " +
                "  CASE WHEN a.appt_date = CURDATE() THEN 1 ELSE 2 END, " + // Today's appointments first
                "  CASE WHEN a.status = 'CONFIRMED' THEN 1 " +
                "       WHEN a.status = 'RESCHEDULED' THEN 2 " +
                "       WHEN a.status = 'PENDING' THEN 3 " +
                "       ELSE 4 END, " +
                "  a.appt_date ASC, a.appt_time ASC";

        return jdbcTemplate.query(sql, appointmentRowMapper(), doctorId);
    }

    public List<AppointmentDTO> getAllAppointments() {
        // Add appointment_type and additional_charge to the SELECT list
        String sql = "SELECT a.appointment_id, a.appt_date, a.appt_time, a.status, " +
                "a.is_rescheduled, a.last_modified_by, a.appointment_type, a.additional_charge, " +
                "CONCAT('Doc: ', d.last_name, ' | Pat: ', p.last_name) AS opposite_name " +
                "FROM appointments a " +
                "JOIN users d ON a.doctor_id = d.user_id " +
                "JOIN users p ON a.patient_id = p.user_id " +
                "ORDER BY a.appt_date DESC";

        return jdbcTemplate.query(sql, appointmentRowMapper());
    }

    // --- SECTION 2: BOOKING & UPDATES ---

    // Now includes 'type' and 'addCharge' for initial booking
    public boolean bookAppointment(int doctorID, int patientID, String date, String time, String type, String addCharge) {
        // Availability Check
        String checkSql = "SELECT COUNT(*) FROM appointments WHERE doctor_id = ? AND appt_date = ? AND appt_time = ? AND status != 'CANCELLED'";
        Integer count = jdbcTemplate.queryForObject(checkSql, Integer.class, doctorID, date, time);

        if (count != null && count > 0) return false;

        // Insert with Tracking and Type Metadata
        String insertSql = "INSERT INTO appointments (doctor_id, patient_id, appt_date, appt_time, status, last_modified_by, appointment_type, additional_charge) " +
                "VALUES (?, ?, ?, ?, 'PENDING', ?, ?, ?)";

        return jdbcTemplate.update(insertSql, doctorID, patientID, date, time, patientID, type, addCharge) > 0;
    }

    public boolean updateAppointmentStatus(int appointmentID, String status, String newDate, String newTime, int userId) {
        String sql;
        int rowsAffected;

        if (newDate != null && !newDate.isEmpty() && newTime != null && !newTime.isEmpty()) {
            sql = "UPDATE appointments SET status = ?, appt_date = ?, appt_time = ?, " +
                    "is_rescheduled = 1, last_modified_by = ? WHERE appointment_id = ?";
            rowsAffected = jdbcTemplate.update(sql, status, newDate, newTime, userId, appointmentID);
        } else {
            sql = "UPDATE appointments SET status = ?, last_modified_by = ? WHERE appointment_id = ?";
            rowsAffected = jdbcTemplate.update(sql, status, userId, appointmentID);
        }

        // --- FILE HANDLING TRIGGER ---
        if (rowsAffected > 0 && "CONFIRMED".equalsIgnoreCase(status)) {
            try {
                String fetchSql = "SELECT patient_id, doctor_id, appointment_type, additional_charge, appt_date, appt_time " +
                        "FROM appointments WHERE appointment_id = ?";
                Map<String, Object> data = jdbcTemplate.queryForMap(fetchSql, appointmentID);

                String type = (String) data.get("appointment_type");
                String addCharge = (String) data.get("additional_charge");
                String actualDate = data.get("appt_date").toString();
                String actualTime = data.get("appt_time").toString();

                Appointment apptObj;
                if ("SURGERY".equalsIgnoreCase(type)) {
                    Surgery surg = new Surgery((int)data.get("doctor_id"), (int)data.get("patient_id"), actualDate, actualTime, "OT-1");
                    surg.setAddCharge(addCharge);
                    apptObj = surg;
                } else {
                    apptObj = new Consultation((int)data.get("doctor_id"), (int)data.get("patient_id"), actualDate, actualTime, "Room-101");
                }

                double fee = apptObj.calculateFee();

                String logEntry = String.format("%d|%d|%d|%s|%.2f|%s",
                        appointmentID,
                        (int)data.get("patient_id"),
                        (int)data.get("doctor_id"),
                        type.toUpperCase(),
                        fee,
                        actualDate+"T"+actualTime);

                apptFileService.logToFile(logEntry);

            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return rowsAffected > 0;
    }

    public boolean cancelAppointment(int appointmentId) {
        String sql = "UPDATE appointments SET status = 'CANCELLED' WHERE appointment_id = ?";
        return jdbcTemplate.update(sql, appointmentId) > 0;
    }

    // --- SECTION 3: AVAILABILITY ---

    public boolean setDoctorAvailability(int doctorId, Integer dayOfWeek, String startTime, String endTime) {
        // Clear any existing recurring schedule for this specific day (e.g., all Mondays)
        jdbcTemplate.update("DELETE FROM doctor_availability WHERE doctor_id = ? AND day_of_week = ?", doctorId, dayOfWeek);

        // Insert with day_of_week populated and available_date as NULL
        String sql = "INSERT INTO doctor_availability (doctor_id, available_date, day_of_week, start_time, end_time) VALUES (?, NULL, ?, ?, ?)";
        return jdbcTemplate.update(sql, doctorId, dayOfWeek, startTime, endTime) > 0;
    }

    public boolean setDoctorAvailability(int doctorId, String availableDate, String startTime, String endTime) {
        // Clear any specific override for this exact date
        jdbcTemplate.update("DELETE FROM doctor_availability WHERE doctor_id = ? AND available_date = ?", doctorId, availableDate);

        // Insert with available_date populated and day_of_week as NULL
        String sql = "INSERT INTO doctor_availability (doctor_id, available_date, day_of_week, start_time, end_time) VALUES (?, ?, NULL, ?, ?)";
        return jdbcTemplate.update(sql, doctorId, availableDate, startTime, endTime) > 0;
    }

    public List<String> getAvailableSlots(int doctorId, String date) {
        List<String> availableSlots = new ArrayList<>();
        String dbDate;
        int dayOfWeekInt;

        try {
            LocalDate localDate = LocalDate.parse(date, DateTimeFormatter.ofPattern("yyyy-MM-dd"));
            dbDate = localDate.toString();
            dayOfWeekInt = localDate.getDayOfWeek().getValue();
        } catch (Exception e) { return availableSlots; }

        String availSql = "SELECT start_time, end_time FROM doctor_availability " +
                "WHERE doctor_id = ? AND (available_date = ? OR day_of_week = ?) " +
                "ORDER BY available_date DESC LIMIT 1";

        jdbcTemplate.query(availSql, (rs) -> {
            int startHour = rs.getTime("start_time").toLocalTime().getHour();
            int endHour = rs.getTime("end_time").toLocalTime().getHour();

            String bookedSql = "SELECT appt_time FROM appointments WHERE doctor_id = ? AND appt_date = ? AND status != 'CANCELLED'";
            List<String> bookedHours = jdbcTemplate.query(bookedSql, (rsBooked, rowNum) -> {
                Time bTime = rsBooked.getTime("appt_time");
                return String.format("%02d:00", bTime.toLocalTime().getHour());
            }, doctorId, dbDate);

            for (int h = startHour; h < endHour; h++) {
                String hourStr = String.format("%02d:00", h);
                if (!bookedHours.contains(hourStr)) {
                    availableSlots.add(hourStr);
                }
            }
        }, doctorId, dbDate, dayOfWeekInt);

        return availableSlots;
    }
}