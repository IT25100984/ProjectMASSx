package com.projectmass.service;

import com.projectmass.model.User;
import org.springframework.stereotype.Service;

@Service
public class PatientFileService extends FileService<User> {

    @Override
    protected String getFileName() {
        return "patients.txt";
    }

    @Override
    protected String getHeader() {
        return "PATIENT PROFILE REGISTER AUDIT LOG";
    }

    @Override
    protected String mapToString(User patient) {
        // ID|Full Name|Email Address
        return patient.getUserID() + "|" +
                patient.getFirstName() + " " + patient.getLastName() + "|" +
                patient.getEmail();
    }

    @Override
    protected boolean isMatch(String line, int... ids) {
        if (ids == null || ids.length == 0) return false;
        try {
            String[] tokens = line.split("\\|");
            int filePatientId = Integer.parseInt(tokens[0].trim());
            return filePatientId == ids[0];
        } catch (Exception e) {
            return false;
        }
    }
}