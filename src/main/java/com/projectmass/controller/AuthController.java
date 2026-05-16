package com.projectmass.controller;

import com.projectmass.dao.AdminDAO;
import com.projectmass.dao.UserDAO;
import com.projectmass.model.Admin;
import com.projectmass.model.Doctor;
import com.projectmass.model.User;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class AuthController {

    @Autowired
    private UserDAO userDAO; // Spring finds your @Repository UserDAO automatically

    @Autowired
    private AdminDAO adminDAO; // 1. Inject your new DAO at the top

    @PostMapping("/registerAdmin") // Or inside your matching registration router handler
    public String registerAdminAccount(@ModelAttribute Admin admin, Model model) {

        // 2. Execute registration through the dedicated admin data pipeline
        boolean success = adminDAO.registerAdmin(admin);

        if (success) {
            return "redirect:/login?msg=reg_success";
        } else {
            model.addAttribute("error", "Database error: Could not commit Admin registry record.");
            return "register";
        }
    }

    // Show the Login Page (The GET request)
    @GetMapping("/login")
    public String showLoginPage() {
        return "login"; // This looks for login.jsp
    }

    // Handle Login Logic (The POST request)
    @PostMapping("/login")
    public String login(@RequestParam("username") String email,
                        @RequestParam("password") String pass,
                        HttpSession session) {

        System.out.println("AuthController: Received login request for " + email);

        User user = userDAO.login(email, pass);

        if (user != null) {
            session.setAttribute("user", user);
            String role = user.getRole().toUpperCase();

            // Redirect based on role
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
        return "register"; // Looks for /WEB-INF/jsp/register.jsp
    }

    // Handle Registration Logic
    @PostMapping("/register")
    public String registerUser(@RequestParam("firstName") String firstName,
                               @RequestParam("lastName") String lastName,
                               @RequestParam("email") String email,
                               @RequestParam("password") String pass,
                               @RequestParam("role") String role) {

        // Create the User object
        User newUser = new User();
        newUser.setFirstName(firstName);
        newUser.setLastName(lastName);
        newUser.setEmail(email);
        newUser.setPassword(pass);
        newUser.setRole(role);

        // Use the @Autowired userDAO to save
        boolean success = userDAO.saveUser(newUser);

        if (success) {
            // Redirect to log in with the status parameter your JSP expects
            return "redirect:/login?status=registered";
        } else {
            return "redirect:/register?msg=error";
        }
    }

}