package com.projectmass.controller;

import com.projectmass.dao.FeedbackDAO;
import com.projectmass.dao.UserDAO;
import com.projectmass.model.Feedback;
import com.projectmass.model.User;
import com.projectmass.service.FeedbackFileService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
public class FeedbackController {

    @Autowired
    private FeedbackDAO feedbackDAO;

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private FeedbackFileService feedbackFileService;

    @GetMapping("/feedback")
    public String feedbackPage(
            @RequestParam(value = "doctorId", required = false) Integer doctorId,
            @RequestParam(value = "appointmentId", required = false) Integer appointmentId,
            HttpSession session, Model model) {

        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        String role = user.getRole();

        if ("PATIENT".equalsIgnoreCase(role)) {
            // Keep track of the specific appointment data coming from the dashboard
            model.addAttribute("selectedDoctorId", doctorId);
            model.addAttribute("selectedAppointmentId", appointmentId);

            // Optional data context if your form layout still lists alternative doctors/history
            model.addAttribute("doctors", userDAO.getAllDoctors());
            model.addAttribute("myFeedback", feedbackDAO.getFeedbackByPatient(user.getUserID()));

            return "feedback_form";

        } else if ("DOCTOR".equalsIgnoreCase(role)) {
            List<Feedback> reviews = feedbackDAO.getFeedbackForDoctor(user.getUserID());
            double avg = feedbackDAO.getAverageRating(user.getUserID());
            model.addAttribute("reviews", reviews);
            model.addAttribute("avgRating", avg);
            return "doctor_feedback";

        } else if ("ADMIN".equalsIgnoreCase(role)) {
            model.addAttribute("allFeedback", feedbackDAO.getAllFeedback());
            return "admin_feedback_modal";
        }

        return "redirect:/login";
    }

    @PostMapping("/submitFeedback")
    public String submitFeedback(
            @RequestParam(value = "doctorId", required = false) Integer doctorId,
            @RequestParam(value = "rating", required = false) Integer rating,
            @RequestParam(required = false) String comment,
            @RequestParam(required = false) Integer appointmentId,
            HttpSession session, Model model) {

        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        if (doctorId == null && appointmentId != null) {
            try {
                // If your appointment tracking holds the doctor connection, resolve it here:
                // doctorId = appointmentDAO.getDoctorIdByAppointment(appointmentId);
                System.out.println("Warning: doctorId was missing, attempting recovery via appointment mapping.");
            } catch (Exception e) {
                System.err.println("Could not resolve doctor recovery mapping: " + e.getMessage());
            }
        }

        if (doctorId == null || rating == null) {
            System.err.println("CRITICAL: Form processing halted. Missing required fields.");
            System.err.println("-> doctorId: " + doctorId + " | rating: " + rating);

            model.addAttribute("error", "Failed to submit review. Form parameters mismatched.");
            model.addAttribute("doctors", userDAO.getAllDoctors());
            model.addAttribute("myFeedback", feedbackDAO.getFeedbackByPatient(user.getUserID()));
            return "feedback_form"; // Loops back safely without throwing a 400 page
        }

        Integer newFeedbackId = feedbackDAO.submitFeedback(user.getUserID(), doctorId, appointmentId, rating, comment);

        if (newFeedbackId != null) {
            try {
                // Action 2: Resolve names and append to text file using the newly generated ID
                String patientName = user.getFirstName() + " " + user.getLastName();
                String doctorName = feedbackDAO.getUserFullName(doctorId);

                // Now your file tracking has an exact 1:1 ID match with SQL!
                feedbackFileService.writeFeedbackToFile(newFeedbackId, patientName, doctorName, rating, comment);
                System.out.println("Success: Feedback successfully written to Database & feedback.txt with ID: " + newFeedbackId);
            } catch (Exception e) {
                System.err.println("Database insert succeeded, but file storage write execution skipped: " + e.getMessage());
            }

            // Send back to dashboard with a clean success toast flag
            return "redirect:/patientDashboard?msg=review_success";
        } else {
            model.addAttribute("error", "Database processing rejected the feedback write operation.");
            model.addAttribute("doctors", userDAO.getAllDoctors());
            model.addAttribute("myFeedback", feedbackDAO.getFeedbackByPatient(user.getUserID()));
            return "feedback_form";
        }
    }

    @PostMapping("/deleteFeedback")
    public String deleteFeedback(@RequestParam("feedbackId") Integer feedbackId, HttpSession session) {
        User user = (User) session.getAttribute("user");

        if (user == null || !"ADMIN".equalsIgnoreCase(user.getRole())) {
            return "redirect:/login";
        }

        try {
            // Clear the record from SQL
            boolean deletedFromDb = feedbackDAO.deleteFeedbackById(feedbackId);

            if (deletedFromDb) {
                // Pass JUST the integer ID to the file service
                feedbackFileService.deleteFeedbackFromFile(feedbackId);
                return "redirect:/adminDashboard?msg=delete_success";
            } else {
                return "redirect:/adminDashboard?msg=delete_failed";
            }

        } catch (Exception e) {
            System.err.println("Error during deletion: " + e.getMessage());
            return "redirect:/adminDashboard?msg=delete_failed";
        }
    }
}