package com.projectmass.model;

public class User {
    private int userID;
    private String firstName;
    private String lastName;
    private String email;
    private String role;
    private String password;

    // Empty constructor for Doctor and Patient Objects to access private variables
    public User() {}

    // Created constructor for current users
    public User(int userID, String firstname, String lastname, String email, String password, String role) {
        this.userID = userID;
        this.firstName = firstname;
        this.lastName = lastname;
        this.email = email;
        this.password = password;
        this.role = role;
    }
    // Created constructor for new users (to avoid unknown userID issue)
    public User(String firstName, String lastName, String email, String password, String role) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.password = password;
        this.role = role;
    }
    // updateUser method to update current users data
    public void updateUser(int userID, String firstname, String lastname, String email, String password, String role) {
        this.userID = userID;
        this.firstName = firstname;
        this.lastName = lastname;
        this.email = email;
        this.password = password;
        this.role = role;
    }

    // implemented getters and setters for private variables
    public int getUserID() {
        return userID;
    }
    public void setUserID(int userID) {
        this.userID = userID;
    }

    public String getFirstName() {
        return firstName;
    }
    public String getLastName() {
        return lastName;
    }
    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }
    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getFullName() {
        return this.firstName + " " + this.lastName;
    }

    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }

    public String getRole() {
        return role;
    }
    public void setRole(String role) {
        this.role = role;
    }

    public void displayDashboard() {
        System.out.println("User Class Dashboard");
    }

}
