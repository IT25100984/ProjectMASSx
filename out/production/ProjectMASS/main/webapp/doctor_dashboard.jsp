<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ page import="com.projectmass.model.User" %>

<%
    // Security Check
    User user = (User) session.getAttribute("user");
    if (user == null || !"DOCTOR".equals(user.getRole())) {
        response.sendRedirect("login.jsp");
        return;
    }
    // ✅ Note: "myAppts" is now passed from the DoctorDashboardServlet via request.setAttribute()
%>
<html>
<head>
    <title>Doctor Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        .nav-pills .nav-link.active {
            background-color: #ffc107;
            color: #000;
            font-weight: 600;
        }
        .nav-pills .nav-link {
            color: #6c757d;
        }
    </style>
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-4">

    <%-- ✅ Success/Error Alerts --%>
    <c:if test="${param.availUpdated == 'true'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Success!</strong> Your work schedule has been successfully saved.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <c:if test="${param.msg == 'success'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm border-0 mb-4" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Action Successful!</strong> The appointment status was updated.
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    </c:if>

    <div class="p-5 mb-4 bg-primary text-white rounded-3 shadow">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="display-5 fw-bold">Doctor Portal</h1>
                <p class="fs-4 mb-0">Welcome, Dr. ${user.firstName} ${user.lastName}</p>
                <span class="badge bg-light text-primary fs-6 mt-2">
                    <i class="bi bi-patch-check"></i> Specialization: ${user.specialization}
                </span>
            </div>
            <div class="btn-group">
                <button data-bs-toggle="modal" data-bs-target="#availabilityModal" class="btn btn-warning text-dark">
                    <i class="bi bi-calendar-check-fill me-1"></i> Set Work Hours
                </button>
                <button data-bs-toggle="modal" data-bs-target="#profileModal" class="btn btn-outline-light">
                    <i class="bi bi-gear"></i> Set Profile Info
                </button>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0">Your Schedule</h5>
            <span class="badge bg-secondary">${not empty myAppts ? myAppts.size() : 0} Appointments</span>
        </div>
        <div class="card-body p-0">
            <table class="table table-hover align-middle mb-0">
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
                                    <span class="badge
                                        ${appt.status == 'PENDING' ? 'bg-warning text-dark' :
                                          appt.status == 'CANCELLED' ? 'bg-danger' :
                                          appt.status == 'RESCHEDULED' ? 'bg-info text-dark' : 'bg-success'}">
                                        ${appt.status}
                                    </span>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <c:if test="${appt.status != 'CONFIRMED' && appt.status != 'CANCELLED'}">
                                            <a href="updateAppointment?id=${appt.appointmentID}&action=accept" class="btn btn-sm btn-success">
                                                Accept
                                            </a>
                                        </c:if>

                                        <button type="button" class="btn btn-sm btn-warning text-dark" data-bs-toggle="modal" data-bs-target="#rescheduleModal${appt.appointmentID}">
                                            Suggest Time
                                        </button>

                                        <a href="javascript:void(0);" onclick="confirmCancel('${appt.appointmentID}', '${appt.oppositePartyName}')" class="btn btn-sm btn-outline-danger">
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

<%-- PROFILE MODAL --%>
<div class="modal fade" id="profileModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form action="updateProfile" method="POST" class="modal-content">
            <div class="modal-header bg-primary text-white">
                <h5 class="modal-title">Update Professional Details</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
            <c:if test="${user.role == 'DOCTOR'}">
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
            </c:if>
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

<%-- AVAILABILITY MODAL --%>
<div class="modal fade" id="availabilityModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <form action="updateAvailability" method="POST" class="modal-content">
            <div class="modal-header bg-warning text-dark">
                <h5 class="modal-title fw-bold"><i class="bi bi-calendar-check-fill me-2"></i>Schedule Work Hours</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">

                <ul class="nav nav-pills nav-fill mb-3" id="availTab" role="tablist">
                    <li class="nav-item">
                        <button class="nav-link active btn-sm" id="weekly-tab" data-bs-toggle="pill" data-bs-target="#weeklyPane" type="button">Weekly Schedule</button>
                    </li>
                    <li class="nav-item">
                        <button class="nav-link btn-sm" id="single-tab" data-bs-toggle="pill" data-bs-target="#singlePane" type="button">Single Specific Day</button>
                    </li>
                </ul>

                <hr>

                <input type="hidden" id="scheduleType" name="scheduleType" value="weekly">

                <div class="tab-content" id="availTabContent">

                    <%-- Tab 1: Weekly Schedule --%>
                    <div class="tab-pane fade show active" id="weeklyPane" role="tabpanel">
                        <label class="form-label fw-bold">Select Active Days</label>
                        <div class="d-flex flex-wrap gap-2 mb-3">
                            <input type="checkbox" class="btn-check" name="days" id="mon" value="1">
                            <label class="btn btn-outline-primary btn-sm" for="mon">Mon</label>

                            <input type="checkbox" class="btn-check" name="days" id="tue" value="2">
                            <label class="btn btn-outline-primary btn-sm" for="tue">Tue</label>

                            <input type="checkbox" class="btn-check" name="days" id="wed" value="3">
                            <label class="btn btn-outline-primary btn-sm" for="wed">Wed</label>

                            <input type="checkbox" class="btn-check" name="days" id="thu" value="4">
                            <label class="btn btn-outline-primary btn-sm" for="thu">Thu</label>

                            <input type="checkbox" class="btn-check" name="days" id="fri" value="5">
                            <label class="btn btn-outline-primary btn-sm" for="fri">Fri</label>

                            <input type="checkbox" class="btn-check" name="days" id="sat" value="6">
                            <label class="btn btn-outline-primary btn-sm" for="sat">Sat</label>

                            <input type="checkbox" class="btn-check" name="days" id="sun" value="7">
                            <label class="btn btn-outline-primary btn-sm" for="sun">Sun</label>
                        </div>
                    </div>

                    <%-- Tab 2: Specific Date --%>
                    <div class="tab-pane fade" id="singlePane" role="tabpanel">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Select Calendar Day</label>
                            <input type="date" id="availDatePicker" name="availDate" class="form-control">
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">Start Time</label>
                        <select name="startTime" class="form-select" required>
                            <c:forEach var="h" begin="8" end="20">
                                <option value="${String.format('%02d:00', h)}">${String.format('%02d:00', h)}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-6 mb-3">
                        <label class="form-label fw-bold">End Time</label>
                        <select name="endTime" class="form-select" required>
                            <c:forEach var="h" begin="9" end="21">
                                <option value="${String.format('%02d:00', h)}">${String.format('%02d:00', h)}</option>
                            </c:forEach>
                        </select>
                    </div>
                </div>

                <div class="alert alert-info py-2 m-0 shadow-sm border-0">
                    <small><i class="bi bi-info-circle-fill me-1"></i> Setting this will tell patients which hours you are available.</small>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="submit" class="btn btn-primary px-4">Save Availability</button>
            </div>
        </form>
    </div>
</div>

<%-- RESCHEDULE MODALS (Generated dynamically for each appointment) --%>
<c:if test="${not empty myAppts}">
    <c:forEach var="appt" items="${myAppts}">
        <div class="modal fade" id="rescheduleModal${appt.appointmentID}" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog">
                <form action="updateAppointment" method="POST" class="modal-content border-0 shadow">
                    <input type="hidden" name="id" value="${appt.appointmentID}">
                    <input type="hidden" name="action" value="reschedule">

                    <div class="modal-header border-0 pb-0">
                        <h5 class="modal-title fw-bold text-warning">
                            <i class="bi bi-calendar2-plus me-2"></i>Suggest Alternate Time
                        </h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body pt-3">
                        <div class="p-3 bg-light rounded-3 mb-3">
                            <p class="small text-muted mb-1">Appointment With</p>
                            <p class="fw-bold mb-0">${appt.oppositePartyName}</p>
                            <p class="small text-muted mt-2 mb-0">Original Slot: <span class="text-dark">${appt.dateTime}</span></p>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">New Date</label>
                            <input type="date" name="newDate" class="form-control reschedule-date" required>
                        </div>

                        <div class="mb-3">
                            <label class="form-label fw-semibold">New Time</label>
                            <select name="newTime" class="form-select" required>
                                <option value="09:00">09:00 AM</option>
                                <option value="10:00">10:00 AM</option>
                                <option value="11:00">11:00 AM</option>
                                <option value="12:00">12:00 PM</option>
                                <option value="13:00">01:00 PM</option>
                                <option value="14:00">02:00 PM</option>
                                <option value="15:00">03:00 PM</option>
                                <option value="16:00">04:00 PM</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-footer border-0">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" class="btn btn-warning text-dark px-4">Send Suggestion</button>
                    </div>
                </form>
            </div>
        </div>
    </c:forEach>
</c:if>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<script>
    document.addEventListener("visibilitychange", () => {
        // Automatically sync data when the doctor returns to this tab
        if (document.visibilityState === 'visible') {
            window.location.href = "doctorDashboard";
        }
    });

    document.addEventListener("DOMContentLoaded", function() {
        // 1. Force Profile Update if specialization is default/empty
        const spec = "${user.specialization}";
        if (spec === "" || spec === "General Practitioner" || spec === "null") {
            const profileModalEl = document.getElementById('profileModal');
            if (profileModalEl) {
                new bootstrap.Modal(profileModalEl).show();
            }
        }

        // 2. Set Minimum Dates (Today)
        const today = new Date().toISOString().split('T')[0];
        const dateInput = document.getElementById('availDatePicker');
        if(dateInput) {
            dateInput.setAttribute('min', today);
            dateInput.value = today;
        }

        document.querySelectorAll('.reschedule-date').forEach(el => {
            el.setAttribute('min', today);
        });

        // 3. Availability Toggle Logic
        const weeklyTabEl = document.getElementById('weekly-tab');
        const singleTabEl = document.getElementById('single-tab');
        const scheduleTypeHidden = document.getElementById('scheduleType');

        if (weeklyTabEl && singleTabEl) {
            weeklyTabEl.addEventListener('shown.bs.tab', () => {
                scheduleTypeHidden.value = 'weekly';
                if (dateInput) dateInput.value = '';
            });

            singleTabEl.addEventListener('shown.bs.tab', () => {
                scheduleTypeHidden.value = 'single';
                document.querySelectorAll('input[name="days"]').forEach(box => box.checked = false);
            });
        }
    });

    function confirmCancel(apptId, patientName) {
        if (confirm("Are you sure you want to cancel the appointment with " + patientName + "?")) {
            window.location.href = "updateAppointment?id=" + apptId + "&action=cancel";
        }
    }
</script>

</body>
</html>