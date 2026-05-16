package com.projectmass.controller;

import com.projectmass.dao.FeedbackDAO;
import com.projectmass.model.Feedback;
import com.projectmass.service.FeedbackFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.util.List;

@Controller
public class HomeController {

    @Autowired
    private FeedbackFileService feedbackFileService;

    @GetMapping({"/", "/index"})
    public String showWelcomePage(Model model) {
        // Read directly via the dedicated service layer
        model.addAttribute("publicReviews", feedbackFileService.getFeedbackFromTextFile());
        return "index";
    }
}