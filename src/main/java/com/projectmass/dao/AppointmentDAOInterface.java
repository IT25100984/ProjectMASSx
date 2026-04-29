package com.projectmass.dao;

import com.projectmass.dto.AppointmentDTO;
import java.util.List;

public interface AppointmentDAOInterface {

    // Retrieval Methods
    List<AppointmentDTO> getAppointmentsByPatient(int patientId);
    List<AppointmentDTO> getAppointmentsByDoctor(int doctorId);
    List<AppointmentDTO> getAllAppointments();

    // Booking & Status Updates
    boolean bookAppointment(int doctorID, int patientID, String date, String time, String type, String addCharge);
    boolean updateAppointmentStatus(int appointmentID, String status, String newDate, String newTime, int userId);
    boolean cancelAppointment(int appointmentId);

    // Availability Management (Overloaded methods)
    boolean setDoctorAvailability(int doctorId, Integer dayOfWeek, String startTime, String endTime);
    boolean setDoctorAvailability(int doctorId, String availableDate, String startTime, String endTime);
    List<String> getAvailableSlots(int doctorId, String date);
}