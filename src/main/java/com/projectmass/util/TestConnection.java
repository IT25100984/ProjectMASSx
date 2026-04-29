package com.projectmass.util;

import java.sql.Connection;

public class TestConnection {
    public static void main(String[] args) {
        System.out.println("Attempting to connect to MySQL...");

        Connection conn = DBConnection.getConnection();

        if (conn != null) {
            System.out.println("SUCCESS: IntelliJ is now talking to the ProjectMASS database!");
        } else {
            System.out.println("FAILURE: The connection could not be established.");
            System.out.println("Checklist:\n1. Is MySQL80 running in Services?\n2. Is the password in DBConnection.java correct?\n3. Did you add the Connector/J JAR to Libraries?");
        }
    }
}