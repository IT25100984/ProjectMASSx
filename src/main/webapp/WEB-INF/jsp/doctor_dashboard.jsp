<%@ page contentType="text/html;charset=UTF-8"  %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:useBean id="user" scope="session" class="com.projectmass.model.User" />

<c:if test="${empty sessionScope.user || sessionScope.user.role != 'DOCTOR'}">
    <c:redirect url="/login" />
</c:if>

<c:set var="doctor" value="${sessionScope.user}" />

<html>
<head>
    <title>Doctor Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

    <style>
        .appointment-container {
            max-height: 450px;
            overflow-y: auto;
        }
        .table thead th {
            position: sticky;
            top: 0;
            z-index: 10;
            background-color: #f8f9fa;
            border-bottom: 2px solid #dee2e6;
        }
    </style>
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-4">
    <c:if test="${param.msg == 'success' || param.msg == 'acceptSuccess' || param.msg == 'rescheduled'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Action Successful!</strong> The schedule has been updated.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <div class="p-5 mb-4 bg-primary text-white rounded-3 shadow">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="display-5 fw-bold text-white">Doctor Portal</h1>
                <div class="text-white">
                    <p class="fs-4 mb-0">Welcome, Dr. ${user.firstName} ${user.lastName}</p>
                    <%-- Display Specialization below the name --%>
                    <p class="fs-6 opacity-75">
                        <i class="bi bi-patch-check-fill me-1"></i>
                        ${not empty doctor.specialization ? doctor.specialization : 'General'}
                        | License ID: ${doctor.licenseID != 0 ? doctor.licenseID : 'N/A'}
                    </p>
                </div>
            </div>

            <%-- Vertical Button Stack from previous step --%>
            <div class="d-flex flex-column gap-2" style="width: 200px;">
                <button type="button" class="btn btn-warning w-100" data-bs-toggle="modal" data-bs-target="#doctorProfileModal">
                    <i class="bi bi-pencil-square"></i> Update Profile
                </button>
                <button type="button" class="btn btn-warning w-100" data-bs-toggle="modal" data-bs-target="#setWorkHoursModal">
                    <i class="bi bi-calendar-check"></i> Set Work Hours
                </button>
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

    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white">
            <h5 class="mb-0">Your Schedule</h5>
        </div>
        <div class="card-body p-0 appointment-container">
            <table class="table table-hover align-middle mb-0" id="apptTable">
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
                            <tr class="appointment-row">
                                <td>${appt.dateTime}</td>
                                <td>${appt.oppositePartyName}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${appt.status == 'CONFIRMED'}"><span class="badge bg-success">CONFIRMED</span></c:when>
                                        <c:when test="${appt.status == 'PENDING'}"><span class="badge bg-primary">PENDING</span></c:when>
                                        <c:when test="${appt.status == 'CANCELLED'}"><span class="badge bg-danger">CANCELLED</span></c:when>
                                        <c:when test="${appt.status == 'RESCHEDULED'}"><span class="badge bg-info text-dark">RESCHEDULED</span></c:when>
                                        <c:otherwise><span class="badge bg-warning text-dark">${appt.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <c:choose>
                                            <c:when test="${appt.status == 'CANCELLED'}">
                                                <button type="button" class="btn btn-sm btn-outline-secondary" disabled>Cancelled</button>
                                            </c:when>
                                            <c:when test="${appt.status == 'CONFIRMED'}">
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmCancel('${appt.appointmentID}')">Cancel</button>
                                            </c:when>
                                            <c:otherwise>
                                                <%-- Logic Fix: Check if user is receiver of proposal --%>
                                                <c:if test="${sessionScope.user.userID != appt.lastModifiedBy}">
                                                    <a href="updateAppointment?id=${appt.appointmentID}&action=accept" class="btn btn-sm btn-success">Accept</a>
                                                </c:if>

                                                <c:if test="${!appt.rescheduled}">
                                                    <button type="button" class="btn btn-sm btn-warning text-dark"
                                                            data-bs-toggle="modal" data-bs-target="#rescheduleModal${appt.appointmentID}">
                                                        Reschedule
                                                    </button>
                                                </c:if>
                                                <button type="button" class="btn btn-sm btn-outline-danger" onclick="confirmCancel('${appt.appointmentID}')">Cancel</button>
                                            </c:otherwise>
                                        </c:choose>
                                        <button type="button" class="btn btn-info btn-sm text-white"
                                                data-bs-toggle="modal" data-bs-target="#aboutModal${appt.appointmentID}">
                                            About
                                        </button>
                                    </div>

                                    <%-- About Modal for each appointment --%>
                                    <div class="modal fade" id="aboutModal${appt.appointmentID}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow">
                                                <div class="modal-header bg-info text-white">
                                                    <h5 class="modal-title"><i class="bi bi-receipt-cutoff me-2"></i>Appointment Summary</h5>
                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body p-4">
                                                    <div class="row g-3">
                                                        <div class="col-6">
                                                            <label class="text-muted small fw-bold text-uppercase">Type</label>
                                                            <p class="fw-bold text-primary mb-0">${appt.appointmentType}</p>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <label class="text-muted small fw-bold text-uppercase">Total Cost</label>
                                                            <p class="fw-bold text-success mb-0">
                                                                <c:choose>
                                                                    <c:when test="${appt.appointmentType == 'SURGERY'}">
                                                                        <%-- Match the logic in your Surgery.java --%>
                                                                        <c:set var="extra" value="${appt.additionalCharge == 'anesthesia' ? 2500 :
                                                                                                   appt.additionalCharge == 'facility' ? 1500 :
                                                                                                   appt.additionalCharge == 'equipment' ? 3000 : 500}" />
                                                                        LKR ${5000 + extra}.00
                                                                    </c:when>
                                                                    <c:otherwise>LKR 2000.00</c:otherwise>
                                                                </c:choose>
                                                            </p>
                                                        </div>
                                                        <div class="col-12 mt-3">
                                                            <hr class="my-0 opacity-10">
                                                        </div>
                                                        <div class="col-6">
                                                            <label class="text-muted small fw-bold text-uppercase">Date</label>
                                                            <p class="mb-0 text-dark">
                                                                <c:out value="${fn:contains(appt.dateTime, ' at ') ? appt.dateTime.split(' at ')[0] : appt.dateTime}" />
                                                            </p>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <label class="text-muted small fw-bold text-uppercase">Scheduled Time</label>
                                                            <p class="mb-0 text-dark">
                                                                <c:out value="${fn:contains(appt.dateTime, ' at ') ? appt.dateTime.split(' at ')[1] : '--:--'}" />
                                                            </p>
                                                        </div>
                                                    </div>
                                                </div>
                                                <div class="modal-footer bg-light border-0">
                                                    <button type="button" class="btn btn-secondary btn-sm px-4" data-bs-dismiss="modal">Close</button>
                                                </div>
                                            </div>
                                        </div>
                                    </div>

                                    <%-- Reschedule Modal with Clean Hourly Select --%>
                                    <div class="modal fade" id="rescheduleModal${appt.appointmentID}" tabindex="-1">
                                        <div class="modal-dialog">
                                            <div class="modal-content">
                                                <div class="modal-header">
                                                    <h5 class="modal-title">Reschedule Appointment</h5>
                                                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                                </div>
                                                <form action="updateAppointment" method="post">
                                                    <div class="modal-body text-dark text-start">
                                                        <input type="hidden" name="id" value="${appt.appointmentID}">
                                                        <input type="hidden" name="action" value="rescheduled">
                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">Select New Date</label>
                                                            <input type="date" name="newDate" class="form-control" required min="2026-04-22">
                                                        </div>
                                                        <div class="mb-3">
                                                            <label class="form-label fw-bold">Select New Time</label>
                                                            <c:set var="startH" value="${not empty currentStart ? currentStart.substring(0,2) : 8}" />
                                                            <c:set var="endH" value="${not empty currentEnd ? currentEnd.substring(0,2) : 18}" />

                                                            <label class="form-label fw-bold">(Hourly)</label>
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
                                                        <button type="submit" class="btn btn-primary">Send Proposal</button>
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
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="doctorProfileModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Update Professional Info</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
        <form action="updateProfile" method="post">
                <div class="modal-body">
                    <%-- Predefined Specialization Dropdown --%>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Medical Specialization</label>
                        <select name="specialization" class="form-select" required>
                            <option value="" disabled ${empty doctor.specialization ? 'selected' : ''}>Choose specialization...</option>
                            <c:forTokens items="General Practitioner,Pharmacist,Cardiology,Dermatology,Pediatric,Neurology,Orthopedic"
                                         delims="," var="spec">
                                <option value="${spec}" ${doctor.specialization == spec ? 'selected' : ''}>${spec}</option>
                            </c:forTokens>
                        </select>
                    </div>

                    <%-- New License ID Field --%>
                    <div class="mb-3">
                        <label class="form-label fw-bold">Medical License ID</label>
                        <input type="text" name="licenseID" class="form-control"
                               value="${doctor.licenseID}"
                               placeholder="e.g. SLMC-12345" required>
                        <div class="form-text">Your verified medical registration number.</div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>
