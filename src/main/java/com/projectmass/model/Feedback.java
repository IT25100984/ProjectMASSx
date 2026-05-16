package com.projectmass.model;

import java.time.LocalDateTime;

// 1. Interface Implementation: Feedback now contracts to implement UserInteraction behaviors
public class Feedback implements UserInteraction {
    private int feedbackId;
    private int patientId;
    private int doctorId;
    private Integer appointmentId;
    private int rating;
    private String comment;
    private LocalDateTime createdAt; // Will double to satisfy the getTimestamp() contract

    // Extra display fields (joined from users table or tokenized from feedback.txt)
    private String patientName;
    private String doctorName;

    public Feedback() {
        // Initialize the creation timestamp right when the feedback object is instantiated
        this.createdAt = LocalDateTime.now();
    }

    // --- Fulfilling the UserInteraction Interface Contract ---

    @Override
    public String getInteractionType() {
        return "PATIENT_FEEDBACK";
    }

    @Override
    public LocalDateTime getTimestamp() {
        return this.createdAt;
    }

    // 2. Polymorphism: Overriding the interface's default summary tracking layout
    @Override
    public String getDisplaySummary() {
        return "Feedback ID " + feedbackId + " submitted by " +
                (patientName != null ? patientName : "Patient #" + patientId) +
                " for Dr. " + (doctorName != null ? doctorName : "ID #" + doctorId) +
                " [Rating: " + rating + "/5]";
    }

    // --- Standard Getters and Setters (Encapsulation Boundaries) ---

    public int getFeedbackId() { return feedbackId; }
    public void setFeedbackId(int feedbackId) { this.feedbackId = feedbackId; }

    public int getPatientId() { return patientId; }
    public void setPatientId(int patientId) { this.patientId = patientId; }

    public int getDoctorId() { return doctorId; }
    public void setDoctorId(int doctorId) { this.doctorId = doctorId; }

    public Integer getAppointmentId() { return appointmentId; }
    public void setAppointmentId(Integer appointmentId) { this.appointmentId = appointmentId; }

    public int getRating() { return rating; }
    public void setRating(int rating) { this.rating = rating; }

    public String getComment() { return comment; }
    public void setComment(String comment) { this.comment = comment; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public String getDoctorName() { return doctorName; }
    public void setDoctorName(String doctorName) { this.doctorName = doctorName; }

    /** Returns star string for display e.g. ★★★☆☆ */
    public String getStars() {
        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= 5; i++) {
            sb.append(i <= rating ? "★" : "☆");
        }
        return sb.toString();
    }
}