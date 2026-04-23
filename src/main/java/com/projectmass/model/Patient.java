package com.projectmass.model;

public class Patient extends User {
    private String medicalHistory;
    private String bloodGroup;

    public Patient(){}

    // patient constructor to initialize new patient data
    public Patient(int id, String firstName, String lastName, String email, String password, String bloodGroup, String medicalHistory) {
        super(id, firstName, lastName, email, password, "PATIENT");
        this.bloodGroup = bloodGroup;
        this.medicalHistory = medicalHistory;
    }
    // patient constructor for "Search User" List by Admin
    public Patient(int id, String firstName, String lastName, String bloodGroup) {
        this.setUserID(id);
        this.setFirstName(firstName);
        this.setLastName(lastName);
        this.bloodGroup = bloodGroup;
    }

    // updatePatient method to edit current patient data
    public void updatePatient(int id, String firstName, String lastName, String email, String password, String bloodGroup, String medicalHistory) {
        this.bloodGroup = bloodGroup;
        this.medicalHistory = medicalHistory;
        this.setUserID(id);
        this.setFirstName(firstName);
        this.setLastName(lastName);
        this.setEmail(email);
        this.setPassword(password);
        this.setRole("PATIENT");
    }

    // Getters and Setters to retrieve patient private data
    public String getMedicalHistory() {
        return medicalHistory;
    }
    public void setMedicalHistory(String medicalHistory) {
        this.medicalHistory = medicalHistory;
    }

    public String getBloodGroup() {
        return bloodGroup;
    }
    public void setBloodGroup(String bloodGroup) {
        this.bloodGroup = bloodGroup;
    }

    /**
     * Using Polymorphism to Override a method from User Object
     * This way we can create a custom dashboard view for patients only.
     */
    @Override
    public void displayDashboard() {
        System.out.println("Displaying Patient Portal: View your appointments and history.");

    }
}