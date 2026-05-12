package com.projectmass.controller;

import com.projectmass.dao.AppointmentDAO;
import com.projectmass.dao.AppointmentDAOInterface;
import com.projectmass.dao.UserDAO;
import com.projectmass.model.Pharmacy;
import com.projectmass.model.User;
import com.projectmass.service.MedFileService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.io.IOException;
import java.util.List;

@Controller
public class PrescriptionController {

    @Autowired
    private MedFileService medService; // Spring will inject this now

    @GetMapping("/updateOrder")
    public String updateOrder(@RequestParam("id") int orderId, @RequestParam("action") String action) {
        List<Pharmacy> allOrders = medService.getAllOrders();
        boolean found = false;

        for (Pharmacy order : allOrders) {
            if (order.getOrderID() == orderId) {
                if ("complete".equalsIgnoreCase(action)) {
                    order.setStatus("COMPLETED");
                } else if ("cancel".equalsIgnoreCase(action)) {
                    order.setStatus("CANCELLED");
                }
                found = true;
                break;
            }
        }

        if (found) {
            medService.saveAllOrders(allOrders);
            return "redirect:/pharmacistDashboard?msg=success";
        }
        return "redirect:/pharmacistDashboard?msg=error";
    }

    @GetMapping("/orderPrescription")
    public String showPrescriptionPage(Model model, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || !"PATIENT".equalsIgnoreCase(user.getRole())) {
            return "redirect:/login";
        }

        List<Pharmacy> allOrders = medService.getAllOrders();
        List<Pharmacy> myOrders = new java.util.ArrayList<>();

        for (Pharmacy order : allOrders) {
            if (order.getPatientID() == user.getUserID()) {
                myOrders.add(order);
            }
        }

        // Send the filtered list to the JSP
        model.addAttribute("myOrders", myOrders);

        return "prescriptions";
    }

    @PostMapping("/submitPrescription")
    public String submitPrescription(@RequestParam("cartData") String cartData, HttpSession session) {
        User user = (User) session.getAttribute("user");
        if (user == null || cartData == null || cartData.isEmpty()) {
            return "redirect:/orderPrescription";
        }

        System.out.println("Cart Data: "+ cartData);

        String orderDate = java.time.LocalDate.now().toString();
        String ordertime = java.time.LocalTime.now().format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
        String[] orderedItems = cartData.split(";");

        for (String itemStr : orderedItems) {
            if (itemStr.trim().isEmpty()) continue;
            String[] details = itemStr.split(",");

            if (details.length >= 3) {
                String name = details[0].trim();
                int qty = Integer.parseInt(details[1].trim());
                double price = Double.parseDouble(details[2].trim());

                // Fixed: Passing "PENDING" directly because the JSP doesn't send status
                Pharmacy order = new Pharmacy(user.getUserID(), orderDate, ordertime, name, qty, price, "PENDING");
                //System.out.println("New Order : "+ order);
                medService.logToFile(order);
            }
        }
        return "redirect:/orderPrescription";
    }
}