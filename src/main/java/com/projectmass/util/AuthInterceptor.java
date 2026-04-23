package com.projectmass.util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

@Component
public class AuthInterceptor implements HandlerInterceptor {
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        HttpSession session = request.getSession(false);
        String uri = request.getRequestURI();

        // Allow access to login, register, and static resources
        if (uri.endsWith("/login") || uri.endsWith("/register") || uri.contains("/css/") || uri.contains("/js/")) {
            return true;
        }

        if (session != null && session.getAttribute("user") != null) {
            return true;
        }

        response.sendRedirect(request.getContextPath() + "/login");
        return false;
    }
}