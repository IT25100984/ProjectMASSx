package com.projectmass.controller;

import com.projectmass.service.FeedbackFileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

@ControllerAdvice
public class GlobalLayoutAdvice {

    @Autowired
    private FeedbackFileService feedbackFileService;

    @ModelAttribute
    public void addGlobalAttributes(Model model) {
        try {
            model.addAttribute("publicReviews", feedbackFileService.getFeedbackFromTextFile());
        } catch (Exception e) {
            model.addAttribute("publicReviews", new java.util.ArrayList<>());
        }
    }
}