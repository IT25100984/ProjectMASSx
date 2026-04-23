package com.projectmass.controller;

import com.projectmass.dao.AppointmentDAO;
import com.projectmass.dao.UserDAO;
import com.projectmass.dto.AppointmentDTO;
import com.projectmass.model.Doctor;
import com.projectmass.model.Patient;
import com.projectmass.model.User;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
public class DashboardController {

    @Autowired
    private AppointmentDAO apptDAO; // Don't forget to add @Repository to AppointmentDAO!

    @Autowired
    private UserDAO userDAO;

    @GetMapping("/patientDashboard")
    public String showPatientDashboard(HttpSession session, Model model, HttpServletResponse response) {
        // Prevent caching (Standard security for dashboards)
        response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

        User currentUser = (User) session.getAttribute("user");

        if (currentUser != null && "PATIENT".equalsIgnoreCase(currentUser.getRole())) {
            List<AppointmentDTO> myAppointments = apptDAO.getAppointmentsByPatient(currentUser.getUserID());

            // Pass data to JSP (Replaces request.setAttribute)
            model.addAttribute("appointments", myAppointments);

            return "patient_dashboard";
        }
        return "redirect:/login";
    }

    @GetMapping("/doctorDashboard")
    public String showDoctorDashboard(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");

        if (user != null && "DOCTOR".equalsIgnoreCase(user.getRole())) {
            List<AppointmentDTO> myAppts = apptDAO.getAppointmentsByDoctor(user.getUserID());

            // This name "myAppts" matches your JSP loop: ${myAppts}
            model.addAttribute("myAppts", myAppts);

            return "doctor_dashboard";
        }
        return "redirect:/login";
    }

    // Add this method to your existing DashboardController.java

    @GetMapping("/adminDashboard")
    public String showAdminDashboard(HttpSession session, Model model) {
        User currentUser = (User) session.getAttribute("user");

        // Security check
        if (currentUser != null && "ADMIN".equalsIgnoreCase(currentUser.getRole())) {
            // Fetch all appointments for the hospital
            List<AppointmentDTO> allAppointments = apptDAO.getAllAppointments();

            // This name "adminApps" must match your admin_dashboard.jsp loop
            model.addAttribute("adminApps", allAppointments);

            return "admin_dashboard";
        }
        return "redirect:/login";
    }

    // Handles UpdateProfileServlet logic
    @PostMapping("/updateProfile")
    public String updateProfile(@RequestParam(required = false) String bloodGroup,
                                @RequestParam(required = false) String medicalHistory,
                                @RequestParam(required = false) String specialization,
                                @RequestParam(required = false, defaultValue = "0") int licenseID,
                                HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        boolean success = false;

        if ("PATIENT".equals(user.getRole())) {
            success = userDAO.updateProfile(user.getUserID(), bloodGroup, medicalHistory);
            if (success) {
                // Cast to Patient to access setBloodGroup
                Patient patient = (Patient) user;
                patient.setBloodGroup(bloodGroup);
                patient.setMedicalHistory(medicalHistory);
            }
        } else if ("DOCTOR".equals(user.getRole())) {
            success = userDAO.updateProfile(user.getUserID(), specialization, licenseID);
            if (success) {
                // Cast to Doctor to access setLicenseID and setSpecialization
                Doctor doctor = (Doctor) user;
                doctor.setSpecialization(specialization);
                doctor.setLicenseID(licenseID);
            }
        }

        String path = "DOCTOR".equals(user.getRole()) ? "/doctorDashboard" : "/patientDashboard";
        return success ? "redirect:" + path + "?updated=true" : "redirect:" + path + "?error=true";
    }

    @GetMapping("/updateProfile")
    public String showUpdateProfile(HttpSession session, Model model) {
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }
        // Pass the current user object to the form to pre-fill fields
        model.addAttribute("user", user);
        return "updateProfilePage"; // This should be the name of your JSP file
    }

}