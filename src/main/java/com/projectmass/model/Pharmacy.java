package com.projectmass.model;

public class Pharmacy extends Appointment {
    private int orderID;
    private String medicineName;
    private int quantity;
    private double medicinePrice;
    private String oppositePartyName;
    private String status = "PENDING";

    // Constructor for NEW orders (from Patient Dashboard)
    public Pharmacy(int patientID, String date, String time, String medicineName, int quantity, double medicinePrice, String status) {
        super(0, patientID, date, time);
        this.medicineName = medicineName;
        this.quantity = quantity;
        this.medicinePrice = medicinePrice;
        this.status = status;
        // Generate unique Order ID
        this.orderID = (int) (System.currentTimeMillis() % 100000);
    }

    // Constructor for LOADING orders (from MedFileService)
    public Pharmacy(int orderID, int patientID, int doctorID, String date, String time,
                    String medicineName, int quantity, double medicinePrice, String status) {
        super(doctorID, patientID, date, time);
        this.orderID = orderID;
        this.medicineName = medicineName;
        this.quantity = quantity;
        this.medicinePrice = medicinePrice;
        this.status = status;
    }

    // GETTERS AND SETTERS
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    // Re-mapped to match your Controller logic
    public String getMedicineName() { return medicineName; }
    public int getQuantity() { return quantity; }
    public double getMedicinePrice() { return medicinePrice; }
    public int getOrderID() { return orderID; }
    public void setOrderID(int orderId) { this.orderID = orderId; }
    public double getTotalFee() {
        return medicinePrice * quantity;
    }
    public String getOppositePartyName() {return oppositePartyName;}
    public void setOppositePartyName(String oppositePartyName) { this.oppositePartyName = oppositePartyName; }

    @Override
    public double calculateFee() {
        return quantity * medicinePrice;
    }

    public String toFileString() {
        // Order: ID | Name | Qty | Price | Status | Time | PatientID
        return orderID + "|" + medicineName + "|" + quantity + "|" + medicinePrice + "|" + status + "|" + getTime() + "|" + getPatientID();
    }


}