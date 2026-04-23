<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.projectmass.model.User" %>

<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"PATIENT".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    // Note: The List<AppointmentDTO> appointments is now passed seamlessly by the Servlet!
%>
<html>
<head>
    <title>Patient Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        /* Pulse effect for new suggestions */
        @keyframes pulse {
            0% { opacity: 1; }
            50% { opacity: 0.5; }
            100% { opacity: 1; }
        }
        .animate-pulse {
            animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite;
        }
    </style>
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-4">

    <%-- ✅ Action Messages (Success or Error) --%>
    <c:if test="${param.msg == 'success'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Action Successful!</strong> Your appointment schedule has been updated.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <%-- ✅ Profile Updates using JSTL (Replacing raw <% scriptlets %>) --%>
    <c:if test="${param.updated == 'true'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Profile Updated!</strong> Your medical information was successfully saved.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.error == 'true'}">
        <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Error!</strong> Could not save profile information.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="p-5 mb-4 bg-white rounded-3 shadow-sm border">
        <h1 class="display-5 fw-bold">Patient Dashboard</h1>
        <p class="col-md-8 fs-4 text-muted">Manage your medical appointments and records here.</p>
    </div>

    <div class="card shadow border-0 mb-4">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h2 class="mb-1">Welcome, ${user.firstName} ${user.lastName}</h2>
                    <div class="text-muted mb-0">
                        <div class="mb-2">
                            <strong>Blood Group:</strong> <span class="badge bg-danger">${user.bloodGroup}</span>
                        </div>
                        <div>
                            <strong>Medical History:</strong>
                            <button type="button"
                                    class="btn btn-sm btn-link text-decoration-none p-0 pb-1"
                                    data-bs-toggle="popover"
                                    data-bs-trigger="focus"
                                    data-bs-title="Medical History Detail"
                                    data-bs-content="${not empty user.medicalHistory ? user.medicalHistory : 'No history recorded.'}">
                                <i class="bi bi-info-circle"></i> View Details
                            </button>
                        </div>
                    </div>
                </div>
                <div class="btn-group">
                    <button data-bs-toggle="modal" data-bs-target="#profileModal" class="btn btn-outline-warning">
                        <i class="bi bi-pencil-square"></i> Update Info
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
                                <td>${appt.dateTime}</td>

                                <td><i class="bi bi-person-badge me-1"></i> Dr. ${appt.oppositePartyName}</td>

                                <td>
                                    <span class="badge
                                        ${appt.status == 'RESCHEDULED' ? 'bg-info text-dark animate-pulse' :
                                          appt.status == 'PENDING' ? 'bg-warning text-dark' :
                                          appt.status == 'CONFIRMED' ? 'bg-success' : 'bg-danger'}">
                                        ${appt.status == 'RESCHEDULED' ? 'NEW SUGGESTION' : appt.status}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <c:if test="${appt.status == 'RESCHEDULED'}">
                                            <a href="updateAppointment?id=${appt.appointmentID}&action=accept"
                                               class="btn btn-sm btn-success shadow-sm">
                                                Accept
                                            </a>
                                        </c:if>

                                        <a href="javascript:void(0);"
                                           onclick="confirmPatientCancel('${appt.appointmentID}', '${appt.oppositePartyName}')"
                                           class="btn btn-sm btn-outline-danger">
                                           Cancel
                                        </a>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="4" class="text-center py-5 text-muted">
                                <i class="bi bi-calendar-x fs-1 d-block mb-2"></i>
                                No upcoming appointments found.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%-- PROFILE MODAL --%>
<div class="modal fade" id="profileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form action="updateProfile" method="POST" class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold">Update Your Medical Profile</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="mb-3">
                    <label class="form-label fw-semibold">Blood Group</label>
                    <select name="bloodGroup" class="form-select">
                        <option value="A+" ${user.bloodGroup == 'A+' ? 'selected' : ''}>A+</option>
                        <option value="A-" ${user.bloodGroup == 'A-' ? 'selected' : ''}>A-</option>
                        <option value="B+" ${user.bloodGroup == 'B+' ? 'selected' : ''}>B+</option>
                        <option value="B-" ${user.bloodGroup == 'B-' ? 'selected' : ''}>B-</option>
                        <option value="O+" ${user.bloodGroup == 'O+' ? 'selected' : ''}>O+</option>
                        <option value="O-" ${user.bloodGroup == 'O-' ? 'selected' : ''}>O-</option>
                        <option value="AB+" ${user.bloodGroup == 'AB+' ? 'selected' : ''}>AB+</option>
                        <option value="AB-" ${user.bloodGroup == 'AB-' ? 'selected' : ''}>AB-</option>
                        <option value="N/A" ${user.bloodGroup == 'N/A' || empty user.bloodGroup ? 'selected' : ''}>N/A</option>
                    </select>
                </div>
                <div class="mb-3">
                    <label class="form-label fw-semibold">Medical History</label>
                    <textarea name="medicalHistory" class="form-control" rows="4"
                              placeholder="Describe allergies, past surgeries, or chronic conditions...">${user.medicalHistory}</textarea>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary px-4">Save Information</button>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        // --- 1. POPUP MODAL LOGIC ---
        const userId = "${user.userID}"; // Just check if current user profile is lacking
        const groupVal = "${user.bloodGroup}";
        if (groupVal === "N/A" || groupVal === "" || groupVal === "null") {
            var myModal = new bootstrap.Modal(document.getElementById('profileModal'));
            myModal.show();
        }

        // --- 2. POPOVER LOGIC ---
        var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
        var popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
            return new bootstrap.Popover(popoverTriggerEl);
        });
    });

    function confirmPatientCancel(apptId, doctorName) {
        const userConfirmed = confirm("Are you sure you want to cancel your appointment with Dr. " + doctorName + "?");
        if (userConfirmed) {
            window.location.href = "updateAppointment?id=" + apptId + "&action=cancel";
        }
    }
</script>
</body>
</html>