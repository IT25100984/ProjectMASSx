package com.projectmass.model;

public class Admin extends User {

    public Admin() {
        super();
    }

    public Admin(int id, String firstName, String lastName, String email, String password) {
        super(id, firstName, lastName, email, password, "ADMIN");
    }

    // Polymorphism: Changing the interface contract value dynamically
    @Override
    public String getInteractionType() {
        return "ADMIN_CONTROL_SESSION";
    }

    // Polymorphism: Overriding the interface's default summary display
    @Override
    public String getDisplaySummary() {
        return "Administrator: " + getFirstName() + " " + getLastName() + " (ID: #" + getUserID() + ") initialized core console.";
    }

    public void generateReport() {
        System.out.println("Generating system usage report...");
    }
}