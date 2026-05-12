package com.projectmass.service;

import org.springframework.stereotype.Service;

import java.io.*;
import java.nio.file.*;
import java.util.ArrayList;
import java.util.List;

@Service
public class ApptFileService extends FileService<String> {

    @Override
    protected String getFileName() { return "billHistory.txt"; }

    @Override
    protected String getHeader() { return "PROJECT MASS APPOINTMENT BILLING HISTORY"; }

    @Override
    protected String mapToString(String data) {
        return data; // In this case, your data is already a formatted string
    }

    @Override
    protected boolean isMatch(String line, int... ids) {
        String[] parts = line.split("\\|");
        if (parts.length < 3 || ids.length < 2) return false;

        try {
            int filePatientID = Integer.parseInt(parts[1].trim());
            int fileDoctorID = Integer.parseInt(parts[2].trim());

            return filePatientID == ids[0] && fileDoctorID == ids[1];
        } catch (NumberFormatException e) {
            return false;
        }
    }
}
