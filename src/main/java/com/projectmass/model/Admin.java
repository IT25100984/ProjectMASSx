package com.projectmass.model;


public class Admin extends User {

    public Admin(){}
    // admin constructor to implement admin object
    // super() used to access empty User constructor
    public Admin(int id, String firstName, String lastName, String email, String password) {
        super(id, firstName, lastName, email, password, "ADMIN");
    }

    // Using Polymorphism to create a unique dashboard for Admins
    @Override
    public void displayDashboard() {
        System.out.println("Displaying Admin Panel: System-wide oversight and user management.");
    }

    // Admin-specific method to generate system usage report with Information Hiding and Abstraction
    public void generateReport() {
        System.out.println("Generating system usage report...");
    }
}