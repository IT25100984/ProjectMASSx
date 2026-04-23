package com.projectmass.model;

public class Availability {
    private int id;
    private int doctorId;
    private Integer dayOfWeek; // ✅ Added: 1 (Mon) to 7 (Sun) for weekly rules (can be null)
    private String date;       // Specific calendar date (can be null for weekly rules)
    private String startTime;
    private String endTime;

    // --- Constructors ---
    public Availability() {}

    public Availability(int id, int doctorId, Integer dayOfWeek, String date, String startTime, String endTime) {
        this.id = id;
        this.doctorId = doctorId;
        this.dayOfWeek = dayOfWeek;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
    }

    // --- Getters and Setters ---

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(int doctorId) {
        this.doctorId = doctorId;
    }

    public Integer getDayOfWeek() {
        return dayOfWeek;
    }

    public void setDayOfWeek(Integer dayOfWeek) {
        this.dayOfWeek = dayOfWeek;
    }

    public String getDate() {
        return date;
    }

    public void setDate(String date) {
        this.date = date;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public String getEndTime() {
        return endTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
}