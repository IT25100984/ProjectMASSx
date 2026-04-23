package com.projectmass.dto;

public class AppointmentDTO {
    private int appointmentID; // 👈 Add this field
    private String dateTime;
    private String oppositePartyName;
    private String status;

    private boolean isRescheduled;
    private int lastModifiedBy;

    public AppointmentDTO() {}

    public AppointmentDTO(String dateTime, String oppositePartyName, String status) {
        this.dateTime = dateTime;
        this.oppositePartyName = oppositePartyName;
        this.status = status;
    }

    public AppointmentDTO(int appointmentID, String dateTime, String oppositePartyName, String status, boolean isRescheduled, int lastModifiedBy) {
        this.appointmentID = appointmentID;
        this.dateTime = dateTime;
        this.oppositePartyName = oppositePartyName;
        this.status = status;
        this.isRescheduled = isRescheduled;
        this.lastModifiedBy = lastModifiedBy;
    }

    // Getters and Setters
    public int getAppointmentID() { return appointmentID; }
    public void setAppointmentID(int id) { this.appointmentID = id; }

    public String getDateTime() { return dateTime; }
    public void setDateTime(String dateTime) { this.dateTime = dateTime; }

    public String getOppositePartyName() { return oppositePartyName; }
    public void setOppositePartyName(String oppositePartyName) { this.oppositePartyName = oppositePartyName; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    /**
     * Standard JavaBean getter for boolean.
     * JSP EL will find this when you call ${appt.rescheduled}
     */
    public boolean isRescheduled() { return isRescheduled; }
    public void setRescheduled(boolean rescheduled) { this.isRescheduled = rescheduled; }

    public int getLastModifiedBy() { return lastModifiedBy; }
    public void setLastModifiedBy(int lastModifiedBy) { this.lastModifiedBy = lastModifiedBy; }
}