package com.projectmass.util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBConnection {
    // Using Port 3306 to connect with SQL Server
    // User and Password for SQL Connection created when executing server
    private static final String URL = "jdbc:mysql://localhost:3306/ProjectMASS";
    private static final String USER = "root";
    private static final String PASSWORD = "admin123";

    public static Connection getConnection() {
        try {
            // Loads Library
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (Exception e) {
            System.out.println("❌ Connection Error: " + e.getMessage());
            return null;
        }
    }
}
