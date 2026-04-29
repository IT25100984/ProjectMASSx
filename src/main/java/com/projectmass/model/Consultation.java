package com.projectmass.model;

public class Consultation extends Appointment {
    private String roomNumber;
    private static final double CONSULTATION_FEE = 1500.00; // Example currency

    public Consultation(int doctorID, int patientID, String date, String time, String roomNumber) {
        super(doctorID, patientID, date, time); // Inheritance: Passing data to parent constructor
        this.roomNumber = roomNumber;
    }

    @Override
    public double calculateFee() {
        return CONSULTATION_FEE; // Polymorphism: Specific fee for consultation
    }

    public String getRoomNumber() { return roomNumber; }
}