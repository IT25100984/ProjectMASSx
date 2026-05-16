package com.projectmass.model;

public abstract class Appointment {
    private int appointmentID;
    private int doctorID;
    private int patientID;
    private String date;
    private String time;
    private String status;
    private int lastModifiedBy;

    public Appointment(int doctorID, int patientID, String date, String time) {
        this.doctorID = doctorID;
        this.patientID = patientID;
        this.date = date;
        this.time = time;
        this.status = "PENDING";
    }

    // Abstract method: Every subclass MUST implement this (Polymorphism)
    public abstract double calculateFee();

    // Standard Getters and Setters (Encapsulation)
    public int getAppointmentId() { return appointmentID; }
    public void setAppointmentId(int id) { this.appointmentID = id; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public int getDoctorID() { return doctorID; }
    public void setDoctorID(int doctorID) { this.doctorID = doctorID; }

    public int getPatientID() { return patientID; }
    public void setPatientID(int patientID) { this.patientID = patientID; }

    public String getDate() { return date; }
    public void setDate(String date) { this.date = date; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }

    public int getLastModifiedBy() { return lastModifiedBy; }
    public void setLastModifiedBy(int lastModifiedBy) { this.lastModifiedBy = lastModifiedBy; }
}