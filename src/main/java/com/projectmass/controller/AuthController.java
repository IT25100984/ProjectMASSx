package com.projectmass.controller;

import com.projectmass.dao.AdminDAO;
import com.projectmass.dao.UserDAO;
import com.projectmass.model.Admin;
import com.projectmass.model.Doctor;
import com.projectmass.model.User;
import com.projectmass.service.PatientFileService;
import com.projectmass.service.DoctorFileService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class AuthController {

    @Autowired
    private UserDAO userDAO;

    @Autowired
    private AdminDAO adminDAO;

    // Injecting the specialized OOP file services for individual marking criteria
    @Autowired
    private PatientFileService patientFileService;

    @Autowired
    private DoctorFileService doctorFileService;

    @PostMapping("/registerAdmin")
    public String registerAdminAccount(@ModelAttribute Admin admin, Model model) {
        boolean success = adminDAO.registerAdmin(admin);

        if (success) {
            return "redirect:/login?msg=reg_success";
        } else {
            model.addAttribute("error", "Database error: Could not commit Admin registry record.");
            return "register";
        }
    }

    // Show the Login Page
    @GetMapping("/login")
    public String showLoginPage() {
        return "login";
    }

    // Handle Login Logic
    @PostMapping("/login")
    public String login(@RequestParam("username") String email,
                        @RequestParam("password") String pass,
                        HttpSession session) {

        System.out.println("AuthController: Received login request for " + email);
        User user = userDAO.login(email, pass);

        if (user != null) {
            session.setAttribute("user", user);
            String role = user.getRole().toUpperCase();

            return switch (role) {
                case "ADMIN" -> "redirect:/adminDashboard";
                case "PATIENT" -> "redirect:/patientDashboard";
                case "DOCTOR" -> {
                    Doctor doc = (Doctor) user;
                    yield "PHARMACIST".equalsIgnoreCase(doc.getSpecialization())
                            ? "redirect:/pharmacistDashboard"
                            : "redirect:/doctorDashboard";
                }
                default -> "redirect:/login?error=invalidRole";
            };
        }
        return "redirect:/login?error=true";
    }

    // Handle Logout Logic
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
        return "redirect:/login";
    }

    // Show the Registration Page
    @GetMapping("/register")
    public String showRegisterPage() {
        return "register";
    }

    // Handle Registration Logic with File Sync
    @PostMapping("/register")
    public String registerUser(@RequestParam("firstName") String firstName,
                               @RequestParam("lastName") String lastName,
                               @RequestParam("email") String email,
                               @RequestParam("password") String pass,
                               @RequestParam("role") String role) {

        User newUser = new User();
        newUser.setFirstName(firstName);
        newUser.setLastName(lastName);
        newUser.setEmail(email);
        newUser.setPassword(pass);
        newUser.setRole(role);

        // 1. Save to the database
        boolean success = userDAO.saveUser(newUser);

        if (success) {
            /* * NOTE: Ensure your userDAO.saveUser() method populates the auto-generated
             * ID back into the 'newUser' object using GeneratedKeyHolder (just like FeedbackDAO does),
             * so newUser.getUserID() is not zero/null here!
             */

            // 2. Dual-Layer Text File Sync based on selection role
            if ("PATIENT".equalsIgnoreCase(role)) {
                patientFileService.logToFile(newUser);
                System.out.println("Sync: Patient saved to MySQL and patients.txt");
            } else if ("DOCTOR".equalsIgnoreCase(role)) {
                doctorFileService.logToFile(newUser);
                System.out.println("Sync: Doctor saved to MySQL and doctors.txt");
            }

            return "redirect:/login?status=registered";
        } else {
            return "redirect:/register?msg=error";
        }
    }

    // NEW: Handle Profile Deletion across Database and Text Files (CRUD: Delete)
    @PostMapping("/profile/delete")
    public String deleteProfile(HttpSession session, RedirectAttributes redirectAttributes) {
        // 1. Session boundary guard check
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        int userId = user.getUserID();
        String role = user.getRole();

        // 2. Execute deletion command at the relational database tier
        // Change the method call name below if your UserDAO uses a slightly different name (e.g., deleteUser(id))
        boolean dbDeleted = userDAO.deleteUserById(userId);

        if (dbDeleted) {
            // 3. Polymorphically execute deletion at the flat-file disk layer
            if ("PATIENT".equalsIgnoreCase(role)) {
                patientFileService.deleteById(userId);
                System.out.println("Sync: Account ID " + userId + " removed from patients.txt");
            } else if ("DOCTOR".equalsIgnoreCase(role)) {
                doctorFileService.deleteById(userId);
                System.out.println("Sync: Account ID " + userId + " removed from doctors.txt");
            }

            // 4. Tear down the stateless security token environment since the account is gone
            session.invalidate();

            redirectAttributes.addFlashAttribute("successMessage", "Your account has been permanently closed.");
            return "redirect:/login?msg=deleted";
        } else {
            redirectAttributes.addFlashAttribute("errorMessage", "Database constraint error: Could not complete profile deletion.");
            return "redirect:/login?error=delete_failed";
        }
    }
}