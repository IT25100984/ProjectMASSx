package com.projectmass.model;

public class Surgery extends Appointment {
    private String theaterID;
    private double equipmentCharge;

    public Surgery(int doctorID, int patientID, String date, String time, String theaterID, double equipmentCharge) {
        super(doctorID, patientID, date, time);
        this.theaterID = theaterID;
        this.equipmentCharge = equipmentCharge;
    }

    @Override
    public double calculateFee() {
        // Polymorphism: Fee calculation logic is different from a Consultation
        return 5000.00 + equipmentCharge;
    }

    public String getTheaterID() { return theaterID; }
}