package com.projectmass.model;

public class Surgery extends Appointment {
    private String theaterID;
    private String addCharge;

    // Standard constructor matching your DAO usage
    // Match the parameter names to what they actually are to avoid confusion
    public Surgery(int doctorID, int patientID, String date, String time, String theaterID) {
        super(doctorID, patientID, date, time);
        this.theaterID = theaterID;
    }

    @Override
    public double calculateFee() {
        double baseFee = 5000.00;
        double extraCost = 0.0;

        // Check for null to avoid NullPointerException
        if (addCharge == null) {
            extraCost = 0.0;
        } else if ("anesthesia".equalsIgnoreCase(addCharge)) {
            extraCost = 2500.00;
        } else if ("facility".equalsIgnoreCase(addCharge)) {
            extraCost = 1500.00;
        } else if ("equipment".equalsIgnoreCase(addCharge)) {
            extraCost = 3000.00;
        } else {
            extraCost = 500.00;
        }

        return baseFee + extraCost;
    }

    public void setAddCharge(String addCharge) {
        this.addCharge = addCharge;
    }

    public String getAddCharge() { return addCharge; }
    public String getTheaterID() { return theaterID; }
}