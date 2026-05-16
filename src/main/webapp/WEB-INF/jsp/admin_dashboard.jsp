<%@ page contentType="text/html;charset=UTF-8"  %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:useBean id="user" scope="session" class="com.projectmass.model.User" />

<%-- Operational Security Guard: Enforce strict Admin system role boundary --%>
<c:if test="${empty sessionScope.user || sessionScope.user.role != 'ADMIN'}">
    <c:redirect url="/login" />
</c:if>

<html>
<head>
    <title>Admin Control Center | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        .dashboard-container { max-height: 500px; overflow-y: auto; }
        .table thead th { position: sticky; top: 0; z-index: 10; background-color: #f8f9fa; border-bottom: 2px solid #dee2e6; }
        /* Premium Amber/Gold Gradient Profile Header */
        .bg-admin-gold { background: linear-gradient(45deg, #fb8500, #ffb703); }
        .btn-gold-action { background-color: #ffb703; color: #023047; font-weight: 600; border: none; }
        .btn-gold-action:hover { background-color: #fb8500; color: #fff; }
    </style>
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-4">

    <%-- Routing Notification Alerts for System Activity --%>
<c:if test="${param.msg == 'delete_success'}">
    <div class="alert alert-success alert-dismissible fade show shadow-sm border-0" role="alert">
        <i class="bi bi-check-circle-fill me-2"></i>
        <strong>Success!</strong> The feedback record has been permanently deleted from the text database layer.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

<c:if test="${param.msg == 'delete_failed'}">
    <div class="alert alert-danger alert-dismissible fade show shadow-sm border-0" role="alert">
        <i class="bi bi-exclamation-triangle-fill me-2"></i>
        <strong>Deletion Failed!</strong> The database layer rejected the delete request. Ensure the feedback record is not tied to an active appointment integrity constraint.
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    </div>
</c:if>

    <%-- Profile Header styled in Gold / Amber --%>
    <div class="p-5 mb-4 bg-admin-gold text-white rounded-3 shadow">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="display-5 fw-bold text-white"><i class="bi bi-shield-lock-fill me-2"></i>Admin Dashboard</h1>
                <div class="text-white">
                    <p class="fs-4 mb-0">Welcome, System Administrator ${user.firstName} ${user.lastName}</p>
                    <p class="fs-6 opacity-90">
                        <i class="bi bi-person-badge-fill me-1"></i>
                        Role: Security & Infrastructure Architect | Node Live
                    </p>
                </div>
            </div>
            <div style="width: 230px;">
                <button type="button" class="btn btn-gold-action w-100 py-2 shadow-sm text-uppercase tracking-wider"
                        data-bs-toggle="modal" data-bs-target="#adminFeedbackModal">
                    <i class="bi bi-star-fill me-2 text-dark"></i> Manage Reviews
                </button>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="row mb-3 g-2">
        <div class="col-md-4">
            <div class="input-group shadow-sm">
                <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                <input type="text" id="appSearch" class="form-control" placeholder="Search Patient or Doctor...">
            </div>
        </div>
        <div class="col-md-8 text-end">
            <div class="form-check form-switch d-inline-block align-middle mt-2">
                <input class="form-check-input" type="checkbox" id="toggleSystemView" checked>
                <label class="form-check-label fw-bold" for="toggleSystemView">Show Completed Actions</label>
            </div>
        </div>
    </div>

    <%-- Main Operational Overview Table --%>
    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-activity me-2"></i>Global System Appointments Activity Log</h5>
            <span class="badge bg-warning text-dark fw-bold">Live Stream Registry</span>
        </div>
        <div class="card-body p-0 dashboard-container">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-secondary">
                    <tr>
                        <th>App ID</th>
                        <th>Patient Identity</th>
                        <th>Assigned Practitioner</th>
                        <th>Operational Status</th>
                        <th>Administrative Options</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty adminApps}">
                        <c:forEach var="app" items="${adminApps}">
                            <tr class="app-row">
                                <td class="fw-bold">#${app.appointmentID}</td>
                                <td>
                                    <span class="fw-semibold">${app.patientName}</span>
                                    <small class="text-muted d-block">ID: #${app.patientId}</small>
                                </td>
                                <td>
                                    <span class="fw-semibold">Dr. ${app.doctorName}</span>
                                    <small class="text-muted d-block">ID: #${app.doctorId}</small>
                                </td>
                                <td>
                                    <span class="badge bg-primary text-uppercase">${app.status}</span>
                                </td>
                                <td>
                                    <button class="btn btn-sm btn-outline-secondary" disabled>
                                        <i class="bi bi-lock-fill"></i> Managed
                                    </button>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="5" class="text-center py-5 text-muted">
                                <i class="bi bi-folder-x fs-3 d-block mb-2 text-secondary"></i>
                                No running system appointments parsed by the controller channel.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%@ include file="admin_feedback_modal.jsp" %>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('appSearch');
        const rows = document.querySelectorAll('.app-row');

        searchInput.addEventListener('input', function() {
            const query = searchInput.value.toLowerCase();
            rows.forEach(row => {
                const text = row.innerText.toLowerCase();
                row.style.display = text.includes(query) ? "" : "none";
            });
        });
    });
</script>
</body>
</html>