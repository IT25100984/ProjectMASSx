package com.projectmass.service;

import com.projectmass.model.User;
import org.springframework.stereotype.Service;

@Service
public class DoctorFileService extends FileService<User> {

    @Override
    protected String getFileName() {
        return "doctors.txt";
    }

    @Override
    protected String getHeader() {
        return "DOCTOR CLINICAL ROSTER AUDIT LOG";
    }

    @Override
    protected String mapToString(User doctor) {
        // ID|Full Name|Medical Specialty Role
        return doctor.getUserID() + "|" +
                doctor.getFirstName() + " " + doctor.getLastName() + "|" +
                doctor.getRole();
    }

    @Override
    protected boolean isMatch(String line, int... ids) {
        if (ids == null || ids.length == 0) return false;
        try {
            String[] tokens = line.split("\\|");
            int fileDoctorId = Integer.parseInt(tokens[0].trim());
            return fileDoctorId == ids[0];
        } catch (Exception e) {
            return false;
        }
    }
}