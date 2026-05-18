<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<jsp:useBean id="patient" scope="session" class="com.projectmass.model.User" />

<c:if test="${empty sessionScope.user || sessionScope.user.role != 'PATIENT'}">
    <c:redirect url="/login" />
</c:if>

<c:set var="patient" value="${sessionScope.user}" />

<html>
<head>
    <title>Patient Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
        .animate-pulse { animation: pulse 2s cubic-bezier(0.4, 0, 0.6, 1) infinite; }
        .appointment-container { max-height: 450px; overflow-y: auto; }
        .table thead th { position: sticky; top: 0; z-index: 10; background-color: #212529; }
    </style>
</head>
<body class="bg-light">

<%@ include file="header.jsp" %>

<div class="container mt-4">
    <c:if test="${param.msg == 'success' || param.msg == 'rescheduled'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Action Successful!</strong> Schedule updated.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

<div class="p-5 mb-4 text-black rounded-3 shadow"
     style="background: linear-gradient(135deg, #ffffff -15%, #7dd3fc 20%, #38b6ff 60%, #0284c7 100%);">        <h1 class="display-5 fw-bold">Patient Dashboard</h1>
        <p class="col-md-8 fs-4 text-muted">Manage your medical appointments and records here.</p>
    </div>

    <div class="card shadow border-0 mb-4 text-black rounded-3 shadow"
     style="background: linear-gradient(135deg, #f8fafc 0%, #38b6ff 45%, #0d6efd 100%);">
        <div class="card-body">
            <div class="d-flex justify-content-between align-items-center">
                <div>
                    <h2 class="mb-1">Welcome, ${patient.firstName} ${patient.lastName}</h2>
                    <div class="text-muted">
                        <strong>Blood Group:</strong>
                        <span class="badge bg-danger">${patient.bloodGroup}</span>
                        <%-- New trigger for the View Modal --%>
                        <button type="button" class="btn btn-sm ms-2"
                                data-bs-toggle="modal" data-bs-target="#viewMedicalModal"
                                style="background-color: rgba(255, 255, 255, 0.6); color: #1e3a8a; border: 1px solid rgba(30, 58, 138, 0.2); border-radius: 20px; padding: 4px 14px; font-weight: 600; font-size: 0.85rem;">
                            <i class="bi bi-eye-fill me-1" style="color: #1e3a8a;"></i> View Medical History
                        </button>
                    </div>
                </div>
                <div class="d-flex flex-column gap-2" style="width: 200px;">
                    <button type="button" class="btn btn-warning d-flex align-items-center gap-2" data-bs-toggle="modal" data-bs-target="#profileModal">
                        <i class="bi bi-pencil-square"></i> Update Info
                    </button>
                    <a href="book_appointment" class="btn btn-primary d-flex align-items-center gap-2">
                        <i class="bi bi-calendar-plus"></i> Book New Appointment
                    </a>
                    <c:if test="${user.role == 'PATIENT'}">
                        <a href="orderPrescription" class="btn btn-success btn-lg shadow-sm mt-2">
                            <i class="bi bi-capsule me-2"></i>Order Prescription
                        </a>
                    </c:if>
                    <form action="/profile/delete" method="POST" onsubmit="return confirm('WARNING: Are you absolutely certain you want to permanently delete your profile? This cannot be undone.');" style="margin-top: 10px; width: 100%;">
                        <button type="submit" class="btn btn-danger" style="width: 100%; background-color: #dc3545; color: white; font-weight: bold; border: none; padding: 8px 12px; cursor: pointer; border-radius: 4px;">
                            Delete Profile
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <div class="row mb-3 g-2">
        <div class="col-md-4">
            <div class="input-group shadow-sm">
                <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                <input type="date" id="dateFilter" class="form-control">
            </div>
        </div>
        <div class="col-md-8 text-end">
            <div class="form-check form-switch d-inline-block align-middle mt-2">
                <input class="form-check-input" type="checkbox" id="toggleCancelled" checked>
                <label class="form-check-label fw-bold" for="toggleCancelled">Show Cancelled</label>
            </div>
        </div>
    </div>

    <div class="card shadow border-0">
        <div class="card-header bg-primary text-white">
            <h5 class="mb-0">Upcoming Appointments</h5>
        </div>
        <div class="card-body p-0 appointment-container">
            <table class="table table-hover mb-0 align-middle">
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
                            <tr class="appointment-row">
                                <td>${appt.dateTime}</td>
                                <td><i class="bi bi-person-badge me-1"></i> Dr. ${appt.oppositePartyName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${appt.status == 'CONFIRMED'}"><span class="badge bg-success">CONFIRMED</span></c:when>
                                        <c:when test="${appt.status == 'PENDING'}"><span class="badge bg-primary">PENDING</span></c:when>
                                        <c:when test="${appt.status == 'CANCELLED'}"><span class="badge bg-danger">CANCELLED</span></c:when>
                                        <c:when test="${appt.status == 'RESCHEDULED'}"><span class="badge bg-info text-dark animate-pulse">NEW SUGGESTION</span></c:when>
                                        <c:otherwise><span class="badge bg-warning text-dark">${appt.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                    <c:choose>
                                        <%-- Case 1: Appointment is Cancelled --%>
                                        <c:when test="${appt.status == 'CANCELLED'}">
                                            <button class="btn btn-sm btn-outline-secondary" disabled>Cancelled</button>
                                        </c:when>

                                        <%-- Case 2: Appointment is Confirmed --%>
                                        <c:when test="${appt.status == 'CONFIRMED'}">
                                            <button onclick="confirmCancel('${appt.appointmentID}')" class="btn btn-sm btn-outline-danger">Cancel</button>
                                        </c:when>



                                        <%-- Case 3: Appointment is Pending or Rescheduled --%>
                                        <c:when test="${appt.status == 'PENDING' || appt.status == 'RESCHEDULED'}">
                                            <%-- Show Accept ONLY if the other patient made the last change --%>
                                            <c:if test="${sessionScope.user.userID != appt.lastModifiedBy}">
                                                <a href="updateAppointment?id=${appt.appointmentID}&action=accept"
                                                   class="btn btn-sm btn-success">Accept</a>
                                            </c:if>

                                            <button type="button" class="btn btn-sm btn-warning"
                                                    data-bs-toggle="modal" data-bs-target="#rescheduleModal${appt.appointmentID}">
                                                Reschedule
                                            </button>

                                            <button onclick="confirmCancel('${appt.appointmentID}')" class="btn btn-sm btn-outline-danger">Cancel</button>
                                        </c:when>
                                    </c:choose>
                                        <button type="button" class="btn btn-info btn-sm text-white"
                                                data-bs-toggle="modal" data-bs-target="#aboutModal${appt.appointmentID}">
                                            About
                                        </button>
                                        <a href="feedback?appointmentId=${appt.appointmentID}&doctorId=${appt.doctorId}" class="btn btn-primary btn-sm">
                                            <i class="bi bi-star-fill me-1"></i>Review
                                        </a>
                                    </div>

                                    <%-- About Modal for Patient --%>
                                    <div class="modal fade" id="aboutModal${appt.appointmentID}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow">
                                                <div class="modal-header bg-info text-white">
                                                    <h5 class="modal-title"><i class="bi bi-info-circle me-2"></i>Appointment Summary</h5>
                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body p-4">
                                                    <div class="row g-3">
                                                        <div class="col-6">
                                                            <label class="text-muted small fw-bold text-uppercase">Consultation Type</label>
                                                            <p class="fw-bold text-primary mb-0">${appt.appointmentType}</p>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <label class="text-muted small fw-bold text-uppercase">Estimated Cost</label>
                                                            <p class="fw-bold text-success mb-0">
                                                                <c:choose>
                                                                    <c:when test="${appt.appointmentType == 'SURGERY'}">
                                                                        <%-- Match the logic in your Surgery.java --%>
                                                                        <c:set var="extra" value="${appt.additionalCharge == 'anesthesia' ? 2500 :
                                                                                                   appt.additionalCharge == 'facility' ? 1500 :
                                                                                                   appt.additionalCharge == 'equipment' ? 3000 : 500}" />
                                                                        LKR ${5000 + extra}.00
                                                                    </c:when>

                                                                    <c:when test="${appt.appointmentType == 'PHARMACY'}">
                                                                        LKR ${appt.totalFee}.00
                                                                    </c:when>

                                                                    <c:otherwise>LKR 2000.00</c:otherwise>
                                                                </c:choose>
                                                            </p>
                                                        </div>
                                                        <div class="col-12 mt-3">
                                                            <hr class="my-0 opacity-10">
                                                        </div>
                                                        <div class="col-12">
                                                            <label class="text-muted small fw-bold text-uppercase">Date & Time</label>
                                                            <p class="mb-0 text-dark">${appt.dateTime}</p>
                                                        </div>
                                                        <div class="col-12 mt-2">
                                                            <div class="alert alert-light border-0 small mb-0 p-2">
                                                                <i class="bi bi-hospital me-1"></i> Location: General Hospital Colombo
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="modal-footer bg-light border-0">
                                                    <button type="button" class="btn btn-secondary btn-sm px-4" data-bs-dismiss="modal">Close</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- FIX 3: Reschedule Modal with hourly selection --%>
                                    <div class="modal fade" id="rescheduleModal${appt.appointmentID}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Reschedule Appointment</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <form action="updateAppointment" method="post">
                                                    <div class="modal-body">
                                                        <input type="hidden" name="id" value="${appt.appointmentID}">
                                                        <input type="hidden" name="action" value="rescheduled">

                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">New Preferred Date</label>
                                                            <input type="date" name="newDate" class="form-control" required min="2026-04-22">
                                                        </div>

                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">New Preferred Time (Hourly)</label>
                                                            <%-- Extract hour safely --%>
                                                            <c:set var="startH" value="${not empty currentStart ? currentStart.substring(0,2) : 8}" />
                                                            <c:set var="endH" value="${not empty currentEnd ? currentEnd.substring(0,2) : 18}" />

                                                            <select name="newTime" class="form-select" required>
                                                                <option value="" disabled selected>Choose a time...</option>
                                                                <c:forEach var="hour" begin="${startH}" end="${endH}">
                                                                    <c:set var="displayTime" value="${hour < 10 ? '0' : ''}${hour}:00" />
                                                                    <option value="${displayTime}">${displayTime}</option>
                                                                </c:forEach>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="modal-footer">
                                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                                        <button type="submit" class="btn btn-primary">Request Change</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr><td colspan="4" class="text-center py-5 text-muted">No appointments found.</td></tr>
                    </c:otherwise>
                </c:choose>
                    <div class="modal fade" id="viewMedicalModal" tabindex="-1">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header bg-light">
                                <h5 class="modal-title">My Medical Record</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                            </div>
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label class="fw-bold text-muted small text-uppercase">Current Blood Group</label>
                                    <p class="fs-5"><span class="badge bg-danger">${patient.bloodGroup}</span></p>
                                </div>
                                <div>
                                    <label class="fw-bold text-muted small text-uppercase">Medical History & Notes</label>
                                    <div class="p-3 bg-light rounded border mt-2" style="min-height: 150px; white-space: pre-wrap;">
                                        <c:out value="${not empty patient.medicalHistory ? patient.medicalHistory : 'No history recorded.'}" />
                                    </div>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                <%-- Optional: Shortcut to the Edit modal you already built --%>
                                <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#profileModal">
                                    Edit Info
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                    <div class="modal fade" id="profileModal" tabindex="-1">
                        <div class="modal-dialog">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Update Medical Profile</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                </div>
                                <form action="updateProfile" method="post">
                                    <div class="modal-body">
                                        <%-- Blood Group Selection --%>
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Blood Group</label>
                                            <select name="bloodGroup" class="form-select">
                                                <%-- Iterating through blood types for a cleaner list --%>
                                                <c:forTokens items="A+,A-,B+,B-,AB+,AB-,O+,O-" delims="," var="group">
                                                    <option value="${group}" ${patient.bloodGroup == group ? 'selected' : ''}>
                                                        ${group}
                                                    </option>
                                                </c:forTokens>
                                            </select>
                                        </div>

                                        <%-- Focus on Medical Data --%>
                                        <div class="mb-3">
                                            <label class="form-label fw-bold">Medical History & Allergies</label>
                                            <textarea name="medicalHistory"
                                                      class="form-control"
                                                      rows="6"
                                                      placeholder="Enter chronic conditions, allergies, or current medications...">${patient.medicalHistory}</textarea>
                                            <div class="form-text text-muted">
                                                <i class="bi bi-info-circle me-1"></i>
                                                Providing accurate history helps doctors provide better care.
                                            </div>
                                        </div>
                                    </div>

                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        <button type="submit" class="btn btn-primary">
                                            <i class="bi bi-save me-1"></i> Save Medical Info
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const dateInput = document.getElementById('dateFilter');
        const toggle = document.getElementById('toggleCancelled');
        const rows = document.querySelectorAll('.appointment-row');

        const savedToggleState = localStorage.getItem('showCancelledPreference');
        if (savedToggleState !== null) {
            toggle.checked = (savedToggleState === 'true');
        }

        function filterTable() {
            const filterDate = dateInput.value;
            const showCancelled = toggle.checked;
            localStorage.setItem('showCancelledPreference', showCancelled);

            rows.forEach(row => {
                const dateText = row.cells[0].innerText;
                const statusBadge = row.cells[2].querySelector('.badge');
                const statusText = statusBadge ? statusBadge.innerText.toUpperCase() : "";
                let isVisible = true;
                if (filterDate && !dateText.includes(filterDate)) isVisible = false;
                if (!showCancelled && statusText.includes('CANCELLED')) isVisible = false;
                row.style.display = isVisible ? "" : "none";
            });
        }

        dateInput.addEventListener('input', filterTable);
        toggle.addEventListener('change', filterTable);
        filterTable();
    });

    function confirmCancel(id) {
        if (confirm("Are you sure you want to cancel this appointment?")) {
            window.location.href = "updateAppointment?id=" + id + "&action=cancel";
        }
    }
</script>
</body>
</html>