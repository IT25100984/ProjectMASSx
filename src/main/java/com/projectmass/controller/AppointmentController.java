package com.projectmass.controller;

import com.projectmass.dao.AppointmentDAO;
import com.projectmass.dao.AppointmentDAOInterface;
import com.projectmass.dao.UserDAO;
import com.projectmass.model.User;
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
public class AppointmentController {

    private final AppointmentDAOInterface apptDAO;

    @Autowired
    public AppointmentController(AppointmentDAOInterface appointmentDAO) {
        this.apptDAO = appointmentDAO;
    }

    @Autowired
    private UserDAO userDAO;

    @GetMapping("/getAvailableSlots")
    @ResponseBody
    public List<String> getSlots(@RequestParam int doctorId, @RequestParam String date) {
        return apptDAO.getAvailableSlots(doctorId, date);
    }

    @GetMapping("/getDoctorsBySpec")
    @ResponseBody
    public List<User> getDoctors(@RequestParam(required = false) String specialization) {
        if (specialization == null || specialization.isEmpty() || specialization.equals("All Specializations")) {
            return userDAO.getAllDoctors();
        }
        return userDAO.getDoctorsBySpecialization(specialization);
    }

    // 1. Handles Appointment Booking (POST)
    @PostMapping("/bookAppointment")
    public String bookAppointment(@RequestParam("date") String date,
                                  @RequestParam("time") String time,
                                  @RequestParam("doctorId") int doctorId,
                                  HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"PATIENT".equalsIgnoreCase(user.getRole())) {
            return "redirect:/login";
        }

        // Logic: The patient is the first person to "modify" this record
        boolean success = apptDAO.bookAppointment(doctorId, user.getUserID(), date, time);
        return success ? "redirect:/patientDashboard?msg=success" : "redirect:/book_appointment?error=failed";
    }

    @GetMapping("/book_appointment")
    public String showBookingPage(Model model) {
        // Spring manages the UserDAO, so no 'new' keyword is needed
        List<User> doctorList = userDAO.getAllDoctors();

        // This makes 'doctorList' available to your <c:forEach> in the JSP
        model.addAttribute("doctorList", doctorList);

        return "book_appointment";
    }

    // 2. Handles "Accept" and "Cancel" (GET)
    @GetMapping("/updateAppointment")
    public String updateStatus(@RequestParam("id") int id,
                               @RequestParam("action") String action,
                               HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        boolean success = false;

        if ("accept".equalsIgnoreCase(action)) {
            // We pass the current user's ID.
            // In the DAO, this will set the status to CONFIRMED and record that this user accepted it.
            success = apptDAO.updateAppointmentStatus(id, "CONFIRMED", null, null, user.getUserID());
        } else if ("cancel".equalsIgnoreCase(action)) {
            success = apptDAO.cancelAppointment(id);
        }

        // Role-based redirect logic
        String dashboard = "DOCTOR".equalsIgnoreCase(user.getRole()) ? "doctorDashboard" : "patientDashboard";

        if (success) {
            return "redirect:/" + dashboard + "?msg=" + action + "Success";
        } else {
            return "redirect:/" + dashboard + "?msg=error";
        }
    }

    // 3. Handles "Suggest Time" / Rescheduling (POST)
    @PostMapping("/updateAppointment")
    public String rescheduled(@RequestParam("id") int id,
                              @RequestParam("action") String action,
                              @RequestParam("newDate") String newDate,
                              @RequestParam("newTime") String newTime,
                              HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null) return "redirect:/login";

        if ("rescheduled".equalsIgnoreCase(action)) {
            // Pass user.getUserID() so the DAO knows who is initiating the reschedule
            boolean success = apptDAO.updateAppointmentStatus(id, "RESCHEDULED", newDate, newTime, user.getUserID());

            if (success) {
                // Redirect based on role so they go back to the right dashboard
                String target = "doctor".equalsIgnoreCase(user.getRole()) ? "doctorDashboard" : "patientDashboard";
                return "redirect:/" + target + "?msg=rescheduled";
            }
        }
        return "redirect:/doctorDashboard?msg=error";
    }

    // 4. Handles Doctor Availability
    @PostMapping("/updateAvailability")
    public String updateAvailability(@RequestParam(value="workDays", required=false) List<Integer> days,
                                     @RequestParam("startTime") String start,
                                     @RequestParam("endTime") String end,
                                     HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user != null && days != null) {
            for (Integer dayValue : days) {
                // This now matches your day_of_week column (1 for Mon, 2 for Tue, etc.)
                apptDAO.setDoctorAvailability(user.getUserID(), dayValue, start, end);
            }
        }
        return "redirect:/doctorDashboard?msg=success";
    }
}