</div>

<%-- NEW: Set Weekly Availability Modal --%>
<div class="modal fade" id="setWorkHoursModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Set Weekly Work Hours</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form action="updateAvailability" method="post">
                <div class="modal-body text-start">
                    <p class="text-muted small">Select the days you are available and set a consistent time range.</p>

                    <div class="mb-3">
                        <label class="form-label fw-bold">Available Days</label>
                        <div class="d-flex flex-wrap gap-2">
                            <%-- Mon-Fri uses values 1-5 for easier database mapping --%>
                            <c:forEach var="day" items="${['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']}" varStatus="status">
                                <div class="form-check form-check-inline">
                                    <input class="form-check-input" type="checkbox" name="workDays" value="${status.index + 1}" id="day${status.index + 1}">
                                    <label class="form-check-label" for="day${status.index + 1}">${day}</label>
                                </div>
                            </c:forEach>
                        </div>
                    </div>

                    <div class="row">
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">Start Time</label>
                            <select name="startTime" class="form-select" required>
                                <c:forEach var="h" begin="0" end="23">
                                    <c:set var="fmtH" value="${h < 10 ? '0' : ''}${h}:00" />
                                    <option value="${fmtH}" ${currentStart == fmtH ? 'selected' : ''}>${fmtH}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-6 mb-3">
                            <label class="form-label fw-bold">End Time</label>
                            <select name="endTime" class="form-select" required>
                                <c:forEach var="h" begin="0" end="23">
                                    <c:set var="fmtH" value="${h < 10 ? '0' : ''}${h}:00" />
                                    <option value="${fmtH}" ${currentEnd == fmtH ? 'selected' : ''}>${fmtH}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-primary">Save Schedule</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const dateInput = document.getElementById('dateFilter');
        const toggle = document.getElementById('toggleCancelled');
        const rows = document.querySelectorAll('.appointment-row');

        const savedState = localStorage.getItem('doctor_showCancelled');
        if (savedState !== null) {
            toggle.checked = (savedState === 'true');
        }

        function filterTable() {
            const filterDate = dateInput.value;
            const showCancelled = toggle.checked;
            localStorage.setItem('doctor_showCancelled', showCancelled);

            rows.forEach(row => {
                const dateText = row.cells[0].innerText;
                const statusText = row.cells[2].innerText.toUpperCase();
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