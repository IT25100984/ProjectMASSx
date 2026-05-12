package com.projectmass.model;

public class Doctor extends User {
    // Encapsulation of private attributes specific to Doctors
    private String specialization;
    private int licenseID;

    // Default Constructor for Doctor object
    public Doctor() {
        super(); // this super() calls the empty constructor of the User class
    }

    // A safe constructor for the "Search Results" list by Patients
    public Doctor(int id, String firstName, String lastName, String specialization, int  licenseID) {
        this.setUserID(id);
        this.setFirstName(firstName);
        this.setLastName(lastName);
        this.setSpecialization(specialization);
        this.setLicenseID(licenseID);
        // Password and email are left null/empty for security
    }

    // A safe constructor for the "Search User" list by Admin
    public Doctor(int id, String firstName, String lastName, String specialization) {
        this.setUserID(id);
        this.setFirstName(firstName);
        this.setLastName(lastName);
        this.setSpecialization(specialization);
        // Password and email are left null/empty for security
    }

    // Overloaded constructor to initialize Doctor attributes
    public Doctor(int id, String firstName, String lastName, String email, String password, String specialization, int licenseID) {
        super(id, firstName, lastName, email, password, "DOCTOR");
        this.specialization = specialization;
        this.licenseID = licenseID;
    }
    // updateDoctor to edit current Doctor attributes
    public void updateDoctor(int id, String firstName, String lastName, String email, String password, String specialization, int licenseID) {
        this.setUserID(id);
        this.setFirstName(firstName);
        this.setLastName(lastName);
        this.setEmail(email);
        this.setPassword(password);
        this.setRole("DOCTOR");
        this.specialization = specialization;
        this.licenseID = licenseID;
    }

    // Getters and Setters implemented to access private attributes
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) {
        this.specialization = specialization;
    }

    public int getLicenseID() {
        return licenseID;
    }
    public void setLicenseID(int licenseID) { this.licenseID = licenseID;}

    @Override
    public void displayDashboard() {
        System.out.println("Displaying Doctor Portal for: " + getFirstName() + " " + getLastName());
    }
}