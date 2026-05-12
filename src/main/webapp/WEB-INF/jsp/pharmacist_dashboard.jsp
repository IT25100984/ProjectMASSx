<%@ page contentType="text/html;charset=UTF-8"  %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<jsp:useBean id="user" scope="session" class="com.projectmass.model.User" />

<%-- Logic: Pharmacist is a DOCTOR role with a PHARMACIST specialization --%>
<c:if test="${empty sessionScope.user ||
              sessionScope.user.role != 'DOCTOR' ||
              fn:toUpperCase(sessionScope.user.specialization) != 'PHARMACIST'}">
    <c:redirect url="/login" />
</c:if>

<html>
<head>
    <title>Pharmacist Dashboard | ProjectMASS</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        .order-container { max-height: 500px; overflow-y: auto; }
        .table thead th { position: sticky; top: 0; z-index: 10; background-color: #f8f9fa; border-bottom: 2px solid #dee2e6; }
        .bg-pharmacy { background: linear-gradient(45deg, #198754, #20c997); }
    </style>
</head>
<body class="bg-light">
<%@ include file="header.jsp" %>

<div class="container mt-4">
    <%-- Success/Error Alerts --%>
    <c:if test="${param.msg == 'success'}">
        <div class="alert alert-success alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi bi-check-circle-fill me-2"></i>
            <strong>Success!</strong> orders.txt has been updated successfully.
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    </c:if>

    <%-- Profile Header --%>
    <div class="p-5 mb-4 bg-pharmacy text-white rounded-3 shadow">
        <div class="d-flex justify-content-between align-items-center">
            <div>
                <h1 class="display-5 fw-bold text-white">Pharmacy Portal</h1>
                <div class="text-white">
                    <p class="fs-4 mb-0">Welcome, Dr. ${user.firstName} ${user.lastName}</p>
                    <p class="fs-6 opacity-75">
                        <i class="bi bi-patch-check-fill me-1"></i>
                        Licensed Pharmacist | License ID: ${user.licenseID != 0 ? user.licenseID : 'N/A'}
                    </p>
                </div>
            </div>
            <div style="width: 200px;">
                <button type="button" class="btn btn-warning w-100 fw-bold shadow-sm">
                    <i class="bi bi-box-seam"></i> Inventory Log
                </button>
            </div>
        </div>
    </div>

    <%-- Filter Bar --%>
    <div class="row mb-3 g-2">
        <div class="col-md-4">
            <div class="input-group shadow-sm">
                <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
                <input type="text" id="orderSearch" class="form-control" placeholder="Search Order ID or Patient Name...">
            </div>
        </div>
        <div class="col-md-8 text-end">
            <div class="form-check form-switch d-inline-block align-middle mt-2">
                <input class="form-check-input" type="checkbox" id="toggleCompleted" checked>
                <label class="form-check-label fw-bold" for="toggleCompleted">Show Completed/Cancelled</label>
            </div>
        </div>
    </div>

    <div class="card shadow-sm border-0">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-clipboard-pulse me-2"></i>Prescription Requests</h5>
            <span class="badge bg-secondary">System: orders.txt</span>
        </div>
        <div class="card-body p-0 order-container">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-secondary">
                    <tr>
                        <th>Order ID</th>
                        <th>Patient Name</th>
                        <th>Medicine Info</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                <c:choose>
                    <c:when test="${not empty allOrders}">
                        <c:forEach var="order" items="${allOrders}">
                            <tr class="order-row">
                                <td class="fw-bold">#${order.orderID}</td>
                                <td>${order.patientID}</td>
                                <td>${order.medicineName} <span class="text-muted">(x${order.quantity})</span></td>
                                <td>
                                    <c:choose>
                                        <c:when test="${order.status == 'COMPLETED'}"><span class="badge bg-success">READY</span></c:when>
                                        <c:when test="${order.status == 'CANCELLED'}"><span class="badge bg-danger">CANCELLED</span></c:when>
                                        <c:when test="${order.status == 'PENDING'}"><span class="badge bg-primary">PENDING</span></c:when>
                                        <c:otherwise><span class="badge bg-warning text-dark">${order.status}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="d-flex gap-2">
                                        <c:choose>
                                            <c:when test="${order.status == 'PENDING'}">
                                                <a href="updateOrder?id=${order.orderID}&action=complete" class="btn btn-sm btn-success">
                                                    Ready
                                                </a>
                                                <button class="btn btn-sm btn-outline-danger" onclick="confirmCancel('${order.orderID}')">
                                                    Cancel
                                                </button>
                                            </c:when>
                                            <c:otherwise>
                                                <button class="btn btn-sm btn-outline-secondary" disabled>Closed</button>
                                            </c:otherwise>
                                        </c:choose>

                                        <button type="button" class="btn btn-info btn-sm text-white"
                                                data-bs-toggle="modal" data-bs-target="#orderModal${order.orderID}">
                                            Details
                                        </button>
                                    </div>

                                    <%-- Prescription Detail Modal --%>
                                    <div class="modal fade" id="orderModal${order.orderID}" tabindex="-1" aria-hidden="true">
                                        <div class="modal-dialog modal-dialog-centered">
                                            <div class="modal-content border-0 shadow">
                                                <div class="modal-header bg-info text-white">
                                                    <h5 class="modal-title"><i class="bi bi-capsule me-2"></i>Prescription Summary</h5>
                                                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                                                </div>
                                                <div class="modal-body p-4">
                                                    <div class="row g-3">
                                                        <div class="col-12">
                                                            <label class="text-muted small fw-bold text-uppercase">Medicine Name</label>
                                                            <p class="fw-bold fs-5 text-primary mb-0">${order.medicineName}</p>
                                                        </div>
                                                        <div class="col-6">
                                                            <label class="text-muted small fw-bold text-uppercase">Quantity</label>
                                                            <p class="mb-0 text-dark">${order.quantity} units</p>
                                                        </div>
                                                        <div class="col-6 text-end">
                                                            <label class="text-muted small fw-bold text-uppercase">Total Cost</label>
                                                            <p class="fw-bold text-success mb-0"><fmt:formatNumber value="${order.medicinePrice}" type="currency" currencySymbol="LKR" /></p>
                                                        </div>
                                                        <div class="col-12">
                                                            <label class="text-muted small fw-bold text-uppercase">Status</label>
                                                            <p class="mb-0"><span class="badge ${order.status == 'COMPLETED' ? 'bg-success' : 'bg-primary'}">${order.status}</span></p>
                                                        </div>
                                                        <div class="col-12 mt-3">
                                                            <hr class="my-0 opacity-10">
                                                        </div>
                                                        <div class="col-12">
                                                            <div class="alert alert-warning border-0 small mb-0 d-flex align-items-center">
                                                                <i class="bi bi-exclamation-triangle-fill fs-4 me-2"></i>
                                                                <span>Verify Patient ID <strong>#${order.patientID}</strong> before releasing medication.</span>
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
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr><td colspan="5" class="text-center py-5 text-muted">No pending prescriptions in the system.</td></tr>
                    </c:otherwise>
                </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function confirmCancel(id) {
        if (confirm("Are you sure you want to cancel Order #" + id + "? This will update the database file.")) {
            window.location.href = "updateOrder?id=" + id + "&action=cancel";
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const searchInput = document.getElementById('orderSearch');
        const toggle = document.getElementById('toggleCompleted');
        const rows = document.querySelectorAll('.order-row');

        function filterTable() {
            const query = searchInput.value.toLowerCase();
            const showInactive = toggle.checked;

            rows.forEach(row => {
                const text = row.cells[1].innerText.toLowerCase()
                const status = row.cells[3].innerText.trim();

                let matchesSearch = text.includes(query);
                let isInactive = (status === 'COLLECTED' || status === 'CANCELLED');
                let matchesStatus = showInactive || !isInactive;

                row.style.display = (matchesSearch && matchesStatus) ? "" : "none";
            });
        }

        searchInput.addEventListener('input', filterTable);
        toggle.addEventListener('change', filterTable);
    });
</script>
</body>
</html>