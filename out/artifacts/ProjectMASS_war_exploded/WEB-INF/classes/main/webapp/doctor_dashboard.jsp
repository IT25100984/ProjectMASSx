<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.projectmass.model.User" %>
<%@ page import="com.projectmass.dto.AppointmentDTO" %>
<%@ page import="java.util.List" %>
<%@ page import="com.projectmass.dao.AppointmentDAO" %>
<%
    User user = (User) session.getAttribute("user");
    // Secure the page: only allow DOCTORs
    if (user == null || !"DOCTOR".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch appointments specifically for this doctor
    AppointmentDAO apptDao = new AppointmentDAO();
    List<AppointmentDTO> myAppts = apptDao.getAppointmentsByDoctor(user.getUserID());
    request.setAttribute("myAppts", myAppts);
%>
<html>
<head>
    <title>Doctor Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-4">
    <div class="p-5 mb-4 bg-primary text-white rounded-3 shadow">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="display-5 fw-bold">Doctor Portal</h1>
                <p class="fs-4 mb-0">Welcome, Dr. ${user.firstName} ${user.lastName}</p>
                <span class="badge bg-light text-primary fs-6 mt-2">
                    <i class="bi bi-patch-check"></i> Specialization: ${user.specialization}
                </span>
            </div>
            <button data-bs-toggle="modal" data-bs-target="#profileModal" class="btn btn-outline-light">
                <i class="bi bi-gear"></i> Set Profile Info
            </button>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Your Schedule</h5>
            <span class="badge bg-secondary">${myAppts.size()} Appointments</span>
        </div>
        <div class="card-body p-0">
            <table class="table table-hover mb-0">
                <thead class="table-secondary">
                <tr>
                    <th>Date & Time</th>
                    <th>Patient Name</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty myAppts}">
                        <c:forEach var="appt" items="${myAppts}">
                            <tr>
                                <td>${appt.dateTime}</td>
                                <td><i class="bi bi-person"></i> ${appt.oppositePartyName}</td>
                                <td>
                                    <span class="badge ${appt.status == 'Confirmed' ? 'bg-success' : 'bg-info'}">
                                            ${appt.status}
                                    </span>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-outline-danger">Cancel</button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="4" class="text-center py-5 text-muted">
                                <i class="bi bi-calendar-x fs-1 d-block mb-2"></i>
                                No appointments scheduled.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="profileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form action="updateProfile" method="POST" class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Update Professional Details</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Specialization</label>
                    <select name="specialization" class="form-select">
                        <option value="General Practitioner" ${user.specialization == 'General Practitioner' ? 'selected' : ''}>General Practitioner</option>
                        <option value="Cardiology" ${user.specialization == 'Cardiology' ? 'selected' : ''}>Cardiology</option>
                        <option value="Dermatology" ${user.specialization == 'Dermatology' ? 'selected' : ''}>Dermatology</option>
                        <option value="Pediatrics" ${user.specialization == 'Pediatrics' ? 'selected' : ''}>Pediatrics</option>
                        <option value="Neurology" ${user.specialization == 'Neurology' ? 'selected' : ''}>Neurology</option>
                    </select>
                </div>
                <div class="alert alert-info py-2">
                    <small><i class="bi bi-info-circle"></i> This specialization will be visible to patients when they book appointments.</small>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary">Update Specialization</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    // Auto-show modal if specialization is still default or not set
    document.addEventListener("DOMContentLoaded", function() {
        const spec = "${user.specialization}";
        if (spec === "" || spec === "General Practitioner") {
            var myModal = new bootstrap.Modal(document.getElementById('profileModal'));
            myModal.show();
        }
    });
</script>

</body>
</html>