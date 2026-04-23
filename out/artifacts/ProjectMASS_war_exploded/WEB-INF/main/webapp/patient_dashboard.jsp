<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.projectmass.model.User" %>
<%@ page import="com.projectmass.dao.AppointmentDAO" %>
<%@ page import="com.projectmass.dto.AppointmentDTO" %>
<%@ page import="java.util.List" %>
<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"PATIENT".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }

    // Fetch appointments for the logged-in patient
    AppointmentDAO dao = new AppointmentDAO();
    List<AppointmentDTO> appointments = dao.getAppointmentsByPatient(user.getUserID());
    request.setAttribute("appointments", appointments);
%>
<html>
<head>
    <title>Patient Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-4">
    <div class="p-5 mb-4 bg-white rounded-3 shadow-sm border">
        <h1 class="display-5 fw-bold">Patient Dashboard</h1>
        <p class="col-md-8 fs-4 text-muted">Manage your medical appointments and records here.</p>
    </div>

    <div class="card shadow border-0 mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h2 class="mb-1">Welcome, ${user.firstName} ${user.lastName}</h2>
                    <p class="text-muted mb-0">
                        <strong>Blood Group:</strong> <span class="badge bg-danger">${user.bloodGroup}</span> |
                        <strong>Medical History:</strong> ${user.medicalHistory}
                    </p>
                </div>
                <div class="btn-group">
                    <button data-bs-toggle="modal" data-bs-target="#profileModal" class="btn btn-outline-warning">
                        <i class="bi bi-pencil-square"></i> Set Profile Info
                    </button>
                    <a href="book_appointment.jsp" class="btn btn-primary shadow-sm">
                        <i class="bi bi-calendar-plus"></i> Book New Appointment
                    </a>
                </div>
            </div>
        </div>
    </div>

    <div class="card shadow border-0">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0">Upcoming Appointments</h5>
        </div>
        <div class="card-body p-0">
            <table class="table table-hover mb-0">
                <thead class="table-dark">
                <tr>
                    <th>Date & Time</th>
                    <th>Doctor</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty appointments}">
                        <c:forEach var="appt" items="${appointments}">
                            <tr>
                                    <%-- Uses DTO getters to prevent property not found errors --%>
                                <td>${appt.dateTime}</td>
                                <td>Dr. ${appt.oppositePartyName}</td>
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
                            <td colspan="4" class="text-center py-4 text-muted">No upcoming appointments found.</td>
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
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title">Complete Your Medical Profile</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label">Blood Group</label>
                    <select name="bloodGroup" class="form-select">
                        <option value="A+" ${user.bloodGroup == 'A+' ? 'selected' : ''}>A+</option>
                        <option value="A-" ${user.bloodGroup == 'A-' ? 'selected' : ''}>A-</option>
                        <option value="B+" ${user.bloodGroup == 'B+' ? 'selected' : ''}>B+</option>
                        <option value="O+" ${user.bloodGroup == 'O+' ? 'selected' : ''}>O+</option>
                        <option value="AB+" ${user.bloodGroup == 'AB+' ? 'selected' : ''}>AB+</option>
                        <option value="N/A" ${user.bloodGroup == 'N/A' ? 'selected' : ''}>N/A</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label">Medical History</label>
                    <textarea name="medicalHistory" class="form-control" rows="4"
                              placeholder="Allergies, past surgeries, or chronic conditions...">${user.medicalHistory}</textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary">Save Information</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // Auto-show modal if blood group is not set
        const bloodGroup = "${user.bloodGroup}";
        if (bloodGroup === "N/A" || bloodGroup === "") {
            var myModal = new bootstrap.Modal(document.getElementById('profileModal'));
            myModal.show();
        }
    });
</script>
</body>
</html>